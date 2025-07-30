#通过外部传参 读取自定义参数 1:configuration(0:DailyBuild|1:TestFlight|2:Release) 2:target_name 3:项目工程根目录（一般与target相同）
# 1 2 必须 3可选，3不填用2的值
# 使用了gitsubmodule 构建组件，兼容git 检出不兼容，需要先执行 git submodule update --init --recursive
git submodule update --init --recursive
# 拉取自模块更新
git submodule update --remote

#打包方式：configuration(0:DailyBuild|1:TestFlight|2:Release|3:TFInner)
configuration=0

#项目配置：
targetName=PscexampleiOS

#渠道号：pgy下载 url后缀
pgyChannel=144

#是否启用通知 有传值1则启用群通知，2启用内部群通知
notify=1

#1 启用oss 2 启用pgy+oss else pgy
publish=0

sh PSC_iOS_Build_SH/UniversalBuild.sh -cfg $configuration -target_name $targetName -channel_name $pgyChannel -notify $notify -publish $publish
