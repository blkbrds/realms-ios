//
//  Model.swift
//  RealmS
//
//  Created by DaoNV on 3/14/16.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper
@testable import RealmS

typealias JSObject = [String: AnyObject]
typealias JSArray = [JSObject]

class User: Object, Mappable {
	dynamic var id: String!
	dynamic var name: String?
	dynamic var address: Address?
	let dogs = List<Dog>()

	override class func primaryKey() -> String? {
		return "id"
	}

	convenience required init?(_ map: Map) {
		self.init()
		id <- map["id"]
	}

	func mapping(map: Map) {
		name <- map["name"]
		address <- map["address"]
		dogs <- map["dogs"]
	}
}

class Address: Object, Mappable {
	dynamic var street = ""
	dynamic var city = ""
	dynamic var country = ""

	convenience required init?(_ map: Map) {
		self.init()
	}

	func mapping(map: Map) {
		street <- map["street"]
		city <- map["city"]
		country <- map["country"]
	}
}

class Dog: Object, Mappable {
	dynamic var id: String!
	dynamic var name: String?
	dynamic var color: String?

	override class func primaryKey() -> String? {
		return "id"
	}

	convenience required init?(_ map: Map) {
		self.init()
		id <- map["id"]
	}

	func mapping(map: Map) {
		name <- map["name"]
		color <- map["color"]
	}
}