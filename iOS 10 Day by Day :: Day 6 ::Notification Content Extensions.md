##【iOS 10 day by day】Day6: 自定义的通知界面

原文出处：[https://www.shinobicontrols.com/blog/ios-10-day-by-day-day-6-notification-content-extensions](https://www.shinobicontrols.com/blog/ios-10-day-by-day-day-6-notification-content-extensions)


##目录
- 1、示例工程
- 2、创建Extension
- 3、把 Extension 与通知 category 关联起来，建立通知框架
- 4、自定义的通知界面
- 5、接受用户的操作


上篇简单介绍了 UserNotifications 这个新的通知框架。新框架可以统一处理本地通知和远程推送，同时增加了一些新 API 来控制等待中和已发出的通知。

本次介绍一个新的通知框架：UserNotificationsUI。本框架的功能可以自定义通知界面，这个框架的 API 非常简单，只含有一个公共的 protocol：UNNotificationContentExtension 

## 工程
效果图如下：

![](http://upload-images.jianshu.io/upload_images/227290-0c09d911ff05670f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

源码地址：
[https://github.com/kengsir/iOS10-day-by-day](https://github.com/kengsir/iOS10-day-by-day)


## 创建 Extension

首先，我们要给闹钟 app 的工程加一个新的 target。在下面这个选择 target 模板的界面，选择 Notification Content。命名为：NagMeContentExtension

![](http://upload-images.jianshu.io/upload_images/227290-457495502483a4e0.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

除了默认的Info.plist之外，这个 extension 还包含另外两个文件：

1、MainInterface.storyboard : 把自定义通知界面的 UI 画在这里

2、NotificationViewController.swift : 一个 UIViewController 的子类，这就是自定义界面的 ViewController，通过这个类来管理自定义的界面。

## 把 Extension 与通知 category 关联起来

默认的通知界面如下图：

![](http://ww1.sinaimg.cn/mw690/6f5f9fe7gw1fa3c2m88e2j20af0j5wes.jpg)

我们需要让系统知道，是哪个通知要展示这个界面。一个 category 就是一个简单的对象（参考 [UNNotificationCategory](https://developer.apple.com/reference/usernotifications/unnotificationcategory)）,里面定义了app支持哪些类型的通知，以及每种通知关联了什么操作--就是用户把通知展开的时候，通知下面出现的那些操作按钮。

实现这一步，需要打开 extension 的 Info.plist，展开 NSExtensionAttributes Dictionary，把下面 UNNotificationExtensionCategory 这个键对应的值改为通知 category 的名字("reminder")。注意，这个值既可以填一个 string ，也可以填一个 string 数组，如果想让多个通知 category 共用一个 extension 界面就可以填 string 数组。

![](http://upload-images.jianshu.io/upload_images/227290-9b24c7f12530f35a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

build、run 一下：

![](http://upload-images.jianshu.io/upload_images/227290-a353d8b38a265c5d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

现在用的是 extension 默认的 MainInterface.storyboard 界面，然后是 NotificationViewController 里的模板代码在更新界面上的 label。不过这个界面还是有几点需要改进的地方。首先，通知的内容（"Walk Dog!!"）在 extension 的界面上和 DefaultContent 区域重复出现了两次。我们先把这个重复的去掉吧！



## 去掉 DefaultContent

DefaultContent 显示在哪里：

![](http://upload-images.jianshu.io/upload_images/227290-92ea97efc85da478.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

很简单，只需在 Info.plist 文件里的 NSExtensionAttributes 下面增加一个 key ，UNNotificationExtensionDefaultContentHidden，然后值设为 YES，就不会显示 DefaultContent 了。


## 自定义的通知界面

>NotificationViewController 就是一个单纯的 UIViewController 的子类，用起来跟你平常在主 app 里用普通的 viewController 是一样的。唯一的不同点在于它的 userInteraction 是 disabled 的，意思是完全无法接收到用户的点击、触摸事件。所以有部分控件是用不了的，比如 UIScrollView、UIButton 等。

切换到 MainInterface.storyboard，加上 UI 控件。加一个 label 描述提醒的事项，加一个小喇叭的图片。加完之后，只需拖几个 IBOutlets 出来，就大功告成啦！

收到通知的时候，我们要更新 label 上的文本，同时摇晃小喇叭的图片——用这种粗暴的方式吸引用户的注意力。要实现这些功能，需要在 NotificationViewController 里进行一些修改。我们的 viewController 实现了 UNNotificationContentExtension 这个 protocol，下面用到的就是这个 protocol 中定义的方法：



```
func didReceive(_ notification: UNNotification) {
  label.text = "Reminder: \(notification.request.content.body)"
  speakerLabel.shake() // 具体实现下载源码可以看到
}

```

![](http://upload-images.jianshu.io/upload_images/227290-c6a3ef31d3366d9c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)



## 接受用户的操作
有一点要改进：点击 “Cancel” 按钮，只会让用户切回到闹钟 app，这一步有点多余。

在上一篇文章我们讲了怎么给通知加上操作按钮：通知出现时可以进行的每一项操作都是一个 UNNotificationAction，关联在通知 category 上。更详细的介绍可以参考官方文档。

而 UNNotificationContentExtension 这个 protocol 提供了另一个处理点击事件的方法：didReceive(_:completionHandler:)。我们就用这个方法，把小喇叭的 icon 改成红线划掉的小喇叭，然后把通知从 UNNotificationCenter 中移除。

文／戴仓薯（简书作者）
原文链接：http://www.jianshu.com/p/001a5ab81808
著作权归作者所有，转载请联系作者获得授权，并标注“简书作者”。


```
func didReceive(_ response: UNNotificationResponse,
                completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {

  if response.actionIdentifier == "cancel" {
    let request = response.notification.request

    let identifiers = [request.identifier]

    // 移除后续的通知
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)

    // 移除之前的通知，不在用户的通知列表里占地方了
    UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: identifiers)

    // 通知取消的视觉反馈
    speakerLabel.text = "🔇" 
    speakerLabel.cancelShake()

    completion(.doNotDismiss)
  }
  else {
    completion(.dismiss)
  }
}
```

相关的通知都移除了，UI 也更新了，接下来我们需要告诉系统该怎么处置这个通知界面。因为我们想让用户看到被划掉的小喇叭，得到通知被取消的视觉反馈，所以要把通知留在屏幕上，因此回调里传入 UNNotificationContentExtensionResponseOption 的一个取值 .doNotDismiss。



![](http://upload-images.jianshu.io/upload_images/227290-8ceac0cb657dfe5d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

>既然要用这个方法处理点击，就得处理好每一个按钮事件。在这个例子里，我们只有一个“Cancel”按钮。然而，如果还有别的按钮，它们的点击事件也需要处理好：要么也在 extension 工程的这个方法里处理，要么回调传 UNNotificationContentExtensionResponseOption.dismissAndForwardAction，传给主 app 去处理。

