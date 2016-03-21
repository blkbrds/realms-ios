//
//  RealmMapper.swift
//  RealmS
//
//  Created by DaoNV on 1/12/16.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

import RealmSwift
import ObjectMapper

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

// MARK: - Mapping
// MARK: <T: Object where T: Mappable, T: JSPrimaryKey>

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
	}
}

public func <- <T: Object where T: Mappable>(inout left: T!, right: Map) {
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
	}
}

public func <- <T: Object where T: Mappable>(inout left: [T]?, right: Map) {
	if right.mappingType == .FromJSON {
		if let value = right.currentValue {
			if let jsArray = value as? [[String: AnyObject]] {
				left = [T]()
				let mapper = Mapper<T>()
				for json in jsArray {
					if let obj = mapper.map(json) {
						left?.append(obj)
					}
				}
			} else if value is NSNull {
				left = nil
			}
		}
	} else {
		if left == nil {
			var objs: [T]? = left?.map { $0 }
			objs <- right
		} else {
			var objs: [T]? = left?.map { $0 }
			objs <- right
		}
	}
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
	}

	var objs: [T]?
	if right.mappingType == .FromJSON {
		if right.currentValue != nil {
			left.removeAll()
			objs <- right
			if let objs = objs {
				left.appendContentsOf(objs)
			}
		}
	} else {
		objs = left.map { $0 }
		objs <- right
	}
}

//public class RSMapper <T: Object where T: Mappable> {
//	let mapper = Mapper<T>()
//
//	private func test<N: Mappable>(type: N.Type, json: [String: AnyObject]) -> N? {
//		let map = Map(mappingType: .FromJSON, JSONDictionary: json, toObject: true)
//		return N.init(map)
//	}
//
//	func map(json: [String: AnyObject]) -> T? {
//		if let key = T.primaryKey() {
//			if let obj = test(T.self, json: json) {
//				if let id = obj.valueForKey(key) {
//					if let old = RealmS().objectForPrimaryKey(T.self, key: id) {
//						return mapper.map(json, toObject: old)
//					} else {
//						return mapper.map(json)
//					}
//				} else {
//					NSLog("\(T.self) must map primary key in init?(_ map: Map)")
//				}
//			}
//			return nil
//		} else {
//			return mapper.map(json)
//		}
//	}
//
//	func map(jsArray: [[String: AnyObject]]) -> [T] {
//		var objs = [T]()
//		for json in jsArray {
//			if let obj = map(json) {
//				objs.append(obj)
//			}
//		}
//		return objs
//	}
//}

extension Mapper where N: Object {
	private func test<T: Mappable>(type: T.Type, json: [String: AnyObject]) -> T? {
		let map = Map(mappingType: .FromJSON, JSONDictionary: json, toObject: true)
		return T.init(map)
	}

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
}