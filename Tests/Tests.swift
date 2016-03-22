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

	func test() {
		let realm = RealmS()
		realm.write {
			realm.add(User.self, json: jsUser)
		}
		let user: User! = realm.objects(User).filter("id = %@", jsUser["id"]!).first
		XCTAssertNotNil(user)

		realm.write {
			realm.add(User.self, json: jsUser)
		}
		XCTAssertEqual(realm.objects(User).count, 1)

		let dog: Dog! = user.dogs.first
		XCTAssertNotNil(dog)

		let color: String! = jsDogs.first?["color"] as? String
		XCTAssertNotNil(color)

		realm.write {
			realm.add(Dog.self, json: jsDogs)
		}
		XCTAssertEqual(dog.color, color)

		jsUser["address"] = nil
		realm.write {
			realm.add(User.self, json: jsUser)
		}
		XCTAssertNotNil(user.address)

		jsUser["address"] = NSNull()
		realm.write {
			realm.add(User.self, json: jsUser)
		}
		XCTAssertNil(user.address)

		jsUser["dogs"] = nil
		realm.write {
			realm.add(User.self, json: jsUser)
		}
		XCTAssertEqual(user.dogs.count, 1)

		jsUser["dogs"] = NSNull()
		realm.write {
			realm.add(User.self, json: jsUser)
		}
		XCTAssertEqual(user.dogs.count, 0)
	}
}
