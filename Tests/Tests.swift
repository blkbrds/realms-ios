//
//  Tests.swift
//  RealmS
//
//  Created by DaoNV on 3/14/16.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

@testable import RealmS
import XCTest

extension XCTestCase {
	func initialize() {
	}
}

class Test_RealmS: XCTestCase {
	let jsUser: JSObject = [
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
		let user = realm.objects(User).filter("id = %@", jsUser["id"]!).first
		XCTAssertNotNil(user)
		realm.write {
			realm.add(User.self, json: jsUser)
		}
		XCTAssertEqual(realm.objects(User).count, 1)
		log()
	}

	func testUpdate() {
		let realm = RealmS()
		realm.write {
			realm.add(User.self, json: jsUser)
		}
		if let user = realm.objects(User).filter("id = %@", jsUser["id"]!).first, dog = user.dogs.first, color = jsDogs.first?["color"] as? String {
			realm.write {
				realm.add(Dog.self, json: jsDogs)
			}
			XCTAssertEqual(dog.color, color)
		}
		log()
	}

	func log() {
		print("\n")
		let realm = RealmS()
		NSLog("\(realm.objects(User))")
		NSLog("\(realm.objects(Address))")
		NSLog("\(realm.objects(Dog))")
		print("\n")
	}
}
