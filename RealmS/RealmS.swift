//
//  RealmS.swift
//  RealmS
//
//  Created by DaoNV on 1/10/16.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

import RealmSwift

extension Realm {

  /**
   Obtains an instance of the default Realm.

   The default Realm is used by the `Object` class methods
   which do not take a `Realm` parameter, but is otherwise not special. The
   default Realm is persisted as `default.realm` under the Documents directory of
   your Application on iOS, and in your application's Application Support
   directory on OS X.

   The default Realm is created using the default `Configuration`, which
   can be changed via `Configuration.defaultConfiguration` setter.

   @return The default `Realm` instance for the current thread.
   */
  public static var defaultRealm: Realm! {
    do {
      return try Realm()
    } catch {
      return nil
    }
  }

  // MARK: Transactions

  /**
   Performs actions contained within the given block inside a write transaction.

   Write transactions cannot be nested, and trying to execute a write transaction
   on a `Realm` which is already in a write transaction will return an exception.
   Calls to `write` from `Realm` instances in other threads will block
   until the current write transaction completes.

   Before executing the write transaction, `write` updates the `Realm` to the
   latest Realm version, as if `refresh()` was called, and generates notifications
   if applicable. This has no effect if the `Realm` was already up to date.

   - parameter block: The block to be executed inside a write transaction.

   - returns: An NSError if the transaction could not be written.
   */
  public func writeBlock(@noescape block: (() -> Void)) -> NSError? {
    do {
      try write(block)
    } catch {
      return error as NSError
    }
    return nil
  }

  // MARK: Insert

  /**
   Adds or updates an object to be persisted it in this Realm.

   When the object has a primary key: If no objects exist in
   the Realm instance with the same primary key value, the object is inserted. Otherwise,
   the existing object is updated with any changed values.

   When added, all (child) relationships referenced by this object will also be
   added to the Realm if they are not already in it. If the object or any related
   objects already belong to a different Realm an exception will be thrown. Use one
   of the `create` functions to insert a copy of a persisted object into a different
   Realm.

   The object to be added must be valid and cannot have been previously deleted
   from a Realm (i.e. `invalidated` must be false).

   - parameter object: Object to be added to this Realm.
   */

  public func addOrUpdate<T: Object>(object: T) {
    add(object, update: T.primaryKey() != nil)
  }

  /**
   Adds or updates objects in the given sequence to be persisted it in this Realm.

   - warning: This method can only be called during a write transaction.

   - parameter objects: A sequence which contains objects to be added to this Realm.
   */
  public func addOrUpdate<S: SequenceType where S.Generator.Element: Object>(objects: S) {
    let update = S.Generator.Element.primaryKey() != nil
    for obj in objects {
      add(obj, update: update)
    }
  }
}
