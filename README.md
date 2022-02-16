# XcodeBugFix
Fixed Xcode13 No Respond When Editing

解决 Xcode13 的卡顿问题

本插件根据 [Xcode-Plugin-Template](https://github.com/doge1024/Xcode-Plugin-Template) 模板开发

# Installation

1. 打开 `钥匙串访问` app
2. 打开 钥匙串访问/证书助理/创建证书...
3. 创建一个名为 `XcodeSigner` ，证书类型为 `代码签名` 的根证书
4. 执行 `sudo codesign -f -s XcodeSigner /Applications/Xcode.app` 将 Xcode 重新签名 （过程较长，中间会提示输入密码）
5. 执行 `mkdir -p ~/Library/Application\ Support/Developer/Shared/Xcode/Plug-ins` 创建插件目录
6. 然后下载最新的release包，解压放到第5步的Plug-ins文件夹中，重启 Xcode ，会有弹窗提示点击 `Load bundle` 就可以体验到流畅的编辑体验了
7. 如果想要关闭，Edit菜单下有个按钮`切换XcodeBugFix开关`，点击切换状态，（0/1表示关闭/开启）

# Notes

如果你想自己解决问题，向项目贡献代码：
1. 按照上面的步骤，将 Xcode 重新签名
2. 下载本项目，直接运行，系统会再启动一个Xcode，并可以打断点，方便你调试解决问题
3. ❤️如果有用，Star一下⭐️ 
