//
//  Tests.swift
//  RealmS
//
//  Created by DaoNV on 3/14/16.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

import XCTest
import RealmSwift
import ObjectMapper
@testable import RealmS

class Tests: XCTestCase {

    var jsUsers: [[String: Any]] = [
        [
            "id": "1",
            "name": "User A",
            "address": [
                "street": "123 Street",
                "city": "City Abc",
                "country": "Country Q",
                "phone": [
                    "number": "+849876543210",
                    "type": "Work"
                ]
            ],
            "dogs": [
                [
                    "id": "1",
                    "name": "Pluto",
                    "color": "Black"
                ],
                [
                    "id": "2",
                    "name": "Gome",
                    "color": "Brown"
                ]
            ]
        ],
        [
            "id": "2",
            "name": "User B",
            "address": [
                "street": "456 Street",
                "city": "City Xyz",
                "country": "Country W",
                "phone": [
                    "number": "+849876543211",
                    "type": "Work"
                ]
            ],
            "dogs": [
                [
                    "id": "1",
                    "name": "Pluto",
                    "color": "Black"
                ],
                [
                    "id": "2",
                    "name": "Gozer",
                    "color": "White"
                ]
            ]
        ]
    ]

    var jsUser: [String: Any] {
        let jsUser: [String: Any]! = jsUsers.first
        XCTAssertNotNil(jsUser)
        return jsUser
    }

    var userId: String {
        let userId: String! = jsUser["id"] as? String
        XCTAssertNotNil(userId)
        return userId
    }

    let jsDogs: [[String: Any]] = [
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
        DispatchOnce {
            var config = Realm.Configuration.defaultConfiguration
            config.deleteRealmIfMigrationNeeded = true
            Realm.Configuration.defaultConfiguration = config
            RealmS.onError { (_, error, _) in
                XCTAssertThrowsError(error)
            }
        }
    }

    override func tearDown() {
        let realm = RealmS()
        if realm.isInWriteTransaction {
            realm.cancelWrite()
        }
        realm.write {
            realm.deleteAll()
        }
        super.tearDown()
    }

    func test_config() {
        let config = RealmS().configuration
        do {
            let origin = try Realm().configuration
            XCTAssertEqual(config.fileURL, origin.fileURL)
        } catch {
            XCTAssertFalse(true)
        }
    }

    func test_schema() {
        var classes: [String] = []
        for cls in RealmS().schema.objectSchema {
            classes.append(cls.className)
        }
        classes.sort()
        XCTAssertEqual(classes.joined(separator: ","), "Address,Dog,Phone,User")
    }

    func test_cancel() {
        let realm = RealmS()
        realm.beginWrite()
        XCTAssertTrue(realm.isInWriteTransaction)
        realm.cancelWrite()
        XCTAssertFalse(realm.isInWriteTransaction)
    }

    func test_commitWrite() {
        let realm = RealmS()
        realm.beginWrite()
        XCTAssertTrue(realm.isInWriteTransaction)
        realm.commitWrite()
        XCTAssertFalse(realm.isInWriteTransaction)
    }

    func test_map() {
        let realm = RealmS()
        realm.write {
            realm.map(User.self, json: jsUsers)
        }
        realm.write {
            realm.map(User.self, json: jsUsers)
        }
        let users = realm.objects(User.self)
        XCTAssertEqual(users.count, 2)
        let dogs = realm.objects(Dog.self)
        XCTAssertEqual(dogs.count, 2)
        let addrs = realm.objects(Address.self)
        XCTAssertEqual(addrs.count, 4)
        let user: User! = users.filter("id = %@", userId).first
        XCTAssertNotNil(user)
        let addr: Address! = user.address
        XCTAssertNotNil(addr)
        XCTAssertNotNil(addr.phone)
        XCTAssertEqual(user.dogs.count, 2)
        realm.write {
            realm.map(User.self, json: jsUsers)
        }
    }

    func test_add() {
        var dogs: [Dog] = []
        for i in 1...3 {
            let obj = Dog()
            obj.id = "\(i)"
            obj.name = "Pluto \(i)"
            obj.color = "White \(i)"
            dogs.append(obj)
        }
        let realm = RealmS()
        realm.write {
            realm.add(dogs)
        }
        XCTAssertEqual(realm.objects(Dog.self).count, 3)
    }

    func test_create() {
        let realm = RealmS()
        realm.write {
            for jsUser in jsUsers {
                realm.create(User.self, value: jsUser)
            }
        }
        let users = realm.objects(User.self).filter("id = %@", userId)
        XCTAssertEqual(users.count, 1)
        let user: User! = users.first
        let addr: Address! = user.address
        XCTAssertNotNil(addr)
        XCTAssertNotNil(addr.phone)
        XCTAssertEqual(user.dogs.count, 2)
        realm.write {
            realm.map(User.self, json: jsUsers)
        }
        XCTAssertEqual(users.count, 1)
    }

    // Also test clean
    func test_delete_object() {
        let realm = RealmS()
        realm.write {
            realm.map(User.self, json: jsUsers)
        }
        let users = realm.objects(User.self)
        XCTAssertEqual(users.count, 2)
        let user: User! = users.first
        realm.write {
            realm.delete(user)
        }
        XCTAssertEqual(users.count, 1)
        let addrs = realm.objects(Address.self)
        XCTAssertEqual(addrs.count, 1)
        let phones = realm.objects(Phone.self)
        XCTAssertEqual(phones.count, 1)
        let dogs = realm.objects(Dog.self)
        XCTAssertEqual(dogs.count, 2)
    }

    // Also test clean
    func test_delete_results() {
        let realm = RealmS()
        realm.write {
            realm.map(User.self, json: jsUsers)
        }
        let users = realm.objects(User.self)
        XCTAssertEqual(users.count, 2)
        realm.write {
            realm.delete(users)
        }
        XCTAssertTrue(realm.isEmpty)
    }

    func test_relationChange() {
        let realm = RealmS()
        realm.write {
            realm.map(User.self, json: jsUsers)
        }
        let user: User! = realm.objects(User.self).filter("id = %@", userId).first
        XCTAssertNotNil(user)
        let dog: Dog! = user.dogs.first
        XCTAssertNotNil(dog)
        let color: String! = jsDogs.first?["color"] as? String
        XCTAssertNotNil(color)
        realm.write {
            realm.map(Dog.self, json: jsDogs)
        }
        XCTAssertEqual(dog.color, color)
    }

    func test_addNilObject() {
        let realm = RealmS()
        realm.write {
            realm.map(User.self, json: jsUsers)
        }
        let user: User! = realm.objects(User.self).filter("id = %@", userId).first
        XCTAssertNotNil(user)
        var jsUser = self.jsUser
        jsUser["address"] = nil
        realm.write {
            realm.map(User.self, json: jsUser)
        }
        XCTAssertNotNil(user.address)
    }

    func test_addNullObject() {
        let realm = RealmS()
        realm.write {
            realm.map(User.self, json: jsUsers)
        }
        let user: User! = realm.objects(User.self).filter("id = %@", userId).first
        XCTAssertNotNil(user)
        var jsUser = self.jsUser
        jsUser["address"] = NSNull()
        realm.write {
            realm.map(User.self, json: jsUser)
        }
        XCTAssertNil(user.address)
    }

    func test_addNilList() {
        let realm = RealmS()
        realm.write {
            realm.map(User.self, json: jsUsers)
        }
        let user: User! = realm.objects(User.self).filter("id = %@", userId).first
        XCTAssertNotNil(user)
        var jsUser = self.jsUser
        jsUser["dogs"] = nil
        realm.write {
            realm.map(User.self, json: jsUser)
        }
        XCTAssertEqual(user.dogs.count, 2)
    }

    func test_addNullList() {
        let realm = RealmS()
        realm.write {
            realm.map(User.self, json: jsUsers)
        }
        let user: User! = realm.objects(User.self).filter("id = %@", userId).first
        XCTAssertNotNil(user)
        var jsUser = self.jsUser
        jsUser["dogs"] = NSNull()
        realm.write {
            realm.map(User.self, json: jsUsers)
        }
        XCTAssertEqual(user.dogs.count, 2)
    }

    func test_multiThread() {
        let expect = expectation(description: "test_multiThread")
        let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.default)
        let group = DispatchGroup()

        let jsUsers = self.jsUsers
        for _ in 0 ..< 10 {
            group.enter()
            queue.async(execute: {
                let realm = RealmS()
                realm.write {
                    realm.map(User.self, json: jsUsers)
                }
                group.leave()
            })
        }

        group.notify(queue: DispatchQueue.main) {
            expect.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }

    func test_notif() {
        let expect = expectation(description: "test_notif")
        let queue = DispatchQueue.global(qos: DispatchQoS.background.qosClass)

        let realm = RealmS()
        let users = realm.objects(User.self)
        let token = users.addNotificationBlock { change in
            switch change {
            case .update(_, let deletions, let insertions, let modifications):
                XCTAssertEqual(deletions.count, 0)
                XCTAssertEqual(insertions.count, 2)
                XCTAssertEqual(modifications.count, 0)
                expect.fulfill()
            case .error(let error):
                XCTAssertThrowsError(error)
            default:
                break
            }
        }

        queue.async(execute: {
            let realm = RealmS()
            realm.write {
                realm.map(User.self, json: self.jsUsers)
            }
        })

        waitForExpectations(timeout: 10, handler: nil)
        token.stop()
    }
}
