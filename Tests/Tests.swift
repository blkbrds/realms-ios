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

    let jsUsers: [[String: Any]] = {
        guard let url = Bundle(for: Tests.self).url(forResource: "users", withExtension: "json") else {
            fatalError("Missing resource.")
        }

        do {
            let data = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            guard let array = json as? [[String: Any]] else {
                fatalError("Wrong JSON format.")
            }
            return array
        } catch {
            fatalError(error.localizedDescription)
        }
    }()

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

    let jsPets: [[String: Any]] = [
        [
            "pk": "1",
            "name": "Pluto",
            "color": [
                "hex": "ff0000",
                "name": "red new"
            ]
        ],
        [
            "pk": "2",
            "name": "Lux",
            "color": [
                "hex": "ffffff",
                "name": "white new"
            ]
        ]
    ]

    var jsPet: [String: Any] {
        let jsPet: [String: Any]! = jsPets.first
        XCTAssertNotNil(jsPet)
        return jsPet
    }

    override func setUp() {
        super.setUp()
        DispatchOnce {
            Realm.Configuration.defaultConfiguration.inMemoryIdentifier = "XCTestCase database"
            let realm = RealmS()
            realm.write {
                realm.deleteAll()
            }
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
        var names: [String] = []
        for cls in RealmS().schema.objectSchema {
            names.append(cls.className)
        }
        names.sort()
        XCTAssertEqual(names.joined(separator: ","), "Address,Color,Pet,Phone,RLMClassPermission,RLMPermission,RLMPermissionRole,RLMPermissionUser,RLMRealmPermission,RealmSwiftClassPermission,RealmSwiftPermission,RealmSwiftPermissionRole,RealmSwiftPermissionUser,RealmSwiftRealmPermission,User")
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
        XCTAssertGreaterThan(users.count, 0)
        let dogs = realm.objects(Pet.self)
        XCTAssertGreaterThan(dogs.count, 0)
        let addrs = realm.objects(Address.self)
        XCTAssertGreaterThan(addrs.count, 0)
        let user: User! = users.filter("id = %@", userId).first
        XCTAssertNotNil(user)
        let addr: Address! = user.address
        XCTAssertNotNil(addr)
        XCTAssertGreaterThan(addr.phones.count, 0)
        XCTAssertGreaterThan(user.dogs.count, 0)
        realm.write {
            realm.map(User.self, json: jsUsers)
        }
    }

    func test_add() {
        var dogs: [Pet] = []
        for index in 1...3 {
            let obj = Pet()
            obj.id = "\(index)"
            obj.name = "Pluto \(index)"
            let color = Color()
            color.hex = "ffffff"
            color.name = "white"
            obj.color = color
            dogs.append(obj)
        }
        let realm = RealmS()
        realm.write {
            realm.add(dogs)
        }
        XCTAssertGreaterThan(realm.objects(Pet.self).count, 0)
    }

    func test_create() {
        let realm = RealmS()
        realm.write {
            for jsUser in jsUsers {
                realm.create(User.self, value: jsUser)
            }
        }
        let users = realm.objects(User.self).filter("id = %@", userId)
        XCTAssertGreaterThan(users.count, 0)
        let user: User! = users.first
        let addr: Address! = user.address
        XCTAssertNotNil(addr)
        XCTAssertGreaterThan(addr.phones.count, 0)
        XCTAssertGreaterThan(user.dogs.count, 0)
        realm.write {
            realm.map(User.self, json: jsUsers)
        }
        XCTAssertGreaterThan(users.count, 0)
    }

    // Also test clean
    func test_delete_object() {
        let realm = RealmS()
        realm.write {
            realm.map(User.self, json: jsUsers)
        }
        let users = realm.objects(User.self)
        XCTAssertGreaterThan(users.count, 0)
        let user: User! = users.first
        realm.write {
            realm.delete(user)
        }
        XCTAssertGreaterThan(users.count, 0)
        let addrs = realm.objects(Address.self)
        XCTAssertGreaterThan(addrs.count, 0)
        let phones = realm.objects(Phone.self)
        XCTAssertGreaterThan(phones.count, 0)
        let dogs = realm.objects(Pet.self)
        XCTAssertGreaterThan(dogs.count, 0)
    }

    // Also test clean
    func test_delete_results() {
        let realm = RealmS()
        realm.write {
            realm.map(User.self, json: jsUsers)
        }
        let users = realm.objects(User.self)
        XCTAssertGreaterThan(users.count, 0)
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
        let user: User! = realm.object(ofType: User.self, forPrimaryKey: userId)
        XCTAssertNotNil(user)
        let dog: Pet! = user.dogs.first
        XCTAssertNotNil(dog)
        guard let jsColor = jsPet["color"] as? [String: Any],
            let hex = jsColor["hex"] as? String else {
                XCTFail("Fail with hex color")
                return
        }
        realm.write {
            realm.map(Pet.self, json: jsPets)
        }
        XCTAssertEqual(dog.color?.hex, hex)
    }

    func test_addNilObject() {
        let realm = RealmS()
        realm.write {
            realm.map(User.self, json: jsUsers)
        }
        let user: User! = realm.object(ofType: User.self, forPrimaryKey: userId)
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
        let user: User! = realm.object(ofType: User.self, forPrimaryKey: userId)
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
        let user: User! = realm.object(ofType: User.self, forPrimaryKey: userId)
        XCTAssertNotNil(user)
        var jsUser = self.jsUser
        jsUser["dogs"] = nil
        realm.write {
            realm.map(User.self, json: jsUser)
        }
        XCTAssertGreaterThan(user.dogs.count, 0)
    }

    func test_addNullList() {
        let realm = RealmS()
        realm.write {
            realm.map(User.self, json: jsUsers)
        }
        let user: User! = realm.object(ofType: User.self, forPrimaryKey: userId)
        XCTAssertNotNil(user)
        var jsUser = self.jsUser
        jsUser["dogs"] = NSNull()
        realm.write {
            realm.map(User.self, json: jsUser)
        }
        XCTAssertTrue(user.dogs.isEmpty)
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
        let token = users.observe { change in
            switch change {
            case .update(_, let deletions, let insertions, let modifications):
                XCTAssertTrue(deletions.isEmpty)
                XCTAssertGreaterThan(insertions.count, 0)
                XCTAssertTrue(modifications.isEmpty)
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
        token.invalidate()
    }
}
