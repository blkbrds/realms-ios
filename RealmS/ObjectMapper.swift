//
//  RealmMapper.swift
//  RealmS
//
//  Created by DaoNV on 1/12/16.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

import RealmSwift
import ObjectMapper

// MARK: Extend
extension RealmS {
  /*
  Insert an object has primaryKey.
  
  - warning: This method can only be called during a write transaction.
  
  - parameter type:   The object type to create.
  - parameter json:   The value used to populate the object.
  */
  public func add<T: Object where T: Mappable>(type: T.Type, json: [String : AnyObject]) -> T! {
    if let key = T.primaryKey() {
      if let id = json[key] {
        var obj: T!
        if let exist = objects(T).filter("%K = %@", key, id).first {
          obj = exist
        } else {
          obj = create(T.self, value: [key : id])
        }
        Mapper<T>().map(json, toObject: obj)
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
}

// MARK:- Mappable Objects - <T: Object where T: Mappable>

public protocol JSPrimaryKey {
  static func jsPrimaryKey() -> String?
}

/// Optional Mappable objects
public func <- <T: Object where T: Mappable, T: JSPrimaryKey>(inout left: T?, right: Map) {
  if right.mappingType == MappingType.FromJSON {
    if let value = right.currentValue {
      if left != nil {
        if value is NSNull {
          left = nil
        } else if let json = value as? [String : AnyObject] {
          if let key = T.primaryKey() {
            if let id = left!.valueForKey(key), jsKey = T.jsPrimaryKey(), jsID = json[jsKey] {
              if "\(id)" == "\(jsID)" {
                Mapper<T>().map(value, toObject: left!)
              } else {
                left = Mapper<T>().map(value)
              }
            }
          } else {
            left = Mapper<T>().map(value)
          }
        }
      }
    }
  }
}

/// Implicitly unwrapped optional Mappable objects
public func <- <T: Object where T: Mappable, T: JSPrimaryKey>(inout left: T!, right: Map) {
  if right.mappingType == MappingType.FromJSON {
    if let value = right.currentValue {
      if left != nil {
        if value is NSNull {
          left = nil
        } else if let json = value as? [String : AnyObject] {
          if let key = T.primaryKey() {
            if let id = left.valueForKey(key), jsKey = T.jsPrimaryKey(), jsID = json[jsKey] {
              if "\(id)" == "\(jsID)" {
                Mapper<T>().map(value, toObject: left!)
              } else {
                left = Mapper<T>().map(value)
              }
            }
          } else {
            left = Mapper<T>().map(value)
          }
        }
      }
    }
  }
}