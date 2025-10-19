# libsodium-jni 构建指南（NDK r28+ 支持）

本文档说明如何构建支持 Android NDK r28+ 的 libsodium-jni 项目。

## 📋 系统要求

### 必需软件
- **Java 17 或 21** (必需 - AGP 8.2.2 不支持 Java 8)
- **Android NDK r28+** (推荐 r28.0.12433566 或更高)
- **Android SDK** (compileSdkVersion 34)
- **Gradle 8.11.1+** (已包含在项目中)
- **SWIG** (用于生成 JNI 绑定)
- **Autotools** (用于构建 libsodium)

### 支持的架构
- ✅ armeabi-v7a (ARMv7)
- ✅ arm64-v8a (ARMv8/ARM64)
- ✅ x86
- ✅ x86_64
- ❌ armeabi (已移除，NDK r28+ 不再支持)

## 🚀 快速开始

### 第 1 步：安装 Java 17

#### macOS 用户：
```bash
# 使用 Homebrew 安装
brew install openjdk@17

# 或者运行我们提供的安装脚本
./install-java17.sh
```

#### 手动安装：
从以下网站下载 Java 17：
- https://adoptium.net/
- https://www.oracle.com/java/technologies/downloads/#java17

### 第 2 步：设置环境变量

```bash
# 设置 Java 17
export JAVA_HOME=$(/usr/libexec/java_home -v 17)

# 设置 Android NDK 路径（根据你的实际路径修改）
export ANDROID_NDK_HOME=/path/to/your/ndk-r28

# 或者在 local.properties 中配置
echo "sdk.dir=/path/to/android/sdk" > local.properties
echo "ndk.dir=/path/to/android/sdk/ndk/28.0.12433566" >> local.properties
```

### 第 3 步：构建项目

```bash
# 清理
./gradlew clean

# 构建 AAR
./gradlew assembleRelease

# 或者构建所有变体
./gradlew build
```

## 📝 详细构建步骤

### 1. 验证环境

```bash
# 检查 Java 版本（应该显示 17.x.x）
java -version

# 检查 Gradle 版本
./gradlew --version

# 检查 NDK 路径
echo $ANDROID_NDK_HOME
```

### 2. 编译 libsodium 原生库

libsodium 会在构建过程中自动编译。如果需要手动编译特定架构：

```bash
# 编译 ARMv7
./gradlew compileNative_armv7-a

# 编译 ARM64
./gradlew compileNative_armv8-a

# 编译 x86
./gradlew compileNative_i686

# 编译 x86_64
./gradlew compileNative_westmere
```

### 3. 生成 SWIG 绑定（如果需要）

```bash
./gradlew generateSWIGsource
```

### 4. 运行测试

```bash
# 单元测试
./gradlew test

# Android 设备测试（需要连接设备或模拟器）
./gradlew connectedAndroidTest
```

### 5. 发布到 Maven

```bash
# 构建并发布到本地 Maven
./gradlew publishToMavenLocal

# 发布到 Sonatype（需要配置凭据）
./gradlew publish
```

## ⚙️ 配置文件说明

### build.gradle
- **compileSdkVersion**: 34
- **minSdkVersion**: 21 (Android 5.0)
- **targetSdkVersion**: 34
- **ndkVersion**: 28.0.12433566
- **Java版本**: 1.8 (运行时兼容性)

### jni/Application.mk
- **APP_PLATFORM**: android-21
- **APP_ABI**: armeabi-v7a arm64-v8a x86 x86_64
- **APP_STL**: c++_static

## 🔧 常见问题解决

### Q1: "Unsupported class file major version 68" 错误
**原因**: 使用了 Java 24，但 Gradle 不支持

**解决方案**:
```bash
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
./gradlew clean build
```

### Q2: "Could not resolve class MavenDeployment" 错误
**原因**: 旧的 maven 插件已被移除

**解决方案**: 已更新为 maven-publish 插件（无需操作）

### Q3: NDK 找不到或版本不匹配
**解决方案**:
```bash
# 设置 NDK 路径
export ANDROID_NDK_HOME=/path/to/your/ndk-r28

# 或在 local.properties 中配置
echo "ndk.dir=/path/to/ndk-r28" >> local.properties
```

### Q4: "armeabi" 架构构建失败
**原因**: NDK r28+ 已移除 armeabi 支持

**解决方案**: 不再支持 armeabi，请使用 armeabi-v7a

### Q5: Gradle 构建很慢
**解决方案**:
```bash
# 清理 Gradle 缓存
rm -rf ~/.gradle/caches

# 使用 Gradle daemon 和并行构建
./gradlew --daemon --parallel build
```

## 📦 构建输出

构建成功后，输出文件位于：

```
build/outputs/aar/
├── libsodium-jni-debug.aar
└── libsodium-jni-release.aar

build/libs/
├── libsodium-jni-2.1.0-SNAPSHOT.jar
├── libsodium-jni-2.1.0-SNAPSHOT-sources.jar
└── libsodium-jni-2.1.0-SNAPSHOT-javadoc.jar
```

## 🔄 版本信息

- **libsodium**: 1.0.20
- **Android Gradle Plugin**: 8.2.2
- **Gradle**: 8.11.1
- **最低 Android 版本**: API 21 (Android 5.0)
- **目标 Android 版本**: API 34

## 📚 更多信息

- **libsodium 文档**: https://libsodium.gitbook.io/
- **Android NDK 文档**: https://developer.android.com/ndk
- **项目原始仓库**: https://github.com/joshjdevl/libsodium-jni

## 🆘 获取帮助

如果遇到问题：

1. 检查 Java 版本是否为 17 或 21
2. 确认 NDK 路径正确设置
3. 清理并重新构建: `./gradlew clean build`
4. 查看详细日志: `./gradlew build --info --stacktrace`

---

**最后更新**: 2025-10-17
**维护者**: 社区贡献

