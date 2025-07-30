#!/bin/bash

# [背景]
# 基础组件拆分到一定程度时，主工程剩下的就多数与视图界面(vc、view等)相关的类文件。此时可以考虑对业务组件进行设计和规划，但是在此时，工程还存在如下问题：
# 冗余文件：
#   未被引用到Project，但存在在工程目录中的冗余的类文件
#
# author: paysonchen
# [目的]
# 为了减轻业务组件的工作量和复杂度，在此之前最好能净化/清理一下工程
#
# [目录]
#   - find_all_file_no_project.sh
# [说明]
# 1、通过递归遍历工程目录，将遍历后的类名逐一与XXX.xcodeproj/project.pbxproj 文件内容进行匹配
# 2、匹配不成功则输出文件列表
# 3、【人工】对文件列表一一检查，确认是冗余文件则从工程中删除
#
# [参数]
# 1、参数1，指定xcode工程自身的主工程类所在目录，而非project所在的目录
#   例如 XXX/ProjectName/ProjectName.xcodeproj/project.pbxproj
#       XXX/ProjectName/ProjectName/AppDelegate.h
#   需要传入的是下面这地址：
#       XXX/ProjectName/ProjectName
# [调用说明]
# 1、未指定目录，则取当前目录：sh find_all_file_no_project.sh
# 2、指定目录：sh find_all_file_no_project.sh /Users/xxxxx/Project-IOS/ProjectName/ProjectName


#!/bin/bash

function main() {
    
    # 设置项目目录
    project_directory=$1

    if [ -z "$1" ]; then
        #未传参为当前目录
        project_directory=.
    fi

    # 设置其他目录
    parent_path=$(dirname "$project_directory")
    echo "project 路径："$parent_path
    
    current_dir=$(basename "$project_directory")
    echo "当前路径 文件夹名称："$current_dir

    
    project_path=$(find "$parent_path"/$current_dir.xcodeproj -type f \( -name "*.pbxproj" \))
    echo "project 路径："$project_path

    all_file_path=$(find "$project_directory" -type f \( -name "*.h" \))
    all_file_path_cnt=$(find "$project_directory" -type f \( -name "*.h" \) | wc -l)

    echo "主工程 头文件数量："$all_file_path_cnt

    for src_file in $all_file_path; do
    #    echo $src_file
        filename=$(basename "$src_file" .h)
        if  ! grep -q "\b$filename\b" "$project_path";  then
            echo "project不包含："$src_file
        fi
    done
}


main $1
