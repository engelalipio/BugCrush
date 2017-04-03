//
//  AMSChain.h
//  ECrush
//
//  Created by Engel Alipio on 8/16/14.
//  Copyright (c) 2017 Agile Mobile Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AMSInsect;

typedef NS_ENUM(NSUInteger, ChainType) {
    ChainTypeHorizontal,
    ChainTypeVertical,
};

@interface AMSChain : NSObject
@property (assign, nonatomic) NSUInteger score;
@property (strong, nonatomic, readonly) NSArray *insects;
@property (assign, nonatomic) ChainType chainType;

- (void)addInsect:(AMSInsect *)insect;
@end
