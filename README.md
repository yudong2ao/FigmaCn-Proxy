# Figma 客户端汉化脚本与代理自启配置

本项目基于 [Mitmproxy](https://mitmproxy.org/) 实现，主要功能为：通过本地代理拦截 Figma 客户端的语言包请求并重定向至第三方中文语言包，同时实现了 Mitmproxy 的后台静默运行与开机自启。

## 原理说明
Figma 客户端在启动时会请求官方的英文语言包。本脚本通过本地代理拦截该请求，并返回 HTTP 307 重定向，将其指向第三方开源的 [Figma 中文语言包](https://kailous.github.io/figma-zh-CN-localized/lang/zh.json)。

## 脚本说明
- `figma_zh_cn.py`: 核心拦截逻辑脚本。
- `run_mitmdump.py`: Python 包装脚本，用于配置并启动 `mitmdump`（默认监听 `8089` 端口，并加载汉化脚本），防止后台运行崩溃。
- `MitmServer.vbs`: VBScript 脚本，用于在后台静默启动 Python 进程，避免出现命令提示符黑框。

## 安装与使用说明

### 1. 运行环境与依赖
请确保你的电脑上已安装 Python 3。然后使用 pip 安装 mitmproxy：
```bash
pip install mitmproxy
```

### 2. 生成与安装根证书
为了拦截 HTTPS 请求，你需要让 Mitmproxy 在本地生成信任证书并将其安装到系统中：
1. 打开命令提示符或 PowerShell，直接运行一次 `mitmdump` 命令（这会在你的用户目录 `~/.mitmproxy/` 下自动生成证书文件）。
2. 按 `Ctrl+C` 退出运行。
3. 进入 `C:\Users\你的用户名\.mitmproxy\` 文件夹。
4. 双击打开 `mitmproxy-ca-cert.p12` 文件开始安装证书。
5. 存储位置选择 **本地计算机**（或当前用户）。
6. 选择 **将所有的证书都放入下列存储**，点击“浏览”。
7. 选择 **受信任的根证书颁发机构**，一直点击下一步完成安装。

### 3. 配置 Figma 客户端代理
为了不影响系统的全局网络请求，建议直接通过快捷方式为 Figma 客户端单独设置代理参数。
- **不要修改官方默认快捷方式**：Figma 官方默认生成的快捷方式指向带有版本号的路径（如 `app-xxx\Figma.exe`）。客户端更新后路径失效会导致代理参数丢失。
- **配置步骤**：
  1. 找到 Figma 安装根目录下的主程序（通常默认安装在 `C:\Users\你的用户名\AppData\Local\Figma\Figma.exe`）。
  2. 右键该 `Figma.exe` 选择“发送到” -> “桌面快捷方式”。
  3. 在桌面上找到新创建的快捷方式，右键点击选择“属性”。
  4. 在“目标”一栏的末尾，加上一个空格以及代理参数：
     `--proxy-server=127.0.0.1:8089`
  5. 点击“确定”保存。
  6. 建议将此自定义快捷方式放入“开始菜单”替换原有官方快捷方式。

### 4. 启动与开机自启配置
- **测试运行**：直接双击项目目录下的 `MitmServer.vbs`，即可在后台静默启动代理服务（日志会输出到 `mitm_startup.log`）。
- **设置开机自启**：
  1. 右键点击 `MitmServer.vbs`，选择“创建快捷方式”。
  2. 按下 `Win + R` 键，输入 `shell:startup` 回车，打开系统的“启动”文件夹。
  3. 将该快捷方式放入“启动”文件夹，以后每次开机即可自动在后台静默运行。

### 5. 关闭代理服务
如需手动停止后台的代理服务：
- 打开 Windows 任务管理器（`Ctrl + Shift + Esc`）。
- 找到 `python.exe` 进程并“结束任务”。
- 或者在命令提示符中执行：`taskkill /f /im python.exe`。

## 致谢
感谢 [kailous](https://github.com/kailous) 提供的 Figma 汉化语言包。
