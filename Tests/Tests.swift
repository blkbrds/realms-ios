//
//  Tests.swift
//  RealmS
//
//  Created by DaoNV on 3/14/16.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

@testable import RealmS
import ObjectMapper
import XCTest

extension XCTestCase {
  func initialize() {
  }
}

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
  }

  override func tearDown() {
    let realm = RealmS()
    realm.write {
      realm.deleteAll()
    }
    super.tearDown()
  }

  func testAdd() {
    let realm = RealmS()
    realm.write {
      realm.add(User.self, json: jsUser)
    }
    let user: User! = realm.objects(User).filter("id = %@", jsUser["id"]!).first
    XCTAssertNotNil(user)
  }

  func testAddMore() {
    let realm = RealmS()
    realm.write {
      realm.add(User.self, json: jsUser)
    }
    realm.write {
      realm.add(User.self, json: jsUser)
    }
    XCTAssertEqual(realm.objects(User).count, 1)
  }

  func testRelation() {
    let realm = RealmS()
    realm.write {
      realm.add(User.self, json: jsUser)
    }
    if let user = realm.objects(User).filter("id = %@", jsUser["id"]!).first {
      let dog: Dog! = user.dogs.first
      XCTAssertNotNil(dog)
    }
  }

  func testRelationChange() {
    let realm = RealmS()
    realm.write {
      realm.add(User.self, json: jsUser)
    }
    if let user = realm.objects(User).filter("id = %@", jsUser["id"]!).first,
      dog = user.dogs.first,
      color = jsDogs.first?["color"] as? String {
        realm.write {
          realm.add(Dog.self, json: jsDogs)
        }
        XCTAssertEqual(dog.color, color)
    }
  }

  func testAddNilObject() {
    let realm = RealmS()
    realm.write {
      realm.add(User.self, json: jsUser)
    }
    if let user = realm.objects(User).filter("id = %@", jsUser["id"]!).first {
      jsUser["address"] = nil
      realm.write {
        realm.add(User.self, json: jsUser)
      }
      XCTAssertNotNil(user.address)
    }
  }

  func testAddNullObject() {
    let realm = RealmS()
    realm.write {
      realm.add(User.self, json: jsUser)
    }
    if let user = realm.objects(User).filter("id = %@", jsUser["id"]!).first {
      jsUser["address"] = NSNull()
      realm.write {
        realm.add(User.self, json: jsUser)
      }
      XCTAssertNil(user.address)
    }
  }

  func testAddNilList() {
    let realm = RealmS()
    realm.write {
      realm.add(User.self, json: jsUser)
    }
    if let user = realm.objects(User).filter("id = %@", jsUser["id"]!).first {
      jsUser["dogs"] = nil
      realm.write {
        realm.add(User.self, json: jsUser)
      }
      XCTAssertEqual(user.dogs.count, 1)
    }
  }

  func testAddNullList() {
    let realm = RealmS()
    realm.write {
      realm.add(User.self, json: jsUser)
    }
    if let user = realm.objects(User).filter("id = %@", jsUser["id"]!).first {
      jsUser["dogs"] = NSNull()
      realm.write {
        realm.add(User.self, json: jsUser)
      }
      XCTAssertEqual(user.dogs.count, 0)
    }
  }
}
