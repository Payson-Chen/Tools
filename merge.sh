#!/bin/bash

# [背景]
# ​    组件化过程中不可避免的会遇到这样一个问题：
#​    组件化的过程一般周期比较长，此过程中不免会有业务需求的输入，这样就会导致一个情况：
#​    组件化分支已经将主工程里的类迁移到pod仓库,而在此期间的业务需求代码对这些被迁移的类有修改，
#​    合并主干（其他分支）代码时,主干（其他分支）有对移动之前的类做修改的情况下,会导致合并冲突,
#​    这种冲突是整个类都是新增符号(+),没有冲突符号，此时无法简单的通过工具，或者冲突的符号对其进行解冲突。
#
# author: paysonchen
# [目的]
# 为了减轻组件化分支合并主干分支的工作量和复杂度
#
# [目录]
#   - merge.sh
# [说明]
# 1、整理project 冲突文件的路径列表
# 2、整理冲突列表在各个pod库中的路径列表
# 3、在未预合并分支上先mv一份整理后的pod库中的路径列表到主工程
# 4、再进行分支合并
# 5、解决冲突后，执行将主工程的上述列表，mv到各个pod库
# 6、提交各个Pod库代码
# 7、整理Project文件及工程类
# 8、提交Project代码
#
# [参数]
# 1、参数1：源路径：从参数1下的文件路径了列表，移动到参数2（索引）对应的路径
#   例如 merge_pods_files.txt
# 2、参数2，目标移动路径列表
#   例如 merge_project_files.txt
#
# [调用说明]
# 1、需要指定目录
#  从Pod移动到主工程：sh merge.sh merge_pods_files.txt merge_project_files.txt
#  从主工程移动到Pod：sh merge.sh merge_project_files.txt merge_pods_files.txt


# 从外部文件中读取源文件路径和目标文件夹路径
#"source_paths.txt"
source_file=$1
#"destination_paths.txt"
destination_file=$2

# 检查源文件是否存在
if [ ! -f "$source_file" ]; then
    echo "源文件 '$source_file' 不存在。"
    exit 1
fi

# 检查目标文件夹文件是否存在
if [ ! -f "$destination_file" ]; then
    echo "源文件 '$source_file' 不存在。"
    exit 1
fi

#保证每条记录都有一个回车（最后一行如果没有回车，会被忽略）
while IFS= read -r source_path && IFS= read -r destination_folder <&3; do
    source_paths+=("$source_path")
    destination_paths+=("$destination_folder")
done < $source_file 3< $destination_file

# 输出数组长度
echo "源文件路径数组长度：${#source_paths[@]}"
echo "目标文件夹路径数组长度：${#destination_paths[@]}"

#exit 0
# 遍历索引
for index in "${!source_paths[@]}"; do
    echo "遍历目标文件夹路径数组,index="$index
    source_path="${source_paths[$index]}"
    destination_path="${destination_paths[$index]}"

    # 构建目标文件的完整路径
#    destination_path="${destination_folder}${source_path}"

    # 检查目标文件是否存在，如果存在则删除
    if [ -e "$destination_path" ]; then
        rm "$destination_path"
    fi

    # 确保目标文件夹存在
    mkdir -p "$(dirname "$destination_path")"

    # 复制源文件到目标路径
    mv "$source_path" "$destination_path"
done

echo "文件复制完成。"
