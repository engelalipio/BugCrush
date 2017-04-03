//
//  AMSMyScene.h
//  ECrush
//

//  Copyright (c) 2017 Agile Mobile Solutions. All rights reserved.
//

@import SpriteKit;

@class AMSLevel;
@class AMSSwap;
@class AMSInsect;

@interface AMSMyScene : SKScene

@property(nonatomic,strong) AMSLevel  *level;
@property(strong, nonatomic)SKNode    *tilesLayer;
@property(nonatomic,assign) NSInteger swipeFromColumn;
@property(nonatomic,assign) NSInteger swipeFromRow;
@property (copy, nonatomic) void (^swipeHandler)(AMSSwap *swap);
@property (strong, nonatomic) SKSpriteNode *selectionSprite;
-(void) removeAllinsectSprites;
-(void) animateGameOver;
-(void) animateBeginGame;
-(void) animateFallingInsects:(NSArray *)columns completion:(dispatch_block_t)completion;
-(void) animateSwap:(AMSSwap *)swap completion:(dispatch_block_t)completion;
-(void) animateInvalidSwap:(AMSSwap *)swap completion:(dispatch_block_t)completion;
-(void) addSpriteForInsects:(NSSet *)insects;
-(void) addTiles;
-(void) animateMatchedInsects:(NSSet *)chains completion:(dispatch_block_t)completion;
-(void) animateNewInsects:(NSArray *)columns completion:(dispatch_block_t)completion;
-(void) animateIdleAction:(AMSInsect *) insect;
@end
