//
//  RealmMapper.swift
//  RealmS
//
//  Created by DaoNV on 1/12/16.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

import ObjectMapper

public protocol JSPrimaryKey {
    static func jsPrimaryKey() -> String?
}

extension RealmS {
  /*
  Import object from json.
  
  - warning: This method can only be called during a write transaction.
  
  - parameter type:   The object type to create.
  - parameter json:   The value used to populate the object.
  */
  public func add<T: Object where T: Mappable, T: JSPrimaryKey>(type: T.Type, json: [String : AnyObject]) -> T? {
    if let key = T.primaryKey() {
      if let jsKey = T.jsPrimaryKey(), id = json[jsKey] {
        if let obj = objects(T).filter("%K = %@", key, id).first {
          Mapper<T>().map(json, toObject: obj)
          return obj
        } else if let obj = Mapper<T>().map(json) {
          add(obj)
          return obj
        }
      }
    } else if let obj = Mapper<T>().map(json) {
      add(obj)
      return obj
    }
    return nil
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

// MARK:- <T: Object where T: Mappable, T: JSPrimaryKey>

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