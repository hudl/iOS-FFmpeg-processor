//
//  HlsManifestParser.h
//  Hudl
//
//  Created by Brian Clymer on 1/5/15.
//  Copyright (c) 2015 Agile Sports Technologies, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HlsManifestParser : NSObject

- (NSArray *)parseAssetGroupsForManifest:(NSString *)manifestPath;
+ (NSArray *)parseAssetGroupsForManifest:(NSString *)manifestPath;
+ (void)setParser:(HlsManifestParser *)manifestParser;

@end
