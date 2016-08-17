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

    /**
     Import JSON as Mappable Object.
     - parammeter T: Mappable Object.
     - parameter type: mapped type.
     - parameter json: JSON type is `[String: AnyObject]`.
     - returns: mapped object.
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

    /**
     Import JSON as array of Mappable Object.
     - parammeter T: Mappable Object.
     - parameter type: mapped type.
     - parameter json: JSON type is `[[String: AnyObject]]`.
     - returns: mapped objects.
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

    /**
     Map JSON as Mappable Object.
     - parammeter N: Mappable Object.
     - parameter json: JSON type is `[String: AnyObject]`.
     - returns: mapped object.
     */
    public func map(json: JSObject) -> N? {
        let mapper = Mapper<N>()
        let map = Map(mappingType: .FromJSON, JSONDictionary: json, toObject: true)

        guard let key = N.primaryKey() else {
            guard let obj = N.init(map: map) else { return nil }
            return mapper.map(json, toObject: obj)
        }
        guard let obj = N.init(map: map) else { return nil }
        guard let id = obj.valueForKey(key) else {
            fatalError("\(N.self)'s primary key must be mapped in init?(_ map: Map)")
        }

        if let old = RealmS().objectForPrimaryKey(N.self, key: id) {
            return mapper.map(json, toObject: old)
        } else {
            return mapper.map(json, toObject: obj)
        }
    }

    /**
     Map JSON as Mappable Object.
     - parammeter N: Mappable Object.
     - parameter jsArray: JSON type is `[[String: AnyObject]]`.
     - returns: mapped objects.
     */
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

/**
 Map to optional Mappable Object.
 - parammeter T: Mappable Object.
 - parameter left: Optional variable.
 - parameter right: Map object.
 */
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

/**
 Map to implicitly unwrapped optional Mappable Object.
 - parammeter T: Mappable Object.
 - parameter left: Implicitly unwrapped optional variable.
 - parameter right: Map object.
 */
public func <- <T: Object where T: Mappable>(inout left: T!, right: Map) {
    var object: T? = left
    object <- right
}

/**
 Relation must be marked as being optional or implicitly unwrapped optional.
 - parammeter T: Mappable Object.
 - parameter left: mapped variable.
 - parameter right: Map object.
 */
@available( *, deprecated = 1, message = "relation must be marked as being optional or implicitly unwrapped optional")
public func <- <T: Object where T: Mappable>(inout left: T, right: Map) {
    fatalError("deprecated: relation must be marked as being optional or implicitly unwrapped optional")
}

/**
 Map to List of Mappable Object.
 - parammeter T: Mappable Object.
 - parameter left: mapped variable.
 - parameter right: Map object.
 */
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

/**
 Transform for Object, only support transform to JSON.
 */
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

/**
 Transform for List of Object, only support transform to JSON.
 */
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
