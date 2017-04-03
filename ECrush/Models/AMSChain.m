//
//  AMSChain.m
//  ECrush
//
//  Created by Engel Alipio on 8/16/14.
//  Copyright (c) 2017 Agile Mobile Solutions. All rights reserved.
//

#import "AMSChain.h"
#import "AMSInsect.h"
@implementation AMSChain {
    NSMutableArray *_insects;
}

@synthesize score = _score;

- (void)addInsect:(AMSInsect *)insect {
    if (_insects == nil) {
        _insects = [NSMutableArray array];
    }
    [_insects addObject:insect];
}

- (NSArray *)insects {
    return _insects;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"type:%ld insects:%@", (long)self.chainType, self.insects];
}

@end
