#!/bin/bash

# [背景]
# 组件化过程中，经常创建私有Pod库
#
# author: paysonchen
# [目的]
# 使用官方提供的创建Pod库会有一系列选项 ，为了频繁创建效率提升，考虑将一些选项默认化，抽出shell脚本
#
# [目录]
#   - pod_lib_ceate_with_psc_temp.sh
# [说明]
# 1、指定创建模板：template_url
# 2、执行 pod lib create
#
# [参数]
# 1、参数1，私有Pod库名称
#
# [调用说明]
# 1、输入私有Pod库名称 sh pod_lib_ceate_with_psc_temp.sh XXX

template_url="ssh://paysonchen@psc-devops.psc.com:30022/psc/psc-ios/Pods/Tmplate/PSC_iOS_Objc_Demo_NoneTest.git"
echo "pod lib create from  --template-url=$template_url"
echo "parm=$1"

pod lib create $1 --template-url=$template_url
