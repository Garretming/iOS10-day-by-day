//
//  Account.swift
//  ThreadSanitizer
//
//  Created by Samuel Burnstone on 04/08/2016.
//  Copyright © 2016 ShinobiControls. All rights reserved.
//

import Foundation

//MARK: - 未使用GCD之前的银行帐号方法
//class Account {
//    var balance: Int = 0
//    
//    func withdraw(amount: Int, completed: () -> ()) {
//        let newBalance = self.balance - amount
//        
//        if newBalance < 0 {
//            print("You don't have enough money to withdraw \(amount)")
//            return
//        }
//        
//        // Simulate processing of fraud checks
//        sleep(2)
//        
//        self.balance = newBalance
//        
//        completed()
//    }
//    
//    func deposit(amount: Int, completed: () -> ()) {
//        let newBalance = self.balance + amount
//        self.balance = newBalance
//        
//        completed()
//    }
//}


//MARK: - 第一次使用GCD优化
//class Account{
//        var balance: Int = 0
//        
//        func withdraw(amount: Int, onSuccess: @escaping () -> ()) {
//            DispatchQueue(label: "com.shinobicontrols.balance-moderator").async {
//                let newBalance = self.balance - amount
//                
//                if newBalance < 0 {
//                    print("You don't have enough money to withdraw \(amount)")
//                    return
//                }
//                
//                // 模仿银行的防伪验证过程
//                sleep(2)
//                
//                self.balance = newBalance
//                
//                DispatchQueue.main.async {
//                    onSuccess()
//                }
//            }
//        }
//        
//        func deposit(amount: Int, onSuccess: () -> ()) {
//            let newBalance = self.balance + amount
//            self.balance = newBalance
//            
//            onSuccess()
//        }
//}

//MARK: - 使用Thread Sanitizer检测出线程竞态后的优化
//class Account{
//    
//    var balance: Int = 0
//    /// 用一个公共的 queue,把存钱和取钱放在同一个线程里进行
//    /// Serial queue to moderate access to `balance` property
//    private let queue = DispatchQueue(label: "com.shinobicontrols.balance-moderator")
//
//    
//    func withdraw(amount: Int, onSuccess: @escaping () -> ()) {
//        queue.async {
//            let newBalance = self.balance - amount
//            
//            if newBalance < 0 {
//                print("You don't have enough money to withdraw \(amount)")
//                return
//            }
//            
//            // 模仿银行的防伪验证过程
//            sleep(2)
//            
//            self.balance = newBalance
//            
//            DispatchQueue.main.async {
//                onSuccess()
//            }
//        }
//    }
//    
//    func deposit(amount: Int, onSuccess: @escaping () -> ()) {
//        queue.async {
//            
//            let newBalance = self.balance + amount
//            self.balance = newBalance
//            
//            DispatchQueue.main.async {
//                onSuccess()
//            }
//        }
//    }
//}


//MARK: - 最终优化代码
class Account {
    private var _balance: Int = 0
    var balance: Int {
        return queue.sync {
            return _balance
        }
    }
    
    /// Serial queue to moderate access to `balance` property
    private let queue = DispatchQueue(label: "com.shinobicontrols.balance-moderator")
    
    /// 从账户中取出 $100
    func withdraw(amount: Int, onSuccess: @escaping () -> ()) {
        queue.async {
            let newBalance = self._balance - amount

            if newBalance < 0 {
                print("You don't have enough money to withdraw \(amount)")
                return
            }
            
            // Some bogus processing to force a race condition when `deposit` method simulataneouslySimulate invoked
            // We'll pretend it's for checking for fraudulent withdrawals :)
            sleep(1)
            
            self._balance = newBalance
            
            DispatchQueue.main.async {
                onSuccess()
            }
        }
    }
    
    /// 将 $100 存入帐号中
    func deposit(amount: Int, onSuccess: @escaping () -> ()) {
        queue.async {
            let newBalance = self._balance + amount
            self._balance = newBalance
            
            DispatchQueue.main.async {
                onSuccess()
            }
        }
    }
}
