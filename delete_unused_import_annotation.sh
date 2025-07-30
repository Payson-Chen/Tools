#!/bin/bash

# 遍历指定目录下的类删除注释掉的import代码行的脚本
# author: paysonchen
# [目的]
# 工程阶段性整理无用import（注释掉）
#
# [目录]
#   - delete_unused_import_annotation.sh
#
# [说明]
# 1、遍历指定目录
# 2、检索代码行
# 3、符合给定条件：//import
# 4、删除代码行
#
# [参数]
# 1、参数1，指定目录
#
# [调用说明]
# 1 调用示例：sh delete_unused_import_annotation.sh your_path


find $1 -type f \( -name "*.h" -o -name "*.m" \) -exec sed -i '' '/\/\/#import/d' {} \;
