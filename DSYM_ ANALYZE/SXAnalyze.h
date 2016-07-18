//
//  SXAnalyze.h
//  DSYM_ ANALYZE
//
//  Created by Sunny on 16/7/8.
//  Copyright © 2016年 Sunny. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * kErrorExtensionResult = @"文件后缀或格式不符";
static NSString * kErrorFaild       = @"解析失败";

//static NSString * const kExtensionIPA    = @".ipa";
static NSString * const kExtensionAPP    = @".app";
static NSString * const kExtensionDSYM   = @".app.dsym";

/// 解析成功
typedef void (^AnalyzeSuccessBlock)(NSString * sucess);
typedef void (^AnalyzeFailedBlock)(NSString * fail);

@interface SXAnalyze : NSObject


@property (nonatomic , strong , readonly) NSString * filePath;

/// 解析UUID
- (void)AnalyzeFileUUID:(NSString *)filePath WithSucess:(AnalyzeSuccessBlock)sucess failed:(AnalyzeFailedBlock)failed;

/// 解析错误的内存地址
- (void)analyzeError:(NSString *)err armv:(NSString *)arm WithSuccess:(AnalyzeSuccessBlock)sucess failed:(AnalyzeFailedBlock)failed;

/// 验证文件后缀
+ (BOOL)verifyFileExtension:(NSString *)filePath;

/// 格式化UUID
+ (NSArray *)getUUIDFormat:(NSString *)uuidStr;
/// 获取armv类型
+ (NSString *)getArmvType:(NSString *)uuidStr;

@end
