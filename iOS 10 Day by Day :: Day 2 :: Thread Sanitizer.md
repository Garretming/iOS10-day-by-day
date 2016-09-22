# iOS 10 Day by Day :: Day 2 :: Thread Sanitizer

本文介绍了 Xcode 8 的新出的多线程调试工具 Thread Sanitizer，可以在 app 运行时发现线程竞态。

原文出处：[https://www.shinobicontrols.com/blog/ios-10-day-by-day-day-2-thread-sanitizer](https://www.shinobicontrols.com/blog/ios-10-day-by-day-day-2-thread-sanitizer)

想象一下，项目已经快结束了，但是只剩下那种很难检测的偶发的 bug，这种情况的确让人揪心，不过苹果正在致力解决此类问题。

这种情况经常是多个线程访问同一块内存造成的。我可以大胆猜测，多线程的 bug 是许多程序员的梦魇。这类 bug 非常难定位，而且只有特定条件下才能重现：所以找出问题的原因确实困难重重。

而问题的原因常常是所谓的『线程竞态』。对这个名词我们不再多费笔墨去解释了，以下摘自 [Google 的 ThreadSanitizer](https://github.com/google/sanitizers/wiki/ThreadSanitizerCppManual) 文档：

>A data race occurs when two threads access the same variable concurrently and at least one of the accesses is write.

>两个线程同时访问同一个变量，而且其中至少一个线程要做的是写操作，这种情况就叫竞态。

调试竞态问题曾经让程序员们大为头疼；不过值得庆幸的是，Xcode 发布了一个新的线程调试工具叫做 **Thread Sanitizer** 可以检测出这类问题，甚至比你发现得还早。

##Project

这次的示例程序能让用户存钱、取钱，每次 $100。下文会一步一步对工程进行优化，最终完成工程已经放在 [Github](https://github.com/kengsir/iOS10-day-by-day) 上了。运行版本 Xcode8 GM版本。

##The Account
Account 银行模型如下面所示：

```
import Foundation

class Account {
    var balance: Int = 0

    func withdraw(amount: Int, completed: () -> ()) {
        let newBalance = self.balance - amount

        if newBalance < 0 {
            print("You don't have enough money to withdraw \(amount)")
            return
        }

        // 银行要执行防伪验证，这是下文中需要优化的点
        sleep(2)

        self.balance = newBalance

        completed()
    }

    func deposit(amount: Int, completed: () -> ()) {
        let newBalance = self.balance + amount
        self.balance = newBalance

        completed()
    }
}
```

其中包含了
withdraw()能让我们给账户取钱，
deposit()能让我们给账户存钱的方法,存取的金额写死为 $100。

其中，deposit()方法是立即返回的，而withdraw方法要花一点时间才能执行完。我们名义上说是因为银行要执行防伪验证，背后其实就是让线程 sleep 了 2 秒。这是下文中使用多线程优化的借口。

另外一点要注意的是 completed block，在存取成功之后执行。

##View Controller

View Controller 里有两个 button ——一个存钱、一个取钱——还有一个 label，显示当前账户余额。Storyboard 中的布局是这样的：

![viewcontroller](https://www.shinobicontrols.com/wp-content/uploads/2016/08/Storyboard_Screen.png)

从 Storyboard 中引出显示余额 label 的 IBOutlet，再写几个方法更新余额的显示：

```
import UIKit

class ViewController: UIViewController {

    @IBOutlet var balanceLabel: UILabel!

    let account = Account()

    override func viewDidLoad() {
        super.viewDidLoad()
        updateBalanceLabel()
    }

    @IBAction func withdraw(_ sender: UIButton) {
        self.account.withdraw(amount: 100, onSuccess: updateBalanceLabel)
    }

    @IBAction func deposit(_ sender: UIButton) {
        self.account.deposit(amount: 100, onSuccess: updateBalanceLabel)
    }

    func updateBalanceLabel() {
        balanceLabel.text = "Balance: $\(account.balance)"
    }
}
```

看看第一版本的效果如何：

![第一版本](https://www.shinobicontrols.com/wp-content/uploads/2016/08/Block_Thread.gif)

可以发现，取钱的时候由于我们所写的withdraw方法里有严格的『防伪验证』机制，也就是 sleep 了 2 秒。在方法结束前会一直 block 主线程。而我们希望的是用户能快速重复存钱、取钱，将延迟率降低。

##使用Dispatch Queues

如果要是能把withdraw方法从主线程移出来，就解决这问题了。我们可以用上新出的『Swift 化』的 GCD 库：

```
func withdraw(amount: Int, onSuccess: () -> ()) {
    DispatchQueue(label: "com.shinobicontrols.balance-moderator").async {
        let newBalance = self.balance - amount

        if newBalance < 0 {
            print("You don't have enough money to withdraw \(amount)")
            return
        }

        // 模仿银行的防伪验证过程
        sleep(2)

        self.balance = newBalance

        DispatchQueue.main.async {
            onSuccess()
        }
    }
}
```

再看看效果：

![GCD](https://www.shinobicontrols.com/wp-content/uploads/2016/08/Race_Condition.gif)

仔细看gif图，也可以下载demo将注释的内容去掉然后跑一下看看效果。一开始账户余额是 $100，我们先取了 $100，然后存了 $100，怎么账户余额只剩下 0 了？

存取方法肯定是没问题的（刚才都分别测过了），看起来问题就出在把 withdraw 的任务放到单独线程这一步。


##Thread Sanitizer 主角登场

开启 Thread Sanitizer，只需点击 target 的 Edit Scheme...，然后在 Diagnostics tab 下勾选 Thread Sanitizer。可以选择 Pause on issues，这样比较方便一步步调试问题。我们把它勾上。

![scheme](http://upload-images.jianshu.io/upload_images/227290-74bbbdb64832f3c2.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![ss](http://upload-images.jianshu.io/upload_images/227290-08340b87870f35aa.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)



因为 thread sanitizer 只在运行时工作，我们需要把工程重新编译、重新跑一下。

>在 WWDC 演讲中，苹果推荐在所有的单元测试里都打开 thread sanitizer。Sanitizer 只在运行时有效，而且必须要代码运行到那儿才能检测出线程竞态。如果你的代码单元测试覆盖率很高，那么 Thread Sanitizer 能找出工程里绝大部分的线程竞态（可以参考下我们在 iOS 9 Day by Day 里写过的 [Xcode 7 的测试覆盖工具](https://www.shinobicontrols.com/blog/ios9-day-by-day-day5-xcode-code-coverage-tools)）。
.

>还要注意的一点是，对于 Swift 这个工具只对 Swift 3 的代码有效（Objective-C 也兼容），而且只能用 64 位的模拟器来跑。




现在我们再把之前的操作重复一遍，先取钱，再马上存钱。这时候 thread sanitizer 把 app 暂停了，因为它发现了线程竞态。它清晰地展现出了冲突发生时的调用栈。

![调用](http://upload-images.jianshu.io/upload_images/227290-e19e48a069420aef.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

而且，它在控制台里打印出了相关信息。

通过调用栈和打印出的信息，Thread Analyzer 给力地帮我们定位了问题所在： Account.deposit 方法与 Account.widthdraw 方法会访问同一个属性 Account.balance，从而出现了竞态。哎呀，看样子我们应该把存钱和取钱放在同一个线程里进行。

我们修改一下 Account 类的代码，用一个公共的 queue：

```
class Account {
    var balance: Int = 0
    private let queue = DispatchQueue(label: "com.shinobicontrols.balance-moderator")

    func withdraw(amount: Int, onSuccess: () -> ()) {
        queue.async {
            // 跟之前一样...
        }
    }

    func deposit(amount: Int, onSuccess: () -> ()) {
        queue.async {
            let newBalance = self.balance + amount
            self.balance = newBalance

            DispatchQueue.main.async {
                onSuccess()
            }
        }
    }
}
```

再跑一遍代码，发现还是有竞态；只不过这次不是在 Account 类里，而是由 ViewController 类在主线程访问 balance 造成的。
![2](http://upload-images.jianshu.io/upload_images/227290-7aec6f70c3c9b401.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

为解决这个问题，我们可以把 balance 属性改成 private 保护起来，只能在 Account 类内部访问它，然后改用 queue 来返回结果。

```
private var _balance: Int = 0
var balance: Int {
    return queue.sync {
        return _balance
    }
}
```

之前所有对 balance 属性的写操作都要改成私有的 _balance。

现在再跑一遍，再怎么重复点击 "withdraw" 和 "deposit" 都不会触发Thread Sanitizer 了。