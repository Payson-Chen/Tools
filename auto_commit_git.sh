#!/bin/bash

# 遍历更新当前目录下，子目录git仓库的脚本
# author: paysonchen
# [目的]
# 组件化建设过程及后续的协同开发中，经常碰到团队人员更新组件库代码及主工程，主工程容易更新，但是随着pod库的增多，每次更新组件库仓库的重复劳动需要被改进
#
# [目录]
#   - auto_commit_git.sh 遍历更新当前目录下，子目录git仓库的脚本
#
# [说明]
# 1、遍历指定目录（若未传参数则为当前目录）下的子目录
# 2、cd 到子目录
# 3、检查当前分支
# 4、提交修改
# 5、commit 、push
#
# [参数]
# 1、参数1，指定目录
# 2、参数2，提交信息
#
# [调用说明]
# 1、未指定目录，则取当前目录：sh auto_commit_git.sh
# 2、指定目录：sh auto_commit_git.sh /User/xxx/xx "提交信息"


if [ -z "$1" ]; then
    export dist_path=*/
    echo '///指定目录 为空:'${dist_path}
else
    export dist_path=$1/*/
    echo '///指定目录 不为空:'${dist_path}
fi

echo '///指定:'$1
echo '///指定:'$2

# 遍历指定目录的子目录
for dir in ${dist_path}; do
  cd "$dir"  # 进入子目录
  echo '///进入子目录:'${dir}

  # 检查是否是git仓库
  if [ -d .git ]; then
    echo "commiting git repository in $dir"
    current_branch=`git branch --show-current`
    echo "current_branch is $current_branch"
    
    git add .
    msg=""
    if [ -z "$2" ]; then
        msg="--update:更新代码"
        echo '///提交记录 为空:'$msg
    else
        msg=$2
        echo '///提交记录 不为空:'$msg
    fi

    git commit -m "$msg"
    git push -f origin master
  else
    echo "Skipping non-git repository in $dir"
  fi

  cd ..  # 返回上一级目录
done
