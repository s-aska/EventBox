//
//  EventBoxTests.swift
//  EventBoxTests
//
//  Created by Shinichiro Aska on 11/29/14.
//  Copyright (c) 2014 Shinichiro Aska. All rights reserved.
//

import Foundation
import XCTest
import EventBox

class EventBoxTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        EventBox.off(self)
    }
    
    override func tearDown() {
        EventBox.off(self)
        super.tearDown()
    }
    
    func testOnMainThread() {
        let name = Notification.Name.init(rawValue: "onMainThread")
        EventBox.onMainThread(self, name: name) { _ in
            XCTAssertTrue(Thread.isMainThread)
        }
        EventBox.post(name)
    }
    
    func testOnMainThreadWithSender() {
        let senderA = 1 as AnyObject
        let senderB = 2 as AnyObject
        var sendersA: [AnyObject] = []
        var sendersAll: [Any?] = []
        let name = Notification.Name.init(rawValue: "onMainThreadWithSender")
        
        EventBox.onMainThread(self, name: name, sender: senderA) { (notification: Notification!) in
            sendersA.append(notification.object as AnyObject)
            return
        }
        
        EventBox.onMainThread(self, name: name) { (notification: Notification!) in
            sendersAll.append(notification.object)
            return
        }
        EventBox.post(name, sender: senderA)
        EventBox.post(name, sender: senderB)
        EventBox.post(name)
        
        XCTAssertEqual(sendersA.count, 1)

        XCTAssertEqual(sendersAll.count, 3)
        XCTAssertTrue(sendersAll.last! == nil)
    }
    
    func testOnBackgroundThread() {
        let name = Notification.Name.init(rawValue: "onMainThread")
        EventBox.onBackgroundThread(self, name: name) { _ in
            XCTAssertTrue(Thread.isMainThread == false)
        }
        EventBox.post(name)
    }
    
    func testOnBackgroundThreadWithSender() {
        let name = Notification.Name.init(rawValue: "onBackgroundThreadWithSender")
        let senderA = 1 as AnyObject
        let senderB = 2 as AnyObject
        var sendersA: [Int] = []
        var sendersAll: [Any?] = []
        
        EventBox.onMainThread(self, name: name, sender: senderA) { (notification: Notification!) in
            sendersA.append(notification.object as! Int)
            return
        }
        
        EventBox.onMainThread(self, name: name) { (notification: Notification!) in
            sendersAll.append(notification.object)
            return
        }
        EventBox.post(name, sender: senderA)
        EventBox.post(name, sender: senderB)
        EventBox.post(name)
        
        XCTAssertEqual(sendersA.count, 1)

        XCTAssertEqual(sendersAll.count, 3)
        XCTAssertTrue(sendersAll.last! == nil)
    }
    
    func testOff() {
        let name = Notification.Name.init(rawValue: "counter")

        var count = 0
        
        let handler = { (n: Notification!) -> Void in
            count += 1
            return
        }
        
        EventBox.onMainThread(self, name: name, handler: handler)
        
        EventBox.post(name)
        EventBox.post(name)

        EventBox.off(self)
        
        EventBox.post(name)
        EventBox.post(name)

        EventBox.onMainThread(self, name: name, handler: handler)
        
        EventBox.post(name)
        EventBox.post(name)

        XCTAssertEqual(count, 4)
    }
    
    func testOffWithName() {
        let name1 = Notification.Name.init(rawValue: "counter1")
        let name2 = Notification.Name.init(rawValue: "counter2")
        let name3 = Notification.Name.init(rawValue: "counter3")

        var count = 0
        
        let handler = { (n: Notification!) -> Void in
            count += 1
            return
        }
        
        EventBox.onMainThread(self, name: name1, handler: handler)
        EventBox.onMainThread(self, name: name2, handler: handler)
        EventBox.onMainThread(self, name: name3, handler: handler)
        
        EventBox.post(name1)
        EventBox.post(name2)
        EventBox.post(name3)
        
        XCTAssertEqual(count, 3)
        
        count = 0
        
        EventBox.off(self, name: name1)
        EventBox.off(self, name: name2)
        
        EventBox.post(name1)
        EventBox.post(name2)
        EventBox.post(name3)
        
        XCTAssertEqual(count, 1)
    }
    
}

