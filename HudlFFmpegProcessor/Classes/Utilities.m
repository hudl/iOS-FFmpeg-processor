//
//  Utilities.m
//  HudlFFmpegProcessor
//
//  Created by Brian Clymer on 1/21/15.
//  Copyright (c) 2015 Agile Sports - Hudl. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities

+ (NSString *)applicationSupportDirectory
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:path])
    {
        [manager createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:NULL];
    }
    
    return path;
}

+ (NSString *)fileNameStringFromDate:(NSDate *)date
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"MM-dd-yyyy_HH-mm-ss.SSS"];
    return [formatter stringFromDate:date];
}

@end
