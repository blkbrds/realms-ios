//
//  RealmMapper.swift
//  RealmS
//
//  Created by DaoNV on 1/12/16.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

import RealmSwift
import ObjectMapper

public typealias JSObject = [String: AnyObject]
public typealias JSArray = [JSObject]

// MARK: Mapping
extension Realm {

  /*
   Import object from json.

   - warning: This method can only be called during a write transaction.

   - parameter type:   The object type to create.
   - parameter json:   The value used to populate the object.
   */
  public func adds<T: Object where T: Mappable>(type: T.Type, json: JSObject) -> T? {
    if let obj = Mapper<T>().map(json) {
      if obj.realm == nil {
        adds(obj)
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
  public func adds<T: Object where T: Mappable>(type: T.Type, json: JSArray) -> [T] {
    var objs = [T]()
    for js in json {
      if let obj = adds(type, json: js) {
        objs.append(obj)
      }
    }
    return objs
  }
}

extension Mapper where N: Object {
  public func map(json: JSObject) -> N? {
    let mapper = Mapper<N>()
    if let key = N.primaryKey() {
      if let obj = test(N.self, json: json) {
        if let id = obj.valueForKey(key) {
          if let old = RLM.objectForPrimaryKey(N.self, key: id) {
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

  public func map(jsArray: JSArray) -> [N] {
    var objs = [N]()
    for json in jsArray {
      if let obj = map(json) {
        objs.append(obj)
      }
    }
    return objs
  }

  private func test<T: Mappable>(type: T.Type, json: JSObject) -> T? {
    let map = Map(mappingType: .FromJSON, JSONDictionary: json, toObject: true)
    return T.init(map)
  }
}

// MARK: Operators
public func <- <T: Object where T: Mappable>(inout left: T?, right: Map) {
  if right.mappingType == MappingType.FromJSON {
    if !right.isKeyPresent { return }
    guard let value = right.currentValue else {
      left = nil
      return
    }
    guard let json = value as? JSObject, let obj = Mapper<T>().map(json) else { return }
    left = obj
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
    if !right.isKeyPresent { return }
    left.removeAll()
    guard let json = right.currentValue as? JSArray else { return }
    let objs = Mapper<T>().map(json)
    left.appendContentsOf(objs)
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
    guard let obj = value else { return NSNull() }
    var json = Mapper<T>().toJSON(obj)
    if let key = T.primaryKey() {
      json[key] = obj.valueForKey(key)
    }
    return json
  }
}

private class ListTrans<T: Object where T: Mappable>: TransformType {
  func transformFromJSON(value: AnyObject?) -> List<T>? {
    fatalError("please use direct mapping without transform")
  }

  func transformToJSON(value: List<T>?) -> AnyObject? {
    guard let list = value else { return NSNull() }
    var json = JSArray()
    let mapper = Mapper<T>()
    for obj in list {
      json.append(mapper.toJSON(obj))
    }
    return json
  }
}
