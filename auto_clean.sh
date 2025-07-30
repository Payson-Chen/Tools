#!/bin/bash

# [背景]
# 组件化过程中，经常出现以下编译错误：
# Build service could not create build operation: unknown error while handling message: MsgHandlingError(message: "unable to initiate PIF transfer session (operation in progress?)")
#
# author: paysonchen
# [目的]
# 为解决上述错误，需要清理构建索引目录并重启xcode，由于操作重复，考虑抽出shell脚本
#
# [目录]
#   - auto_clean.sh
# [说明]
# 1、CD[指定xcode构建索引目录]目录
# 2、递归删除当前文件下所有文件
# 3、重启xcode
#
# [参数]
# 1、参数1，指定xcode构建索引目录
# 1、参数2，指定要打开的Xcode项目目
#
# [调用说明]
# 1、未指定目录，则取当前目录：sh auto_clean.sh
# 2、指定目录：sh auto_clean.sh /xcode构建索引目录/ /要打开的Xcode项目目录/

#获取当前用户名
user_name=$(whoami)

#重启xcode
killall Xcode

export XcodeDerivedDataPath=/Users/$user_name/Library/Developer/Xcode/DerivedData
export XcodeWorkspacePath=/Applications/Xcode.app

if [ -z "$1" ]; then
    echo '///入参1为空，使用默认xcode构建索引目录:'${XcodeDerivedDataPath}
else
    XcodeDerivedDataPath=$1
    echo '///入参1不为空，xcode构建索引目录:'${XcodeDerivedDataPath}
fi

if [ -z "$2" ]; then
    echo '///入参2为空，使用默认xcode项目目录:'${XcodeWorkspacePath}
else
    XcodeWorkspacePath=$2
    echo '///入参2不为空，xcode项目目录:'${XcodeWorkspacePath}
fi

#cd到xcode构建索引目录
cd  $XcodeDerivedDataPath

exit_status=$?

if [ $exit_status -ne 0 ]; then
    echo '///切换目录失败:'${XcodeDerivedDataPath}
    exit -1
else
    echo '///切换目录成功:'${XcodeDerivedDataPath}
fi

#删除当前目录所有构件索引
rm -rf *


#休眠一下，不然可能导致重启失败
sleep 0.1

#重启项目工程
open $XcodeWorkspacePath
