#!/bin/bash
# 遍历指定目录下，自动安装证书
# author: paysonchen
# [目的]
# 自动化安装开发者证书

# [说明]
# 1、遍历指定目录下证书
# 2、安装目录下的p12、cer、mobileprovision
#
# [参数]
# 1、参数1，项目标识
# 2、参数2，p12证书密码
#
# [调用说明]
#  sh install_cer.sh PsciOSOperations $P12_PWD


function installFromFold()
{
    local func=$1
    
    echo "installFromFold para:1="$1"   2="$2

    # 使用 find 命令查找所有文件，并通过 for 循环遍历
    find "$2" -type f | while read -r file; do
        # 在这里对每个文件执行操作，例如打印文件名
        if [[ $(basename "$file") != .* ]]; then
            echo "$file"
            # 如果你想对每个文件执行更复杂的操作，可以在这里添加
            # 例如，使用另一个命令处理文件，或者对文件名进行某些操作
            echo "installFromFold:$file"
            $func $file
        else
            echo "未执行文件:$file"
        fi
    done

}

function installP12()
{
    # 设置证书文件路径: "p12/p12Release.p12"

    CERTIFICATE_PATH=$1
    # 设置导入证书时使用的密码
    CERTIFICATE_PASSWORD=$p12PWD

    # 指定钥匙串的路径（此例为登录钥匙串）
    KEYCHAIN_PATH=~/Library/Keychains/login.keychain-db

    # 安装证书到钥匙串
    security import "$CERTIFICATE_PATH" -k "$KEYCHAIN_PATH" -P "$CERTIFICATE_PASSWORD" -T /usr/bin/codesign

    # 验证证书是否成功安装
    security find-identity -p codesigning

    echo "P12 installation is completed."
}


function installCer()
{

    CERTIFICATE_PATH=$1

    # 指定钥匙串的路径（此例为登录钥匙串）
    KEYCHAIN_PATH=~/Library/Keychains/login.keychain-db

    # 导入.cer证书到钥匙串
    security import "$CERTIFICATE_PATH" -k "$KEYCHAIN_PATH" -T /usr/bin/codesign

    echo "Certificate ($CERTIFICATE_PATH) installation is completed."
}

function installProfile()
{
    # 设置.mobileprovision文件路径
    MOBILEPROVISION_PATH=$1


    #获取描述文件中UUID
    UUID=`grep UUID -A1 -a $MOBILEPROVISION_PATH | grep -io '[-A-F0-9]\{36\}'`
    echo "uuid="$UUID
    echo "MOBILEPROVISION_PATH="$MOBILEPROVISION_PATH
        

    # 复制到Xcode识别的目录
    cp "$MOBILEPROVISION_PATH" ~/Library/MobileDevice/Provisioning\ Profiles/$UUID.mobileprovision

    echo "Mobile Provisioning Profile installation is completed."$MOBILEPROVISION_PATH"==>"$UUID
}

#配置项目名称
ProjName=$1

#p12 证书密码
p12PWD=$2


installFromFold installP12 ./p12

installFromFold installCer ./Cer

installFromFold installProfile ./$ProjName

# 提前解锁钥匙串
security unlock-keychain -p $BUILD_MECHINE_PWD ~/Library/Keychains/login.keychain-db
