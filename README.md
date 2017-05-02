[![Build Status](https://travis-ci.org/zendobk/RealmS.svg?branch=master)](https://travis-ci.org/zendobk/RealmS)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/RealmS.svg)](https://img.shields.io/cocoapods/v/RealmS.svg)
[![Platform](https://img.shields.io/cocoapods/p/RealmS.svg?style=flat)](http://cocoadocs.org/docsets/RealmS)
[![Coverage Status](https://codecov.io/github/zendobk/RealmS/coverage.svg?branch=master)](https://codecov.io/github/zendobk/RealmS?branch=master)

[![RealmSwift](https://img.shields.io/badge/RealmSwift-~%3E%202.2-brightgreen.svg)](https://img.shields.io/badge/RealmSwift-~%3E%202.2-brightgreen.svg)
[![ObjectMapper](https://img.shields.io/badge/ObjectMapper-~%3E%202.2-brightgreen.svg)](https://img.shields.io/badge/ObjectMapper-~%3E%202.2-brightgreen.svg)

Realm + ObjectMapper
====================

## Requirements

 - iOS 8.0+
 - Xcode 8.3 (Swift 3.1)

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

pod 'RealmS', '~> 2.3'
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
    dynamic var id: String!
    dynamic var name: String?
    dynamic var address: Address?
    let dogs = List<Dog>()

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
```

### Import JSON to Realm

```swift
let realm = RealmS()
realm.write {
  realm.map(User.self, jsUser) // map JSON object
  realm.map(Shop.self, jsShops) // map JSON array
}
```

> nil value will be bypass, if you want set `nil` please use `NSNull()` instead

### Clean Up

```swift
extension User {
    override public class func relativedTypes() -> [Object.Type] {
        return [Address.self, Dog.self]
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
