//
//  YBSwizzle.h
//  YBJK
//
//  Created by mahong on 16/10/19.
//  Copyright © 2016年 mahong. All rights reserved.
//

#import <Foundation/Foundation.h>

extern void YBSwizzleMethod(Class cls, SEL originalSelector, SEL swizzledSelector);
