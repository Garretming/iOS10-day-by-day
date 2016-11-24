# iOS 10 Day by Day // Day 4 // UIViewPropertyAnimator 

[原文出处](https://www.shinobicontrols.com/blog/ios-10-day-by-day-day-4-uiviewpropertyanimator)


##Back in the Dark Ages - 回顾以前


用基于 block 的 UIView animations 为 view 增加动画属性（例如frame, transform 等等）是非常简单的事情，例如下面的几行代码：

```
view.alpha = 1

UIView.animate(withDuration: 2) {
    containerView.alpha = 0
}
``` 


动画结束之后的操作可以放在 completion blocks。如果默认的匀速动画不能满足你的要求，还可以调整时间曲线。

但是，如果你需要一种自定义的曲线动画，相应的属性变化首先要快速开始，然后再急速慢下来，该怎么办呢？另外一个有点麻烦的问题是，怎么取消正在进行中的动画？虽然这些问题都可以解决，用第三方库或者[创建一个新的 animation 来取代进行中的 animation](http://stackoverflow.com/questions/15693795/how-to-interrupt-uiview-animation-before-completion)。但苹果在 UIKit 中新加的组件能把这些步骤简化许多：进入UIViewPropertyAnimator的世界吧！



## A new era of animation - animation 新纪元

UIViewPropertyAnimator 的 API 是重写的而且拥有高扩展性。它覆盖了传统 UIView animation 动画的绝大部分功能，并且大大增强了你对动画过程的掌控能力。具体来说，你可以在动画过程中任意时刻暂停，可以随后再选择继续，甚至还能在动画过程中动态改变动画的属性（例如，本来动画终点在屏幕左下角的，可以在动画过程中把终点改到右上角）。

为了探索这个新的类，我们来看几个例子，这几个例子都是演示一张图片划过屏幕的动画。这次是用 Playground 来写 Sample，下载地址请戳我-> [github地址](http://www.code4app.com)


##Playground “忍者” 示例的前期准备

这个 Playground 的例子都是展现了一个忍者划过屏幕的动画。为了方便对比这些页面的代码，我们把公共部分的代码写在 Sources 文件夹里。这样不仅能简化每个页面的代码，还能加快编译过程，因为 Sources 里的代码是预编译过的。

在 Playground 中, Sources 里包含一个简单的 UIView 子类，叫做NinjaContainerView。它的唯一功能就是添加一个 UIImageView 作为子 view，来显示我们的小忍者。我把忍者图片加到了 Resources 里。


```
import UIKit

public class NinjaContainerView: UIView {

    public let ninja: UIImageView = {
        let image = UIImage(named: "ninja")
        let view = UIImageView(image: image)
        view.frame = CGRect(x: 0, y: 0, width: 45, height: 39)
        return view
    }()

    public override init(frame: CGRect) {
        // Animating view
        super.init(frame: frame)

        // Position ninja in the bottom left of the view
        ninja.center = {
            let x = (frame.minX + ninja.frame.width / 2)
            let y = (frame.maxY - ninja.frame.height / 2)
            return CGPoint(x: x, y: y)
        }()

        // Add image to the container
        addSubview(ninja)
        backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Moves the ninja view to the bottom right of its container, positioned just inside.
    public func moveNinjaToBottomRight() {
        ninja.center = {
            let x = (frame.maxX - ninja.frame.width / 2)
            let y = (frame.maxY - ninja.frame.height / 2)
            return CGPoint(x: x, y: y)
        }()
    }
}
```

现在，在每个 playground 页面里，我们可以复制粘贴以下代码：

```
import UIKit
import PlaygroundSupport

// Container for our animating view
let containerView = NinjaContainerView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))

let ninja = containerView.ninja

// Show the container view in the Assistant Editor
PlaygroundPage.current.liveView = containerView
```

这里用到了 Playground 的 "Live View" 功能：不用启动 iOS 模拟器就可以展示动画效果。尽管 Playground 还是有些不够好用，但用来尝试新功能是非常合适的。

要显示 Live View 面板，点击菜单栏上的 View -> Assistant Editor -> Show Assistant Editor，或者点击右上角工具栏里两环相套的图标。如果在右半边的编辑器里没有看到 live view，要确保选中的是 Timeline 而不是 Manual。



##从简单的开始


下面例子展示了像传统使用基于 block animation 回调来使用 UIViewPropertyAnimator

```
UIViewPropertyAnimator(duration: 1, curve: .easeInOut) {
    containerView.moveNinjaToBottomRight()
}.startAnimation()
```

这会触发一个时长为 1 秒，时间曲线是缓进缓出的动画。动画的内容是闭包里的部分。


我们是通过调用 startAnimation() 来手动启动动画的。
另外一种创建 animator 的方法可以不用手动启动动画，就是 runningPropertyAnimator(withDuration:delay:options:animations:completion:)。确实有点长，所以可能还不如用第一种。

![1](https://www.shinobicontrols.com/wp-content/uploads/2016/08/Basic_Animation.gif)

先创建好 animator ，再往上添加动画也很容易：

```
// Now we've set up our view, let's animate it with a simple animation
let animator = UIViewPropertyAnimator(duration: 1, curve: .easeInOut)

// Add our first animation block
animator.addAnimations {
    containerView.moveNinjaToBottomRight()
}

// Now here goes our second
animator.addAnimations {
    ninja.alpha = 0
}
```

这两个 animation block 会同时进行。

![2](https://www.shinobicontrols.com/wp-content/uploads/2016/08/Block_Animations.gif)

添加 completion block 的方法也很类似：

```
animator.addCompletion {
    _ in
    print("Animation completed")
}

animator.addCompletion {
    position in
    switch position {
    case .end: print("Completion handler called at end of animation")
    case .current: print("Completion handler called mid-way through animation")
    case .start: print("Completion handler called  at start of animation")
    }
}
```

案例中的动画如果完整运行完的话，会在控制台看到如下的打印信息：

```
Animation completed
Completion handler called at end of animation
```


##进度拖拽和反向动画

我们可以利用 animator 让动画跟随拖拽的进度进行：

```
let animator = UIViewPropertyAnimator(duration: 5, curve: .easeIn)

// Add our first animation block
animator.addAnimations {
    containerView.moveNinjaToBottomRight()
}

let scrubber = UISlider(frame: CGRect(x: 0, y: 0, width: containerView.frame.width, height: 50))
containerView.addSubview(scrubber)

let eventListener = EventListener()
eventListener.eventFired = {
    animator.fractionComplete = CGFloat(scrubber.value)
}

scrubber.addTarget(eventListener, action: #selector(EventListener.handleEvent), for: .valueChanged)
```

![3](https://www.shinobicontrols.com/wp-content/uploads/2016/08/Scrubbable.gif)

>Playground 能在 Live Views 里面添加可交互的 UI 控件。燃鹅，接受响应事件就有点麻烦，因为我们需要一个 NSObject 的子类来监听诸如 .valueChanged 这种事件。所以，我们简单创建一个 EventListener，一旦触发它的 handleEvent 方法，它会调用我们的 eventFired 闭包。

这里 fraction 的值跟时间没有关系了，所以我们的小忍者不再像之前定义的那样，只会缓慢移动。

Property animator 最强大的功能体现在它能随时打断正在进行的动画。让动画反向也非常容易，只需设置 isReversed 属性。

为了演示这一点，我们使用关键帧动画，这样就可以制作一个多阶段的动画：

```
animator.addAnimations {
    UIView.animateKeyframes(withDuration: animationDuration, delay: 0, options: [.calculationModeCubic], animations: {
        UIView.addKeyframe(withRelativeStartTime: 0,  relativeDuration: 0.5) {
            ninja.center = containerView.center
        }
        UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
            containerView.moveNinjaToBottomRight()
        }
    })
}

let button = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 30)))
button.setTitle("Reverse", for: .normal)
button.setTitleColor(.black(), for: .normal)
button.setTitleColor(.gray(), for: .highlighted)
let listener = EventListener()
listener.eventFired = {
    animator.isReversed = true
}

button.addTarget(listener, action: #selector(EventListener.handleEvent), for: .touchUpInside)
containerView.addSubview(button)

animator.startAnimation()
``` 

点击按钮会启动反转动画效果，只要这一时刻动画效果还没有结束。

![4](https://www.shinobicontrols.com/wp-content/uploads/2016/08/Reversible.gif)


#自定义曲线

Property animator 不仅简洁优雅，而且具有很强的扩展性。如果需要替代掉苹果提供的动画曲线，只需传进一个实现 UITimingCurveProvider 协议的对象。大部分情况下用到的是 UICubicTimingParameters 或者 UISpringTimingParameters。

例如，我们想让小忍者在划过屏幕的过程中，先快速加速，然后再慢慢停止。如下图的贝塞尔曲线所示（绘制曲线用了这个很方便的在线工具-》[贝塞尔曲线在线工具](http://cubic-bezier.com/#.17,.67,.83,.67)）：

![5](https://www.shinobicontrols.com/wp-content/uploads/2016/08/Bezier_Curve.png)

```
let bezierParams = UICubicTimingParameters(controlPoint1: CGPoint(x: 0.05, y: 0.95),
                                                   controlPoint2: CGPoint(x: 0.15, y: 0.95))

let animator = UIViewPropertyAnimator(duration: 4, timingParameters:bezierParams)

animator.addAnimations {
    containerView.moveNinjaToBottomRight()
}

animator.startAnimation()
```


![6](https://www.shinobicontrols.com/wp-content/uploads/2016/08/Cubic_Params.gif)


