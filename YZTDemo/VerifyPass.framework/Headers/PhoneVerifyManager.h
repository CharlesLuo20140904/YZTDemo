//
//  Created by yzt on 16-11-5.
//  Copyright (c) 2016年 yzt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhoneVerifyManager : NSObject

/// 请求超时时间为20
@property (nonatomic, assign) NSInteger timeoutIntervalForRequest;
/// 服务器请求地址，默认地址为 https://www.400yzt.com:8443/app.core/service/
@property (nonatomic, strong) NSString *verifyServerURL;
/// 公钥证书地址 默认地址为 [[NSBundle mainBundle] pathForResource:@"public_key" ofType:@"pem"]
@property (nonatomic, strong) NSString *publicKeyPath;
/// 私钥证书地址 默认地址为 [[NSBundle mainBundle] pathForResource:@"private_key" ofType:@"pem"]
@property (nonatomic, strong) NSString *privateKeyPath;

+ (instancetype)sharedInstance;


/**
 初始化sdk

 @param appIDStr 

 @return return value description
 */
- (void)requestToken:(NSString *)appIDStr;

/**
 创建注册

 @param phone 电话号码
 @param busiType 业务编号
 @param compeltion block 回调 其中status取值
                                     0:待验证
                                     2:验证失败
 */
- (void)createVerification:(NSString *)phone busiType:(NSString *)busiType completion:(void(^)(NSInteger status,NSString *desc,NSString *verifyPhone))compeltion;

/**
 查询注册
 
 @param phone 电话号码
 @param busiType 业务编号
 @param compeltion block 回调 其中status取值
                                     0:待验证
                                     1:验证通过
                                     2:验证失败
 */
- (void)queryVerification:(NSString *)phone busiType:(NSString *)busiType completion:(void(^)(NSInteger status,NSString *desc))compeltion;

/**
 清除注册
 
 @param phone 电话号码
 @param busiType 业务编号
 @param compeltion block 回调 其中status取值
                                     1:成功
                                     2:失败
 */
- (void)cleanVerification:(NSString *)phone busiType:(NSString *)busiType completion:(void(^)(NSInteger status,NSString *desc))compeltion;

@end

