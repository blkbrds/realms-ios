//
//  CleanUp.swift
//  RealmS
//
//  Created by DaoNV on 5/24/16.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

import RealmSwift
import RealmS

extension User {
    override class func relativedTypes() -> [Object.Type] {
        return [Address.self, Dog.self]
    }

    override class func clean() { }
}

extension Address {
    override class func relativedTypes() -> [Object.Type] {
        return [Phone.self]
    }

    override class func clean() {
        let realm = RealmS()
        let objs = realm.objects(self).filter("users.@count = 0")
        realm.write {
            realm.delete(objs)
        }
    }
}

extension Phone {
    override class func clean() {
        let realm = RealmS()
        let objs = realm.objects(self).filter("addresses.@count = 0")
        realm.write {
            realm.delete(objs)
        }
    }
}

extension Dog {
    override class func relativedTypes() -> [Object.Type] {
        return [Phone.self]
    }

    override class func clean() {
        let realm = RealmS()
        let objs = realm.objects(self).filter("users.@count = 0")
        realm.write {
            realm.delete(objs)
        }
    }
}
