[![Build Status](https://travis-ci.org/zendobk/RealmS.svg?branch=master)](https://travis-ci.org/zendobk/RealmS)

[Realm](https://github.com/realm/realm-cocoa/tree/v0.97.1)
============

Realm is a mobile database that runs directly inside phones, tablets or wearables.
This repository holds the source code for the iOS & OSX versions of Realm, for both Swift & Objective-C.

## Features

* **Mobile-first:** Realm is the first database built from the ground up to run directly inside phones, tablets and wearables.
 
* **Simple:** Data is directly [exposed as objects](https://realm.io/docs/objc/latest/#models) and [queryable by code](https://realm.io/docs/objc/latest/#queries), removing the need for ORM's riddled with performance & maintenance issues. Plus, we've worked hard to [keep our API down to just 4 common classes](https://realm.io/docs/objc/latest/api/) (Object, Array, Results and Realms) and 1 utility class (Migrations): most of our users pick it up intuitively, getting simple apps up & running in minutes.
* **Modern:** Realm supports relationships, generics, vectorization and even Swift.
* **Fast:** Realm is faster than even raw SQLite on common operations, while maintaining an extremely rich feature set.

[ObjectMapper](https://github.com/Hearst-DD/ObjectMapper/tree/1.1.1)
============

ObjectMapper is a framework written in Swift that makes it easy for you to convert your model objects (classes and structs) to and from JSON. 

## Features:
- Mapping JSON to objects
- Mapping objects to JSON
- Nested Objects (stand alone, in arrays or in dictionaries)
- Custom transformations during mapping
- Struct support

RealmS
============

## Features:
- Import data from JSON.
- Map Realm.List type with ObjectMapper.

## Requirements

 - iOS 8.0+
 - Xcode 7.2+

## Installation
 
 > **Embedded frameworks require a minimum deployment target of iOS 8.**

### CocoaPods
 
 [CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:
 
 ```bash
 $ gem install cocoapods
 ```
 
 > CocoaPods 0.39.0+ is required to build RealmS 1.2+.
 
 To integrate RealmS into your Xcode project using CocoaPods, specify it in your `Podfile`:
 
 ```ruby
 source 'https://github.com/CocoaPods/Specs.git'
 platform :ios, '8.0'
 use_frameworks!
 
 pod 'RealmS', '1.3.0'
 ```
 
 Then, run the following command:
 
 ```bash
 $ pod install
 ```