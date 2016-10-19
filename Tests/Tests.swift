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

    var jsUser: JSObject = [
        "id": "1",
        "name": "User",
        "address": [
            "street": "123 Street",
            "city": "City",
            "country": "Country",
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

    private lazy var load: () = {
        Realm.Configuration.defaultConfiguration.deleteRealmIfMigrationNeeded = true
        RealmS.onError { (realm, error, type) in
            XCTAssertThrowsError(error)
        }
    }()

    override func setUp() {
        super.setUp()
        let _ = load
    }

    override func tearDown() {
        let realm = RealmS()
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
            XCTAssertThrowsError(error)
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
            realm.map(User.self, json: jsUser)
        }
        let userID: String! = jsUser["id"] as? String
        let user: User! = realm.objects(User).filter("id = %@", userID).first
        XCTAssertNotNil(user)
        let addr: Address! = user.address
        XCTAssertNotNil(addr)
        XCTAssertNotNil(addr.phone)
        XCTAssertEqual(user.dogs.count, 1)
        realm.write {
            realm.map(User.self, json: jsUser)
        }
        let users = realm.objects(User).filter("id = %@", userID)
        XCTAssertEqual(users.count, 1)
    }

    func test_add() {
        var dogs: [Dog] = []
        for i in 1...3 {
            let obj = Dog()
            obj.id = "\(i)"
            obj.name = "Pluto"
            obj.color = "white"
            dogs.append(obj)
        }
        let realm = RealmS()
        realm.write {
            realm.add(dogs)
        }
        XCTAssertEqual(realm.objects(Dog).count, 3)
    }

    func test_create() {
        let realm = RealmS()
        realm.write {
            realm.create(User.self, value: jsUser)
        }
        guard let userID = jsUser["id"] else { assertionFailure("jsUser has no id"); return }
        let user: User! = realm.objects(User).filter("id = %@", userID).first
        XCTAssertNotNil(user)
        let addr: Address! = user.address
        XCTAssertNotNil(addr)
        XCTAssertNotNil(addr.phone)
        XCTAssertEqual(user.dogs.count, 1)
        realm.write {
            realm.map(User.self, json: jsUser)
        }
        let users = realm.objects(User).filter("id = %@", userID)
        XCTAssertEqual(users.count, 1)
    }

    // Also test clean
    func test_delete_object() {
        let realm = RealmS()
        realm.write {
            realm.map(User.self, json: jsUser)
        }
        guard let userID = jsUser["id"] else { assertionFailure("jsUser has no id"); return }
        if let user = realm.objects(User).filter("id = %@", userID).first {
            realm.write {
                realm.delete(user)
            }
            let users = realm.objects(User)
            XCTAssertTrue(users.isEmpty)
            let addrs = realm.objects(Address)
            XCTAssertTrue(addrs.isEmpty)
            let phones = realm.objects(Phone)
            XCTAssertTrue(phones.isEmpty)
            let dogs = realm.objects(Dog)
            XCTAssertTrue(dogs.isEmpty)
        }
    }

    // Also test clean
    func test_delete_results() {
        let realm = RealmS()
        realm.write {
            realm.map(User.self, json: jsUser)
        }
        let users = realm.objects(User)
        XCTAssertEqual(users.count, 1)
        realm.write {
            realm.delete(users)
        }
        XCTAssertTrue(realm.isEmpty)
    }

    func test_relationChange() {
        let realm = RealmS()
        realm.write {
            realm.map(User.self, json: jsUser)
        }
        let userID: String! = jsUser["id"] as? String
        if let user = realm.objects(User).filter("id = %@", userID).first,
            let dog = user.dogs.first,
            let color = jsDogs.first?["color"] as? String {
                realm.write {
                    realm.map(Dog.self, json: jsDogs)
                }
                XCTAssertEqual(dog.color, color)
        }
    }

    func test_addNilObject() {
        let realm = RealmS()
        realm.write {
            realm.map(User.self, json: jsUser)
        }
        guard let userID = jsUser["id"] else { assertionFailure("jsUser has no id"); return }
        if let user = realm.objects(User).filter("id = %@", userID).first {
            jsUser["address"] = nil
            realm.write {
                realm.map(User.self, json: jsUser)
            }
            XCTAssertNotNil(user.address)
        }
    }

    func test_addNullObject() {
        let realm = RealmS()
        realm.write {
            realm.map(User.self, json: jsUser)
        }
        guard let userID = jsUser["id"] else { assertionFailure("jsUser has no id"); return }
        guard let user = realm.objects(User).filter("id = %@", userID).first else { return }
        jsUser["address"] = NSNull()
        realm.write {
            realm.map(User.self, json: jsUser)
        }
        XCTAssertNil(user.address)
    }

    func test_addNilList() {
        let realm = RealmS()
        realm.write {
            realm.map(User.self, json: jsUser)
        }
        guard let userID = jsUser["id"] else { assertionFailure("jsUser has no id"); return }
        if let user = realm.objects(User).filter("id = %@", userID).first {
            jsUser["dogs"] = nil
            realm.write {
                realm.map(User.self, json: jsUser)
            }
            XCTAssertEqual(user.dogs.count, 1)
        }
    }

    func test_addNullList() {
        let realm = RealmS()
        realm.write {
            realm.map(User.self, json: jsUser)
        }
        guard let userID = jsUser["id"] else { assertionFailure("jsUser has no id"); return }
        if let user = realm.objects(User).filter("id = %@", userID).first {
            jsUser["dogs"] = NSNull()
            realm.write {
                realm.map(User.self, json: jsUser)
            }
            XCTAssertEqual(user.dogs.count, 0)
        }
    }

    func test_multiThread() {
        let expect = expectation(description: "test_multiThread")
        let queue = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background)
        let group = DispatchGroup()

        for _ in 0 ..< 10 {
            group.enter()
            queue.async(execute: {
                let realm = RealmS()
                realm.write {
                    realm.map(User.self, json: self.jsUser)
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
                XCTAssertEqual(insertions.count, 1)
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
                realm.map(User.self, json: self.jsUser)
            }
        })

        waitForExpectations(timeout: 10, handler: nil)
        token.stop()
    }
}
