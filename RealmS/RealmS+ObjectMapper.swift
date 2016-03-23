//
//  RealmMapper.swift
//  RealmS
//
//  Created by DaoNV on 1/12/16.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

import RealmSwift
import ObjectMapper

// MARK: Mapping
extension RealmS {
  /*
   Import object from json.

   - warning: This method can only be called during a write transaction.

   - parameter type:   The object type to create.
   - parameter json:   The value used to populate the object.
   */
  public func add<T: Object where T: Mappable>(type: T.Type, json: [String: AnyObject]) -> T? {
    if let obj = Mapper<T>().map(json) {
      if obj.realm == nil {
        add(obj)
      }
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
  public func add<T: Object where T: Mappable>(type: T.Type, json: [[String: AnyObject]]) -> [T] {
    var objs = [T]()
    for js in json {
      if let obj = add(type, json: js) {
        objs.append(obj)
      }
    }
    return objs
  }
}

extension Mapper where N: Object {
  public func map(json: [String: AnyObject]) -> N? {
    let mapper = Mapper<N>()
    if let key = N.primaryKey() {
      if let obj = test(N.self, json: json) {
        if let id = obj.valueForKey(key) {
          if let old = RealmS().objectForPrimaryKey(N.self, key: id) {
            return mapper.map(json, toObject: old)
          } else {
            return mapper.map(json, toObject: obj)
          }
        } else {
          NSLog("\(N.self) must map primary key in init?(_ map: Map)")
        }
      }
      return nil
    } else {
      if let obj = test(N.self, json: json) {
        return mapper.map(json, toObject: obj)
      }
    }
    return nil
  }

  public func map(jsArray: [[String: AnyObject]]) -> [N] {
    var objs = [N]()
    for json in jsArray {
      if let obj = map(json) {
        objs.append(obj)
      }
    }
    return objs
  }

  private func test<T: Mappable>(type: T.Type, json: [String: AnyObject]) -> T? {
    let map = Map(mappingType: .FromJSON, JSONDictionary: json, toObject: true)
    return T.init(map)
  }
}

// MARK: Operators
public func <- <T: Object where T: Mappable>(inout left: T?, right: Map) {
  if right.mappingType == MappingType.FromJSON {
    if let value = right.currentValue {
      if left != nil && value is NSNull {
        left = nil
        return
      }
      if let json = value as? [String: AnyObject], obj = Mapper<T>().map(json) {
        left = obj
      }
    }
  } else {
    left <- (right, ObjTrans<T>())
  }
}

public func <- <T: Object where T: Mappable>(inout left: T!, right: Map) {
  var _left: T? = left
  _left <- right
}

public func <- <T: Object where T: Mappable>(inout left: T, right: Map) {
  fatalError("relation must be optional or implicitly unwrapped optional")
}

public func <- <T: Object where T: Mappable>(left: List<T>, right: Map) {
  if right.mappingType == MappingType.FromJSON {
    if let value = right.currentValue {
      left.removeAll()
      if let json = value as? [[String: AnyObject]] {
        let objs = Mapper<T>().map(json)
        left.appendContentsOf(objs)
      }
    }
  } else {
    var _left = left
    _left <- (right, ListTrans<T>())
  }
}

// MARK: Private
private class ObjTrans<T: Object where T: Mappable>: TransformType {
  func transformFromJSON(value: AnyObject?) -> T? {
    fatalError("please use direct mapping without transform")
  }

  func transformToJSON(value: T?) -> AnyObject? {
    if let value = value {
      var json = Mapper<T>().toJSON(value)
      if let key = T.primaryKey() {
        json[key] = value.valueForKey(key)
      }
      return json
    }
    return NSNull()
  }
}

private class ListTrans<T: Object where T: Mappable>: TransformType {
  func transformFromJSON(value: AnyObject?) -> List<T>? {
    fatalError("please use direct mapping without transform")
  }

  func transformToJSON(value: List<T>?) -> AnyObject? {
    if let list = value {
      var json = [[String: AnyObject]]()
      let mapper = Mapper<T>()
      for obj in list {
        json.append(mapper.toJSON(obj))
      }
      return json
    }
    return NSNull()
  }
}
