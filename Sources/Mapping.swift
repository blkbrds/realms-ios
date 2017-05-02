//
//  RealmMapper.swift
//  RealmS
//
//  Created by DaoNV on 1/12/16.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

import RealmSwift
import ObjectMapper

// MARK: - Main
extension RealmS {

    // MARK: Map

    /**
     Import JSON as Mappable Object.
     - parammeter T: Mappable Object.
     - parameter type: mapped type.
     - parameter json: JSON type is `[String: AnyObject]`.
     - returns: mapped object.
     */
    @discardableResult
    public func map<T: Object>(_ type: T.Type, json: [String: Any]) -> T? where T: BaseMappable {
        guard let obj = Mapper<T>().map(JSON: json) else {
            return nil
        }
        if obj.realm == nil {
            add(obj)
        }
        return obj
    }

    /**
     Import JSON as array of Mappable Object.
     - parammeter T: Mappable Object.
     - parameter type: mapped type.
     - parameter json: JSON type is `[[String: AnyObject]]`.
     - returns: mapped objects.
     */
    @discardableResult
    public func map<T: Object>(_ type: T.Type, json: [[String: Any]]) -> [T] where T: BaseMappable {
        var objs = [T]()
        for js in json {
            if let obj = map(type, json: js) {
                objs.append(obj)
            }
        }
        return objs
    }
}

// MARK: - StaticMappable pre-implement
extension RealmS {
    public func object<T: Object>(ofType: T.Type, forMapping map: Map) -> T? where T: BaseMappable {
        guard let key = T.primaryKey() else {
            return T()
        }
        guard let id: Any = map[key].value() else { return nil }
        if let exist = object(ofType: T.self, forPrimaryKey: id) {
            return exist
        }
        let new = T()
        new.setValue(id, forKey: key)
        return new
    }
}
