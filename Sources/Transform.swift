//
//  Transform.swift
//  RealmS
//
//  Created by DaoNV on 4/26/17.
//  Copyright © 2017 Apple Inc. All rights reserved.
//

import RealmSwift
import ObjectMapper

// MARK: - Internal

/**
 Transform for Object, only support transform to JSON.
 */
internal final class ObjectTransform<T: Object>: TransformType where T: BaseMappable {
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
internal final class ListTransform<T: Object>: TransformType where T: BaseMappable {
    @available( *, deprecated: 1, message: "Please use direct mapping without transform.")
    func transformFromJSON(_ value: Any?) -> List<T>? {
        assertionFailure("Deprecated: Please use direct mapping without transform.")
        return nil
    }

    func transformToJSON(_ value: List<T>?) -> Any? {
        guard let list = value else { return NSNull() }
        var json: [[String: Any]] = []
        let mapper = Mapper<T>()
        for obj in list {
            json.append(mapper.toJSON(obj))
        }
        return json
    }
}
