//
//  Tests.swift
//  RealmS
//
//  Created by DaoNV on 3/14/16.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

import RealmSwift
import ObjectMapper
@testable import RealmS
import XCTest

class Tests: XCTestCase {
  var jsUser: JSObject = [
    "id": "1",
    "name": "User",
    "address": [
      "street": "123 Street",
      "city": "City",
      "country": "Country"
    ],
    "dogs": [
      [
        "id": "1",
        "name": "Pluto",
        "color": "Black"
      ]
    ]
  ]

  let jsDogs: JSArray = [
    [
      "id": "1",
      "name": "Pluto",
      "color": "Black new"
    ],
    [
      "id": "2",
      "name": "Lux",
      "color": "White"
    ]
  ]

  override func setUp() {
    super.setUp()
    Realm.Configuration.defaultConfiguration.deleteRealmIfMigrationNeeded = true
  }

  override func tearDown() {
    let realm = Realm.defaultRealm
    realm.writeBlock {
      realm.deleteAll()
    }
    super.tearDown()
  }

  func test_conflict() {
    let realm = Realm.defaultRealm
    realm.writeBlock {
      let user = User()
      user.id = "123"
      realm.addOrUpdate(user)
    }
  }

  func test_add() {
    let realm = Realm.defaultRealm
    realm.writeBlock {
      realm.add(User.self, json: jsUser)
      realm.add(User.self, json: jsUser)
    }
    guard let userID = jsUser["id"] else { assertionFailure("jsUser has no id"); return }
    let user = realm.objects(User).filter("id = %@", userID).first
    XCTAssertNotNil(user)
    realm.writeBlock {
      realm.add(User.self, json: jsUser)
    }
    XCTAssertEqual(realm.objects(User).count, 1)
  }

  func test_relation() {
    let realm = Realm.defaultRealm
    realm.writeBlock {
      realm.add(User.self, json: jsUser)
    }
    guard let userID = jsUser["id"] else { assertionFailure("jsUser has no id"); return }
    if let user = realm.objects(User).filter("id = %@", userID).first {
      let dog = user.dogs.first
      XCTAssertNotNil(dog)
    }
  }

  func test_relationChange() {
    let realm = Realm.defaultRealm
    realm.writeBlock {
      realm.add(User.self, json: jsUser)
    }
    guard let userID = jsUser["id"] else { assertionFailure("jsUser has no id"); return }
    if let user = realm.objects(User).filter("id = %@", userID).first,
      dog = user.dogs.first,
      color = jsDogs.first?["color"] as? String {
        realm.writeBlock {
          realm.add(Dog.self, json: jsDogs)
        }
        XCTAssertEqual(dog.color, color)
    }
  }

  func test_addNilObject() {
    let realm = Realm.defaultRealm
    realm.writeBlock {
      realm.add(User.self, json: jsUser)
    }
    guard let userID = jsUser["id"] else { assertionFailure("jsUser has no id"); return }
    if let user = realm.objects(User).filter("id = %@", userID).first {
      jsUser["address"] = nil
      realm.writeBlock {
        realm.add(User.self, json: jsUser)
      }
      XCTAssertNotNil(user.address)
    }
  }

  func test_addNullObject() {
    let realm = Realm.defaultRealm
    realm.writeBlock {
      realm.add(User.self, json: jsUser)
    }
    guard let userID = jsUser["id"] else { assertionFailure("jsUser has no id"); return }
    guard let user = realm.objects(User).filter("id = %@", userID).first else { return }
    jsUser["address"] = NSNull()
    realm.writeBlock {
      realm.add(User.self, json: jsUser)
    }
    XCTAssertNil(user.address)
  }

  func test_addNilList() {
    let realm = Realm.defaultRealm
    realm.writeBlock {
      realm.add(User.self, json: jsUser)
    }
    guard let userID = jsUser["id"] else { assertionFailure("jsUser has no id"); return }
    if let user = realm.objects(User).filter("id = %@", userID).first {
      jsUser["dogs"] = nil
      realm.writeBlock {
        realm.add(User.self, json: jsUser)
      }
      XCTAssertEqual(user.dogs.count, 1)
    }
  }

  func test_addNullList() {
    let realm = Realm.defaultRealm
    realm.writeBlock {
      realm.add(User.self, json: jsUser)
    }
    guard let userID = jsUser["id"] else { assertionFailure("jsUser has no id"); return }
    if let user = realm.objects(User).filter("id = %@", userID).first {
      jsUser["dogs"] = NSNull()
      realm.writeBlock {
        realm.add(User.self, json: jsUser)
      }
      XCTAssertEqual(user.dogs.count, 0)
    }
  }

  func test_multiThread() {
    let expect = expectationWithDescription("test_multiThread")
    let queue = dispatch_queue_create("test_multiThread", DISPATCH_QUEUE_CONCURRENT)
    let group = dispatch_group_create()
    for i in 0 ..< 10 {
      dispatch_group_enter(group)
      dispatch_async(queue, {
        let realm = Realm.defaultRealm
        let error = realm.writeBlock {
          realm.add(User.self, json: self.jsUser)
        }
        let thread = NSThread.currentThread()
        let addr = unsafeAddressOf(thread)
        print("thread \(addr), task \(i)")
        XCTAssertNil(error)
        dispatch_group_leave(group)
      })
    }
    dispatch_group_notify(group, dispatch_get_main_queue()) {
      expect.fulfill()
    }
    waitForExpectationsWithTimeout(10, handler: nil)
  }
}
