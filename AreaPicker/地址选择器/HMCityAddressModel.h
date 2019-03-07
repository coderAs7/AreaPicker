//
//  HMCityAddressModel.h
//  MeiLiBa
//
//  Created by MacBook Pro on 2019/3/5.
//  Copyright © 2019年 NAN. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HMCityAddressModel : NSObject
//"id": "140000",
//"cl_Name": "山西省",
//"cl_PId": "100000",
//"cl_Layer": "999003",
//"cl_IsDelete": 0,
//"cl_FullChar": "SXS",
//"cl_HeadChar": "S",
//"cl_Acronym": "晋",
//"cl_FullPy": "shanxisheng",
//"cl_IsCenterCity": 0,
//"cl_city": []

@property (nonatomic,strong) NSString *ID;
@property (nonatomic,strong) NSString *cl_Name;
@property (nonatomic,strong) NSString *cl_PId;
@property (nonatomic,strong) NSString *cl_Layer;
@property (nonatomic,strong) NSString *cl_IsDelete;
@property (nonatomic,strong) NSString *cl_FullChar;
@property (nonatomic,strong) NSString *cl_HeadChar;
@property (nonatomic,strong) NSString *cl_Acronym;
@property (nonatomic,strong) NSString *cl_FullPy;
@property (nonatomic,strong) NSString *cl_IsCenterCity;
@property (nonatomic,strong) NSArray <HMCityAddressModel *> *cl_city;

@end

NS_ASSUME_NONNULL_END
