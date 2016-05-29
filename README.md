[![Build Status](https://travis-ci.org/zendobk/RealmS.svg?branch=master)](https://travis-ci.org/zendobk/RealmS)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/RealmS.svg)](https://img.shields.io/cocoapods/v/RealmS.svg)
[![Platform](https://img.shields.io/cocoapods/p/RealmS.svg?style=flat)](http://cocoadocs.org/docsets/RealmS)
[![Coverage Status](https://codecov.io/github/zendobk/RealmS/coverage.svg?branch=master)](https://codecov.io/github/zendobk/RealmS?branch=master)

[![RealmSwift](https://img.shields.io/badge/RealmSwift-~%3E%201.0-brightgreen.svg)](https://img.shields.io/badge/RealmSwift-~%3E%201.0-brightgreen.svg)
[![ObjectMapper](https://img.shields.io/badge/ObjectMapper-~%3E%201.2.0-brightgreen.svg)](https://img.shields.io/badge/ObjectMapper-~%3E%201.2.0-brightgreen.svg)

[RealmS](https://github.com/zendobk/RealmS)
============

A RealmSwift extension.

## Features:
- Data importing from JSON with truly update.
- Object, List mapping with ObjectMapper.

## Requirements

 - iOS 8.0+
 - Xcode 7.3 (Swift 2.2)

## Installation
 
 > Embedded frameworks require a minimum deployment target of iOS 8

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
 ```

> CocoaPods 1.0.0+ is required to build RealmS 1.6.0+

To integrate RealmS into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'RealmS', '~> 1.6.0'
```

Then, run the following command:

```bash
$ pod install
```

## Usage

### Mapping
```swift
import RealmSwift
import ObjectMapper
import RealmS

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

    let users = LinkingObjects(fromType: User.self, property: "address")

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

    let users = LinkingObjects(fromType: User.self, property: "dogs")

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
```
### Import JSON to Realm
```swift
let realm = RealmS()
realm.write {
  realm.map(User.self, jsUser)
  realm.map(Shop.self, jsShops)
}
```

> nil value will be bypass, if you want set `nil` please use `NSNull()` instead
 
### Clean Up

```swift
extension User {
    override class func relativedTypes() -> [Object.Type] {
        return [Address.self, Dog.self]
    }

    override class func clean() { }
}

extension Address {
    override class func clean() {
        let realm = RealmS()
        let objs = realm.objects(self).filter("users.@count = 0")
        realm.write {
            realm.delete(objs)
        }
    }
}

extension Dog {
    override class func clean() {
        let realm = RealmS()
        let objs = realm.objects(self).filter("users.@count = 0")
        realm.write {
            realm.delete(objs)
        }
    }
}
```

`Address`, `Dog` will be clean-up after a user was deleted from Realm.
