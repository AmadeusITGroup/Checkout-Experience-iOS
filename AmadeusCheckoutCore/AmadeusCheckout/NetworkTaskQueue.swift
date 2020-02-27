//
//  NetworkTaskQueue.swift
//  AmadeusCheckout
//
//  Created by Yann Armelin on 27/08/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import Foundation


/*
 A queue of URLSessionTask, that are automatically started as soon as the network is reachable.
 If network is still unreachable when the timeout occurs, tasks are put in a specific queue
 that can be resumed if user decides to retry.
*/
class NetworkTaskQueue {
    typealias TimeoutCallback = ((URLSessionTask)->Void)
    
    static var sharedInstance = NetworkTaskQueue()
    static let networkReachabilityTimeout = 3.0
    
    var reachability: Reachability? = nil
    var isNetworkReachable = false
    
    // This list contains all the tasks that were created when the network
    // was not available.
    // If the expirationDate is reached before the network is available,
    // they are moved to the expiredTasks list
    var pendingTasks: [(task:URLSessionTask, expiration:Date)] = []
    
    // This list contains all the tasks that waited for network for more
    // than `NetworkTaskQueue.networkReachabilityTimeout` seconds.
    // They can be put back in the pendingTasks list with the retryStuckTasks
    // method.
    var expiredTasks: [URLSessionTask] = []
    
    init() {
        do {
            try reachability = Reachability()
            reachability?.whenReachable = {[weak self] _ in
                self?.isNetworkReachable = true
                self?.resumePendingTasks()
            }
            reachability?.whenUnreachable = {[weak self] _ in
                self?.isNetworkReachable = false
            }
            try reachability?.startNotifier()
        } catch {
            isNetworkReachable = true
        }
    }
    
    func handleTask(_ task: URLSessionTask) {
        if isNetworkReachable {
            task.resume()
        } else {
            let timeout = NetworkTaskQueue.networkReachabilityTimeout
            pendingTasks.append((task:task, expiration: Date().addingTimeInterval(timeout)))
            DispatchQueue.main.asyncAfter(deadline: .now() + timeout + 0.1) {[weak self] in
                self?.releaseExpiredTasks()
            }
        }
    }

    func cancelTasks() {
        for task in pendingTasks {
            task.task.cancel()
        }
        pendingTasks = []
        for task in expiredTasks {
            task.cancel()
        }
        expiredTasks = []
    }
    
    func retryStuckTasks() {
        DispatchQueue.main.async {[weak self] in
            if let this = self {
                for task in this.expiredTasks {
                    self?.handleTask(task)
                }
                this.expiredTasks = []
            }
        }
    }
    
    fileprivate func resumePendingTasks() {
        DispatchQueue.main.async {[weak self] in
            if let this = self {
                for task in this.pendingTasks {
                    task.task.resume()
                }
                this.pendingTasks = []
            }
        }
    }
    
    fileprivate func releaseExpiredTasks() {
        var nonExpiredTasks: [(task:URLSessionTask, expiration:Date)] = []
        let now = Date()
        for task in pendingTasks {
            if task.expiration < now {
                expiredTasks.append(task.task)
            } else {
                nonExpiredTasks.append(task)
            }
        }
        pendingTasks = nonExpiredTasks
        
        if expiredTasks.count > 0 {
            NotificationCenter.default.post(name:NSNotification.Name.AMRequestNetworkAlert, object: self)
        }
    }
}
