//
//  AssetGroup.h
//  Hudl
//
//  Created by Brian Clymer on 12/15/14.
//  Copyright (c) 2014 Agile Sports Technologies, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AssetGroup : NSObject

@property (nonatomic, copy) NSString *fileName;
@property (nonatomic) int32_t order;
@property (atomic) double duration;

@end