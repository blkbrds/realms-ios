//
//  RealmMapper.swift
//  RealmS
//
//  Created by DaoNV on 1/12/16.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

import RealmSwift
import ObjectMapper

public typealias JSObject = [String: Any]
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
    @discardableResult
    public func map<T: Object>(_ type: T.Type, json: JSObject) -> T? where T: Mappable {
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
    @discardableResult
    public func map<T: Object>(_ type: T.Type, json: JSArray) -> [T] where T: Mappable {
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
    fileprivate init?(_ map: Map) {
        self.init(map: map)
    }
}

extension Mapper where N: Object, N: Mappable {

    /**
     Map JSON as Mappable Object.
     - parammeter N: Mappable Object.
     - parameter json: JSON type is `[String: AnyObject]`.
     - returns: mapped object.
     */
    public func map(_ json: JSObject) -> N? {
        let mapper = Mapper<N>()
        let map = Map(mappingType: .fromJSON, JSON: json, toObject: true)

        guard let key = N.primaryKey() else {
            guard let obj = N(map) else { return nil }
            return mapper.map(JSON: json, toObject: obj)
        }
        guard let obj = N(map) else { return nil }
        guard let id = obj.value(forKey: key) else {
            assertionFailure("\(N.self)'s primary key must be mapped in init?(_ map: Map).")
            return nil
        }

        if let old = RealmS().object(ofType: N.self, forPrimaryKey: id) {
            return mapper.map(JSON: json, toObject: old)
        } else {
            return mapper.map(JSON: json, toObject: obj)
        }
    }

    /**
     Map JSON as Mappable Object.
     - parammeter N: Mappable Object.
     - parameter jsArray: JSON type is `[[String: AnyObject]]`.
     - returns: mapped objects.
     */
    public func map(_ jsArray: JSArray) -> [N] {
        var objs = [N]()
        for json in jsArray {
            if let obj = map(json) {
                objs.append(obj)
            }
        }
        return objs
    }
}

extension Mapper where N: Object, N: Mappable, N: StaticMappable {

    /**
     Map JSON as Mappable Object.
     - parammeter N: Mappable Object.
     - parameter json: JSON type is `[String: AnyObject]`.
     - returns: mapped object.
     */
    public func map(_ json: JSObject) -> N? {
        let mapper = Mapper<N>()
        let map = Map(mappingType: .fromJSON, JSON: json, toObject: true)

        guard let key = N.primaryKey() else {
            guard let obj = N.objectForMapping(map: map) as? N else { return nil }
            return mapper.map(JSON: json, toObject: obj)
        }
        guard let obj = N(map) else { return nil }
        guard let id = obj.value(forKey: key) else {
            assert(false, "\(N.self)'s primary key must be mapped in init?(_ map: Map)")
            return nil
        }

        if let old = RealmS().object(ofType: N.self, forPrimaryKey: id) {
            return mapper.map(JSON: json, toObject: old)
        } else {
            return mapper.map(JSON: json, toObject: obj)
        }
    }

    /**
     Map JSON as Mappable Object.
     - parammeter N: Mappable Object.
     - parameter jsArray: JSON type is `[[String: AnyObject]]`.
     - returns: mapped objects.
     */
    public func map(_ jsArray: JSArray) -> [N] {
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
public func <- <T: Object>(left: inout T?, right: Map) where T: Mappable {
    if right.mappingType == MappingType.fromJSON {
        if !right.isKeyPresent { return }
        guard let value = right.currentValue else {
            left = nil
            return
        }
        guard let json = value as? JSObject, let obj = Mapper<T>().map(json) else { return }
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
public func <- <T: Object>(left: inout T!, right: Map) where T: Mappable {
    var object: T? = left
    object <- right
}

/**
 Relation must be marked as being optional or implicitly unwrapped optional.
 - parammeter T: Mappable Object.
 - parameter left: mapped variable.
 - parameter right: Map object.
 */
@available( *, deprecated : 1, message : "Relation must be marked as being optional or implicitly unwrapped optional.")
public func <- <T: Object>(left: inout T, right: Map) where T: Mappable {
    assertionFailure("Deprecated: Relation must be marked as being optional or implicitly unwrapped optional.")
}

/**
 Map to List of Mappable Object.
 - parammeter T: Mappable Object.
 - parameter left: mapped variable.
 - parameter right: Map object.
 */
public func <- <T: Object>(left: List<T>, right: Map) where T: Mappable {
    if right.mappingType == MappingType.fromJSON {
        if !right.isKeyPresent { return }
        left.removeAll()
        guard let json = right.currentValue as? JSArray else { return }
        let objs = Mapper<T>().map(json)
        left.append(objectsIn: objs)
    } else {
        var _left = left
        _left <- (right, ListTransform<T>())
    }
}

// MARK: Transform

/**
 Transform for Object, only support transform to JSON.
 */
private class ObjectTransform<T: Object>: TransformType where T: Mappable {
    @available( *, deprecated: 1, message: "Please use direct mapping without transform.")
    func transformFromJSON(_ value: Any?) -> T? {
        assertionFailure("Deprecated: Please use direct mapping without transform.")
        return nil
    }

    func transformToJSON(_ value: T?) -> Any? {
        guard let obj = value else { return NSNull() }
        var json = Mapper<T>().toJSON(obj)
        if let key = T.primaryKey() {
            json[key] = obj.value(forKey: key)
        }
        return json
    }
}

/**
 Transform for List of Object, only support transform to JSON.
 */
private class ListTransform<T: Object>: TransformType where T: Mappable {
    @available( *, deprecated: 1, message: "Please use direct mapping without transform.")
    func transformFromJSON(_ value: Any?) -> List<T>? {
        assertionFailure("Deprecated: Please use direct mapping without transform.")
        return nil
    }

    func transformToJSON(_ value: List<T>?) -> Any? {
        guard let list = value else { return NSNull() }
        var json = JSArray()
        let mapper = Mapper<T>()
        for obj in list {
            json.append(mapper.toJSON(obj))
        }
        return json
    }
}
