//
//  HMCityAddressModel.m
//  MeiLiBa
//
//  Created by MacBook Pro on 2019/3/5.
//  Copyright © 2019年 NAN. All rights reserved.
//

#import "HMCityAddressModel.h"

@implementation HMCityAddressModel
+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{
             @"ID" : @"id"
             };
}

+ (NSDictionary *)mj_objectClassInArray{
    return @{
             @"cl_city":NSStringFromClass([HMCityAddressModel class]),
             };
}
@end
