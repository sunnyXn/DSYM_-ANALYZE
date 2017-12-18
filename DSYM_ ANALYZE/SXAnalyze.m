//
//  SXAnalyze.m
//  DSYM_ ANALYZE
//
//  Created by Sunny on 16/7/8.
//  Copyright © 2016年 Sunny. All rights reserved.
//

#import "SXAnalyze.h"


#define kDwarfdumpPath @"/usr/bin/dwarfdump"
#define kAtosPath  @"/usr/bin/atos"

@implementation SXAnalyze

- (void)AnalyzeFileUUID:(NSString *)filePath WithSucess:(AnalyzeSuccessBlock)sucess failed:(AnalyzeFailedBlock)failed
{
    if (![[self class] verifyFileExtension:filePath])
    {
        failed(kErrorExtensionResult);
        return;
    }
    
    _filePath = filePath;
    
    NSTask * task = [[NSTask alloc] init];
    
    [task setLaunchPath:kDwarfdumpPath];
    
    NSString * args = nil;
    
    if ([self lowerString:filePath hasSuffix:kExtensionDSYM])
    {
        args = [NSString stringWithFormat:@"%@",filePath];
    }
    
    else if ([self lowerString:filePath hasSuffix:kExtensionAPP])
    {
        NSString * fileName = [[filePath lastPathComponent] stringByDeletingPathExtension];
        args = [NSString stringWithFormat:@"%@",filePath];
        args = [args stringByAppendingPathComponent:fileName];
    }
//    else if ([self lowerString:filePath hasSuffix:kExtensionIPA])
    {
        
    }
    
    
    [task setArguments:@[@"-u" , args]];
    
    NSPipe * pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    
    NSFileHandle * file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSString * result = [[NSString alloc] initWithData:[file readDataToEndOfFile] encoding:NSUTF8StringEncoding];
    //    NSLog(@"res:%@",result);
    
    
    if (result)
    {
        sucess(result);
    }
    else
    {
        failed(kErrorFaild);
    }
}

- (void)analyzeError:(NSString *)err armv:(NSString *)arm WithSuccess:(AnalyzeSuccessBlock)sucess failed:(AnalyzeFailedBlock)failed
{
    NSTask * task = [[NSTask alloc] init];
    
    [task setLaunchPath:kAtosPath];
    
    NSString * args = nil;
    
    if ([self lowerString:self.filePath hasSuffix:kExtensionDSYM])
    {
        NSString * fileName = [[self.filePath lastPathComponent] stringByDeletingPathExtension];
        fileName = [fileName stringByDeletingPathExtension];
        fileName = [@"Contents/Resources/DWARF" stringByAppendingPathComponent:fileName];
        args = [NSString stringWithFormat:@"%@",self.filePath];
        args = [args stringByAppendingPathComponent:fileName];
    }
    
    else if ([self lowerString:self.filePath hasSuffix:kExtensionAPP])
    {
        NSString * fileName = [[self.filePath lastPathComponent] stringByDeletingPathExtension];
        args = [NSString stringWithFormat:@"%@",self.filePath];
        args = [args stringByAppendingPathComponent:fileName];
    }
//    else if ([self lowerString:self.filePath hasSuffix:kExtensionIPA])
    {
        
    }
    
    
    [task setArguments:@[@"-o" , args , @"-arch" , arm, err]];
    
    NSPipe * pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    
    NSFileHandle * file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSString * result = [[NSString alloc] initWithData:[file readDataToEndOfFile] encoding:NSUTF8StringEncoding];
    
    if (result)
    {
        sucess(result);
    }
    else
    {
        failed(kErrorFaild);
    }
}

+ (BOOL)verifyFileExtension:(NSString *)filePath
{
    BOOL isResult = NO;
    if (filePath && (   [[filePath lowercaseString] hasSuffix:kExtensionAPP]
//                     || [[filePath lowercaseString] hasSuffix:kExtensionIPA]
                     || [[filePath lowercaseString] hasSuffix:kExtensionDSYM]))
    {
        NSDictionary * fileAtts = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        if (fileAtts && [[fileAtts fileType] isEqualToString:NSFileTypeDirectory])
        {
            isResult = YES;
        }
    }
    return isResult;
}

+ (NSArray *)getUUIDFormat:(NSString *)uuidStr
{
    NSMutableArray * uuids = [NSMutableArray array];
    
    NSArray * componts = [uuidStr componentsSeparatedByString:@"\n"];
    
    for (NSString * uid in componts)
    {
        if (uid && uid.length)
        {
            [uuids addObject:uid];
        }
    }
    return uuids;
}

+ (NSString *)getArmvType:(NSString *)uuidStr
{
    NSString * armv = nil;
    
    NSArray * arr = [uuidStr componentsSeparatedByString:@" "];
    
    if (arr.count >= 4)
    {
        armv = [NSString stringWithFormat:@"%@",arr[2]];
        armv = [armv substringWithRange:NSMakeRange(1, armv.length - 2)];
    }
    return armv;
}

- (BOOL)lowerString:(NSString *)string hasSuffix:(NSString *)suf
{
    return [[string lowercaseString] hasSuffix:suf];
}

@end


