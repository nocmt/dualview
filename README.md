# DualView for macOS

<p align="center">
  <b>高性能双屏图片对比工具 | Figma 级丝滑交互 | 专为 macOS 打造</b>
</p>

---

**DualView** 是一款专为摄影师、设计师和视觉工作者打造的 macOS 本地图片查看与对比工具。它解决了 macOS 原生预览工具在查看大图时的诸多痛点，提供了类似 Figma 的专业级交互体验，让图片对比变得前所未有的流畅。

## ✨ 核心痛点解决方案

*   🚀 **Figma 级交互体验**：告别原生预览的生硬，支持 **Ctrl + 滚轮缩放**、**空格/Ctrl 拖拽**，操作直觉与专业设计软件无缝衔接。
*   🖱️ **精准光标缩放**：彻底解决“放大后找不到原位置”的问题，缩放始终以鼠标光标为中心，指哪打哪。
*   ⚡ **双屏同步 (Sync Scroll)**：独创的双屏同步引擎。开启同步后，左右窗口的缩放和平移将保持像素级一致，是对比修图前后差异的神器。
*   🖼️ **高性能大图浏览**：基于 Flutter 渲染引擎，轻松驾驭高分辨率大图，拖拽平滑无卡顿。

## 🎮 操作指南

### 鼠标与触控板

| 操作 | 描述 |
| :--- | :--- |
| **滚轮滚动** | 以光标为中心缩放图片 (默认) |
| **空格 + 拖动** | 平移画布 (Figma 模式) |
| **Ctrl + 拖动** | 平移画布 (备用模式) |
| **直接拖动** | 亦支持直接拖动图片平移 |
| **拖入文件** | 支持直接将图片文件拖入左/右窗口打开 |

### 快捷键

| 按键 | 功能 |
| :--- | :--- |
| `Shift` + `1` | **适应屏幕 (Fit to Screen)** - 快速复位 |
| `Shift` + `0` | **100% 原大** - 查看像素细节 |
| `Double Click` | 双击图片快速复位 |

## 🛠️ 安装与运行

DualView 基于 Flutter 开发，目前支持 macOS 平台。

### 前置要求
*   macOS 环境
*   Flutter SDK (3.0+)

### 开发环境运行
```bash
# 1. 克隆仓库
git clone https://github.com/your-username/dualview.git

# 2. 安装依赖
flutter pub get

# 3. 运行 (macOS 桌面版)
flutter run -d macos
```

### 构建发布包
```bash
flutter build macos --release
```

## 📦 技术栈

*   **Flutter**: UI 框架与渲染引擎
*   **file_selector_macos**: 原生文件选择能力
*   **desktop_drop**: 桌面端拖拽支持
*   **Matrix4**: 复杂的矩阵变换与坐标映射算法

## 📄 License

MIT License. 欢迎 Fork 和提交 PR！
