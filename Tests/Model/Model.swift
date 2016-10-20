//
//  Model.swift
//  RealmS
//
//  Created by DaoNV on 3/14/16.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

import RealmSwift
import ObjectMapper
@testable import RealmS

class User: Object, Mappable {
    dynamic var id: String!
    dynamic var name: String?
    dynamic var address: Address?
    let dogs = List<Dog>()

    override class func primaryKey() -> String? {
        return "id"
    }

    convenience required init?(map: Map) {
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

    dynamic var phone: Phone?

    let users = LinkingObjects(fromType: User.self, property: "address")

    convenience required init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        street <- map["street"]
        city <- map["city"]
        country <- map["country"]
        phone <- map["phone"]
    }
}

class Phone: Object, Mappable {
    enum PhoneType: String {
        case Work = "Work"
        case Home = "Home"
    }

    dynamic var number = ""
    dynamic var type = PhoneType.Home.rawValue

    let addresses = LinkingObjects(fromType: Address.self, property: "phone")

    convenience required init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        number <- map["number"]
        type <- map["type"]
    }
}

class Dog: Object, Mappable {
    dynamic var id: String!
    dynamic var name: String?
    dynamic var color: String?

    let users = LinkingObjects(fromType: User.self, property: "dogs")

    override class func primaryKey() -> String? {
        return "id"
    }

    convenience required init?(map: Map) {
        self.init()
        id <- map["id"]
    }

    func mapping(map: Map) {
        name <- map["name"]
        color <- map["color"]
    }
}
