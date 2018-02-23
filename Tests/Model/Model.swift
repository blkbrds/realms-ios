//
//  Model.swift
//  RealmS
//
//  Created by DaoNV on 3/14/16.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

import RealmSwift
import ObjectMapper
import RealmS

final class User: Object, StaticMappable {
    @objc dynamic var id = ""
    @objc dynamic var name: String?
    @objc dynamic var address: Address?
    let dogs = List<Pet>()
    let cats = List<Pet>()

    override class func primaryKey() -> String? {
        return "id"
    }

    func mapping(map: Map) {
        name <- map["name"]
        address <- map["address"]
        dogs <- map["dogs"]
        cats <- map["cats"]
    }

    static func objectForMapping(map: Map) -> BaseMappable? {
        return RealmS().object(ofType: self, forMapping: map)
    }
}

final class Address: Object, Mappable {
    @objc dynamic var street = ""
    @objc dynamic var city = ""
    @objc dynamic var country = ""

    let phones = List<Phone>()

    let users = LinkingObjects(fromType: User.self, property: "address")

    convenience required init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        street <- map["street"]
        city <- map["city"]
        country <- map["country"]
        phones <- map["phones"]
    }
}

final class Phone: Object, StaticMappable {
    enum PhoneType: String {
        case work
        case home
    }

    @objc dynamic var number = ""
    @objc dynamic var type = PhoneType.home.rawValue

    let addresses = LinkingObjects(fromType: Address.self, property: "phones")

    override static func primaryKey() -> String {
        return "number"
    }

    func mapping(map: Map) {
        type <- map["type"]
    }

    static func objectForMapping(map: Map) -> BaseMappable? {
        return RealmS().object(ofType: self, forMapping: map)
    }
}

final class Pet: Object, StaticMappable {
    @objc dynamic var id = ""
    @objc dynamic var name: String?
    @objc dynamic var color: Color?

    let users = LinkingObjects(fromType: User.self, property: "dogs")

    override class func primaryKey() -> String? {
        return "id"
    }

    func mapping(map: Map) {
        name <- map["name"]
        color <- map["color"]
    }

    static func objectForMapping(map: Map) -> BaseMappable? {
        return RealmS().object(ofType: self, forMapping: map, jsonPrimaryKey: "pk")
    }
}

final class Color: Object, StaticMappable {
    @objc dynamic var hex: String!
    @objc dynamic var name: String?

    let dogs = LinkingObjects(fromType: Pet.self, property: "color")

    override class func primaryKey() -> String? {
        return "hex"
    }

    func mapping(map: Map) {
        name <- map["name"]
    }

    static func objectForMapping(map: Map) -> BaseMappable? {
        return RealmS().object(ofType: self, forMapping: map)
    }
}
