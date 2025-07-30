#!/bin/bash

# 原始图片的路径和名称
original_image=$1

# 输出目录
output_dir="${original_image%/*}"/out/
#output_dir="./out/"

# 分辨率列表，你可以根据需要添加或删除
resolutions=("300x300" "200x200" "180x180" "120x120" "87x87" "80x80" "60x60" "58x58" "40x40")

# 确保输出目录存在
mkdir -p "$output_dir"

# 遍历分辨率列表
for resolution in "${resolutions[@]}"; do
    # 提取宽度和高度
    IFS=x read -ra RESOLUTION <<< "$resolution"
    width=${RESOLUTION[0]}
    height=${RESOLUTION[1]}
    
    # 生成输出文件名
    output_file="$output_dir/image_${width}x${height}.jpg"
    
    # 使用convert命令调整图片大小并保存
    convert "$original_image" -resize "${width}x${height}" "$output_file"
    
    # 检查是否成功
    if [ $? -eq 0 ]; then
        echo "Generated $output_file"
    else
        echo "Failed to generate $output_file"
    fi
done
