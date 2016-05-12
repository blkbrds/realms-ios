//
//  RealmS.swift
//  RealmS
//
//  Created by DaoNV on 1/10/16.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

import RealmSwift

public var RLM: Realm! {
  do {
    return try Realm()
  } catch {
    return nil
  }
}

public extension Realm {

  public static func removeDefaultStoreIfNeeds() -> NSError? {
    if RLM == nil {
      guard let url = Configuration.defaultConfiguration.fileURL else { return nil }
      do {
        try NSFileManager.defaultManager().removeItemAtURL(url)
      } catch {
        return error as NSError
      }
    }
    return nil
  }

  public func writes(@noescape block: (() -> Void)) -> NSError? {
    do {
      try write(block)
    } catch {
      return error as NSError
    }
    return nil
  }

  public func beginWrites() {
    if !inWriteTransaction {
      beginWrite()
    }
  }

  public func commitWrites() -> NSError? {
    do {
      try commitWrite()
      return nil
    } catch {
      return error as NSError
    }
  }

  public func cancelWrites() {
    if inWriteTransaction {
      cancelWrite()
    }
  }

  public func adds<T: Object>(object: T) {
    add(object, update: T.primaryKey() != nil)
  }

  public func adds<S: SequenceType where S.Generator.Element: Object>(objects: S) {
    let update = S.Generator.Element.primaryKey() != nil
    for obj in objects {
      add(obj, update: update)
    }
  }

  public func creates<T: Object>(type: T.Type, value: AnyObject = [:]) -> T {
    let update = T.primaryKey() != nil
    let obj = create(type, value: value, update: update)
    return obj
  }

  public func dynamicCreates(className: String, value: AnyObject = [:]) -> DynamicObject {
    let clazz = NSClassFromString(className) as? Object.Type
    let update = clazz?.primaryKey() != nil
    let obj = dynamicCreate(className, value: value, update: update)
    return obj
  }
}
