#!/bin/bash

# 遍历更新当前目录下，子目录git仓库的脚本
# author: paysonchen
# [目的]
# 组件化建设过程及后续的协同开发中，经常碰到团队人员更新组件库代码及主工程，主工程容易更新，但是随着pod库的增多，每次更新组件库仓库的重复劳动需要被改进
#
# [目录]
#   - auto_update_git.sh.sh 遍历更新当前目录下，子目录git仓库的脚本
#
# [说明]
# 1、遍历指定目录（若未传参数则为当前目录）下的子目录
# 2、cd 到子目录
# 3、检查当前分支
# 4、拉取远端当前分支
#
# [参数]
# 1、参数1，指定目录
#
# [调用说明]
# 1、未指定目录，则取当前目录：sh auto_update_git.sh
# 2、指定目录：sh auto_update_git.sh /User/xxx/xx


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

    git config pull.rebase false # 合并（缺省策略）
    git pull origin $current_branch  # 使用git pull命令更新git仓库
  else
    echo "Skipping non-git repository in $dir"
  fi

  cd ..  # 返回上一级目录
done
