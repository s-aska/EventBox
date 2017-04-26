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
        _ = EventBox.onMainThread(self, name: "onMainThread") { _ in
            XCTAssertTrue(Thread.isMainThread)
        }
        EventBox.post("onMainThread")
    }
    
    func testOnMainThreadWithSender() {
        let senderA = 1 as AnyObject
        let senderB = 2 as AnyObject
        var sendersA: [AnyObject] = []
        var sendersAll: [Any?] = []
        
        _ = EventBox.onMainThread(self, name: "onMainThreadWithSender", sender: senderA) { (notification: Notification!) in
            sendersA.append(notification.object as AnyObject)
            return
        }
        
        _ = EventBox.onMainThread(self, name: "onMainThreadWithSender") { (notification: Notification!) in
            sendersAll.append(notification.object)
            return
        }
        EventBox.post("onMainThreadWithSender", sender: senderA)
        EventBox.post("onMainThreadWithSender", sender: senderB)
        EventBox.post("onMainThreadWithSender")
        
        XCTAssertEqual(sendersA.count, 1)

        XCTAssertEqual(sendersAll.count, 3)
        XCTAssertTrue(sendersAll.last! == nil)
    }
    
    func testOnBackgroundThread() {
        _ = EventBox.onBackgroundThread(self, name: "onBackgroundThread") { _ in
            XCTAssertTrue(Thread.isMainThread == false)
        }
        EventBox.post("onBackgroundThread")
    }
    
    func testOnBackgroundThreadWithSender() {
        let senderA = 1 as AnyObject
        let senderB = 2 as AnyObject
        var sendersA: [Int] = []
        var sendersAll: [Any?] = []
        
        _ = EventBox.onMainThread(self, name: "onBackgroundThreadWithSender", sender: senderA) { (notification: Notification!) in
            sendersA.append(notification.object as! Int)
            return
        }
        
        _ = EventBox.onMainThread(self, name: "onBackgroundThreadWithSender") { (notification: Notification!) in
            sendersAll.append(notification.object)
            return
        }
        EventBox.post("onBackgroundThreadWithSender", sender: senderA)
        EventBox.post("onBackgroundThreadWithSender", sender: senderB)
        EventBox.post("onBackgroundThreadWithSender")
        
        XCTAssertEqual(sendersA.count, 1)

        XCTAssertEqual(sendersAll.count, 3)
        XCTAssertTrue(sendersAll.last! == nil)
    }
    
    func testOff() {
        
        var count = 0
        
        let handler = { (n: Notification!) -> Void in
            count += 1
            return
        }
        
        _ = EventBox.onMainThread(self, name: "counter", handler: handler)
        
        EventBox.post("counter")
        EventBox.post("counter")
        
        EventBox.off(self)
        
        EventBox.post("counter")
        EventBox.post("counter")
        
        _ = EventBox.onMainThread(self, name: "counter", handler: handler)
        
        EventBox.post("counter")
        EventBox.post("counter")
        
        XCTAssertEqual(count, 4)
    }
    
    func testOffWithName() {
        
        var count = 0
        
        let handler = { (n: Notification!) -> Void in
            count += 1
            return
        }
        
        _ = EventBox.onMainThread(self, name: "counter1", handler: handler)
        _ = EventBox.onMainThread(self, name: "counter2", handler: handler)
        _ = EventBox.onMainThread(self, name: "counter3", handler: handler)
        
        EventBox.post("counter1")
        EventBox.post("counter2")
        EventBox.post("counter3")
        
        XCTAssertEqual(count, 3)
        
        count = 0
        
        EventBox.off(self, name: "counter1")
        EventBox.off(self, name: "counter2")
        
        EventBox.post("counter1")
        EventBox.post("counter2")
        EventBox.post("counter3")
        
        XCTAssertEqual(count, 1)
    }
    
}

