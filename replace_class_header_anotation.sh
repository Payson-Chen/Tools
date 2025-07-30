#!/bin/bash

# 遍历更新当前目录下(含子目录）所有iOS工程类文件：.h .m .swift 并对其注释头进行模板替换
# author: paysonchen
# [目的]
#
# 组件化规整之后，可能存在的情况是前后的文件命名不一致导致的影响代码易读性、易维护等问题
# 除此之外，由于代码经由不同人迭代的，甚至不同组织迭代（从外包接手的项目）还存在一些文件注释的注释模板差异的情况
# 此脚本目的为了解决存量类文件头注释统一性问题
#
# [目录]
#   - replace_class_header_anotation.sh 遍历更新当前目录下，子目录git仓库的脚本
#
# [说明]
# 1、遍历指定目录（若未传参数则为当前目录）下的子目录
# 2、匹配所有iOS工程类文件：.h .m .swift
# 3、对其注释头进行模板替换
#
# [参数]
# 1、参数1，指定目录
#
# [调用说明]
# 1、未指定目录，则取当前目录：sh replace_class_header_anotation.sh
# 2、指定目录：sh replace_class_header_anotation.sh /User/xxx/xx
# 本脚本适用于将：下述注释替换成 统一注释模板：
#   其一：
#//
#//  FileName.h
#//  ProjectName
#//
#//  Created by Author on Date.
#// (没版权信息)
#//
#
#   其二：
#   /****************************************************************************************************
#   * 版权所有： Copyright (c) 2012-2021 xxxx. All rights reserved.
#   * 作 者： Author （2021/3/12）
#   * 界面描述：  界面描述
#   ****************************************************************************************************/
#
#   其三：
#   没有任何注释的
#
#
#   替换成统一注释模板：
#
#//
#//  "$filename"
#//  "$project_name"
#//
#//  Created by "$auth" on "$date".
#//  "$copyright_str"
#//
#
#定义版权信息
export copyright_str="Copyright (C) $(date +%Y)  PSC. All rights reserved."

#定义默认用户信息：PaysonChen
export def_author_str="PaysonChen"

#定义默认日期：当前日期
export def_time_str=`date +%Y/%m/%d`

function get_creator_name_with_template_2() {
    file=$1
    creator_name=$(sed -n 's/.*作    者： \(.*\).*/\1/p' $file)
    echo "creator_name="$creator_name" in file="$file
    
    if [ -z "$creator_name" ]; then
        echo '///获取创建者 第二种模板获取 为空 使用默认值'
        creator_name=$def_author_str
    fi
}

function get_creator_name() {
    file=$1
    creator_name=$(sed -n 's/.*Created by \(.*\) on.*/\1/p' $file)
    
    if [ -z "$creator_name" ]; then
        get_creator_name_with_template_2 $file
    fi
    
    echo "--------creator_name=【"$creator_name"】 in file="$file
}



function get_creator_time_with_template_2() {
    file=$1
    creator_time=$(sed -n 's/.*创建日期： \(.*\).*/\1/p' $file)
    echo "-------创建日期=【"$creator_time"】 in file="$file

    if [ -z "$creator_time" ]; then
#        echo '///获取创建时间 第二种模板获取 为空 使用默认值'
        creator_time=$def_time_str
    fi
}


function format_creator_time() {
    creator_time=$1
    
    length=${#creator_time}

    # 截取除最后一个字符外的部分
    creator_time=${creator_time:0:length-1}
    #echo "截去掉最后一个字符后的字符串: $creator_time"
}


function get_creator_time() {
    file=$1
    
    if [ -z "$2" ]; then
        line=5
    else
        line=$2
    fi
    #creator_time=$(sed -n '5s/.*\(.\{10\}\)$/\1/p' $file)
    creator_time=$(awk 'NR=='$line' {print $NF}' $file)

    echo "-------creator_time=【"$creator_time"】 line = "$line" in file="$file
#    date_regex='^(19|20)[0-9]{2}/(0?[1-9]|1[0-2])/(0?[1-9]|[1-2][0-9]|3[0-1]).$'
    #date_regex='^(19[0-9]{2}|20[0-9]{2}|[0-9]{2})/(0?[1-9]|1[0-2])/(0?[1-9]|[1-2][0-9]|3[0-1]).$'
    date_regex='^(19[0-9]{2}|20[0-9]{2}|[0-9]{2})([-/])(0?[1-9]|1[0-2])([-/])(0?[1-9]|[1-2][0-9]|3[0-1]).$'

    # 进行正则匹配
    if [[ $creator_time =~ $date_regex ]]; then
        echo "日期格式正确，截断最后一个小数 ."
        format_creator_time $creator_time
    else
        if [ -z "$2" ]; then
            discount=1
            new_line=$((line-discount))
            echo "常规调用如果匹配不到的话，那么多一次，向上查找"$discount"行，进行递归:"$new_line
            get_creator_time $file $new_line
        else
            echo "日期格式错误，执行第二种匹配"
            get_creator_time_with_template_2 $file
        fi
    fi
    echo "********creator_time=【"$creator_time"】 in file="$file
}



function replace_header_anoation() {
    file=$1

    #定义要替换的字符串
    #文件名
    filename=$(echo "$file" | sed 's#.*/##')
    #项目名
    project_name=$2
    #"PscexampleiOS"
    
    #还有从当前类中获取作者信息，获取不到取默认值
    auth=$creator_name
    
    #还有从当前类中获取作者信息，获取不到取默认值
    date=$creator_time

    #以下是替换的模板
    new_content="//
//  "$filename"
//  "$project_name"
//
//  Created by "$auth" on "$date".
//  "$copyright_str"
//"

    new_content_escaped=$(echo "$new_content" | sed 's/$/\\/') # 转义换行符
    sed -i '' -e "1,7c\\
$new_content_escaped" "$file"

    #还有几个问题待优化
    #1、如果开头没有注释，则会直接覆盖，或者注释不足7行的
    #2、日期正则如果不是以 YYYY/MM/DD or YY/MM/DD 其中/和-都适用
        #2.1但是兼容2023/8/1这样的个位数日期)，
        #2.2如果日期是8/1/23 这样会导致识别错误 会被替换成今天的日期

}

# 统一类头注释
function unify_header_anoation() {
    file=$1

    #还有从当前类中获取作者信息，获取不到取默认值
    get_creator_name $file
    
    #还有从当前类中获取作者信息，获取不到取默认值
    get_creator_time $file
    
    #不传第二个参数 则不执行
    if [ -z "$2" ]; then
        echo '///不传第二个参数 则不执行'
    else
        replace_header_anoation $file $2
    fi
}


function main() {
    file_path=$1

    if [ -z "$file_path" ]; then
        echo '///未指定路径,file_path为. 当前路径'
        file_path=.
    fi


    #遍历当前路径下所有oc类
    find $file_path -type f -name "*.swift" -o -name "*.h" -o -name "*.m" | while read file; do
        unify_header_anoation $file $2
    done
}

#路径  项目名
main $1 $2



