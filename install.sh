#!/bin/bash

# file name
localName="sslocal"
serverName="ssserver"


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
    echo "ExecStart="$binPath$1" -c "$configPath$1".config > /dev/null & " >> $varServiceFile
    echo 'ExecStop=/bin/kill $MAINPID' >> $varServiceFile
    echo 'ExecReload=/bin/kill -USR1 $MAINPID' >> $varServiceFile
    echo "Restart=always" >> $varServiceFile


    echo "[Install]" >> $varServiceFile
    echo "WantedBy=multi-user.target graphical.target" >> $varServiceFile
}

## config
funCopyConfig()
{
    sourcePath="config/"
    varConfigFile=$sourcePath$1".json"
    cp $sourcePath"sslocal.json"  $configPath"sslocal.json"
    cp $sourcePath"ssserver.json"  $configPath"ssserver.json"
}

## architecture arm64 amd64 ......
funCopyBinFile()
{
    ## source file
    sourceFileLocal="bin/shadowsocks-local-$1-$binVersion"
    sourceFileServer="bin/shadowsocks-server-$1-$binVersion"

    ## dist file
    distFileLocal=$binPath"sslocal"
    sourceFileServer=$binPath"ssserver"

    ## chmod +x
    chmod +x $distFileLocal
    chmod +x $sourceFileServer


    ## copy file
    cp $sourceFileLocal $distFileLocal
    cp $sourceFileServer $sourceFileServer
}

architectureArray=("arm64" "amd64")


## get words form input
while true 
do
    echo "select architecture for shadowsocks following"
    for i in ${!architectureArray[@]}
    do
        index=`expr $i + 1`
        echo $index". "${architectureArray[$i]}
    done

    read architecture

    varFlat=false
    for item in ${architectureArray[@]}
    do
        echo $item"   "$architecture
        if [ "$item" == "$architecture" ]  
        then 
            varFlat=true
            break 
        fi

    done

    if $varFlat 
    then
        break
    else
        echo "select error"
    fi
done


echo $architecture
