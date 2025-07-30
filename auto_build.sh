#!/bin/bash
# 需要关联项目自动打包
# author: paysonchen
# [目的]
# 安装开发者证书后，关联项目自动

# [说明]
# 1、触发各代码仓库 指定分支的 构建
#
# [参数]
# 1、参数1，流水线编号
#
# [调用说明]
#  sh auto_build.sh


function auto_build()
{

    pipeline_no=$1

    echo "执行流水线:"$pipeline_no
    echo "devops_access_token:"$devops_access_token

    curl --location --request POST "http://psc-devops.psc.com/v1/pipeline/pipelines/$pipeline_no/manual" \
                    -H "access_token:${devops_access_token}" \
                    --header 'Content-Type: application/json' \
                    --data '{"externalName":"sign_sync_build","scmTriggerType":"BRANCH","variables":null}'

}

e_pipeline_no=2349
op_pipeline_no=2350
opp_pipeline_no=2351
g_pipeline_no=2352

auto_build $e_pipeline_no
auto_build $op_pipeline_no
auto_build $opp_pipeline_no
auto_build $g_pipeline_no

