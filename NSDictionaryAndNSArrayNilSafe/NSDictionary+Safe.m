//
//  NSDictionary+Safe.m
//  WebDemo
//
//  Created by mahong on 17/2/6.
//  Copyright © 2017年 mahong. All rights reserved.
//

#import "NSDictionary+Safe.h"
#import <objc/runtime.h>
#import "YBSwizzle.h"

@implementation NSDictionary (Safe)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        YBSwizzleMethod([self class], @selector(initWithObjects:forKeys:count:), @selector(yb_initWithObjects:forKeys:count:));
        YBSwizzleMethod([self class], @selector(dictionaryWithObjects:forKeys:count:), @selector(yb_dictionaryWithObjects:forKeys:count:));
    });
}

+ (instancetype)yb_dictionaryWithObjects:(const id [])objects forKeys:(const id<NSCopying> [])keys count:(NSUInteger)cnt {
    id safeObjects[cnt];
    id safeKeys[cnt];
    NSUInteger j = 0;
    for (NSUInteger i = 0; i < cnt; i++) {
        id key = keys[i];
        id obj = objects[i];
        if (!key) {
            continue;
        }
        if (!obj) {
            obj = [NSNull null];
        }
        safeKeys[j] = key;
        safeObjects[j] = obj;
        j++;
    }
    return [self yb_dictionaryWithObjects:safeObjects forKeys:safeKeys count:j];
}

- (instancetype)yb_initWithObjects:(const id [])objects forKeys:(const id<NSCopying> [])keys count:(NSUInteger)cnt {
    id safeObjects[cnt];
    id safeKeys[cnt];
    NSUInteger j = 0;
    for (NSUInteger i = 0; i < cnt; i++) {
        id key = keys[i];
        id obj = objects[i];
        if (!key) {
            continue;
        }
        if (!obj) {
            obj = [NSNull null];
        }
        safeKeys[j] = key;
        safeObjects[j] = obj;
        j++;
    }
    return [self yb_initWithObjects:safeObjects forKeys:safeKeys count:j];
}

@end

@implementation NSMutableDictionary (Safe)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        YBSwizzleMethod(objc_getClass("__NSDictionaryM"), @selector(setObject:forKey:), @selector(yb_setObject:forKey:));
        YBSwizzleMethod(objc_getClass("__NSDictionaryM"), @selector(setObject:forKeyedSubscript:), @selector(yb_setObject:forKeyedSubscript:));
    });
}

- (void)yb_setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    if (!aKey) {
        return;
    }
    if (!anObject) {
        anObject = [NSNull null];
    }
    [self yb_setObject:anObject forKey:aKey];
}

- (void)yb_setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key {
    if (!key) {
        return;
    }
    if (!obj) {
        obj = [NSNull null];
    }
    [self yb_setObject:obj forKeyedSubscript:key];
}

@end

@implementation NSNull (Safe)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        YBSwizzleMethod([self class], @selector(methodSignatureForSelector:), @selector(yb_methodSignatureForSelector:));
        YBSwizzleMethod([self class], @selector(forwardInvocation:), @selector(yb_forwardInvocation:));
    });
}

- (NSMethodSignature *)yb_methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *sig = [self yb_methodSignatureForSelector:aSelector];
    if (sig) {
        return sig;
    }
    return [NSMethodSignature signatureWithObjCTypes:@encode(void)];
}

- (void)yb_forwardInvocation:(NSInvocation *)anInvocation {
    NSUInteger returnLength = [[anInvocation methodSignature] methodReturnLength];
    if (!returnLength) {
        // nothing to do
        return;
    }
    
    // set return value to all zero bits
    char buffer[returnLength];
    memset(buffer, 0, returnLength);
    
    [anInvocation setReturnValue:buffer];
}

@end
