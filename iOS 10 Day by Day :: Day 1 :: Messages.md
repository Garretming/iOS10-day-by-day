# iOS 10 Day by Day :: Day 1 :: Messages
文章介绍了如何开发一个 iOS 10 
Messages 的插件（extension）

原文出处：https://www.shinobicontrols.com/blog/ios-10-day-by-day-day-1-messages


###Messages 是 iOS10 中一个巨大的更新。很可能这是在努力抢回 Facebook Messenger，微信和 Snapchat 所占的市场份额。



###Messages 其中一个新功能就是第三方开发者拥有在Messages程序内创建自己的 message extensions 的能力。这些都是建立在iOS8中引入的扩展技术。[Sam Davies](https://www.shinobicontrols.com/blog/ios8-day-by-day-day-2-sharing-extension) 这个博客介绍了这项技术。有关 message extensions 的好处是,你的扩展可以自身存在而不必被捆绑作为父应用程序的一部分。当 iOS10 今年晚些时候发布时，将提供给用户一个专用的 Messages 应用程序商店。



**为了证明这个令人振奋的新的扩展类型，我们就来看看一个项目，允许两个玩家玩的热门游戏：战舰。为了简单起见，游戏的布局保持简单。如果您想下载的项目，[GitHub地址](https://github.com/shinobicontrols/iOS10-day-by-day/tree/master/01%20-%20Messages)，github项目运行在 Xcode8 GM 版本**



![Smaller icon](https://www.shinobicontrols.com/wp-content/uploads/2016/07/App_Demo.gif
), 

#### 游戏规则，如上图所示

* 玩家 A 发起游戏，在棋盘上布置两个『战舰』，然后隐藏起来
* 另一个玩家 B 要猜测战舰的位置
* 如果猜中了两艘隐藏战舰的位置，玩家 B 就赢了；但是如果猜错 3 次，玩家 B 就输了。




###Creating the Project，开始码代码

Xcode 提供了简易的方法让我们创建 extension. 

Simply click File -> New Project and then select the iMessage Application template.

![Smaller icon](https://www.shinobicontrols.com/wp-content/uploads/2016/07/Create_Project.png)

Aside from naming our project and ensuring the language was set to Swift, that’s pretty much all we need to do. The Messages app will automatically recognize our extension when we run the project thanks to the auto-generated MessagesExtension target and the associated Info.plist which declares all we need to get started (the storyboard that defines the interface of the extension and the type of extension we’re building).

给工程起个名字，然后语言选择 Swift（本系列均使用 Swift 语言示例），这就完事了。因为有一个自动生成的MessagesExtensiontarget ，然后默认的Info.plist里带有必需的配置（插件界面的 storyboard 以及插件的类型等），所以只要运行工程，Messages 就能自动识别出我们的插件了。


###Changing the Display Name 更换 Display Name
If you run the MessagesExtension target in the simulator you should be prompted to choose an application to run the extension inside of. We want to choose ‘Messages’.

如果在模拟器里运行MessagesExtension这个 target，它会让你选择在哪个 app 里运行这个插件。我们选择Messages。

![icon](https://www.shinobicontrols.com/wp-content/uploads/2016/07/Run_In_Messages.png)


>When Messages opens we should see our extension shown in the area beneath the message input. If not, then you may need to select the ‘Applications’ icon, then the icon which looks a little like four ellipses and selecting our extension from the list.

It’s a little bland at the moment, but we’ll soon change that. For now, the most pressing matter is to alter the ‘display name’ of our extension: it currently reads ‘MessagesExtension’ (actually it’s more like ‘MessagesEx…’ because it’s truncated). We can change this by clicking on our target and then altering the Display Name field.

此刻有点乏味，就目前而言，最紧迫的事情是要更改我们的扩展的“显示名称”：它目前读'MessagesExtension“（实际上它更像是'MessagesEx...'，因为它是截断的）。我们可以通过点击我们的 target，然后在 Display Name 这一字段进行更改。

![icon](https://www.shinobicontrols.com/wp-content/uploads/2016/07/Alter_Bundle_Name.png)


###游戏面板

这里使用了 UICollectionView 去展示一个 3×3 的方格视图。因为这不是本教程的重点，所以只是略带提一下。

###Models

To help define our game and keep track of its state we have a couple of structs to helps us:

为了记录一局游戏本身以及游戏的状态，我们定义以下两个结构体：

```
struct GameConstants {
    /// Number of ships to place on screen
    static let totalShipCount = 2
    /// The number of attempts the player can have at destroying opponent's ships
    static let incorrectAttemptsAllowed = 3
}

struct GameModel {
    /// The cell locations of the ships
    let shipLocations: [Int]
    /// Whether the game has been completed or is still in progress
    var isComplete: Bool
}
```


###MessagesViewController
MessagesViewController is the entry point to our extension. A subclass of MSMessagesAppViewController, this acts as the root view controller for Messages extension. The template includes an abundance of methods that we can override for responding to fine-grained situations, such as when the user receives a message while the extension is open. We’ll just be making use of a few of these.

MessagesViewController 是我们插件的入口. MessagesViewController 是 MSMessagesAppViewController 的子类。
作为 Messages extension 的root view controller,这个模板类包含了丰富的方法以供我们处理各种细颗粒度情况，例如当用户收到一条短信的时候扩展就会打开。这就是利用其中的方法实现的。

The first thing to note is that our extension can be in two MSMessagesAppPresentationStyle`s when open:

我们首先可以注意到可以使用以下两种类型打开我们的扩展。

* compact
* expanded

compact will be the style used when the extension is opened by the user from the applications drawer and is presented in the keyboard area. 
The expanded style gives the extension a little more breathing room by taking up most of the screen.

compact是用户从应用托盘里打开插件的模式，插件显示在键盘区域里。expanded则多给了一些空间，插件占据屏幕的大部分。

为了让代码整洁一些，我们会用不同的 view controller 来分别实现这两种模式，并且把这些 view Controller 都加为 MessagesViewController 的子 view controller。



###Child View Controllers

We won’t spend too much time looking at the implementation of these controllers and instead focus on the sending of messages along with data about the game state. Please feel free to browse through the code on Github

这里大概的意思就是去GitHub看源码实现，是有关于短信息发送界面的。


###GameStartViewController

When our extension is first opened we’ll be in the compact presentation style. Particularly on an iPhone this isn’t really enough space to display our grid. We could simply request to transition immediately to the expanded style, however Apple warn against doing this as, ultimately, the user should be in control.

We’ll display a simple title screen consisting of a label and a button. When this button is tapped we’ll transition to the main game screen so the user can start positioning their ships.

我们的插件刚启动的时候处于compact状态。这点空间并不够展示游戏的棋盘，在 iPhone 上尤其不够。我们可以简单粗暴地立即切换成expanded状态，但是苹果官方禁止这种做法，控制权应该在用户的手上。

于是，我们显示一个简单的欢迎界面，里面有一个 label 和一个 button。按下 button 的时候，再切换到游戏的主界面，用户就可以开始放置『战舰』了。


###Ship Location View Controller

This is the controller where the game initiator chooses where their ships should be located.

We hook in to the gameBoard‘s onCellSelection handler so we can manage the styling of the cells. Those that have a ship positioned on them will be displayed green whereas the empty cells will remain blue.

When shipsLeftToPosition returns 0 we enable the finish button. The button is hooked up to an IBAction called completedShipLocationSelection: which creates a model of the game and using an extension on UIImage to create a snapshot of the game board (we reset() the board so when we create an image the locations chosen for the ships are hidden – we don’t want to reveal these quite yet!). This snapshot will come in handy when we insert a message later.

这个 view controller 是开始游戏后玩家 A 布置『战舰』的界面。

我们实现gameBoard的onCellSelection方法来控制 cell 的样式：上面有战舰的 cell 显示为绿色，空白的显示为蓝色。

shipsLeftToPosition返回 0 时，结束按钮会变得可点。这个按钮的点击事件是一个叫completedShipLocationSelection:的IBAction方法，它会新建一个游戏 model，然后使用 UIImage 的 extension 来创建一张游戏棋盘的截图（我们会先reset()棋盘，所以截图的时候战舰的位置是隐藏的——现在可不是揭晓谜底的时候！）。这张截图在待会发消息的时候会用到。


###Ship Destroy View Controller

When the other player selects the message in the conversation we want them to see a slightly different view controller – one which will enable them to search for the hidden battleships.

We again hook into the board’s onCellSelection handler. This time we mark a cell as green (a ‘hit’) if the cell location matches one picked by the other player, otherwise we mark it as a ‘miss’ by coloring the cell red.

When a game is completed, either due to the player running out of lives or finding the two ships we configure the model appropriately and then call the completion handler.

当玩家 B 点击对话中的消息时，我们希望他能看到一个不同的 view controller —— 一个能让他寻找隐藏战舰的界面。

我们还是实现棋盘的 onCellSelection 回调。这一次我们把选择的 cell 位置与玩家 A 布置的位置匹配的（『击中战舰』）标为绿色，如果没有击中就标为红色。

游戏结束后，不管是因为 3 条命用完了，还是因为两条战舰都找出来了，我们都会相应地记录在数据模型中，然后调起游戏结束的回调。


###Adding the Child Controllers

Returning to our MessagesViewController, we can now hook up add our child controllers to it.

回到 MessagesViewController ，现在可以添加 子ViewControllers 进去了。

```
class MessagesViewController: MSMessagesAppViewController {
    override func willBecomeActive(with conversation: MSConversation) {
        configureChildViewController(for: presentationStyle, with: conversation)
    }

    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        guard let conversation = self.activeConversation else { return }
        configureChildViewController(for: presentationStyle, with: conversation)
    }
}
```

These two methods, provided by MSMessagesAppViewController, alert us when our extension becomes active (i.e. is opened by the user) and when the view controller will transition to a new presentation style. We’ll use them to configure our child view controllers.

这两个方法是继承至 MSMessagesAppViewController ，分别的作用是提醒我们插件开始可用了（比如被用户打开了）和插件要变换一种展现方式了。我们利用这两个方法配置子ViewControllers


```
private func configureChildViewController(for presentationStyle: MSMessagesAppPresentationStyle,
                                              with conversation: MSConversation) {
    // Remove any existing child view controllers
    for child in childViewControllers {
        child.willMove(toParentViewController: nil)
        child.view.removeFromSuperview()
        child.removeFromParentViewController()
    }

    // Now let's create our new one
    let childViewController: UIViewController

    switch presentationStyle {
    case .compact:
        childViewController = createGameStartViewController()
    case .expanded:
        if let message = conversation.selectedMessage,
            let url = message.url {
            // If the conversation.selectedMessage is set then the user must have selected a pre-existing battleship message
            // therefore we need to show the controller that will enable the user to try and destroy the ships
            let model = GameModel(from: url)
            childViewController = createShipDestroyViewController(with: conversation, model: model)
        }
        else {
          // Otherwise, we are yet to position the ships
            childViewController = createShipLocationViewController(with: conversation)
        }
    }

    // Add controller
    addChildViewController(childViewController)
    childViewController.view.frame = view.bounds
    childViewController.view.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(childViewController.view)

    childViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
    childViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    childViewController.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    childViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

    childViewController.didMove(toParentViewController: self)
}
```

The above method determines which child controller we should show the current user. We know if we’re in the compact style then we should show our ‘start game’ screen.

If we’re in the expanded mode we need to determine if the ship locations have already been chosen. The conversation.selectedMessage will not be nil if the user selected the message from the conversation view – this means the game must be in progress and therefore we should show ShipDestroyViewController. Otherwise we show ShipLocationViewController.

上面这个方法决定了我们该向当前的用户展示哪个子 view controller。如果处于compact 模式，那么应该显示 "start game" 界面。

如果处于expanded模式，我们需要判断是 A 玩家还是 B 玩家。如果是 B 玩家在对话界面中点击消息，此时conversation.selectedMessage就不会是 nil，这说明游戏已经开始了，所以我们要展示ShipDestroyViewController。否则就展示ShipLocationViewController。


###Requesting Permission to Expand

When the ‘Start Game’ button is pressed in GameStartViewController we want our messages extensions to move into the expanded state so we can display our grid.

在GameStartViewController点击 "start game" 按钮，我们希望插件能切换到expanded模式，好让我们展示棋盘。	

```
// Within 'createGameStartViewController'
controller.onButtonTap = {
    [unowned self] in
    self.requestPresentationStyle(.expanded)
}
```

![icon](https://www.shinobicontrols.com/wp-content/uploads/2016/07/Expanding.gif)

###Creating ‘Updatable’ Messages

Usually within the Messages app, any new content – be it a text message or one of the nifty new stickers – is inserted as a new message at the bottom of the transcript, completely independent of all previous messages.

However, this can sometimes be a bit of a pain: for example, a chess game extension would result in a new message being added to the conversation after every move. What we probably want is for the most recent update to take the place of the previous message.

Thankfully, Apple have thought of this and have given us MSSession – a class with no properties or methods that is used to track updatable messages.

```
let session = MSSession()

```

When we send a message, we’ll use this session to alert Messages that it should overwrite the existing message associated with the same session. The previous message is removed from the transcript with our new message being inserted at the bottom.

之前在 Messages 里面，任何新的内容——不管是新的短信还是表情——都会以一条新消息的形式出现在对话的底部，跟之前的所有消息都不相干。

然而，这一点可能带来很多麻烦：比如，一个下国际象棋的游戏插件会造成每走一步棋都要发一条新消息。而我们理想中的情况应该是更新后的消息能代替之前的消息。

谢天谢地，苹果也想到了这一点，给我们提供了一个类MSSession——这个类没有属性也没有方法，只是用来更新消息的。

我们发一条消息的时候，就用这个 session 来告诉 Messages，要覆盖此前 session 相同的信息。前一条信息会被从聊天记录中移除，然后新的信息插入到底部。


###Using Participant Names

In recent years, Apple have talked about maintaining the user’s privacy as being of paramount importance. This is certainly the case with the Messages framework: you cannot identify users except for a UUID which is unique to each device, i.e. you cannot send a UUID string as part of a message and expect the other participants to know who that UUID string represents.

最近几年，苹果一直说要把保护用户隐私当做头等大事。对 Messages framework 来说确实如此：你并不能得到用户的身份，只能得到一个每个设备不同的UUID。也就是说，你不能在消息里加入发消息的用户的身份 ID，然后指望收消息的用户能通过这个 ID 识别出发消息的是谁。


>Additionally, you cannot get access to the content of any message in the conversation, except for the one the user has selected (and this has to have originated from your extension).

>另外，你只能访问到用户点击的那条消息的内容，不能访问到对话中任何其他消息的内容（而且点击的这条消息还必须是从你的插件发出来的）。

The MSConversation instance has two properties that are useful when wishing to print out the names of those involved in the conversation: localParticipantIdentifier and remoteParticipantIdentfiers. These need to be prefixed by a $.

MSConversation 这个类有两个属性localParticipantIdentifier和remoteParticipantIdentfiers，可以用来显示对话双方的名字。要加一个前缀$。

```
let player = "$\(conversation.localParticipantIdentifier)"
```

When sent as part of a message, Messages will parse the UUID and resolve it to the person’s name.

把它放在消息里发出去，Messages 会解析这个 UUID，然后显示出对应的联系人姓名。



![icon](https://www.shinobicontrols.com/wp-content/uploads/2016/07/Resolved_UUID_In_Caption.png)


###Sending and Receiving Application Data

Data about the state of the game is transmitted in the form of a URL. Instances of your extension on other devices should be able to parse this URL and then display the relevant content.

Another benefit to using URLs is that it acts as a back-up for macOS users. The Messages app on the mac unfortunately isn’t capable of using message extensions. From the docs:

游戏状态的数据是以 URL 的形式传递的。你的插件装在任意一台手机上，都应该有能力解析这个 URL，展示相关的内容。

使用 URL 的另一个好处是，它还能为 MacOS 用户提供一个备用方案。不幸的是，MacOS 上的 Messages 应用并不支持插件功能。文档里是这样说的：


>If the message is selected on macOS, the system loads the URL in a web browser. The URL should point to a web service that returns a reasonable result based on the encoded data.

>如果在 macOS 上点击这条信息，系统会转到 web 浏览器打开这个 URL。所以这个 URL 应该定向到你自己的 web service，基于 URL 里 encode 的数据为用户呈现合理的结果。

To construct the URL, we can use URLComponents with a base url and a number of URLQueryItems (effectively key-value pairs).

要构建这个 URL，我们可以使用URLComponents，组合一个 base url 和一群URLQueryItems（都是有效的键值对）。

```
extension GameModel {
    func encode() -> URL {
        let baseURL = "www.shinobicontrols.com/battleship"

        guard var components = URLComponents(string: baseURL) else {
            fatalError("Invalid base url")
        }

        var items = [URLQueryItem]()

        // Location
        let locationItems = shipLocations.map {
            location in
            URLQueryItem(name: "Ship_Location", value: String(location))
        }

        items.append(contentsOf: locationItems)

        // Game Complete
        let complete = isComplete ? "1" : "0"

        let completeItem = URLQueryItem(name: "Is_Complete", value: complete)
        items.append(completeItem)

        components.queryItems = items

        guard let url = components.url else {
            fatalError("Invalid URL components")
        }

        return url
    }
}
```


This will result in our URL looking something like www.shinobicontrols.com/battleship?Ship_Location=0&Ship_Location=1&Is_Complete=0.

The decoding is very much the same in reverse: taking the url, extracting the query items and then parsing the value from each item to construct a new model of our game.

最后得出的 url 结果形如：www.shinobicontrols.com/battleship?Ship_Location=0&Ship_Location=1&Is_Complete=0

而解码基本与此过程相反：先得到 url，取出每个键值对，由每个对应的值来构建游戏的数据模型。


###Inserting the Message into the Conversation

Finally, after all that hard work, we can create the message, ready for the user to send to other participants in the conversation.

经过努力，我们终于创建出了这条消息，准备好让玩家在对话中发给其他玩家了。

```
/// Constructs a message and inserts it into the conversation
func insertMessageWith(caption: String,
                   _ model: GameModel,
                   _ session: MSSession,
                   _ image: UIImage,
                   in conversation: MSConversation) {
    let message = MSMessage(session: session)
    let template = MSMessageTemplateLayout()
    template.image = image
    template.caption = caption
    message.layout = template
    message.url = model.encode()

    // Now we've constructed the message, insert it into the conversation
    conversation.insert(message)
}

```

The message is instantiated with a session so we can update prior instances of the message in the transcript, as discussed earlier.

To determine the appearance of the message, the MSMessageTemplateLayout should be used. It enables us to define a number of attributes, the most important in our example’s case being the caption (the main text) and image properties.

After defining the appearance and configuring the message’s session and URL properties, we can insert the message into the conversation. This will insert the message into Message’s input field. Note, that we are not able to send the message – only insert it.

就像前面说过的那样，这条消息是用一个 session 创建的，这样我们就可以覆盖对话中同一个 session 的信息了。

为了修改消息的外观，我们要用到MSMessageTemplateLayout。它能让我们修改消息的一系列属性，在这个例子里主要用到caption（文字）和image（图片）。

修改完消息的外观，配置好 session 和 URL 属性，我们终于可以把消息插进对话中了。最后这行代码会把消息放进 Messages 的输入框里。注意：我们没有权限直接把这条消息发出去——只能放进输入框里。


###You Are Dismissed
After we’ve inserted the message, we have no need for our extension to hang around any more. The user could manually hide it, however we want to make the experience a little better for them, so we dismiss our MessagesViewController by calling:


插入完这条消息之后，我们的插件也没有必要再在这闲待着了。用户可以手动把它关掉，不过为了让他们体验好一点，所以我们调用这行代码，自己结束掉MessagesViewController的生命：

```
self.dismiss()

```

###Further Reading 扩展阅读


I appreciate that was a rather long post, however I hope it gives some indication as to how powerful Message apps could be in iOS 10.

The current betas are certainly not without their flaws: the simulator is slow to boot up the Messages app and at times flat-out refuses to load the extension – I’ve frequently found myself having to reboot the extension from the Messages application tray. The Messages framework is also extremely ‘chatty': logging has been taken to the extreme. This will of course disappear when iOS 10 comes out of beta, however in its current state you have to keep your eyes peeled for debugging statements that might be relevant to your extension, such as AutoLayout constraint conflicts.

If you’d like to explore this a little more, I recommend taking a look at the WWDC presentation and also looking through the sample provided by Apple: there are a lot of interesting tips that can be gleaned from it, such as elegant ways to decode a URL.

If you have any questions or comments then we would love to hear your feedback. Send me a tweet @sam_burnstone or you can follow @shinobicontrols to get the latest news and updates to the iOS 10 Day by Day series. Thanks for reading!

Check out more posts from this series on the iOS 10 Day by Day index page and be sure to subscribe here.