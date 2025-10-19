#!/bin/bash

# 安装 Java 17 的脚本
# 适用于 macOS

echo "========================================="
echo "安装 Java 17 (OpenJDK)"
echo "========================================="
echo ""

# 检查是否已安装 Homebrew
if ! command -v brew &> /dev/null; then
    echo "❌ 未找到 Homebrew"
    echo ""
    echo "请先安装 Homebrew:"
    echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    echo ""
    exit 1
fi

echo "✅ 找到 Homebrew"
echo ""

# 安装 OpenJDK 17
echo "正在安装 OpenJDK 17..."
brew install openjdk@17

echo ""
echo "========================================="
echo "配置 Java 17"
echo "========================================="
echo ""

# 添加到系统 Java 路径
echo "将 OpenJDK 17 链接到系统..."
sudo ln -sfn /opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-17.jdk 2>/dev/null || \
sudo ln -sfn /usr/local/opt/openjdk@17/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-17.jdk

echo ""
echo "✅ Java 17 安装完成！"
echo ""

# 显示已安装的 Java 版本
echo "系统中的 Java 版本："
/usr/libexec/java_home -V

echo ""
echo "========================================="
echo "设置环境变量"
echo "========================================="
echo ""

JAVA_17_HOME=$(/usr/libexec/java_home -v 17 2>/dev/null)

if [ -n "$JAVA_17_HOME" ]; then
    echo "✅ Java 17 路径: $JAVA_17_HOME"
    echo ""
    echo "请运行以下命令设置 JAVA_HOME:"
    echo "  export JAVA_HOME=$JAVA_17_HOME"
    echo ""
    echo "或者将以下内容添加到 ~/.zshrc 或 ~/.bash_profile:"
    echo "  export JAVA_HOME=\$(/usr/libexec/java_home -v 17)"
    echo ""
else
    echo "❌ 无法找到 Java 17"
fi

echo "========================================="
echo "现在可以构建项目了！"
echo "========================================="
echo ""
echo "运行以下命令:"
echo "  export JAVA_HOME=\$(/usr/libexec/java_home -v 17)"
echo "  ./gradlew clean build"
echo ""

