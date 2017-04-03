//
//  AMSSwap.h
//  ECrush
//
//  Created by Engel Alipio on 8/16/14.
//  Copyright (c) 2017 Agile Mobile Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AMSInsect;

@interface AMSSwap : NSObject

@property(nonatomic,strong) AMSInsect *originalInsect;
@property(nonatomic,strong) AMSInsect *destinationInsect;

@end
