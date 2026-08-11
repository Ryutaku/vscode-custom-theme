# vscode-custom-theme

一套可复用的 VS Code Atom One Dark / Atom One Light 双主题定制，包含按主题分别配置的配色、圆角菜单悬停状态、桌面式鼠标指针、按主题作用域设置的选中文字颜色、精确的当前词语边框，以及 Windows 下可选的原生 Mica / Acrylic 窗口材质。

[English README](README.md)

## 为什么做这个仓库

这个仓库源于我在长期使用 VS Code 过程中一直没有适应的两类体验问题。

### 1. 桌面应用大量沿用了 Web 页面的鼠标指针习惯

VS Code 明明是一款桌面应用，却在按钮、菜单、Tab 页、工具栏操作等大量位置沿用了 Web 页面的交互习惯：鼠标悬停时显示手形指针。这种表现始终让我觉得不符合桌面软件的操作直觉。即使已经使用 VS Code 十来年，我依然没有习惯。

这套配置把普通工作台控件统一恢复为箭头指针；编辑区文字仍保留 I 形光标，Ctrl+单击“转到定义”等真正具有导航含义的交互也继续保留手形指针。

### 2. 喜欢 Atom One Dark / Light，但交互细节仍有不足

Atom One Dark 和 Atom One Light 是我比较喜欢的两款主题配色，但编辑区域的一些状态细节仍不够理想。例如，鼠标单击某个词时出现的是直角边框，与 VS Code 整体逐渐采用的圆角视觉风格不协调；文本选中、焦点和当前词高亮之间的边界也不够清晰，容易影响对“究竟选中了什么”的判断。

这个仓库针对这些细节进行了调整：当前词边框改为圆角，选区背景和选中文字更加清晰，并分别为 Dark / Light 主题整理了更一致的菜单、焦点、光标和高亮配色。

这些修改带有明确的个人使用偏好，并不意味着适合所有人。欢迎大家实际试用，在日常操作中自行体会，也可以按自己的习惯继续调整。

## 功能

- Atom One Dark 保留主题本身的蓝色基调，同时让交互状态更清晰。
- Atom One Light 使用绿色界面色，编辑区选区和光标使用深黄色。
- 菜单悬停项使用圆角背景，父菜单不会错误地给整个子菜单着色。
- 两套主题下的编辑区选中文字均为纯白色。
- 单击词语时只框住当前实例，并关闭 VS Code 对其他同词位置的内置自动高亮；中文全角冒号 `：` 会被正确识别为词语边界。
- 编辑区文字保持 I 形光标，普通工作台控件使用默认箭头；Ctrl+单击“转到定义”等真正的导航操作仍保留手形指针。
- Dark 与 Light 配置可以共存，也可以跟随 Windows 深浅色模式自动切换。
- Windows 11 可以通过可恢复脚本，在半透明 Atom One 界面背后启用原生 Mica 或 Acrylic 材质。

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
| `scripts/vscode-material.ps1` | 启用、切换、查看或关闭 Windows 原生背景材质 |
| `tests/vscode-material.Tests.ps1` | 验证各材质模式能够准确应用并完整撤销 |

## 安装

1. 安装 [Atom One Dark Theme](https://marketplace.visualstudio.com/items?itemName=akamud.vscode-theme-onedark)、[Atom One Light Theme](https://marketplace.visualstudio.com/items?itemName=akamud.vscode-theme-onelight) 和 [Custom CSS and JS Loader](https://marketplace.visualstudio.com/items?itemName=be5invis.vscode-custom-css)。
2. 克隆或下载本仓库。
3. 将 `settings-snippet.jsonc` 中的配置合并到 VS Code 用户 `settings.json`，不要覆盖完整设置文件。
4. 把 `vscode_custom_css.imports` 改为本机 `vscode-custom.css` 的绝对 `file:///` URL。
5. 将 `extensions/local.selection-white-1.2.1` 复制到 `%USERPROFILE%\.vscode\extensions\`。
6. 在命令面板执行 **Enable Custom CSS and JS** 或 **Reload Custom CSS and JS**。
7. 执行 **Developer: Reload Window**。

## Windows Mica 与 Acrylic

材质层是面向 Windows 11 的可选功能。VS Code 目前没有把 Electron 的原生背景材质开放成设置项，因此脚本会在当前安装版本的 `out/main.js` 中加入两处带有明确标记的小修改：启用所选材质和 Chromium Alpha 通道、移除 VS Code 自己的不透明启动背景色，并阻止主题服务在工作台加载完成后再次用实色盖住材质。脚本会在原文件旁创建安全备份；正常关闭材质时只删除本仓库加入的代码，不会整份恢复备份，因此不会覆盖其他修改。

在本仓库目录中打开 PowerShell，然后选择需要的模式：

```powershell
# 类似 Windows Terminal 的半透明模糊效果
powershell -ExecutionPolicy Bypass -File .\scripts\vscode-material.ps1 acrylic

# 更安静、稳定的全窗口材质
powershell -ExecutionPolicy Bypass -File .\scripts\vscode-material.ps1 mica

# 查看状态，或者只删除本仓库加入的补丁
powershell -ExecutionPolicy Bypass -File .\scripts\vscode-material.ps1 status
powershell -ExecutionPolicy Bypass -File .\scripts\vscode-material.ps1 disable
```

切换模式后需要彻底退出并重新打开所有 VS Code 窗口。如果安装目录受保护，请用管理员身份运行 PowerShell。如果未来 VS Code 不再包含脚本预期的唯一窗口创建位置，脚本会安全停止，不会猜测性修改程序文件。

脚本还接受 Electron 的 `tabbed` 和 `auto` 材质模式。透明度集中定义在 `vscode-custom.css` 末尾的 `Windows Mica / Acrylic material layer` 区域，便于自行微调。

## 配色

| 场景 | Atom One Dark | Atom One Light |
|---|---:|---:|
| 主色 | `#0078D4` | `#198754` |
| 菜单悬停 | `#2B50AA` | `#D1E7DD` |
| 编辑区选区 | `#2B50AA` | `#E09D00` |
| 光标与当前词边框 | `#0078D4` | `#E09D00` |

## VS Code 升级

VS Code 升级会覆盖生成的 `workbench.html`，并安装新的 `out/main.js`，但不会影响本仓库中的源文件。升级后需要：

1. 重新执行 **Reload Custom CSS and JS**。
2. 再运行一次 `scripts/vscode-material.ps1 acrylic`，或换成你使用的其他材质。
3. 彻底重启 VS Code。

自定义 CSS 依赖 VS Code 工作台 DOM；如果未来大版本调整界面结构，部分选择器可能需要同步更新。

原生材质补丁不是 VS Code 官方设置。它被设计得尽量小且可恢复，但未来 Electron 或 VS Code 发生变化时，脚本仍可能需要同步调整。

## 说明

- `settings-snippet.jsonc` 只包含本次定制相关设置，已排除账号、密码、许可证、服务器地址和命令历史等私人信息。
- 本地扩展会关闭内置的符号出现位置高亮，并依据 `editor.wordSeparators` 绘制精确的当前词边框。
