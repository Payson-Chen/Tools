#!/bin/bash

# 遍历当前目录下，打印当前组件的最近tag
# author: paysonchen
# [目的]
# 组件化建设过程及后续的协同开发中，有些全局修改需要统一发版
#
# [目录]
#   - auto_print_tag.sh  遍历当前目录下，私有库，打印当前组件的最近tag
#
# [说明]
# 1、遍历指定目录（若未传参数则为当前目录）下的子目录
# 2、cd 到子目录
# 3、检查当前分支
# 4、打印当前组件的最近tag
#
# [参数]
# 1、参数1，指定目录
#
# [调用说明]
# 1、未指定目录，则取当前目录：sh auto_print_tag.sh
# 2、指定目录：sh auto_print_tag.sh /User/xxx/xx


if [ -z "$1" ]; then
    export dist_path=*/
    echo '///指定目录 为空:'${dist_path}
else
    export dist_path=$1/*/
    echo '///指定目录 不为空:'${dist_path}
fi


function get_tag()
{
    latest_tag=$(git describe --abbrev=0 --tags)
    echo "${latest_tag}"
}

    
# 遍历指定目录的子目录
allTaged=""

for dir in ${dist_path}; do
  cd "$dir"  # 进入子目录
  echo '///进入子目录:'${dir}

  # 检查是否是git仓库
  if [ -d .git ]; then
    result=false
    echo "Updating git repository in $dir"
    current_branch=`git branch --show-current`
    echo "current_branch is $current_branch"
    
    git config pull.rebase false # 合并（缺省策略）
    git pull origin $current_branch  # 使用git pull命令更新git仓库


    latest_tag=$(get_tag)

    pod_name=${dir%%/*}

    allTaged="$allTaged pod \"$pod_name\",'$latest_tag' \n"

   


  else
    echo "Skipping non-git repository in $dir"
  fi

  cd ..  # 返回上一级目录
done

echo "------------------------"
echo "allTaged（当前组件版本号）： = \n"$allTaged
echo "------------------------"
