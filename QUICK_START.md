# 🚀 快速开始指南

本项目已成功更新以支持 **NDK r28+**（包括 NDK r29），并使用最新的构建工具。

## ✅ 已完成的更新

### 主要变更
1. ✅ **NDK 支持**: 从旧版本升级到 NDK r29.0.14206865
2. ✅ **Android Gradle Plugin**: 升级到 8.2.2
3. ✅ **Gradle**: 升级到 8.11.1
4. ✅ **Maven 插件**: 从废弃的 `maven` 迁移到 `maven-publish`
5. ✅ **Namespace**: 添加 Android namespace 支持 (AGP 8.0+ 要求)
6. ✅ **架构支持**: 移除 armeabi，保留 armeabi-v7a, arm64-v8a, x86, x86_64
7. ✅ **libsodium**: 更新到 1.0.20
8. ✅ **依赖更新**: 升级到 AndroidX 和最新测试库

### 配置文件更新
- `build.gradle`: 完全现代化，支持 AGP 8+
- `jni/Application.mk`: 更新最低 API 为 21
- `jni/Android.mk`: 更新架构映射
- `AndroidManifest.xml`: 移除 package 属性（使用 namespace）
- `gradle-wrapper.properties`: Gradle 8.11.1

## 📋 系统要求

### 必需软件
```
✅ Java 17 或 21 (必需)
✅ Android NDK r29 (已配置为 29.0.14206865)
✅ Android SDK API 35
✅ Gradle 8.11.1 (已包含)
```

### 可选工具
```
⚙️ SWIG (如需重新生成 JNI 绑定)
⚙️ Autotools (用于编译 libsodium)
```

## 🎯 构建步骤

### 方法 1: 标准构建（推荐）

```bash
# 1. 设置 Java 17
export JAVA_HOME=$(/usr/libexec/java_home -v 17)

# 如果没有 Java 17，运行安装脚本
./install-java17.sh

# 2. 验证环境
java -version  # 应显示 17.x.x
./gradlew --version

# 3. 清理并构建
./gradlew clean
./gradlew build

# 4. 生成 AAR（可选）
./gradlew assembleRelease
```

### 方法 2: 使用 Android Studio

1. **安装 Java 17**
   ```bash
   brew install openjdk@17
   ```

2. **在 Android Studio 中打开项目**
   - File → Open → 选择项目目录
   - Android Studio 会自动检测并安装 NDK r29

3. **同步 Gradle**
   - Tools → AGP Upgrade Assistant (如果提示)
   - File → Sync Project with Gradle Files

4. **构建项目**
   - Build → Make Project
   - 或点击工具栏的构建按钮

### 方法 3: 分步构建（调试用）

```bash
# 1. 设置环境
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk
export ANDROID_NDK_HOME=$ANDROID_SDK_ROOT/ndk/29.0.14206865

# 2. 验证 NDK
ls $ANDROID_NDK_HOME/ndk-build || echo "NDK 未安装"

# 3. 编译 libsodium（可选，会自动执行）
./gradlew compileNative_armv7-a
./gradlew compileNative_armv8-a
./gradlew compileNative_i686
./gradlew compileNative_westmere

# 4. 生成 SWIG 绑定（如果需要）
./gradlew generateSWIGsource

# 5. 构建项目
./gradlew assembleDebug
./gradlew assembleRelease
```

## ⚠️ 常见问题

### 问题 1: "Unsupported class file major version 68"
```bash
# 解决方案：使用 Java 17
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
```

### 问题 2: "NDK not found" 或 "ndk;29.0.14206865 not installed"
```bash
# 方案 A: 使用 Android Studio SDK Manager 安装 NDK r29

# 方案 B: 使用命令行安装
$ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager "ndk;29.0.14206865"

# 方案 C: 接受所有许可
$ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager --licenses
```

### 问题 3: "namespace not specified"
✅ 已修复：在 build.gradle 中添加了 `namespace 'org.kaliumjni.lib'`

### 问题 4: "Could not resolve class MavenDeployment"
✅ 已修复：已迁移到 maven-publish 插件

### 问题 5: libsodium 构建失败
```bash
# 检查 autotools 是否安装
brew install autoconf automake libtool

# 手动编译 libsodium
cd libsodium
./autogen.sh
export ANDROID_NDK_HOME=$HOME/Library/Android/sdk/ndk/29.0.14206865
./dist-build/android-armv7-a.sh
```

## 📦 构建输出

成功构建后，输出文件位于：

```
build/outputs/aar/
├── libsodium-jni-debug.aar          # Debug AAR
└── libsodium-jni-release.aar        # Release AAR (推荐使用)

build/libs/
├── libsodium-jni-2.1.0-SNAPSHOT.jar
├── libsodium-jni-2.1.0-SNAPSHOT-sources.jar
└── libsodium-jni-2.1.0-SNAPSHOT-javadoc.jar
```

## 🔍 验证构建

```bash
# 检查 AAR 内容
unzip -l build/outputs/aar/libsodium-jni-release.aar

# 应该包含以下 .so 文件：
# jni/armeabi-v7a/libsodiumjni.so
# jni/arm64-v8a/libsodiumjni.so
# jni/x86/libsodiumjni.so
# jni/x86_64/libsodiumjni.so
```

## 📚 在项目中使用

### Gradle 依赖（发布到 Maven 后）
```gradle
dependencies {
    implementation 'com.github.joshjdevl.libsodiumjni:libsodium-jni-aar:2.1.0'
}
```

### 本地 AAR
```gradle
dependencies {
    implementation files('libs/libsodium-jni-release.aar')
}
```

### 代码示例
```java
import org.libsodium.jni.NaCl;
import org.libsodium.jni.Sodium;

// 加载库
NaCl.sodium();

// 使用 libsodium
byte[] key = new byte[32];
Sodium.crypto_secretbox_keygen(key);
```

## 🔧 开发工具

项目包含的辅助脚本：

- `install-java17.sh` - 安装 Java 17 (macOS)
- `build-setup.sh` - 检查并设置构建环境
- `BUILD_INSTRUCTIONS.md` - 详细构建说明
- `NDK_R28_UPGRADE.md` - NDK 升级详情

## 📊 版本信息

| 组件 | 版本 |
|------|------|
| libsodium | 1.0.20 |
| Android Gradle Plugin | 8.2.2 |
| Gradle | 8.11.1 |
| NDK | r29.0.14206865 |
| Compile SDK | 35 |
| Min SDK | 26 |
| Target SDK | 35 |
| Java | 17+ |

## 🆘 获取帮助

如果遇到问题：

1. 查看详细日志：
   ```bash
   ./gradlew build --info --stacktrace
   ```

2. 清理并重试：
   ```bash
   ./gradlew clean
   rm -rf .gradle build
   ./gradlew build
   ```

3. 检查环境：
   ```bash
   ./build-setup.sh
   ```

## ✨ 总结

项目已成功现代化，现在支持：
- ✅ 最新的 Android NDK r29
- ✅ Android Gradle Plugin 8.2.2
- ✅ Java 17/21
- ✅ 所有现代 Android 架构（除 armeabi）
- ✅ 标准的 maven-publish 插件
- ✅ Android namespace 规范

**开始构建**: `./gradlew clean build` 🎉

---
**更新日期**: 2025-10-17  
**维护**: 社区贡献

