//
//  AssetGroup.m
//  Hudl
//
//  Created by Brian Clymer on 12/15/14.
//  Copyright (c) 2014 Agile Sports Technologies, Inc. All rights reserved.
//

#import "AssetGroup.h"

@implementation AssetGroup

- (NSString *)description
{
    return [NSString stringWithFormat:@"Order=%@,Duration=%@,Filename=%@", @(self.order), @(self.duration), self.fileName];
}

@end
