//
//  AMSLevel.h
//  ECrush
//
//  Created by Engel Alipio on 8/15/14.
//  Copyright (c) 2017 Agile Mobile Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMSInsect.h"
#import "AMSTile.h"
#import "AMSChain.h"

@class AMSSwap;

static const NSInteger NumColumns  = 9;
static const NSInteger NumRows = 9;


@interface AMSLevel : NSObject
@property (assign, nonatomic) NSUInteger comboMultiplier;
@property (assign, nonatomic) NSUInteger targetScore;
@property (assign, nonatomic) NSUInteger maximumMoves;
@property (strong, nonatomic) NSString   *levelName;
@property (strong, nonatomic) NSSet *possibleSwaps;
-(void)resetComboMultiplier;
-(NSArray *)fillHoles;
-(instancetype)initWithFile:(NSString *)filename;
-(NSArray *) topUpInsects;
-(NSSet *) shuffle;
-(AMSInsect *) insectAtColumn:(NSInteger) column row:(NSInteger)row;
-(AMSTile *)tileAtColumn:(NSInteger)column row:(NSInteger)row;
-(void) performSwap:(AMSSwap *) swap;
-(BOOL)isPossibleSwap:(AMSSwap *)swap;
-(NSSet *) removeMatches;
-(void) detectPossibleSwaps;

@end
