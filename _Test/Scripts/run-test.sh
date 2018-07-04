#!/bin/bash
#
# This is the wapper of xctool, for daily unit test running.
#
# Author: 7
#
# Use xtool-0.3.3

## 教程
# 参数处理  说明
# $#    传递到脚本的参数个数
# $*    以一个单字符串显示所有向脚本传递的参数。
#       如"$*"用「"」括起来的情况、以"$1 $2 … $n"的形式输出所有参数。
# $$    脚本运行的当前进程ID号
# $!    后台运行的最后一个进程的ID号
# $@    与$*相同，但是使用时加引号，并在引号中返回每个参数。
#       如"$@"用「"」括起来的情况、以"$1" "$2" … "$n" 的形式输出所有参数。
# $-    显示Shell使用的当前选项，与set命令功能相同。
# $?    显示最后命令的退出状态。0表示没有错误，其他任何值表明有错误。

## 参考
# [XCode环境变量及路径设置](http://www.cnblogs.com/shirley-1019/p/3823906.html)
# 可以在 ‘xcodebuild -workspace NewStructure.xcworkspace -scheme NewStructureTests -showBuildSettings’ 中获取指定工程的环境变量，
# 比如 SYMROOT = /Users/f7/Library/Developer/Xcode/DerivedData/NewStructure-bfchxxxzffxfbtaqgrnkjhcacmxk/Build/Products

set -e

## 基本信息配置

WORKSPACE="NewStructure.xcworkspace"
SCHEME="NewStructureTests"
TARGET="NewStructureTests"

## 检查帮助

function usage() {
    echo ""
    echo "########################################################################"
    echo "#"
    echo "# 帮助:"
    echo "#"
    echo "#    测试所有用例：       ./run-test.sh -a"
    echo "#    测试单个用例(1)：    ./run-test.sh -f NetworkingTest"
    echo "#    测试单个用例(2)：    ./run-test.sh -f Networking*"
    echo "#"
    echo "########################################################################"
    echo ""
    exit 1
}

if [ $# -lt 1 ]; then
    usage
fi

## 检查依赖项

function checkDependency() {
    command -v xctool  >/dev/null 2>&1 || { echo "please: brew install xctool" >&2; exit 1; }
}

checkDependency

## 检查是否为test做好了必要的build

BUILD_SETTING=$(xcodebuild -workspace $WORKSPACE -scheme $SCHEME -showBuildSettings)
BUILD_SETTING_AAA=${BUILD_SETTING#*" BUILD_ROOT ="} # #号截取，删除左边字符，保留右边字符。
BUILD_SETTING_BBB=${BUILD_SETTING_AAA%" BUILD_STYLE ="*} # %号截取，删除右边字符，保留左边字符
DERIVED_DATA_PATH=$(echo $BUILD_SETTING_BBB | sed s/[[:space:]]//g)

UPPER_DIR=$(cd "$(dirname "$0")/.."; pwd)
CURRENT_DIR=$(pwd)
RESULT_BUNDLE_PATH="$DERIVED_DATA_PATH/Debug-iphonesimulator/NewStructure.app/PlugIns/NewStructureTests.xctest"

# echo $RESULT_BUNDLE_PATH

function checkBuildForTesting() {
    if [ -e "$RESULT_BUNDLE_PATH" ]; then
        echo "======Entering into test======"
    else
        echo "======Cleaning for test======"
        
        xcodebuild -workspace $WORKSPACE -scheme $SCHEME clean -sdk iphonesimulator >/dev/null

        echo "======Building for test======"

        xcodebuild -workspace $WORKSPACE -scheme $SCHEME build-for-testing -sdk iphonesimulator >/dev/null
    fi
}

checkBuildForTesting

## 执行测试

if [ "$1" = "-a" ]; then

    # 当前运行过一次xcode的test，才能成功运行xctool的

  "$SCHEME"/John/Scripts/bin/xctool -workspace $WORKSPACE -scheme $SCHEME run-tests -sdk iphonesimulator

  exit 0
fi

if [ "$1" = "-f" ]; then

  "$SCHEME"/John/Scripts/bin/xctool -workspace $WORKSPACE -scheme $SCHEME run-tests -only $TARGET:$2 -sdk iphonesimulator

  exit 0
fi





