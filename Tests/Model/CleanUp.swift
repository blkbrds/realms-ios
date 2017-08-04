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
    override public class func relativedTypes() -> [Object.Type] {
        return [Address.self, Pet.self]
    }

    override public class func clean() { }
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

extension Pet {
    override class func relativedTypes() -> [Object.Type] {
        return [Color.self]
    }

    override class func clean() {
        let realm = RealmS()
        let objs = realm.objects(self).filter("users.@count = 0")
        realm.write {
            realm.delete(objs)
        }
    }
}

extension Color {
    override class func clean() {
        let realm = RealmS()
        let objs = realm.objects(self).filter("dogs.@count = 0")
        realm.write {
            realm.delete(objs)
        }
    }
}
