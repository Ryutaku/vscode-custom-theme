# vscode-custom-theme

一套可复用的 VS Code Atom One Dark / Atom One Light 双主题定制，包含主题独立配色、圆角菜单状态、桌面式鼠标指针、随主题变化的选区文字，以及精确的当前词语边框。

[English README](README.md)

## 功能

- Atom One Dark 保留原有蓝色体系。
- Atom One Light 使用绿色界面色，编辑区选区和光标使用深黄色。
- 菜单悬停项使用圆角背景，父菜单不会错误地给整个子菜单着色。
- 两套主题下的编辑区选中文字均为纯白色。
- 单击词语时只框住当前词；中文全角冒号 `：` 会被正确识别为词语边界。
- 编辑区文字保持 I 形光标，普通工作台控件使用默认箭头。
- Dark 与 Light 配置可以共存，也可以跟随 Windows 深浅色模式自动切换。

## 效果截图

### Atom One Dark

| 编辑器整体效果 | 圆角菜单悬停效果 |
|---|---|
| ![Atom One Dark 编辑器整体效果](images/dark-overview.png) | ![Atom One Dark 圆角菜单悬停效果](images/dark-menu.png) |

| 文本选区 | 当前词语边框 |
|---|---|
| ![Atom One Dark 文本选区](images/dark-editor-selection.png) | ![Atom One Dark 当前词语边框](images/dark-word-border.png) |

### Atom One Light

| 圆角菜单悬停效果 | 编辑器选区 |
|---|---|
| ![Atom One Light 圆角菜单悬停效果](images/light-menu.png) | ![Atom One Light 编辑器选区](images/light-editor-selection.png) |

| 选区细节 | 当前词语边框 |
|---|---|
| ![Atom One Light 选区细节](images/light-selection-detail.png) | ![Atom One Light 当前词语边框](images/light-word-border.png) |

## 文件说明

| 路径 | 用途 |
|---|---|
| `vscode-custom.css` | 工作台鼠标指针、菜单、圆角和编辑区视觉样式 |
| `settings-snippet.jsonc` | 需要合并进 VS Code 用户设置的主题配置片段 |
| `extensions/local.selection-white-1.2.1/` | 实现主题感知选区文字和精确当前词边框的本地扩展 |

## 安装

1. 安装 [Atom One Dark Theme](https://marketplace.visualstudio.com/items?itemName=akamud.vscode-theme-onedark)、[Atom One Light Theme](https://marketplace.visualstudio.com/items?itemName=akamud.vscode-theme-onelight) 和 [Custom CSS and JS Loader](https://marketplace.visualstudio.com/items?itemName=be5invis.vscode-custom-css)。
2. 克隆或下载本仓库。
3. 将 `settings-snippet.jsonc` 中的配置合并到 VS Code 用户 `settings.json`，不要覆盖完整设置文件。
4. 把 `vscode_custom_css.imports` 改为本机 `vscode-custom.css` 的绝对 `file:///` URL。
5. 将 `extensions/local.selection-white-1.2.1` 复制到 `%USERPROFILE%\.vscode\extensions\`。
6. 在命令面板执行 **Enable Custom CSS and JS** 或 **Reload Custom CSS and JS**。
7. 执行 **Developer: Reload Window**。

## 配色

| 场景 | Atom One Dark | Atom One Light |
|---|---:|---:|
| 主色 | `#0078D4` | `#198754` |
| 菜单悬停 | `#2B50AA` | `#D1E7DD` |
| 编辑区选区 | `#2B50AA` | `#E09D00` |
| 光标与当前词边框 | `#0078D4` | `#E09D00` |

## VS Code 升级

VS Code 升级会覆盖生成的 `workbench.html`，但不会影响本仓库中的源文件。升级后重新执行 **Reload Custom CSS and JS**，然后重启 VS Code 即可。

自定义 CSS 依赖 VS Code 工作台 DOM；如果未来大版本调整界面结构，部分选择器可能需要同步更新。

## 说明

- `settings-snippet.jsonc` 只包含本次定制相关设置，已排除账号、密码、许可证、服务器地址和命令历史等私人信息。
- 本地扩展会关闭内置的符号出现位置高亮，并依据 `editor.wordSeparators` 绘制精确的当前词边框。
