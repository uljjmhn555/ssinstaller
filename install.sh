#!/bin/bash

# file name

# bin path
binPath="/usr/local/bin/"

# config path
configPath="/etc/shadowsocks/"

pidFilePath="/var/run/"

# systemctl service path
servicePath="/etc/systemd/system/"


# ss version
binVersion="1.2.0"

## service content

## $1 type sslocal or ssserver
funCreateServiceFile()
{
    varServiceFile=$servicePath$1".service"

    echo "[Unit]" > $varServiceFile
    echo "Description="$1 >> $varServiceFile
    echo "After=network.target" >> $varServiceFile
    echo "After=syslog.target" >> $varServiceFile

    echo "[Service]" >> $varServiceFile
    echo "Type=forking" >> $varServiceFile
    echo "PIDFile="$pidFilePath$1".pid" >> $varServiceFile
    echo "ExecStart="$binPath$1" -c "$configPath$1".json > /dev/null & " >> $varServiceFile
    echo 'ExecStop=/bin/kill $MAINPID' >> $varServiceFile
    echo 'ExecReload=/bin/kill -USR1 $MAINPID' >> $varServiceFile
    echo "Restart=always" >> $varServiceFile


    echo "[Install]" >> $varServiceFile
    echo "WantedBy=multi-user.target graphical.target" >> $varServiceFile
}

## config
funCopyConfig()
{
    mkdir $configPath
    sourcePath="config/"
    varConfigFile=$sourcePath$1".json"
    cp $sourcePath"sslocal.json"  $configPath
    cp $sourcePath"ssserver.json"  $configPath
}

## architecture arm64 amd64 ......
# funCopyBinFile()
# {
#     ## source file
#     sourceFileLocal="bin/shadowsocks-local-linux-$1-$binVersion"
#     sourceFileServer="bin/shadowsocks-server-linux-$1-$binVersion"

#     ## dist file
#     distFileLocal=$binPath"sslocal"
#     distFileServer=$binPath"ssserver"

#     ## copy file
#     cp $sourceFileLocal $distFileLocal
#     cp $sourceFileServer $distFileServer

#     ## chmod +x
#     chmod +x $distFileLocal
#     chmod +x $distFileServer
# }

## $1 type: server local
## $2 archi: amd64 arm64
## $3 version: 
funGetBinaryFile()
{
    local type="$1"
    local archi="$1"
    local version="$2"
    local fileName = "shadowsocks-$type-linux-$archi-$version"
    local url="https://github.com/uljjmhn555/ssinstaller/releases/$version/$fileName.gz"
    local distFile="ss$type"
    mkdir "bin"
    wget -P "bin/" $url
    gzip -d "bin/$fileName.gz"
    cp "bin/$fileName" $binPath$distFile
    chmod +x $binPath$distFile
}

## architectureArray=("arm64" "arm32" "amd64" "i386")
architectureArray="amd64 i386 arm64 arm32"
versionArray="1.2.0"
typeArray="all server local"

## $1 "array" string eg: "a s d f"
## $2 select type string
## $3 result
getVar(){
    local varList=($1)
    local  __resultVar=$3

    while true 
    do
        echo "select $2 for shadowsocks following by a number.default is [0]"
        for i in ${!varList[*]}
        do
            echo "["$i"]. "${varList[$i]}
        done

        # int
        read varGet
        varGet=${varGet:-0}

        if ! [[ "$varGet" =~ ^[0-9]+$ ]]; then
            echo $varGet" Not a number!"
            continue
        fi
        
        local arrLen=${#varList[@]}

        if [ "$varGet" -lt "$arrLen" ] && [ "$varGet" -ge "0" ] 
        then
            break
        fi

        echo "select error"
    done

    ## return result
    eval $__resultVar="${varList[$varGet]}"  
}

# type
getVar "$typeArray" "type" typeResult
echo "type selected is : "$typeResult

# architecture
getVar "$architectureArray" "architecture" archiResult
echo "architecture selected is : "$archiResult


getVar "$versionArray" "version" versionResult
echo "version selected is : "$versionResult


exit;
echo "copy binary ......"
##funCopyBinFile $architecture

echo "copy default config ......"
funCopyConfig

echo "write service ......"
funCreateServiceFile "sslocal"
funCreateServiceFile "ssserver"


systemctl daemon-reload

echo "...................................."
echo "...................................."
echo "...........install finish..........."
echo "...................................."
echo "...................................."

echo "alter config file from /etc/shadowsocks/"

echo "input \"systemctl start sslocal\" to start the shadowsocks-local service" 
echo "input \"systemctl start ssserver\" to start the shadowsocks-server service" 
echo "input \"systemctl enable sslocal\" for autorun on boot" 
echo "input \"systemctl enable ssserver\" for autorun on boot" 

echo "...................................."
echo "...................................."
echo ".............thank you.............."
echo "...................................."
echo "...................................."