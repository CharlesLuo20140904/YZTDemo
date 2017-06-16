//
//  DesUtil.h
//  YZTDemo
//
//  Created by Chow Tai Fook on 2017/6/15.
//  Copyright © 2017年 Chow Tai Fook. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DesUtil : NSObject
+ (NSString*) AES128Encrypt:(NSString *)plainText;

+ (NSString*) AES128Decrypt:(NSString *)encryptText;

+ (NSString *)convertStringToHexStr:(NSString *)str;//字符串转换为16进制

+(NSString *)bytetohexStr:(NSData *)data;

+ (NSData *)AES128EncryptWithKey:(NSString *)key andIV:(NSString *)ivString encryptString:(NSString *)orignStr;
@end
