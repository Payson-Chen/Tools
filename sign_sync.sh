#!/bin/bash
#
# author: paysonchen
# [目的]
#
# 随着团队成员变更频繁，经常需要加设备以及更新证书，考虑到更新证书的重复性与机械性，可以通过脚本实现将下载后的证书同步到 sign仓库后提交
#
# [目录]
#   - sign_sync.sh 遍历下载目录下的证书列表，一一复制到sign仓库对应的证书目录
#
# [说明]
# 1、定义source_dir 一般为下载目录
# 2、定义目标目录
# 3、定义证书列表
# 4、定义目标证书目录
# 5、判断存在证书时，移动到目标目录
#
# [参数]
# 无
#

# 设置源目录和目标目录
user_name=$(whoami)
source_dir="/Users/$user_name/Downloads"

target_dir="/Users/$user_name/Documents/PSC/git/Inner/Sign/Sign"

# 文件列表
files=("xxx.mobileprovision")
target_fold=("xxx_fold")

# 检查目标目录是否存在，如果不存在则创建
# 检查并创建目标文件夹（如果不存在）
for folder in "${target_fold[@]}"; do
  target_path="$target_dir/$folder"
  if [ ! -d "$target_path" ]; then
    echo "目标文件夹 $target_path 不存在，正在创建..."
    mkdir -p "$target_path"
  fi
done

# 移动文件
for i in "${!files[@]}"; do
  source_file="$source_dir/${files[$i]}"
  target_folder="$target_dir/${target_fold[$i]}"
  
  if [ -f "$source_file" ]; then
    echo "正在移动文件 $source_file 到 $target_folder..."
    mv "$source_file" "$target_folder"
  else
    echo "文件 $source_file 不存在，跳过..."
  fi
done

echo "所有文件移动操作完成！"


