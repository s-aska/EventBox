//
//  EventBox.swift
//  EventBox
//
//  Created by Shinichiro Aska on 11/29/14.
//  Copyright (c) 2014 Shinichiro Aska. All rights reserved.
//

import Foundation

public class EventBox {

    // MARK: - Singleton

    struct Static {
        static let instance = EventBox()
        static let queue = dispatch_queue_create("pw.aska.EventBox", DISPATCH_QUEUE_SERIAL)
    }

    struct NamedObserver {
        let observer: NSObjectProtocol
        let name: String
    }

    var cache = [UInt:[NamedObserver]]()

    // MARK: - addObserverForName

    public class func on(target: AnyObject, name: String, sender: AnyObject?, queue: NSOperationQueue?, handler: ((NSNotification!) -> Void)) -> NSObjectProtocol {
        let id = ObjectIdentifier(target).uintValue
        let observer = NSNotificationCenter.defaultCenter().addObserverForName(name, object: sender, queue: queue, usingBlock: handler)
        let namedObserver = NamedObserver(observer: observer, name: name)

        dispatch_sync(Static.queue) {
            if let namedObservers = Static.instance.cache[id] {
                Static.instance.cache[id] = namedObservers + [namedObserver]
            } else {
                Static.instance.cache[id] = [namedObserver]
            }
        }

        return observer
    }

    public class func onMainThread(target: AnyObject, name: String, handler: ((NSNotification!) -> Void)) -> NSObjectProtocol {
        return EventBox.on(target, name: name, sender: nil, queue: NSOperationQueue.mainQueue(), handler: handler)
    }

    public class func onMainThread(target: AnyObject, name: String, sender: AnyObject?, handler: ((NSNotification!) -> Void)) -> NSObjectProtocol {
        return EventBox.on(target, name: name, sender: sender, queue: NSOperationQueue.mainQueue(), handler: handler)
    }

    public class func onBackgroundThread(target: AnyObject, name: String, handler: ((NSNotification!) -> Void)) -> NSObjectProtocol {
        return EventBox.on(target, name: name, sender: nil, queue: NSOperationQueue(), handler: handler)
    }

    public class func onBackgroundThread(target: AnyObject, name: String, sender: AnyObject?, handler: ((NSNotification!) -> Void)) -> NSObjectProtocol {
        return EventBox.on(target, name: name, sender: sender, queue: NSOperationQueue(), handler: handler)
    }

    // MARK: - removeObserver

    public class func off(target: AnyObject) {
        let id = ObjectIdentifier(target).uintValue
        let center = NSNotificationCenter.defaultCenter()

        dispatch_sync(Static.queue) {
            if let namedObservers = Static.instance.cache.removeValueForKey(id) {
                for namedObserver in namedObservers {
                    center.removeObserver(namedObserver.observer)
                }
            }
        }
    }

    public class func off(target: AnyObject, name: String) {
        let id = ObjectIdentifier(target).uintValue
        let center = NSNotificationCenter.defaultCenter()

        dispatch_sync(Static.queue) {
            if let namedObservers = Static.instance.cache[id] {
                Static.instance.cache[id] = namedObservers.filter({ (namedObserver: NamedObserver) -> Bool in
                    if namedObserver.name == name {
                        center.removeObserver(namedObserver.observer)
                        return false
                    } else {
                        return true
                    }
                })
            }
        }
    }

    // MARK: - postNotificationName

    public class func post(name: String) {
        NSNotificationCenter.defaultCenter().postNotificationName(name, object: nil)
    }

    public class func post(name: String, sender: AnyObject?) {
        NSNotificationCenter.defaultCenter().postNotificationName(name, object: sender)
    }

    public class func post(name: String, userInfo: [NSObject : AnyObject]?) {
        NSNotificationCenter.defaultCenter().postNotificationName(name, object: nil, userInfo: userInfo)
    }

    public class func post(name: String, sender: AnyObject?, userInfo: [NSObject : AnyObject]?) {
        NSNotificationCenter.defaultCenter().postNotificationName(name, object: sender, userInfo: userInfo)
    }

}
