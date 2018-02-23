//
//  Utils.m
//  RealmS
//
//  Created by DaoNV on 4/18/17.
//  Copyright © 2017 Apple Inc. All rights reserved.
//

#import "Utils.h"

void DispatchOnce(void(^block)(void)) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        block();
    });
}
