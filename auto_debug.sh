
#!/bin/bash

# 设置变量，替换为你的应用程序名称、Xcode 项目路径和设备 UDID  xcworkspace xcodeproj
APP_NAME="PscexampleiOS"
PROJECT_PATH="PSC-IOS/PscexampleiOS/PscexampleiOS.xcworkspace"
DEVICE_UDID="00008030-000E050C21D2802E"
bundle_id="com.ndsd.app"
AppPath="/Users/cn22-i570454-a/Library/Developer/Xcode/DerivedData/PscexampleiOS-enujmiuwqdhgvfcldwlvhjxzzewr/Build/Products/Debug-iphoneos/PscexampleiOS.app"
sleepToDebug=20
# 循环执行调试和安装过程
while true
do
    echo "Building and installing $APP_NAME..."

    # 使用 xcodebuild 构建应用程序
   # xcodebuild -workspace "$PROJECT_PATH" -scheme "$APP_NAME" -configuration Debug \
               -destination "id=$DEVICE_UDID"
    
    #clean build

    # 检查构建结果，如果构建成功则安装应用程序到设备上
#    if [ $? -eq 0 ]; then
        # 使用 ios-deploy 将应用程序安装到设备上
        ios-deploy --id "$DEVICE_UDID" --bundle $AppPath --justlaunch
#        ios-deploy --id "$DEVICE_UDID" --bundle_id $bundle_id

        # 检查安装结果，如果安装成功则继续下一轮循环
        if [ $? -eq 0 ]; then
            echo "App installed successfully!"
        else
            echo "Failed to install app."
        fi
#    else
#        echo "Build failed."
#    fi

    # 等待一段时间后继续下一轮循环，例如等待 sleepToDebug 秒
#    sleep $sleepToDebug
done
