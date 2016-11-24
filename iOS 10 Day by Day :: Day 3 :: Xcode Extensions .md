# iOS 10 Day by Day // Day 3 // Xcode Extensions 

[原文出处](https://www.shinobicontrols.com/blog/ios-10-day-by-day-day-3-xcode-source-editor-extensions)

本文介绍了Xcode8的新特性 - 源代码文本编辑器扩展（xcode-source-editor-extensions）

##介绍
爱它或恨它，Xcode是苹果开发的一个重要组成部分（我大部分时间在“爱”她的阵营中）。由于许多开发者抱怨缺乏支持的插件。扩展内置功能允许开发者添加他们自己的功能，如执行拼写检查或转换所有UIColor的变量变成新的色彩文字。


由于Xcode中没有这个能力，[Alcatraz](http://alcatraz.io) 填补了空白，成为事实上的插件管理器。虽然他们起到了巨大的作用，但是由于Xcode编辑功能插件开发比较困难，所以开发插件一般都不得不使用一些稍微肮脏的把戏（苹果不认可的私有API之类的）。由于涉及安全性和稳定性，这些插件在Xcode8上不再提供功能.不过，值得庆幸的是，苹果加入了对扩展Xcode的全新的源代码编辑器的扩展（Source Editor Extensions），并对他提供一流的支持。


##Project


我们构建的DEMO扩展实现了 	替换ASCII字符为Emoji表情的功能。例如 “That’s a nice thing to say :)" 将转化为 “That’s a nice thing to say 😃”。与往常一样，该代码可在[Github](https://github.com/kengsir/iOS10-day-by-day)上下载到，先上效果图：

![1](https://www.shinobicontrols.com/wp-content/uploads/2016/08/Emojificator.gif)

Like we saw in Day 1 when creating an iMessage App, Apple is heavily utilizing its Extensions infrastructure and Xcode Extensions are no different. You can ship an entire app with the extensions included (via the Mac App Store, for example) or sign and distribute the extension yourself. At first, an entire application for a few extensions may seem like overkill, however it serves as a handy location for configuration options; Xcode provides no UI apart from a menu item to run a command.

就像我们在第1天创建的iMessage App时看到，现在苹果的越来越多的新功能都是基于extension（扩展）来做的。我们可以将使用xcode-source-editor-extensions制作的插件上传到 Mac App Store 销售。但扩展提供的UI比较简单，仅有在 Xcode 的 Editor 菜单里面给你的插件生成一个子菜单，用于调用插件。

在开始之前，我们将创建一个新的MacOS项目，将其命名为Emojificate。我们可以忽略与Mac App有关的文件，专注于扩展的开发上面。

我们需要为Xcode扩展添加一个新的 target，新的Xcode扩展选项设置非常简单（如下图所示）。我们需要给个唯一的名称，我把它命名为Emojificator_Extension。


![2](https://www.shinobicontrols.com/wp-content/uploads/2016/08/Project_Name.png)

Xcode will set us up with everything we need to get going.

##Info.plist

To alter the displayed name of the extension, set the Bundle name key to the name of your choice – I went for Emojificator.


![3](https://www.shinobicontrols.com/wp-content/uploads/2016/08/MenuItem.png)

和其他扩展一样，可以在Info.plist里定义扩展的属性。
例如：扩展的类型（Xcode.extension.source-editor）;
扩展的入口类（XCSourceEditorExtension）

您的扩展可以包含任意数量的命令，将出现在的plist文件中指定的顺序。本文介绍的情况是我们只执行一条命令，定义在实现了XCSourceEditorCommand这个协议的类EmojificatorCommand中。

使用XCSourceEditorCommandClassName（如下图所示）这个key来确定Xcode中哪个类会执行命令。

一个类可以执行多条命令，不局限于只执行一条命令。如果需要在不同的类之间共享代码的话，可以使用XCSourceEditorCommandIdentifier（如下图所示）这个key来区分不同的命令。

最后，最简单的，是命令的名字。（出现菜单项的名称）在我们的例子中，我们设置为“Emojificate！”作为XCSourceEditorCommandName键的值。

![4](https://www.shinobicontrols.com/wp-content/uploads/2016/08/Extension_Attributes_Plist.png)

##SourceEditorExtension.swift

这个类扩展的入口点和这个类必须继承XCSourceEditorExtension协议。我们已经在Info.plist中做了一些初始化的操作，所以在这里就不需要再做什么操作了。你也可以在可选方法extensionDidFinishLaunching中做插件的生命周期管理或者对 Command 进行动态配置。

Xcode launches your extension at start up, way before a command is actually invoked. This is done to make executing a command as instantaneous as possible.

当Xcode一启动就会启动插件，实际上就做了一些初始化的操作（调用命令）。
这样做是为了尽可能快的执行命令。

如果你的命令可以动态生成，例如需要做成那种可以在主程序界面提供给用户配置选项的，可以在这个类中重写plist文件定义的命令。 比如下面的代码：


```
var commandDefinitions: [[XCSourceEditorCommandDefinitionKey: AnyObject]] {
    // If your extension needs to return a collection of command definitions that differs from those in its Info.plist, implement this optional property getter.
    return [[
        .classNameKey : "Emojificator_Extension.EmojificateCommand",
        .identifierKey : "com.shinobicontrols.Emojificator_Extension.EmojificateCommand",
        .nameKey : "Emojificate!"
    ]]
}
```


##EmojificatorCommand.swift

By default, Xcode will create a class named SourceEditorCommand, however I’ve renamed it to the slightly more descriptive EmojificateCommand. This is where the logic for our command will reside. It must conform to the XCSourceEditorCommand protocol.

For this example, we’ll define the mapping between the ASCII smileys and their Emoji counterparts. We’ll just pick a selection of them:


默认情况下，Xcode会创建一个名为SourceEditorCommand的类，我们把她重命名为EmojificateCommand,这个名称更贴合我们的项目。这个类里面写了我们处理命令的逻辑。这个类是要遵循XCSourceEditorCommand协议的。

下面的代码举了一个例子，定义了一些ASCII化的表情符号和他们对应的Emoji表情。

```
let asciiToEmojiMap = [
        ":)" : "😃",
        ";)" : "😉",
        ":(" : "😞"]
```

To replace the ASCII items with Emoji, we need two methods:
以下两个方法处理替换ASCII字符成Emoji表情的逻辑。


```extension EmojificateCommand {

    /// Returns whether the string contains an item that can be converted into emoji
    func replaceableItemsExist(in string: String) -> Bool {
        for asciiItem in asciiToEmojiMap.keys {
            if string.contains(asciiItem) {
                return true
            }
        }
        return false
    }

    /// Replaces any ASCII items with their emoji counterparts and returns the newly 'emojified' string
    func replaceASCIIWithEmoji(in string: String) -> String {
        var line = string
        for asciiItem in asciiToEmojiMap.keys {
            line = line.replacingOccurrences(of: asciiItem, with: asciiToEmojiMap[asciiItem]!)
        }
        return line
    }
}
```

Finally, we need to implement the perform(with: completionHandler:) method which will be invoked when the command is executed from within Xcode.

最后，我们需要实现 perform(with: completionHandler:) 方法。附：当我们的插件开始执行命令的时候，就会调用这个方法执行操作。



```func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: (Error?) -> Void) {
    let lines = invocation.buffer.lines

    for (index, line) in lines.enumerated() {
       if let line = line as? String,
           replaceableItemsExist(in: line) {
           lines[index] = replaceASCIIWithEmoji(in: line)
       }
    }

    // Command must perform completion to signify it has completed
    completionHandler(nil)
}

```

The invocation object contains an instance of XCSourceTextBuffer, which describes the contents of the file the command has been invoked on, such as whether it’s a Swift file or an Objective-C header and the number of spaces represented by a tab. We’re interested in modifying the text contents of the buffer. We could use completeBuffer which is a string representation of the buffer or the lines mutable array. Apple recommends modifying the contents of the array if your command is simply altering a few characters here and there, as it’s more performant due to Xcode being able to track just the changed contents of the buffer.

To inform Xcode that the command has finished executing, we call the completion handler.

>Xcode Extensions are run in a separate process to Xcode. This is great news, as it means slow running commands should not result in any noticeable slowdown in Xcode’s performance. One thing to note is Xcode is quite strict in how long your command has to execute. If it has not completed within a few seconds, your execution will be “named and shamed” and the user has the option to cancel the command.


##Running the “Emojificate” command
Here’s a bit of Xcode-ception for you: to test our command, we’ll run our extension in a test version of Xcode. The test version icon is a gray color which helps to differentiate it from our development version.

最后把插件编译运行到 Xcode 8 上面，会出现一个被调试的 Xcode，是黑色的。

![pic](https://www.shinobicontrols.com/wp-content/uploads/2016/08/Grey_Icon.png)

![4](https://www.shinobicontrols.com/wp-content/uploads/2016/08/Run_In_Xcode.png)

然后随便找个项目跑起来测试效果。最终实现效果：

![5](https://www.shinobicontrols.com/wp-content/uploads/2016/08/Emojificator.gif)

