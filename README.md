[![Build Status](https://travis-ci.org/tsrnd/realms-ios.svg?branch=master)](https://travis-ci.org/tsrnd/realms-ios)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/RealmS.svg)](https://img.shields.io/cocoapods/v/RealmS.svg)
[![Platform](https://img.shields.io/cocoapods/p/RealmS.svg?style=flat)](http://cocoadocs.org/docsets/RealmS)
[![Coverage Status](https://codecov.io/github/tsrnd/realms-ios/coverage.svg?branch=master)](https://codecov.io/github/tsrnd/realms-ios?branch=master)

[![RealmSwift](https://img.shields.io/badge/RealmSwift-~%3E%202.2-brightgreen.svg)](https://img.shields.io/badge/RealmSwift-~%3E%202.2-brightgreen.svg)
[![ObjectMapper](https://img.shields.io/badge/ObjectMapper-~%3E%202.2-brightgreen.svg)](https://img.shields.io/badge/ObjectMapper-~%3E%202.2-brightgreen.svg)

Realm + ObjectMapper
====================

## Requirements

 - iOS 8.0+
 - Xcode 9.2 (Swift 4.0+)

## Installation
 
 > Embedded frameworks require a minimum deployment target of iOS 8

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
 ```

> CocoaPods 1.2+ is required to build RealmS 2.3+

To integrate RealmS into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'RealmS', '~> 4.0.0'
```

Then, run the following command:

```bash
$ pod install
```

## Usage

### Mapping

**Rule:**
- Object has `primaryKey` must be StaticMappable (i)
- Object has no `primaryKey` should be Mappable (ii)

```swift
import RealmSwift
import ObjectMapper
import RealmS

// (i)
final class User: Object, StaticMappable {
    @objc dynamic var id: String!
    @objc dynamic var name: String?
    @objc dynamic var address: Address?
    let dogs = List<Pet>()

    override class func primaryKey() -> String? {
        return "id"
    }

    func mapping(map: Map) {
        name <- map["name"]
        address <- map["address"]
        dogs <- map["dogs"]
    }

    static func objectForMapping(map: Map) -> BaseMappable? {
        return RealmS().object(ofType: self, forMapping: map)
    }
}

// (ii)
final class Address: Object, Mappable {
    @objc dynamic var street = ""
    @objc dynamic var city = ""
    @objc dynamic var country = ""

    @objc dynamic var phone: Phone?

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
```

### Import JSON to Realm

```swift
let realm = RealmS()
realm.write {
  realm.map(User.self, jsUser) // map JSON object
  realm.map(Shop.self, jsShops) // map JSON array
}
```

> - `nil` value will be bypass, if you want set `nil` please use `NSNull()` instead.

### Clean Up

```swift
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
```

`Address` table will be clean-up after a `User` is deleted from Realm.
