#!/bin/bash

# 完整的构建脚本 - 支持 NDK r28+ (包括 NDK r29)
# 此脚本会清理、编译所有架构的 libsodium 并构建 Android AAR
# 
# 使用方法：./build-all.sh

set -e  # 遇到错误立即退出

echo "========================================"
echo "libsodium-jni 完整构建脚本"
echo "支持 NDK r28+ (包括 NDK r29)"
echo "========================================"
echo ""

# 检查 Java 版本
echo "1. 检查 Java 环境..."
if [ -z "$JAVA_HOME" ]; then
    # 尝试找到 Java 21 (Android Studio 自带)
    AS_JAVA="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
    if [ -d "$AS_JAVA" ]; then
        export JAVA_HOME="$AS_JAVA"
        echo "✅ 使用 Android Studio JDK: $JAVA_HOME"
    else
        # 尝试找到系统 Java 17 或 21
        JAVA_17=$(/usr/libexec/java_home -v 17 2>/dev/null || echo "")
        JAVA_21=$(/usr/libexec/java_home -v 21 2>/dev/null || echo "")
        
        if [ -n "$JAVA_21" ]; then
            export JAVA_HOME="$JAVA_21"
            echo "✅ 使用 Java 21: $JAVA_HOME"
        elif [ -n "$JAVA_17" ]; then
            export JAVA_HOME="$JAVA_17"
            echo "✅ 使用 Java 17: $JAVA_HOME"
        else
            echo "❌ 错误: 未找到 Java 17 或 21"
            echo "请安装 Java 17 或 21，或运行: ./install-java17.sh"
            exit 1
        fi
    fi
fi

java -version
echo ""

# 检查 NDK
echo "2. 检查 Android NDK..."
if [ -z "$ANDROID_NDK_HOME" ]; then
    # 尝试自动检测 NDK
    SDK_ROOT="$HOME/Library/Android/sdk"
    if [ -d "$SDK_ROOT/ndk/29.0.14206865" ]; then
        export ANDROID_NDK_HOME="$SDK_ROOT/ndk/29.0.14206865"
        echo "✅ 找到 NDK r29: $ANDROID_NDK_HOME"
    elif [ -d "$SDK_ROOT/ndk/28.0.12433566" ]; then
        export ANDROID_NDK_HOME="$SDK_ROOT/ndk/28.0.12433566"
        echo "✅ 找到 NDK r28: $ANDROID_NDK_HOME"
    else
        echo "❌ 错误: 未找到 NDK r28/r29"
        echo "请设置 ANDROID_NDK_HOME 或通过 Android Studio SDK Manager 安装 NDK"
        exit 1
    fi
else
    echo "✅ 使用 NDK: $ANDROID_NDK_HOME"
fi

# 设置 NDK Platform
export NDK_PLATFORM="android-21"
echo "   NDK Platform: $NDK_PLATFORM"
echo ""

# 检查必需工具
echo "3. 检查构建工具..."
MISSING_TOOLS=""

if ! command -v swig &> /dev/null; then
    MISSING_TOOLS="$MISSING_TOOLS swig"
fi

if ! command -v autoconf &> /dev/null; then
    MISSING_TOOLS="$MISSING_TOOLS autoconf"
fi

if ! command -v automake &> /dev/null; then
    MISSING_TOOLS="$MISSING_TOOLS automake"
fi

if ! command -v libtool &> /dev/null && ! command -v glibtool &> /dev/null; then
    MISSING_TOOLS="$MISSING_TOOLS libtool"
fi

if [ -n "$MISSING_TOOLS" ]; then
    echo "❌ 缺少工具:$MISSING_TOOLS"
    echo "正在安装..."
    brew install$MISSING_TOOLS
    echo "✅ 工具安装完成"
fi
echo "✅ 所有必需工具已安装"
echo ""

# 生成 SWIG 绑定
echo "4. 生成 SWIG JNI 绑定..."
cd jni
if [ ! -f sodium_wrap.c ]; then
    swig -java -package org.libsodium.jni -outdir ../src/main/java/org/libsodium/jni sodium.i
    echo "✅ SWIG 绑定已生成"
else
    echo "✅ SWIG 绑定已存在"
fi
cd ..
echo ""

# 编译 libsodium
echo "5. 编译 libsodium 所有架构..."
echo "   这可能需要几分钟，请耐心等待..."
echo ""

echo "   [1/4] 编译 ARMv7..."
./gradlew compileNative_armv7-a --quiet

echo "   [2/4] 编译 ARM64..."
./gradlew compileNative_armv8-a --quiet

echo "   [3/4] 编译 x86..."
./gradlew compileNative_i686 --quiet

echo "   [4/4] 编译 x86_64..."
./gradlew compileNative_westmere --quiet

echo "✅ libsodium 所有架构编译完成"
echo ""

# 创建符号链接（修复 armv8-a+crypto 目录名问题）
echo "6. 修复架构目录名称..."
cd libsodium
if [ -d "libsodium-android-armv8-a+crypto" ] && [ ! -e "libsodium-android-armv8-a" ]; then
    rm -rf libsodium-android-armv8-a
    ln -s libsodium-android-armv8-a+crypto libsodium-android-armv8-a
    echo "✅ 已创建 armv8-a 符号链接"
fi
cd ..
echo ""

# 验证所有库文件存在
echo "7. 验证 libsodium 库文件..."
ALL_EXIST=true
for arch in armv7-a armv8-a i686 westmere; do
    LIB_FILE="libsodium/libsodium-android-$arch/lib/libsodium.a"
    if [ -f "$LIB_FILE" ]; then
        SIZE=$(ls -lh "$LIB_FILE" | awk '{print $5}')
        echo "   ✅ $arch: $SIZE"
    else
        echo "   ❌ $arch: 缺失"
        ALL_EXIST=false
    fi
done

if [ "$ALL_EXIST" = false ]; then
    echo "❌ 某些库文件缺失"
    exit 1
fi
echo ""

# 构建 Android AAR
echo "8. 构建 Android AAR..."
./gradlew assembleRelease

echo ""
echo "========================================"
echo "🎉 构建成功完成！"
echo "========================================"
echo ""
echo "输出文件位于:"
echo "  - build/outputs/aar/libsodium-jni-release.aar"
echo "  - build/outputs/aar/libsodium-jni-debug.aar"
echo ""

# 显示 AAR 内容
echo "AAR 包含的架构:"
unzip -l build/outputs/aar/libsodium-jni-release.aar | grep "\.so$" | awk '{print "  -", $4}'
echo ""

# 显示文件大小
echo "文件大小:"
ls -lh build/outputs/aar/*.aar | awk '{print "  -", $9, ":", $5}'
echo ""

echo "========================================"
echo "构建完成！可以开始使用了 🚀"
echo "========================================"

