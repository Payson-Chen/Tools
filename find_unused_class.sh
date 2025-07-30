#!/bin/bash

# [背景]
# 基础组件拆分到一定程度时，主工程剩下的就多数与视图界面(vc、view等)相关的类文件。此时可以考虑对业务组件进行设计和规划，但是在此时，工程还存在如下问题：
#    冗余文件：
#​    非冗余但未被使用的文件
#
# author: paysonchen
#
# [目的]
# 此脚本解决 "非冗余但未被使用的文件" 的清理
#
# [目录]
#   - find_unused_class.sh
# [说明]
# 1 遍历工程目录的所有实现类：.m文件（不包含category）
# 2 将类名与工程内除自身以外所有文件进行进逐行匹配（包含category）
# 3 当匹配到不包含// 与 #import 开头的行，则算为有引用，否则为未引用
# 4 将未匹配到的文件路径进行输出
# 5 将上述匹配出来的文件先进行移除，再执行一遍（由于第一层被移除，可能会暴露出更多没被引用的类）
# 6 直到没有匹配到未被调用的类为止
#
# [参数]
# 1、参数1，指定xcode工程目录 （未指定则为当前目录）
#
# [调用说明]
# 1、未指定目录，则取当前目录：sh find_unused_class.sh
# 2、指定目录 ：sh find_unused_class.sh /Users/xxxxx/ProjectName-IOS/ProjectName/ProjectName


#!/bin/bash

#是否重复执行到没有找到不可用文件
export cycle_deal=1
export cycle_idx=1
total_unused_file_name=''
function main() {
    
    # 设置项目目录
    project_directory=$1

    if [ -z "$1" ]; then
        #未传参为当前目录
        project_directory=.
    fi

    #初始化参数：
    unused_files=''

    # 查找所有以ViewController.m结尾的文件并输出列表
    all_class_path=$(find "$project_directory" -type f \( -name "*.m" \) | grep -v '+')

    all_file_path=$(find "$project_directory" -type f \( -name "*.m" -o -name "*.h" \) )

    file_cnt=0
    for file in $all_class_path; do
        file_cnt=$((file_cnt+1))
    done
    echo "*******file_cnt："$file_cnt


    for file in $all_class_path; do
        filename=$(basename "$file" .m)
        echo "***********开始遍历文件名："$filename
        is_referenced=false
        for other_file in $all_file_path; do
            other_file_name=$(basename "$other_file")
            #获取除自身以外的类名：不包含拓展的名称，为了避免在自身的.h .m进行引用判断
            other_file_name_without_extension=$(echo "$other_file_name" | cut -d. -f1)
            #获取category的主类名称
            other_file_name_without_extension_before_plus=$(echo "$other_file_name_without_extension" | awk -F'+' '{print $1}')
            if [ "$other_file_name_without_extension_before_plus" != "$filename" ] ; then
            # if [ "$other_file" != "$file" ] && ([ "${other_file##*.}" = "m" ] ); then
                if grep -q "\b$filename\b" "$other_file";  then
                    # 检查文件中是否有注释行
                    has_comment=false
                    while IFS= read -r line; do
                        echo "逐行匹配："$line
                        if ! grep -qE "^[[:space:]]*//" <<< "$line"; then
                            if [[ ! $line =~ ^[[:space:]]*#import ]]; then
                                has_comment=true
                                echo "在文件:"$other_file"匹配"$filename"存在 并且不是 注释代码 或者 import 的 break（"$line
                                break
                            fi

                        fi
                    done <<< "$(grep "\b$filename\b" "$other_file")"
                    
                    if [ "$has_comment" = true ]; then
                        is_referenced=true
                        break
                    fi
                fi
            fi
        done

        if [ "$is_referenced" = false ]; then
            echo "没有被引用到的文件:"$file
            unused_files="$unused_files$file\n"
        fi
        echo "***********"
    done

    # 输出未被引用的文件列表
    if [ -n "$unused_files" ]; then
        echo -e "Unused class files:\n$unused_files"
        total_unused_file_name="$total_unused_file_name$unused_files\n"

        #将检索出来的文件 mv 出来
        mkdir -p ./unused_files/$cycle_idx/
        array=(`echo $unused_files | tr '\n' ' '`)
        for element in "${array[@]}"; do
            element=$(echo "$element" | tr -d '\n')
            echo "Unused class = "$element
            element_filename=$(basename "$element" .m)
            element_dirname=$(dirname "$element")
            
            destFoldName="./unused_files/$cycle_idx/${element_dirname}/${element_filename}"
            mkdir -p $destFoldName
            
            cp -f ${element_dirname}/${element_filename}.h $destFoldName/$element_filename.h
            cp -f ${element_dirname}/${element_filename}.m $destFoldName/$element_filename.m
        done
        
        #cycle_deal参数为空则不循环执行
        if [ -z "$cycle_deal" ]; then
            echo "cycle_deal参数为空则不循环执行"

            exit 0
        else
            #cycle_deal 不为空 循环执行，直到不再有新文件检出
            echo -e "循环执行"
            cycle_idx=$((cycle_idx+1))
            main $1
        fi

    else
        echo "No unused ViewController files found."$all_file_path
        echo "**************************"
        echo "total_unused_file_name class files:\n$total_unused_file_name"
        echo "**************************"

        exit 0
    fi
}


main $1

