#!/bin/bash

# bin path
binPath="/usr/local/bin/"
#binPath="./tmp/"

# config path
configPath="/etc/shadowsocks/"
#configPath="./tmp/"

pidFilePath="/var/run/"
#pidFilePath="./tmp/"

# systemctl service path
servicePath="/etc/systemd/system/"
#servicePath="./tmp/"


## service content
## $1 type local or server
funCreateServiceFile()
{
    local ssType="ss"$1
    local varServiceFile=$servicePath$ssType".service"

    echo "[Unit]" > $varServiceFile
    echo "Description="$ssType >> $varServiceFile
    echo "After=network.target" >> $varServiceFile
    echo "After=syslog.target" >> $varServiceFile

    echo "[Service]" >> $varServiceFile
    echo "Type=forking" >> $varServiceFile
    echo "PIDFile="$pidFilePath$ssType".pid" >> $varServiceFile
    echo "ExecStart="$binPath$ssType" -c "$configPath$ssType".json > /dev/null & " >> $varServiceFile
    echo 'ExecStop=/bin/kill $MAINPID' >> $varServiceFile
    echo 'ExecReload=/bin/kill -USR1 $MAINPID' >> $varServiceFile
    echo "Restart=always" >> $varServiceFile


    echo "[Install]" >> $varServiceFile
    echo "WantedBy=multi-user.target graphical.target" >> $varServiceFile
}

## config
## type server local
funCopyConfig()
{
    local varType="ss"$1
    local sourcePath="config/"
    local varConfigFile=$sourcePath$varType".json"

    mkdir $configPath

    cp $sourcePath"$varType.json"  $configPath
}


## $1 type: server local
## $2 archi: amd64 arm64
## $3 version: 
funGetBinaryFile()
{
    local type="$1"
    local archi="$2"
    local version="$3"
    local fileName="shadowsocks-$type-linux-$archi-$version"
    local url="https://github.com/uljjmhn555/ssinstaller/releases/download/$version/$fileName.gz"
    local distFile="ss$type"
    mkdir "bin"
    wget -P "bin/" $url
    gzip -d "bin/$fileName.gz"
    cp "bin/$fileName" $binPath$distFile
    chmod +x $binPath$distFile
}

## architecture  version  type
architectureArray="amd64 i386 arm64 arm32"
versionArray="1.2.0"
typeArray="server local"


## $1 "array" string eg: "a s d f"
## $2 select type string
## $3 result
getVar(){
    local varList=($1)
    local  __resultVar=$3

    while true 
    do
        echo "select $2 for shadowsocks following by a number.default is [1]"
        echo ""
        for i in ${!varList[*]}
        do
            local index=`expr $i + 1`
            echo "["$index"]. "${varList[$i]}
        done

        # int
        read varGet
        varGet=${varGet:-1}

        if ! [[ "$varGet" =~ ^[0-9]+$ ]]; then
            echo $varGet" Not a number!"
            continue
        fi
        local varGetNew=`expr $varGet - 1`
        
        local arrLen=${#varList[@]}

        if [ "$varGetNew" -lt "$arrLen" ] && [ "$varGetNew" -ge "0" ] 
        then
            break
        fi

        echo "select error"
    done

    ## return result
    eval $__resultVar="${varList[$varGetNew]}"  
}

# type
getVar "$typeArray" "type" typeResult
echo "type selected is : "$typeResult

# architecture
getVar "$architectureArray" "architecture" archiResult
echo "architecture selected is : "$archiResult

# version
getVar "$versionArray" "version" versionResult
echo "version selected is : "$versionResult


## install start

echo "get binary from git release......"
funGetBinaryFile $typeResult $archiResult $versionResult

echo "copy default config ......"
funCopyConfig $typeResult

echo "write service ......"
funCreateServiceFile $typeResult

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