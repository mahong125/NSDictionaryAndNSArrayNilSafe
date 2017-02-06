//
//  YBSwizzle.m
//  YBJK
//
//  Created by mahong on 16/10/19.
//  Copyright © 2016年 mahong. All rights reserved.
//

#import "YBSwizzle.h"
#import <objc/runtime.h>

/**
 *  Method Swizzle
 *
 *  @param cls              执行swizzle的类
 *  @param originalSelector 原方法
 *  @param swizzledSelector 新方法
 *
 *  使用方法 一般在load方法中调用  
 + (void)load
 {
 static dispatch_once_t onceToken;
 dispatch_once(&onceToken, ^{
 YBSwizzleMethod([self class], @selector(viewWillAppear:), @selector(yb_viewWillAppear:));
 });
 }
 */

void YBSwizzleMethod(Class cls, SEL originalSelector, SEL swizzledSelector)
{
    /** 原方法 */
    Method originalMethod = class_getInstanceMethod(cls, originalSelector);
    /** 新方法 */
    Method swizzledMethod = class_getInstanceMethod(cls, swizzledSelector);
    
    /** 先尝试给源方法添加实现，这里是为了避免源方法没有实现的情况 */
    BOOL result = class_addMethod(cls, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    
    if (result)
    {
        /** 添加成功 将源方法的实现替换到交换方法的实现 */
        class_replaceMethod(cls, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }
    else
    {
        /** 添加失败 说明源方法已经有实现，直接将两个方法的实现交换即可 */
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}
