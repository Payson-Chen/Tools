#!/bin/bash

# 遍历当前目录下，私有库自动自增发版
# author: paysonchen
# [目的]
# 组件化建设过程及后续的协同开发中，有些全局修改需要统一发版
#
# [目录]
#   - auto_publish_git.sh  遍历当前目录下，私有库自动自增发版
#
# [说明]
# 1、遍历指定目录（若未传参数则为当前目录）下的子目录
# 2、cd 到子目录
# 3、检查当前分支
# 4、自动发版
#
# [参数]
# 1、参数1，指定目录
#
# [调用说明]
# 1、未指定目录，则取当前目录：sh auto_publish_git.sh
# 2、指定目录：sh auto_publish_git.sh /User/xxx/xx


if [ -z "$1" ]; then
    export dist_path=*/
    echo '///指定目录 为空:'${dist_path}
else
    export dist_path=$1/*/
    echo '///指定目录 不为空:'${dist_path}
fi
    
# 遍历指定目录的子目录
for dir in ${dist_path}; do
  cd "$dir"  # 进入子目录
  echo '///进入子目录:'${dir}

  # 检查是否是git仓库
  if [ -d .git ]; then
    echo "Updating git repository in $dir"
    current_branch=`git branch --show-current`
    echo "current_branch is $current_branch"
    if [ -z "$2" ]; then
        echo "tag 为空，采用自增tag"
        pod push
    else
        echo "tag 不为空，tag="$2
        pod push $2
    fi
  else
    echo "Skipping non-git repository in $dir"
  fi

  cd ..  # 返回上一级目录
done
