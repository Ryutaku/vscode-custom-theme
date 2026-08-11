# vscode-custom-theme

一套基本与主题无关的 VS Code 桌面交互增强。它主要处理鼠标指针、文本命中范围和圆角交互细节，仅在深色模式下把选中文字设为白色以保持清晰对比，可与 Atom One、VSCode Vibrancy Continued 或其他任意主题共同使用。

[English README](README.md)

## 为什么做这个仓库

VS Code 明明是一款桌面应用，却在按钮、菜单、Tab 页和工具栏等大量位置沿用网页常见的手形指针。即使使用多年，这种表现依然不符合传统桌面软件的操作直觉。

编辑区也有一些细节不够精确：单击词语时的边框是直角；内置出现位置高亮会同时标出其他同词内容；中文全角冒号 `：` 默认又不一定符合期望的词语边界。

本仓库只解决这些交互痛点，不再重设主题配色体系；唯一的颜色例外是深色模式下的白色选中文字。

## 功能

- 普通工作台控件使用默认箭头指针。
- 编辑文本保留 I 形指针；普通超链接、ARIA 链接、Monaco 链接、欢迎页 Start 启动入口以及 Ctrl+单击“转到定义”等真实导航仍使用手形指针。
- 单击词语时只框住光标所在的当前实例。
- 中文全角冒号 `：` 被识别为词语分隔符，例如单击 `账号密码：root` 中的 `root` 不会框住前半段。
- 当前词边框、文本选区和菜单悬停状态使用圆角。
- 深色主题下的选中文字强制为白色；选区背景、菜单、光标和边框颜色仍继承当前 VS Code 主题。
- 不包含 `workbench.colorCustomizations`、`editor.tokenColorCustomizations` 或主题自动切换配置。

## 文件说明

| 路径 | 用途 |
|---|---|
| `vscode-custom.css` | 工作台鼠标指针和圆角交互样式 |
| `settings-snippet.jsonc` | 词语边界、出现位置高亮和自定义菜单设置 |
| `extensions/local.editor-interactions-2.1.0/` | 精确当前词边框和深色模式白色选中文字的本地扩展 |

## 安装

1. 克隆或下载本仓库。
2. 将 `settings-snippet.jsonc` 中的配置合并到 VS Code 用户 `settings.json`，不要覆盖完整设置文件。
3. 将 `extensions/local.editor-interactions-2.1.0` 复制到 `%USERPROFILE%\.vscode\extensions\`。
4. 选择一种 CSS 加载方式。

### 使用 VSCode Vibrancy Continued 加载

在 `settings.json` 中加入：

```jsonc
"vscode_vibrancy.imports": [
    "D:/path/to/vscode-custom-theme/vscode-custom.css"
]
```

执行 **Reload Vibrancy**，彻底退出并重新启动 VS Code。

### 使用 Custom CSS and JS Loader 加载

在 `settings.json` 中加入：

```jsonc
"vscode_custom_css.imports": [
    "file:///D:/path/to/vscode-custom-theme/vscode-custom.css"
],
"vscode_custom_css.policy": true
```

执行 **Enable Custom CSS and JS** 或 **Reload Custom CSS and JS**，然后执行 **Developer: Reload Window**。

只选择一种加载方式，避免同一份 CSS 被重复注入。

## VS Code 升级

VS Code 升级可能覆盖 CSS 加载器或 Vibrancy 写入的工作台文件，但不会影响仓库源文件。升级后重新执行对应加载器的 Reload 命令并重启 VS Code。

自定义 CSS 依赖 VS Code 工作台 DOM；如果未来大版本调整界面结构，部分选择器可能需要同步更新。

## 说明

- 本仓库不指定或安装任何配色主题。
- 本地扩展使用当前主题的 `editor.wordHighlightBorder` 绘制当前词边框，并只在深色/高对比深色模式为实际选区添加白色文字装饰。
- `editor.occurrencesHighlight: "off"` 会关闭其他同词位置的自动高亮，这是实现“只框当前词”的一部分。
