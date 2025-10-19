# NDK r28+ 升级说明

本项目已更新以支持 Android NDK r28 及以上版本（包括 NDK r29）。

## 主要变更

### 1. 移除了不支持的架构
- **移除**: `armeabi` (armv6) - NDK r28+ 已不再支持此架构
- **保留**: `armeabi-v7a`, `arm64-v8a`, `x86`, `x86_64`

### 2. 更新的最低 API 级别
- 最低 SDK 版本: Android 5.0 (API 21)
- NDK Platform: android-21

### 3. 配置文件更新
- `jni/Application.mk`: 更新了 APP_PLATFORM 和 APP_ABI
- `jni/Android.mk`: 更新了架构映射
- `build.gradle`: 添加了 `ndkVersion` 配置

## 构建要求

### 必需条件
1. **Android NDK r28+** (推荐 r29.0.14206865 或 r28.0.12433566)
2. **Java 17+** (JDK 17 或 21)
3. **Gradle 8.11+**
4. **Android SDK** (compileSdkVersion 35)

### 环境配置

1. 设置 ANDROID_NDK_HOME 环境变量:
```bash
export ANDROID_NDK_HOME=/path/to/your/ndk-r28
```

2. 或者在 `local.properties` 中配置:
```properties
sdk.dir=/path/to/android/sdk
ndk.dir=/path/to/android/sdk/ndk/28.0.12433566
```

## 构建步骤

1. 确保使用 Java 8:
```bash
export JAVA_HOME=/path/to/jdk1.8
java -version  # 应显示 1.8.x
```

2. 构建项目:
```bash
./gradlew clean build
```

3. 生成 AAR:
```bash
./gradlew assembleRelease
```

## 支持的架构

| 架构 | NDK 名称 | libsodium 输出名称 | 支持状态 |
|------|----------|-------------------|----------|
| ARMv7 | armeabi-v7a | armv7-a | ✅ 支持 |
| ARMv8 | arm64-v8a | armv8-a | ✅ 支持 |
| x86 | x86 | i686 | ✅ 支持 |
| x86_64 | x86_64 | westmere | ✅ 支持 |
| ARMv6 | armeabi | armv6 | ❌ 已移除 |

## 常见问题

### Q: 为什么移除了 armeabi 支持？
A: Google 从 NDK r17 开始弃用 armeabi，在 NDK r28+ 中完全移除。现代 Android 设备都支持 armeabi-v7a 或更高版本。

### Q: 如何获取 NDK r28/r29？
A: 可以通过 Android Studio 的 SDK Manager 下载，或从官方网站下载:
https://developer.android.com/ndk/downloads

或使用 sdkmanager 命令行工具：
```bash
sdkmanager --install "ndk;29.0.14206865"
# 或
sdkmanager --install "ndk;28.0.12433566"
```

### Q: 构建失败怎么办？
A: 请检查:
1. NDK 版本是否正确 (r28+)
2. ANDROID_NDK_HOME 环境变量是否设置
3. Java 版本是否为 1.8
4. Gradle 缓存是否需要清理: `rm -rf ~/.gradle/caches`

## 版本信息

- libsodium: 1.0.20
- Android Gradle Plugin: 8.2.2
- Gradle: 8.4
- 目标 SDK: 34
- 最低 SDK: 21

