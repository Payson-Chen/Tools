#!/bin/bash

# 遍历当前目录下，当最新提交不是Tag记录时（即有需要发版）才进行的私有库自动自增发版
# author: paysonchen
# [目的]
# 组件化建设过程及后续的协同开发中，有些全局修改需要统一发版
#
# [目录]
#   - auto_tag_if_need_git.sh  遍历当前目录下，私有库根据是否需要发版的逻辑进行自动自增发版
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
# 1、未指定目录，则取当前目录：sh auto_tag_if_need_git.sh
# 2、指定目录：sh auto_tag_if_need_git.sh /User/xxx/xx


if [ -z "$1" ]; then
    export dist_path=*/
    echo '///指定目录 为空:'${dist_path}
else
    export dist_path=$1/*/
    echo '///指定目录 不为空:'${dist_path}
fi


function get_tag()
{
    latest_tag=$(git describe --exact-match --tags $(git log -n1 --pretty='%h') 2>/dev/null)
    echo "${latest_tag}"
}

function push_if_need()
{
    if git describe --exact-match --tags $(git log -n1 --pretty='%h') >/dev/null 2>&1; then
        
        latest_tag=$(get_tag)
        echo "[push_if_need]:最新提交是一个标签（${latest_tag}）$1。"
        return 0
    else
        latest_tag=$(get_tag)
        echo "[push_if_need]:最新提交不是标签（${latest_tag}）$1。"
        pod push
        latest_tag=$(get_tag)
        echo "[push_if_need]:打包后的标签（${latest_tag}）$1。"
        return 1
    fi
}
    
# 遍历指定目录的子目录
allTaged=""

modifyTaged=""


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

    if [ -z "$2" ]; then
        echo "tag 为空，采用自增tag"
#        pod push
        push_if_need $dir
        result=$?
    
    else
        echo "tag 不为空，全量发版tag="$2
        pod push $2
    fi
    
    latest_tag=$(get_tag)

    pod_name=${dir%%/*}

    allTaged="$allTaged pod \"$pod_name\",'$latest_tag' \n"


    if [ $result -eq 1 ]; then
#        latest_tag=$(get_tag)
#        pod_name=${dir%%/*}

        modifyTaged="$modifyTaged pod \"$pod_name\",'$latest_tag' \n"
        
        
#        echo "变量是 true。"$dir
#        echo "变量是 true。"$tmp
        echo "变量是 true。"$modifyTaged

    else
        echo "变量是 false。"
    fi


  else
    echo "Skipping non-git repository in $dir"
  fi

  cd ..  # 返回上一级目录
done

echo "------------------------"
echo "allTaged（所有组件）： = \n"$allTaged
echo "------------------------"

echo "------------------------"
echo "allTaged（本次有发版组件）： = \n"$modifyTaged
echo "------------------------"
