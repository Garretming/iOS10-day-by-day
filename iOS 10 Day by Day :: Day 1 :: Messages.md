# iOS 10 Day by Day :: Day 1 :: Messages
文章介绍了如何开发一个 iOS 10 
Messages 的扩展（extension）

原文出处：https://www.shinobicontrols.com/blog/ios-10-day-by-day-day-1-messages


###Messages 是 iOS10 中一个巨大的更新。很可能这是在努力抢回 Facebook Messenger，微信和 Snapchat 所占的市场份额。



###Messages 其中一个新功能就是第三方开发者拥有在Messages程序内创建自己的 message extensions 的能力。这些都是建立在iOS8中引入的扩展技术。[Sam Davies](https://www.shinobicontrols.com/blog/ios8-day-by-day-day-2-sharing-extension) 这个博客介绍了这项技术。有关 message extensions 的好处是,你的扩展可以自身存在而不必被捆绑作为父应用程序的一部分。当 iOS10 今年晚些时候发布时，将提供给用户一个专用的 Messages 应用程序商店。



**为了证明这个令人振奋的新的扩展类型，我们就来看看一个项目，允许两个玩家玩的热门游戏：战舰。为了简单起见，游戏的布局保持简单。如果您想下载的项目，[GitHub地址](https://github.com/shinobicontrols/iOS10-day-by-day/tree/master/01%20-%20Messages)，github项目运行在 Xcode8 beta6**



![Smaller icon](https://www.shinobicontrols.com/wp-content/uploads/2016/07/App_Demo.gif
), 

#### 游戏规则，如上图所示

* 第一位玩家开始游戏并将两只 ‘ships’ 摆放好，程序将 ‘ships’ 的位置记录下来，但第二个玩家看不到 ‘ship’ 所摆放的位置
* 另一个玩家猜测 ‘ships’ 摆放的位置
* 胜出的条件是，在三次点击方块后可以猜中第一位玩家藏好的 ‘ships’ 的位置


###Creating the Project，开始码代码

Xcode 提供了简易的方法让我们创建 extension. 

Simply click File -> New Project and then select the iMessage Application template.

![Smaller icon](https://www.shinobicontrols.com/wp-content/uploads/2016/07/Create_Project.png)

Aside from naming our project and ensuring the language was set to Swift, that’s pretty much all we need to do. The Messages app will automatically recognize our extension when we run the project thanks to the auto-generated MessagesExtension target and the associated Info.plist which declares all we need to get started (the storyboard that defines the interface of the extension and the type of extension we’re building).

命名项目并设置开发语言为 Swift，这几乎是所有我们需要做的。当我们运行项目时， Messages app 将会自动识别我们的扩展。这是因为 auto-generated MessagesExtension target 和 Info.plist 中已经声明了所有我们开始项目需要的东西。（storyboard 也定义了扩展接口和我们正在构建的扩展类型） 



###Changing the Display Name 更换 Display Name
If you run the MessagesExtension target in the simulator you should be prompted to choose an application to run the extension inside of. We want to choose ‘Messages’.

![icon](https://www.shinobicontrols.com/wp-content/uploads/2016/07/Run_In_Messages.png)


>When Messages opens we should see our extension shown in the area beneath the message input. If not, then you may need to select the ‘Applications’ icon, then the icon which looks a little like four ellipses and selecting our extension from the list.

It’s a little bland at the moment, but we’ll soon change that. For now, the most pressing matter is to alter the ‘display name’ of our extension: it currently reads ‘MessagesExtension’ (actually it’s more like ‘MessagesEx…’ because it’s truncated). We can change this by clicking on our target and then altering the Display Name field.

此刻有点乏味，就目前而言，最紧迫的事情是要更改我们的扩展的“显示名称”：它目前读'MessagesExtension“（实际上它更像是'MessagesEx...'，因为它是截断的）。我们可以通过点击我们的 target，然后在 Display Name 这一字段进行更改。

![icon](https://www.shinobicontrols.com/wp-content/uploads/2016/07/Alter_Bundle_Name.png)


###游戏面板

这里使用了 UICollectionView 去展示一个 3×3 的方格视图。因为这不是本教程的重点，所以只是略带提一下。

###Models

To help define our game and keep track of its state we have a couple of structs to helps us:

使用一对结构体定义游戏中的 ’船‘ 运动轨迹状态：

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

MessagesViewController 是我们扩展的入口. MessagesViewController 是 MSMessagesAppViewController 的子类。
作为 Messages extension 的root view controller,这个模板类包含了丰富的方法以供我们处理各种细颗粒度情况，例如当用户收到一条短信的时候扩展就会打开。这就是利用其中的方法实现的。

The first thing to note is that our extension can be in two MSMessagesAppPresentationStyle`s when open:

我们首先可以注意到可以使用以下两种类型打开我们的扩展。

* compact
* expanded

compact will be the style used when the extension is opened by the user from the applications drawer and is presented in the keyboard area. 
The expanded style gives the extension a little more breathing room by taking up most of the screen.


###Child View Controllers

We won’t spend too much time looking at the implementation of these controllers and instead focus on the sending of messages along with data about the game state. Please feel free to browse through the code on Github

这里大概的意思就是去GitHub看源码实现，是有关于短信息发送界面的。


###GameStartViewController

When our extension is first opened we’ll be in the compact presentation style. Particularly on an iPhone this isn’t really enough space to display our grid. We could simply request to transition immediately to the expanded style, however Apple warn against doing this as, ultimately, the user should be in control.

We’ll display a simple title screen consisting of a label and a button. When this button is tapped we’ll transition to the main game screen so the user can start positioning their ships.

###Ship Location View Controller

This is the controller where the game initiator chooses where their ships should be located.

We hook in to the gameBoard‘s onCellSelection handler so we can manage the styling of the cells. Those that have a ship positioned on them will be displayed green whereas the empty cells will remain blue.

When shipsLeftToPosition returns 0 we enable the finish button. The button is hooked up to an IBAction called completedShipLocationSelection: which creates a model of the game and using an extension on UIImage to create a snapshot of the game board (we reset() the board so when we create an image the locations chosen for the ships are hidden – we don’t want to reveal these quite yet!). This snapshot will come in handy when we insert a message later.

###Ship Destroy View Controller

When the other player selects the message in the conversation we want them to see a slightly different view controller – one which will enable them to search for the hidden battleships.

We again hook into the board’s onCellSelection handler. This time we mark a cell as green (a ‘hit’) if the cell location matches one picked by the other player, otherwise we mark it as a ‘miss’ by coloring the cell red.

When a game is completed, either due to the player running out of lives or finding the two ships we configure the model appropriately and then call the completion handler.

###Adding the Child Controllers

Returning to our MessagesViewController, we can now hook up add our child controllers to it.

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


###Requesting Permission to Expand

When the ‘Start Game’ button is pressed in GameStartViewController we want our messages extensions to move into the expanded state so we can display our grid.


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


###Using Participant Names

In recent years, Apple have talked about maintaining the user’s privacy as being of paramount importance. This is certainly the case with the Messages framework: you cannot identify users except for a UUID which is unique to each device, i.e. you cannot send a UUID string as part of a message and expect the other participants to know who that UUID string represents.

>Additionally, you cannot get access to the content of any message in the conversation, except for the one the user has selected (and this has to have originated from your extension).

The MSConversation instance has two properties that are useful when wishing to print out the names of those involved in the conversation: localParticipantIdentifier and remoteParticipantIdentfiers. These need to be prefixed by a $.

```
let player = "$\(conversation.localParticipantIdentifier)"
```

When sent as part of a message, Messages will parse the UUID and resolve it to the person’s name.

![icon](https://www.shinobicontrols.com/wp-content/uploads/2016/07/Resolved_UUID_In_Caption.png)


###Sending and Receiving Application Data

Data about the state of the game is transmitted in the form of a URL. Instances of your extension on other devices should be able to parse this URL and then display the relevant content.

Another benefit to using URLs is that it acts as a back-up for macOS users. The Messages app on the mac unfortunately isn’t capable of using message extensions. From the docs:

>If the message is selected on macOS, the system loads the URL in a web browser. The URL should point to a web service that returns a reasonable result based on the encoded data.


To construct the URL, we can use URLComponents with a base url and a number of URLQueryItems (effectively key-value pairs).

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

###Inserting the Message into the Conversation

Finally, after all that hard work, we can create the message, ready for the user to send to other participants in the conversation.

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


###You Are Dismissed
After we’ve inserted the message, we have no need for our extension to hang around any more. The user could manually hide it, however we want to make the experience a little better for them, so we dismiss our MessagesViewController by calling:

```
self.dismiss()

```

###Further Reading

I appreciate that was a rather long post, however I hope it gives some indication as to how powerful Message apps could be in iOS 10.

The current betas are certainly not without their flaws: the simulator is slow to boot up the Messages app and at times flat-out refuses to load the extension – I’ve frequently found myself having to reboot the extension from the Messages application tray. The Messages framework is also extremely ‘chatty': logging has been taken to the extreme. This will of course disappear when iOS 10 comes out of beta, however in its current state you have to keep your eyes peeled for debugging statements that might be relevant to your extension, such as AutoLayout constraint conflicts.

If you’d like to explore this a little more, I recommend taking a look at the WWDC presentation and also looking through the sample provided by Apple: there are a lot of interesting tips that can be gleaned from it, such as elegant ways to decode a URL.

If you have any questions or comments then we would love to hear your feedback. Send me a tweet @sam_burnstone or you can follow @shinobicontrols to get the latest news and updates to the iOS 10 Day by Day series. Thanks for reading!

Check out more posts from this series on the iOS 10 Day by Day index page and be sure to subscribe here.