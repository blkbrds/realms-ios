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
extension RealmS {

    // MARK: Import

    /*
     Add object from json.

     - warning: This method can only be called during a write transaction.

     - parameter type:   The object type to create.
     - parameter json:   The value used to populate the object.
     */
    public func map<T: Object where T: Mappable>(type: T.Type, json: JSObject) -> T? {
        if let obj = Mapper<T>().map(json) {
            if obj.realm == nil {
                add(obj)
            }
            return obj
        }
        return nil
    }

    /*
     Add array from json.

     - warning: This method can only be called during a write transaction.

     - parameter type:   The object type to create.
     - parameter json:   The value used to populate the object.
     */
    public func map<T: Object where T: Mappable>(type: T.Type, json: JSArray) -> [T] {
        var objs = [T]()
        for js in json {
            if let obj = map(type, json: js) {
                objs.append(obj)
            }
        }
        return objs
    }
}

extension Mappable {
    private init?(map: Map) {
        self.init(map)
    }
}

extension Mapper where N: Object {
    public func map(json: JSObject) -> N? {
        let mapper = Mapper<N>()
        let map = Map(mappingType: .FromJSON, JSONDictionary: json, toObject: true)
        if let key = N.primaryKey() {
            if let obj = N.init(map: map) {
                if let id = obj.valueForKey(key) {
                    if let old = RealmS().objectForPrimaryKey(N.self, key: id) {
                        return mapper.map(json, toObject: old)
                    } else {
                        return mapper.map(json, toObject: obj)
                    }
                } else {
                    fatalError("\(N.self)'s primary key must be mapped in init?(_ map: Map)")
                }
            }
            return nil
        } else {
            if let obj = N.init(map: map) {
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
}

// MARK: Operators
public func <- <T: Object where T: Mappable>(inout left: T?, right: Map) {
    if right.mappingType == MappingType.FromJSON {
        if !right.isKeyPresent { return }
        guard let value = right.currentValue else {
            left = nil
            return
        }
        guard let json = value as? JSObject, obj = Mapper<T>().map(json) else { return }
        left = obj
    } else {
        left <- (right, ObjectTransform<T>())
    }
}

public func <- <T: Object where T: Mappable>(inout left: T!, right: Map) {
    var _left: T? = left
    _left <- right
}

@available( *, deprecated = 1, message = "relation must be marked as being optional or implicitly unwrapped optional")
public func <- <T: Object where T: Mappable>(inout left: T, right: Map) {
    fatalError("relation must be marked as being optional or implicitly unwrapped optional")
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
        _left <- (right, ListTransform<T>())
    }
}

// MARK: Transform

private class ObjectTransform<T: Object where T: Mappable>: TransformType {
    @available( *, deprecated = 1, message = "please use direct mapping without transform")
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

private class ListTransform<T: Object where T: Mappable>: TransformType {
    @available( *, deprecated = 1, message = "please use direct mapping without transform")
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
