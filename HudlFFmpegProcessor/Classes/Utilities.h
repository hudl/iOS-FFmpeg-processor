//
//  Utilities.h
//  HudlFFmpegProcessor
//
//  Created by Brian Clymer on 1/21/15.
//  Copyright (c) 2015 Agile Sports - Hudl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utilities : NSObject

+ (NSString *)applicationSupportDirectory;
+ (NSString *)fileNameStringFromDate:(NSDate *)date;

@end
