## 通过全局热键来控制 ffmpeg 录屏
  - 由于自己想学习 `blender` ,但是通过大量文字笔记去记录操作，笔记这一项工作变得十分繁琐，且不直观。所以我写了一个录屏完成并转成 Webp 动图格式来做操作记录。
  - 由于设计成一个不需要鼠标就可以录屏的单文件应用，所以它的图片储存路径与视频录制路径为固定，想适配自己的路径储存，这个就自己修改源码，自己编译
  - 多次使用生成了图片名会以 `000000.webp` 的次数增长，
  - 由于 Rust 编译成单文件应用，所以在 `Windows 10` 上固定到开始屏幕，就可以通过 `Win + s` 搜索 capturescreen （或者你自己取文件名） 来直接运行，默认运行将会直接录屏，`F9` （前提f9不会被当前应用响应，（这个情况很少）） 将会停止录屏，并会在稍后几秒内转成 Webp 动图。
  - 录屏时使用 `Carnac` 这样的按键记录显示软件会更好



## 想法延伸： 在转成成 webp 的时候对 Windows Explorer 的分组功能做了一个探索
    - 通过下面显示 `备注` 的值可做分组依据

|||
| -- | -- |
|<img src="./img/下载.png">|<img src="./img/下载 (1).png">|

  - Conclusion
    - 核心
      - [Use PowerShell to edit a file's metadata (Details tab of a file in Windows file explorer)](https://stackoverflow.com/questions/64597009/use-powershell-to-edit-a-files-metadata-details-tab-of-a-file-in-windows-file)
      - [pscon.py](https://github.com/SublimeText/Pywin32/blob/master/lib/x64/win32comext/propsys/pscon.py)
      - [PyIPropertyStore.cpp](https://github.com/mhammond/pywin32/blob/master/com/win32comext/propsys/src/PyIPropertyStore.cpp)
      - [Reading and writing Windows “tags” with Python 3](https://stackoverflow.com/questions/61713787/reading-and-writing-windows-tags-with-python-3)
      - [Guide to editing file metadata using PowerShell](https://abdus.dev/posts/powershell-file-metadata-guide/)
    - 添加新的扩展文件属性
      - [Add-ExtendedFileProperties.ps1](https://resources.oreilly.com/examples/9780596528492/blob/master/Add-ExtendedFileProperties.ps1)
    - linux mac,(未细探索)
      - [xattr](https://github.com/xattr/xattr)
    
  - Reference
    - [taglib-sharp](https://github.com/mono/taglib-sharp)
    - [TagLib Audio Meta-Data Library](https://taglib.org/)
    - [itext7-dotnet](https://github.com/itext/itext7-dotnet) (pdf)





































