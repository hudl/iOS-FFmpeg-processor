//
//  HlsManifestParser.m
//  Hudl
//
//  Created by Brian Clymer on 1/5/15.
//  Copyright (c) 2015 Agile Sports Technologies, Inc. All rights reserved.
//

#import "HlsManifestParser.h"
#import "AssetGroup.h"
#import "KFRecorder.h"

static dispatch_once_t onceToken;
static HlsManifestParser *sharedInstance;

@implementation HlsManifestParser

+ (NSArray *)parseAssetGroupsForManifest:(NSString *)manifestPath
{
    return [[self sharedInstance] parseAssetGroupsForManifest:manifestPath];
}

- (NSArray *)parseAssetGroupsForManifest:(NSString *)manifestPath
{
    NSMutableArray *groups = [NSMutableArray new];
    
    // read everything from file
    NSString *fileContents = [NSString stringWithContentsOfFile:manifestPath encoding:NSUTF8StringEncoding error:nil];
    // separate by new line
    NSArray *allLinedStrings = [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    NSString *previousLine = nil;
    
    // create a set of characters that includes all numbers and '.', so that a decimal can be extracted.
    NSMutableCharacterSet *numbersAndDecimal = [[NSCharacterSet decimalDigitCharacterSet] mutableCopy];
    [numbersAndDecimal addCharactersInString:@"."];
    
    for (NSString *line in allLinedStrings)
    {
        if ([line rangeOfString:SegmentManifestName].location != NSNotFound)
        {
            NSString *duration = [[previousLine componentsSeparatedByCharactersInSet:[numbersAndDecimal invertedSet]] componentsJoinedByString:@""];
            AssetGroup *group = [AssetGroup new];
            group.fileName = line;
            group.duration = [duration doubleValue];
            [groups addObject:group];
        }
        previousLine = line;
    }
    
    return groups;
}

// this method can only be called once. It should not switch at runtime.
// If you need to use a changing implementation of HlsManifestParser use it's instance methods, not it's static methods.
+ (void)setParser:(HlsManifestParser *)manifestParser
{
    dispatch_once(&onceToken, ^{
        sharedInstance = manifestParser;
    });
}

+ (instancetype)sharedInstance
{
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

@end
