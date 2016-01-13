//
//  RealmMapper.swift
//  RealmS
//
//  Created by DaoNV on 1/12/16.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

import RealmSwift
import ObjectMapper

// MARK: Import
extension Map {
  public func pk<T>(jsKey: String?) -> T! {
    if let jsKey = jsKey {
      return self[jsKey].value()
    }
    return nil
  }
}

extension RealmS {
  /*
  Import object from json.
  
  - warning: This method can only be called during a write transaction.
  
  - parameter type:   The object type to create.
  - parameter json:   The value used to populate the object.
  */
  public func add<T: Object where T: Mappable, T: JSPrimaryKey>(type: T.Type, json: [String : AnyObject]) -> T! {
    if let key = T.primaryKey() {
      if let jsKey = T.jsPrimaryKey(), id = json[jsKey] {
        var obj: T!
        if let exist = objects(T).filter("%K = %@", key, id).first {
          obj = exist
          Mapper<T>().map(json, toObject: obj)
        } else {
          obj = Mapper<T>().map(json)
          add(obj)
        }
        return obj
      } else {
        return nil
      }
    } else if let obj = Mapper<T>().map(json) {
      add(obj)
      return obj
    } else {
      return nil
    }
  }
  
  /*
  Import array from json.
  
  - warning: This method can only be called during a write transaction.
  
  - parameter type:   The object type to create.
  - parameter json:   The value used to populate the object.
  */
  public func add<T: Object where T: Mappable, T: JSPrimaryKey>(type: T.Type, json: [[String : AnyObject]]) -> [T] {
    var objs = [T]()
    for (_, js) in json.enumerate() {
      if let obj = add(type, json: js) {
        objs.append(obj)
      }
    }
    return objs
  }
}

// MARK:- Mappable Objects - <T: Object where T: Mappable>

public protocol JSPrimaryKey {
  static func jsPrimaryKey() -> String?
}

/// Optional Mappable objects
public func <- <T: Object where T: Mappable, T: JSPrimaryKey>(inout left: T?, right: Map) {
  if right.mappingType == MappingType.FromJSON {
    if let value = right.currentValue {
      if left != nil && value is NSNull {
        left = nil
        return
      }
      if let json = value as? [String : AnyObject], obj = RealmS().add(T.self, json: json) {
        left = obj
      }
    }
  }
}

/// Implicitly unwrapped optional Mappable objects
public func <- <T: Object where T: Mappable, T: JSPrimaryKey>(inout left: T!, right: Map) {
  if right.mappingType == MappingType.FromJSON {
    if let value = right.currentValue {
      if left != nil && value is NSNull {
        left = nil
        return
      }
      if let json = value as? [String : AnyObject], obj = RealmS().add(T.self, json: json) {
        left = obj
      }
    }
  }
}

/// Implicitly unwrapped optional Mappable objects
public func <- <T: Object where T: Mappable, T: JSPrimaryKey>(left: List<T>, right: Map) {
  if right.mappingType == MappingType.FromJSON {
    if let value = right.currentValue {
      left.removeAll()
      if let json = value as? [[String : AnyObject]] {
        let objs = RealmS().add(T.self, json: json)
        left.appendContentsOf(objs)
      }
    }
  }
}