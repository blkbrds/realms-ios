//
//  Operator.swift
//  RealmS
//
//  Created by DaoNV on 4/26/17.
//  Copyright © 2017 Apple Inc. All rights reserved.
//

import RealmSwift
import ObjectMapper

// MARK: - Operators

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
        guard let json = value as? [String: Any],
            let obj = Mapper<T>().map(JSON: json) else { return }
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
 Map to List of Mappable Object.
 - parammeter T: Mappable Object.
 - parameter left: mapped variable.
 - parameter right: Map object.
 */
public func <- <T: Object>(left: List<T>, right: Map) where T: BaseMappable {
    if right.mappingType == MappingType.fromJSON {
        if !right.isKeyPresent { return }
        left.removeAll()
        guard let json = right.currentValue as? [[String: Any]],
            let objs = Mapper<T>().mapArray(JSONArray: json) else { return }
        left.append(objectsIn: objs)
    } else {
        var _left = left
        _left <- (right, ListTransform<T>())
    }
}

// MARK: - Deprecated

/**
 Relation must be marked as being optional or implicitly unwrapped optional.
 - parammeter T: Mappable Object.
 - parameter left: mapped variable.
 - parameter right: Map object.
 */
@available( *, deprecated: 1, message: "Relation must be marked as being optional or implicitly unwrapped optional.")
public func <- <T: Object>(left: inout T, right: Map) where T: Mappable {
    assertionFailure("Deprecated: Relation must be marked as being optional or implicitly unwrapped optional.")
}
