# vscode-custom-theme

一套基本与主题无关的 VS Code 桌面交互增强。它主要处理鼠标指针、文本命中范围和圆角交互细节，并为所有深色主题提供一致的交互配色，可与 Atom One、One Dark Pro、VSCode Vibrancy Continued 或其他主题共同使用。

[English README](README.md)

## 为什么做这个仓库

VS Code 明明是一款桌面应用，却在按钮、菜单、Tab 页和工具栏等大量位置沿用网页常见的手形指针。即使使用多年，这种表现依然不符合传统桌面软件的操作直觉。

编辑区也有一些细节不够精确：单击词语时的边框是直角；内置出现位置高亮会同时标出其他同词内容；全角与半角标点的词语边界也不总是一致。

本仓库只解决这些交互痛点，不重设语法配色，但会为所有深色主题统一编辑区和菜单的交互状态颜色。

## 功能

- 普通工作台控件使用默认箭头指针。
- 编辑文本保留 I 形指针；普通超链接、ARIA 链接、Monaco 链接、欢迎页 Start 启动入口以及 Ctrl+单击“转到定义”等真实导航仍使用手形指针。
- 单击词语时只框住光标所在的当前实例。
- 标点边界以 `editor.wordSeparators` 为唯一来源。仓库提供的配置包含常见半角、中文和全角标点，因此单击 `hello,你好吗` 或 `hello，你好吗` 中的 `hello`，都只会框住 `hello`。
- 当前词边框、文本选区和菜单悬停状态使用圆角。
- 所有深色主题统一使用当前词边框/底色、当前行底色、选区底色、菜单悬停底色，以及白色选中文字。
- 不包含 `workbench.colorCustomizations`、`editor.tokenColorCustomizations` 或主题自动切换配置。

## 文件说明

| 路径 | 用途 |
|---|---|
| `vscode-custom.css` | 工作台鼠标指针和圆角交互样式 |
| `settings-snippet.jsonc` | 词语边界、出现位置高亮和自定义菜单设置 |
| `extensions/local.editor-interactions-2.1.5/` | 按设置判断当前词边界和处理深色模式选区样式的扩展 |

## 安装

1. 克隆或下载本仓库。
2. 将 `settings-snippet.jsonc` 中的配置合并到 VS Code 用户 `settings.json`，不要覆盖完整设置文件。
3. 将 `extensions/local.editor-interactions-2.1.5` 复制到 `%USERPROFILE%\.vscode\extensions\`。
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
- 深色主题统一使用：当前词边框 `#4399F9`、当前词内部底色 `#033E5D`、当前行底色 `#2B2D30`、选区底色 `#214283`、菜单悬停底色 `#2A4371`，选中文字为白色；浅色主题继续使用自身的交互配色。
- 当前词的标点边界完全取自 `editor.wordSeparators`，空白仍是天然边界。是否用 `_`、`$` 等字符切分词语，可直接通过该设置决定。
- `editor.occurrencesHighlight: "off"` 会关闭其他同词位置的自动高亮，这是实现“只框当前词”的一部分。
