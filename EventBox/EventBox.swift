//
//  EventBox.swift
//  EventBox
//
//  Created by Shinichiro Aska on 11/29/14.
//  Copyright (c) 2014 Shinichiro Aska. All rights reserved.
//

import Foundation

open class EventBox {

    // MARK: - Singleton

    struct Static {
        static let instance = EventBox()
        static let queue = DispatchQueue(label: "pw.aska.EventBox", attributes: [])
    }

    struct NamedObserver {
        let observer: NSObjectProtocol
        let name: String
    }

    var cache = [UInt:[NamedObserver]]()

    // MARK: - addObserverForName

    open class func on(_ target: AnyObject, name: Notification.Name, sender: AnyObject?, queue: OperationQueue?, handler: @escaping ((Notification!) -> Void)) {
        let id = UInt(bitPattern: ObjectIdentifier(target))
        let observer = NotificationCenter.default.addObserver(forName: name, object: sender, queue: queue, using: handler)
        let namedObserver = NamedObserver(observer: observer, name: name.rawValue)

        Static.queue.sync {
            if let namedObservers = Static.instance.cache[id] {
                Static.instance.cache[id] = namedObservers + [namedObserver]
            } else {
                Static.instance.cache[id] = [namedObserver]
            }
        }
    }

    open class func onMainThread(_ target: AnyObject, name: Notification.Name, handler: @escaping ((Notification!) -> Void)) {
        EventBox.on(target, name: name, sender: nil, queue: OperationQueue.main, handler: handler)
    }

    open class func onMainThread(_ target: AnyObject, name: Notification.Name, sender: AnyObject?, handler: @escaping ((Notification!) -> Void)) {
        EventBox.on(target, name: name, sender: sender, queue: OperationQueue.main, handler: handler)
    }

    open class func onBackgroundThread(_ target: AnyObject, name: Notification.Name, handler: @escaping ((Notification!) -> Void)) {
        EventBox.on(target, name: name, sender: nil, queue: OperationQueue(), handler: handler)
    }

    open class func onBackgroundThread(_ target: AnyObject, name: Notification.Name, sender: AnyObject?, handler: @escaping ((Notification!) -> Void)) {
        EventBox.on(target, name: name, sender: sender, queue: OperationQueue(), handler: handler)
    }

    // MARK: - removeObserver

    open class func off(_ target: AnyObject) {
        let id = UInt(bitPattern: ObjectIdentifier(target))
        let center = NotificationCenter.default

        Static.queue.sync {
            if let namedObservers = Static.instance.cache.removeValue(forKey: id) {
                for namedObserver in namedObservers {
                    center.removeObserver(namedObserver.observer)
                }
            }
        }
    }

    open class func off(_ target: AnyObject, name: Notification.Name) {
        let id = UInt(bitPattern: ObjectIdentifier(target))
        let center = NotificationCenter.default

        Static.queue.sync {
            if let namedObservers = Static.instance.cache[id] {
                Static.instance.cache[id] = namedObservers.filter({ (namedObserver: NamedObserver) -> Bool in
                    if namedObserver.name == name.rawValue {
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

    open class func post(_ name: Notification.Name) {
        NotificationCenter.default.post(name: name, object: nil)
    }

    open class func post(_ name: Notification.Name, sender: AnyObject?) {
        NotificationCenter.default.post(name: name, object: sender)
    }

    open class func post(_ name: Notification.Name, userInfo: [AnyHashable: Any]?) {
        NotificationCenter.default.post(name: name, object: nil, userInfo: userInfo)
    }

    open class func post(_ name: Notification.Name, sender: AnyObject?, userInfo: [AnyHashable: Any]?) {
        NotificationCenter.default.post(name: name, object: sender, userInfo: userInfo)
    }

}
