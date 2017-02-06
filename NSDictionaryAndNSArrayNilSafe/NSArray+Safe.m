//
//  NSArray+Safe.m
//  WebDemo
//
//  Created by mahong on 17/2/6.
//  Copyright © 2017年 mahong. All rights reserved.
//

#import "NSArray+Safe.h"
#import <objc/runtime.h>
#import "YBSwizzle.h"

@implementation NSArray (Safe)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        YBSwizzleMethod([self class], @selector(addObject:), @selector(yb_addObject:));
        YBSwizzleMethod(objc_getClass("__NSArrayM"), @selector(insertObject:atIndex:), @selector(yb_insertObject:atIndex:));
        YBSwizzleMethod(objc_getClass("__NSArrayM"), @selector(objectAtIndex:), @selector(yb_objectAtIndex:));
        YBSwizzleMethod(objc_getClass("__NSArrayI"), @selector(objectAtIndex:), @selector(yb_ArrayIobjectAtIndex:));
        YBSwizzleMethod(objc_getClass("__NSArray0"), @selector(objectAtIndex:), @selector(yb_emptyObject:));
        YBSwizzleMethod(objc_getClass("__NSPlaceholderArray"), @selector(initWithObjects:count:), @selector(yb_initWithObjects:count:));
    });
}

- (void)yb_addObject:(id)object
{
    if (object) {
        return [self yb_addObject:object];
    }
}

- (void)yb_insertObject:(id)anObject atIndex:(NSUInteger)index
{
    if (anObject) {
        return [self yb_insertObject:anObject atIndex:index];
    }
}

- (id)yb_objectAtIndex:(NSUInteger)index
{
    if (index >= self.count) {
        return nil;
    }
    return [self yb_objectAtIndex:index];
}

- (id)yb_ArrayIobjectAtIndex:(NSUInteger)index
{
    if (index >= self.count) {
        return nil;
    }
    return [self yb_ArrayIobjectAtIndex:index];
}

- (id)yb_emptyObject:(NSUInteger)index
{
    return nil;
}

- (instancetype)yb_initWithObjects:(const id [])objects count:(NSUInteger)cnt
{
    id safeObjects[cnt];
    NSUInteger j = 0;
    for (NSUInteger i = 0; i < cnt; i++) {
        id obj = objects[i];
        if (!obj) {
            obj = [NSNull null];
        }
        safeObjects[j] = obj;
        j++;
    }
    return [self yb_initWithObjects:safeObjects count:j];
}

@end


