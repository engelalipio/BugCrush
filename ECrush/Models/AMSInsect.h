//
//  AMSCookie.h
//  ECrush
//
//  Created by Engel Alipio on 8/15/14.
//  Copyright (c) 2017 Agile Mobile Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
@import SpriteKit;

static const NSUInteger insectTypesNumber = 6;

@interface AMSInsect : NSObject

@property(assign,nonatomic) NSInteger column;
@property(assign,nonatomic) NSInteger row;
@property(assign,nonatomic) NSUInteger insectType;
@property(strong,nonatomic) SKSpriteNode *insectSprite;

-(NSString *) spriteName;
-(NSString *) hightLightedSpriteName;

@end
