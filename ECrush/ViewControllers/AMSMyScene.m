//
//  AMSMyScene.m
//  ECrush
//
//  Created by Engel Alipio on 8/15/14.
//  Copyright (c) 2017 Agile Mobile Solutions. All rights reserved.
//

#import "AMSMyScene.h"
#import "AMSInsect.h"
#import "AMSLevel.h"
#import "AMSSwap.h"

static const CGFloat TileWidth = 32.0;
static const CGFloat TileHeight = 36.0;
static const int BG_Velocity =  5;

@interface AMSMyScene(){
    AMSInsect *idleInsectOne,
                      *idleInsectTwo;
}

@property (strong, nonatomic) SKNode *gameLayer;
@property (strong, nonatomic) SKNode *insectsLayer;

@property (strong, nonatomic) SKAction *swapSound;
@property (strong, nonatomic) SKAction *invalidSwapSound;
@property (strong, nonatomic) SKAction *matchSound;
@property (strong, nonatomic) SKAction *fallingInsectSound;
@property (strong, nonatomic) SKAction *addInsectsSound;
@property (strong, nonatomic) SKAction *scorpionAnimationAction;
@property (strong, nonatomic) NSArray  *scorpionAnimation;
@property (strong, nonatomic) SKAction *beetleAnimationAction;
@property (strong, nonatomic) NSArray  *beetleAnimation;
@property (strong, nonatomic) SKAction *wormAnimationAction;
@property (strong, nonatomic) NSArray  *wormAnimation;
@property (strong, nonatomic) SKAction *antAnimationAction;
@property (strong, nonatomic) NSArray  *antAnimation;
@property (strong, nonatomic) SKAction *spiderAnimationAction;
@property (strong, nonatomic) NSArray  *spiderAnimation;

@property (assign, nonatomic) NSTimeInterval lastUpdateTime;
@property (assign, nonatomic) NSTimeInterval dt;
@property (assign, nonatomic) NSTimeInterval lastTouchedTime;

@end

@implementation AMSMyScene

@synthesize level = _level;
@synthesize tilesLayer = _tilesLayer;
@synthesize swipeFromColumn = _swipeFromColumn;
@synthesize swipeFromRow = _swipeFromRow;
@synthesize lastUpdateTime = _lastUpdateTime;
@synthesize dt = _dt;
@synthesize lastTouchedTime = _lastTouchedTime;

static inline CGPoint CGPointAdd(const CGPoint a, const CGPoint b)
{
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint CGPointMultiplyScalar(const CGPoint a, const CGFloat b)
{
    return CGPointMake(a.x * b, a.y * b);
}

static inline CGPoint CGPointSubtract(const CGPoint a, const CGPoint b)
{
    return CGPointMake(a.x - b.x, a.y - b.y);
}

static inline CGPoint CGPointDivideScalar(const CGPoint a, const CGFloat b)
{
    return CGPointMake(a.x / b, a.y / b);
}

-(void) initInsectAnimations{
    
    NSString *resourceName = @"",
             *message      = @"";
    
    SKTextureAtlas *atlas     = nil;
    
    NSArray        *resources    = nil,
                   *textureNames = nil;
    
    SKTexture      *texture      = nil;
    
    NSMutableDictionary *dict    = nil;
    
    @try{
     resources = [[NSArray alloc] initWithObjects:@"Scorpion",@"Beetle",@"Worm", @"Ant",@"Spider",nil];
  
 
        for (int iresource = 0; iresource < resources.count ; iresource++) {
            
            resourceName  = [resources objectAtIndex:iresource];
            
            atlas = [SKTextureAtlas  atlasNamed:resourceName];
            
            textureNames = [atlas textureNames];
            
            texture = nil;
            
            dict = [[NSMutableDictionary alloc] initWithCapacity:textureNames.count];
            
            for (int iTexture = 0 ; iTexture < textureNames.count; iTexture++) {
                NSString *textureName = [textureNames objectAtIndex:iTexture];
                texture = [atlas textureNamed:textureName];
                
                
                if (texture != nil){
                    [dict setObject:texture forKey:textureName];
                }
            }
            
            switch (iresource) {
                case 0:
                    self.scorpionAnimation = [dict allValues];
                    break;
                case 1:
                    self.beetleAnimation = [dict allValues];
                    break;
                case 2:
                    self.wormAnimation = [dict allValues];
                    break;
                case 3:
                    self.antAnimation = [dict allValues];
                    break;
                case 4:
                    self.spiderAnimation = [dict allValues];
                    break;
            }
            
            message  = [NSString stringWithFormat:@"Sucessfully loaded %lu %@ animations",(unsigned long)[dict count],resourceName];
        }
        
    }
    @catch(NSException *exception){
        message = [exception description];
    }
    @finally{
        
        NSLog(@"%@", message);
        message = @"";
        
        resourceName = @"";
        message      = @"";
        
        atlas     = nil;
        
        resources    = nil;
        textureNames = nil;
        
        texture      = nil;
        
        dict    = nil;
    }
    
 

    
}

-(void)initalizingScrollingBackground
{
    for (int i = 0; i < 2; i++) {
        SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"bg"];
        bg.position = CGPointMake(i * bg.size.width, 0);
        bg.anchorPoint = CGPointZero;
        bg.name = @"bg";
        [self addChild:bg];
    }
    
}

- (void)moveBg
{
    [self enumerateChildNodesWithName:@"bg" usingBlock: ^(SKNode *node, BOOL *stop)
     {
         SKSpriteNode * bg = (SKSpriteNode *) node;
         CGPoint bgVelocity = CGPointMake(- BG_Velocity, 0);
         CGPoint amtToMove = CGPointMultiplyScalar(bgVelocity,_dt);
         bg.position = CGPointAdd(bg.position, amtToMove);
         
         //Checks if bg node is completely scrolled of the screen, if yes then put it at the end of the other node
         if (bg.position.x <= -bg.size.width)
         {
             bg.position = CGPointMake(bg.position.x + bg.size.width*2,
                                       bg.position.y);
         }
     }];
}

- (void)preloadResources {
    
    [SKLabelNode labelNodeWithFontNamed:@"GillSans-BoldItalic"];
    
    //Insect animations
    [self initInsectAnimations];
    
    self.scorpionAnimationAction =   [SKAction animateWithTextures:self.scorpionAnimation
                                                                      timePerFrame:.1
                                                                            resize:YES
                                                                           restore:YES];
 
    self.beetleAnimationAction =   [SKAction animateWithTextures:self.beetleAnimation
                                                      timePerFrame:.1
                                                            resize:YES
                                                           restore:YES];
    
    self.wormAnimationAction =   [SKAction animateWithTextures:self.wormAnimation
                                                    timePerFrame:.1
                                                          resize:YES
                                                         restore:YES];

    self.antAnimationAction =   [SKAction animateWithTextures:self.antAnimation
                                                  timePerFrame:.1
                                                        resize:YES
                                                       restore:YES];
    
    self.spiderAnimationAction =   [SKAction animateWithTextures:self.spiderAnimation
                                                 timePerFrame:.1
                                                       resize:YES
                                                      restore:YES];
    
    self.swapSound = [SKAction playSoundFileNamed:@"Bugs.m4a" waitForCompletion:NO];
    self.invalidSwapSound = [SKAction playSoundFileNamed:@"Error.wav" waitForCompletion:NO];
    self.matchSound = [SKAction playSoundFileNamed:@"hit.m4a" waitForCompletion:NO];
    self.fallingInsectSound = [SKAction playSoundFileNamed:@"Scrape.wav" waitForCompletion:NO];
    self.addInsectsSound = [SKAction playSoundFileNamed:@"Movement.m4a" waitForCompletion:NO];
    
}

- (void)addTiles {
    for (NSInteger row = 0; row < NumRows; row++) {
        for (NSInteger column = 0; column < NumColumns; column++) {
            if ([self.level tileAtColumn:column row:row] != nil) {
                SKSpriteNode *tileNode = [SKSpriteNode spriteNodeWithImageNamed:@"Tile"];
                tileNode.position = [self pointForColumn:column row:row];
                [self.tilesLayer addChild:tileNode];
            }
        }
    }
}

- (void)animateResetGame{
    
    [self.level resetComboMultiplier];
    
    [self removeAllinsectSprites];
    [self addSpriteForInsects:[self.level shuffle]];
    [self animateBeginGame];
}

- (void)animateGameOver {
    SKAction *action = [SKAction moveBy:CGVectorMake(0, -self.size.height) duration:0.3];
    action.timingMode = SKActionTimingEaseIn;
    [self.gameLayer runAction:action];
}

- (void)animateBeginGame {
    self.gameLayer.hidden = NO;
    
    self.gameLayer.position = CGPointMake(0, self.size.height);
    SKAction *action = [SKAction moveBy:CGVectorMake(0, -self.size.height) duration:0.3];
    action.timingMode = SKActionTimingEaseOut;
    [self.gameLayer runAction:action];
}

-(CGPoint) pointForColumn:(NSInteger) column row:(NSInteger) row{
    return CGPointMake(column*TileWidth + TileWidth/2, row *TileHeight + TileHeight / 2);
}

-(void) addSpriteForInsects:(NSSet *)insects{
    for(AMSInsect *cookie in insects){
        NSString *spriteName = [cookie spriteName];
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:spriteName];
        sprite.position = [self pointForColumn:cookie.column row:cookie.row];
        [self.insectsLayer addChild:sprite];
        cookie.insectSprite = sprite;
        [cookie.insectSprite setName:spriteName];
        cookie.insectSprite.alpha = 0;
        cookie.insectSprite.xScale = cookie.insectSprite.yScale = 0.5;
        
        [cookie.insectSprite runAction:[SKAction sequence:@[
                                                      [SKAction waitForDuration:0.25 withRange:0.5],
                                                      [SKAction group:@[
                                                                        [SKAction fadeInWithDuration:0.25],
                                                                        [SKAction scaleTo:1.0 duration:0.25]
                                                                        ]]]]];
        
    }
}

- (BOOL)convertPoint:(CGPoint)point toColumn:(NSInteger *)column row:(NSInteger *)row {
    NSParameterAssert(column);
    NSParameterAssert(row);
    
    // Is this a valid location within the cookies layer? If yes,
    // calculate the corresponding row and column numbers.
    if (point.x >= 0 && point.x < NumColumns*TileWidth &&
        point.y >= 0 && point.y < NumRows*TileHeight) {
        
        *column = point.x / TileWidth;
        *row = point.y / TileHeight;
        return YES;
        
    } else {
        *column = NSNotFound;  // invalid location
        *row = NSNotFound;
        return NO;
    }
}

- (void)animateSwap:(AMSSwap *)swap completion:(dispatch_block_t)completion {
    // Put the cookie you started with on top.
    
    NSString *message= @"";
    const NSTimeInterval Duration = 0.3;
    
    SKAction *moveA = nil,
             *moveB = nil;
    
    @try {
     
        swap.originalInsect.insectSprite.zPosition = 100;
        swap.destinationInsect.insectSprite.zPosition = 90;
        
         moveA = [SKAction moveTo:swap.destinationInsect.insectSprite.position duration:Duration];
         moveA.timingMode = SKActionTimingEaseOut;
         [swap.originalInsect.insectSprite runAction:[SKAction sequence:@[moveA, [SKAction runBlock:completion]]]];
        
         moveB = [SKAction moveTo:swap.originalInsect.insectSprite.position duration:Duration];
         moveB.timingMode = SKActionTimingEaseOut;
        [swap.destinationInsect.insectSprite runAction:moveB];
        [self runAction:self.swapSound];
        
    }
    @catch (NSException *exception) {
        message = [NSString stringWithFormat:@"animateSwap:Error->%@", [exception description]];
    }
    @finally {
        NSLog(@"%@", message);
        message = @"";
    }

}

- (void)trySwapHorizontal:(NSInteger)horzDelta vertical:(NSInteger)vertDelta {
    
    NSInteger toColumn = -1,
              toRow    = -1;
    
    AMSInsect *toCookie   = nil,
              *fromCookie = nil;
    
    NSString *message = @"";
    @try{
        
        // 1
         toColumn = self.swipeFromColumn + horzDelta;
         toRow    = self.swipeFromRow + vertDelta;
        
        // 2
        if (toColumn < 0 || toColumn >= NumColumns) return;
        if (toRow < 0    || toRow >= NumRows) return;
        
        // 3
        toCookie = [self.level insectAtColumn:toColumn row:toRow];
        
        if (toCookie == nil) return;
        
        // 4
        fromCookie = [self.level insectAtColumn:self.swipeFromColumn row:self.swipeFromRow];
        
        if (self.swipeHandler != nil) {
            AMSSwap *swap = [[AMSSwap alloc] init];
            swap.originalInsect = fromCookie;
            swap.destinationInsect = toCookie;
            
            self.swipeHandler(swap);
        }
        
      //  message = [NSString stringWithFormat:@"*** swapping %@ with %@", fromCookie, toCookie];
        
    }
    @catch(NSException *exception){
        message = [NSString stringWithFormat:@"trySwapHorizontal:error->%@",[exception description]];
    }
    @finally{
        NSLog(@"%@",message);
        message  =@"";
        fromCookie = nil;
        toCookie = nil;
    }

}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    NSString *message = @"";
    
    UITouch *touch = nil;
    CGPoint location = CGPointZero;
    
    NSInteger column = -1,
              row    = -1;
    
    NSInteger horzDelta = 0,
              vertDelta = 0;
    
    @try {
        if (self.swipeFromColumn == NSNotFound) return;
        
        // 2
        touch = [touches anyObject];
        location = [touch locationInNode:self.insectsLayer];
        
        
        if ([self convertPoint:location toColumn:&column row:&row]) {
            
            // 3
            
            if (column < self.swipeFromColumn) {          // swipe left
                horzDelta = -1;
            } else if (column > self.swipeFromColumn) {   // swipe right
                horzDelta = 1;
            } else if (row < self.swipeFromRow) {         // swipe down
                vertDelta = -1;
            } else if (row > self.swipeFromRow) {         // swipe up
                vertDelta = 1;
            }
            
            // 4
            if (horzDelta != 0 || vertDelta != 0) {
                [self trySwapHorizontal:horzDelta vertical:vertDelta];
                [self hideSelectionIndicator];
                // 5
                self.swipeFromColumn = NSNotFound;
            }
        }
    }
    @catch (NSException *exception) {
         message = [NSString stringWithFormat:@"touchesMoved->%@",[exception description]];
    }
    @finally {
        NSLog(@"%@", message);
        
         message = @"";
         touch = nil;
         location = CGPointZero;
        
         column = -1,
         row    = -1;
        
         horzDelta = 0,
         vertDelta = 0;
    }
}

- (void)animateNewInsects:(NSArray *)columns completion:(dispatch_block_t)completion {
    // 1
    __block NSTimeInterval longestDuration = 0;
    
    for (NSArray *array in columns) {
        
        // 2
        NSInteger startRow = ((AMSInsect *)[array firstObject]).row + 1;
        
        [array enumerateObjectsUsingBlock:^(AMSInsect *cookie, NSUInteger idx, BOOL *stop) {
            
            // 3
            SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:[cookie spriteName]];
            sprite.position = [self pointForColumn:cookie.column row:startRow];
            [self.insectsLayer addChild:sprite];
            cookie.insectSprite = sprite;
            
            // 4
            NSTimeInterval delay = 0.1 + 0.2*([array count] - idx - 1);
            
            // 5
            NSTimeInterval duration = (startRow - cookie.row) * 0.1;
            longestDuration = MAX(longestDuration, duration + delay);
            
            // 6
            CGPoint newPosition = [self pointForColumn:cookie.column row:cookie.row];
            SKAction *moveAction = [SKAction moveTo:newPosition duration:duration];
            moveAction.timingMode = SKActionTimingEaseOut;
            cookie.insectSprite.alpha = 0;
            [cookie.insectSprite runAction:[SKAction sequence:@[
                                                          [SKAction waitForDuration:delay],
                                                          [SKAction group:@[
                                                                            [SKAction fadeInWithDuration:0.05], moveAction, self.addInsectsSound]]]]];
        }];
    }
    
    // 7
    [self runAction:[SKAction sequence:@[
                                         [SKAction waitForDuration:longestDuration],
                                         [SKAction runBlock:completion]
                                         ]]];
}

- (void)animateScoreForChain:(AMSChain *)chain {
    // Figure out what the midpoint of the chain is.
    AMSInsect *firstCookie = [chain.insects firstObject];
    AMSInsect *lastCookie = [chain.insects lastObject];
    
    NSArray *colors = [[NSArray alloc] initWithObjects:[UIColor whiteColor],[UIColor yellowColor],
                                                                                       [UIColor orangeColor],[UIColor greenColor],
                                                                                       [UIColor purpleColor], [UIColor blueColor],nil];
    
    int rndColor = arc4random_uniform(colors.count);
    
    CGPoint centerPosition = CGPointMake(
                                         (firstCookie.insectSprite.position.x + lastCookie.insectSprite.position.x)/2,
                                         (firstCookie.insectSprite.position.y + lastCookie.insectSprite.position.y)/2 - 8);
    
    // Add a label for the score that slowly floats up.
    SKLabelNode *scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"GillSans-BoldItalic"];
    scoreLabel.fontSize =  25;
    scoreLabel.text = [NSString stringWithFormat:@"%lu", (long)chain.score];
    scoreLabel.position = centerPosition;
    scoreLabel.zPosition = 300;
    scoreLabel.fontColor = [colors objectAtIndex:rndColor];
    [self.insectsLayer addChild:scoreLabel];
    
    SKAction *moveAction = [SKAction moveBy:CGVectorMake(0, 3) duration:0.7];
    moveAction.timingMode = SKActionTimingEaseOut;
    [scoreLabel runAction:[SKAction sequence:@[
                                               moveAction,
                                               [SKAction removeFromParent]
                                               ]]];
}

-(void) animateIdleAction:(AMSInsect*) insect{
    
    NSString *message  = @"",
                    *idleKey  = @"";
    
    SKAction *idleAction   = nil,
                     *repeatAction = nil;
    
    
    @try{
        
        idleKey = @"IdleKey";
        
        if ([insect.spriteName isEqualToString:@"Scorpion"]){
            idleAction = [self scorpionAnimationAction];
        }
        else if ([insect.spriteName isEqualToString:@"Beetle"]){
            idleAction = [self beetleAnimationAction];
        }
        else if ([insect.spriteName isEqualToString:@"Worm"]){
            idleAction = [self wormAnimationAction];
        }
        else if ([insect.spriteName isEqualToString:@"Ant"]){
            idleAction = [self antAnimationAction];
        }
        else if ([insect.spriteName isEqualToString:@"Spider"]){
            idleAction = [self spiderAnimationAction];
        }
        else{
            [self showSelectionIndicatorForInsect:insect];
        }
        
   
        if (idleAction != nil){
            
            repeatAction = [insect.insectSprite actionForKey:idleKey];
            
            if (repeatAction == nil){
                repeatAction = [SKAction repeatActionForever:idleAction ];
                message = [NSString stringWithFormat: @"Repeating Idle action for %@", insect.spriteName ];
                [insect.insectSprite runAction:repeatAction withKey:idleKey];
                if(! idleInsectOne){
                    idleInsectOne = insect;
                }else{
                    if (! idleInsectTwo){
                        idleInsectTwo = insect;
                    }
                }
                
            }else{
                message = [NSString stringWithFormat: @"Idle action for %@ already executing", insect.spriteName ];
            }
        }
        
        
    }@catch(NSException *exception){
        message = [exception description];
    }@finally{
        NSLog(@"%@",message);
        message = @"";
        idleAction = nil;
        repeatAction = nil;
    }
}

- (void)animateFallingInsects:(NSArray *)columns completion:(dispatch_block_t)completion {
    // 1
    __block NSTimeInterval longestDuration = 0;

    
    for (NSArray *array in columns) {
        [array enumerateObjectsUsingBlock:^(AMSInsect *insect, NSUInteger idx, BOOL *stop) {
            CGPoint newPosition = [self pointForColumn:insect.column row:insect.row];
            
            // 2
            NSTimeInterval delay = 0.05 + 0.15*idx;
            
            // 3
            NSTimeInterval duration = ((insect.insectSprite.position.y - newPosition.y) / TileHeight) * 0.1;
            
            // 4
            longestDuration = MAX(longestDuration, duration + delay);
            
            // 5
            SKAction *moveAction = [SKAction moveTo:newPosition duration:duration];
            moveAction.timingMode = SKActionTimingEaseOut;
        
            if ([insect.spriteName isEqualToString:@"Scorpion"]){
                
                [insect.insectSprite runAction:[SKAction sequence:@[
                                                                    [SKAction waitForDuration:delay],
                                                                    [SKAction group:@[self.scorpionAnimationAction,
                                                                                      moveAction, self.fallingInsectSound]]]]];
                
                
            }
            else if ([insect.spriteName isEqualToString:@"Beetle"]){
                
                [insect.insectSprite runAction:[SKAction sequence:@[
                                                                    [SKAction waitForDuration:delay],
                                                                    [SKAction group:@[self.beetleAnimationAction,
                                                                                      moveAction, self.fallingInsectSound]]]]];
                
                
            }
            else if ([insect.spriteName isEqualToString:@"Worm"]){
                
                [insect.insectSprite runAction:[SKAction sequence:@[
                                                                    [SKAction waitForDuration:delay],
                                                                    [SKAction group:@[self.wormAnimationAction,
                                                                                      moveAction, self.fallingInsectSound]]]]];
                
                
            }
            else if ([insect.spriteName isEqualToString:@"Ant"]){
                
                [insect.insectSprite runAction:[SKAction sequence:@[
                                                                    [SKAction waitForDuration:delay],
                                                                    [SKAction group:@[self.antAnimationAction,
                                                                                      moveAction, self.fallingInsectSound]]]]];
                
                
            }
            else if ([insect.spriteName isEqualToString:@"Spider"]){
                
                [insect.insectSprite runAction:[SKAction sequence:@[
                                                                    [SKAction waitForDuration:delay],
                                                                    [SKAction group:@[self.spiderAnimationAction,
                                                                                      moveAction, self.fallingInsectSound]]]]];
                
                
            }
            else{
            
            [insect.insectSprite runAction:[SKAction sequence:@[
                                                          [SKAction waitForDuration:delay],
                                                          [SKAction group:@[moveAction, self.fallingInsectSound]]]]];
            }
        }];
    }
    
    // 6
    [self runAction:[SKAction sequence:@[
                                         [SKAction waitForDuration:longestDuration],
                                         [SKAction runBlock:completion]
                                         ]]];
}

- (void)animateMatchedInsects:(NSSet *)chains completion:(dispatch_block_t)completion {
    
    for (AMSChain *chain in chains) {
        
          [self animateScoreForChain:chain];
        
        for (AMSInsect *cookie in chain.insects) {
            
            // 1
            if (cookie.insectSprite != nil) {
                
                // 2
                SKAction *scaleAction = [SKAction scaleTo:0.1 duration:0.3];
                scaleAction.timingMode = SKActionTimingEaseOut;
                [cookie.insectSprite runAction:[SKAction sequence:@[scaleAction, [SKAction removeFromParent]]]];
                
                // 3
                cookie.insectSprite = nil;
            }
        }
    }
    
    [self runAction:self.matchSound];
    
    // 4
    [self runAction:[SKAction sequence:@[
                                         [SKAction waitForDuration:0.3],
                                         [SKAction runBlock:completion]
                                         ]]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (self.selectionSprite.parent != nil &&
        self.swipeFromColumn != NSNotFound) {
        [self hideSelectionIndicator];
    }
    
    self.swipeFromColumn = NSNotFound;
    self.swipeFromRow    = NSNotFound;
    
    if (_lastUpdateTime){
        _lastTouchedTime = _lastUpdateTime;
    }
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = nil;
    CGPoint location = CGPointZero;
    
    AMSInsect *cookie = nil;
    
    NSInteger column = -1,
              row    = -1;
    
    NSString *message= @"";
    @try {
        
        touch = [touches anyObject];
        location = [touch locationInNode:self.insectsLayer];
        
        // 2
        
        if ([self convertPoint:location toColumn:&column row:&row]) {
            
            // 3
            cookie = [self.level insectAtColumn:column row:row];
            if (cookie != nil) {
                
                // 4
                self.swipeFromColumn = column;
                self.swipeFromRow    = row;
                
                [self showSelectionIndicatorForInsect:cookie];
                
            }
        }
        
    }
    @catch (NSException *exception) {
        message = [NSString stringWithFormat:@"touchesBegan:Error::%@" ,[exception description]];
    }
    @finally {
        NSLog(@"%@",message);
        column = -1;
        row = -1;
        location = CGPointZero;
        touch = nil;
        message = @"";
    }
}

- (void)hideSelectionIndicator {
    [self.selectionSprite runAction:[SKAction sequence:@[
                        [SKAction fadeOutWithDuration:0.3],
                        [SKAction removeFromParent]]]];
}

- (void)showSelectionIndicatorForInsect:(AMSInsect *)insect {
    // If the selection indicator is still visible, then first remove it.
    if (self.selectionSprite.parent != nil) {
        [self.selectionSprite removeFromParent];
    }
    
    SKTexture *texture = [SKTexture textureWithImageNamed:[insect hightLightedSpriteName]];
    self.selectionSprite.size = texture.size;
    [self.selectionSprite runAction:[SKAction setTexture:texture]];
    
    [insect.insectSprite addChild:self.selectionSprite];
    self.selectionSprite.alpha = 1.0;

}

- (void)animateInvalidSwap:(AMSSwap *)swap completion:(dispatch_block_t)completion {
    swap.originalInsect.insectSprite.zPosition = 100;
    swap.destinationInsect.insectSprite.zPosition = 90;
    
    const NSTimeInterval Duration = 0.2;
    
    SKAction *moveA = [SKAction moveTo:swap.destinationInsect.insectSprite.position duration:Duration];
    moveA.timingMode = SKActionTimingEaseOut;
    
    SKAction *moveB = [SKAction moveTo:swap.originalInsect.insectSprite.position duration:Duration];
    moveB.timingMode = SKActionTimingEaseOut;
    
    [swap.originalInsect.insectSprite runAction:[SKAction sequence:@[moveA, moveB, [SKAction runBlock:completion]]]];
    [swap.destinationInsect.insectSprite runAction:[SKAction sequence:@[moveB, moveA]]];
    [self runAction:self.invalidSwapSound];
}

- (void)removeAllinsectSprites {
    [self.insectsLayer removeAllChildren];
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        
        self.gameLayer.hidden = YES;
        
        [self preloadResources];
        
        [self setAnchorPoint:CGPointMake(0.5, 0.5)];
        
        SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"Forest.png"];
        
        [self addChild:background];
        
       /* [self initalizingScrollingBackground];*/
        
        [self setGameLayer:[SKNode node]];
        
        [self addChild:self.gameLayer];
        
        CGPoint layerPosition = CGPointMake(-TileWidth *NumColumns /2, -TileHeight *NumRows /2);
        
        self.tilesLayer = [SKNode node];
        self.tilesLayer.position = layerPosition;
        [self.tilesLayer setAlpha:0.5];
        [self.gameLayer addChild:self.tilesLayer];
        
        self.insectsLayer = [SKNode node];
        self.insectsLayer.position = layerPosition;
        
        [self.gameLayer addChild:self.insectsLayer];
        
        self.swipeFromRow    = NSNotFound;
        self.swipeFromColumn = NSNotFound;
        
        self.selectionSprite = [SKSpriteNode node];
        
        
    }
    return self;
}

-(void) calculateLastTouchedTime{
    
    NSTimeInterval lastTouchedInterval = 0 ;
    NSString *message = @"";
    NSSet *possibleSwaps = nil;
    AMSSwap *possibleSwap = nil;
    @try {
        
        if (_lastTouchedTime && _lastUpdateTime){
            
            lastTouchedInterval = _lastUpdateTime - _lastTouchedTime;
            
            //If has been more than the threshold secs notify user
            if (lastTouchedInterval >= kLastTouchedThreshold){
               //Detect if there are any possible swaps to show the user in case she/he is stuck
              message = [NSString stringWithFormat:@"Last Touched was more than %f", lastTouchedInterval ];
                
              [self.level detectPossibleSwaps];
              possibleSwaps = [self.level possibleSwaps];
                if (possibleSwaps != nil){
                   
                    //Get the first swap pair
                    NSEnumerator *swapEnum = [possibleSwaps objectEnumerator];
                    
                    if (swapEnum != nil){
                        NSArray *insectSwaps = [swapEnum allObjects];
                        
                        if (insectSwaps != nil){
                            possibleSwap = (AMSSwap*)[insectSwaps firstObject];
                            
                            if (possibleSwap != nil){
                                    [self animateIdleAction:[possibleSwap originalInsect]];
                            
                                    [self animateIdleAction:[possibleSwap destinationInsect]];
                            }else{
                                [self animateResetGame];
                            }
                        }
                    }else{
                    [self animateResetGame];
                    }
                    
                }else{
                    [self animateResetGame];
                }
            }else{
                
                
                if (idleInsectOne){
                    [idleInsectOne.insectSprite removeActionForKey:@"IdleKey"];
                    NSLog(@"Stopped idleInsectOne Idle");
                    idleInsectOne = nil;
                }
                if (idleInsectTwo){
                    [idleInsectTwo.insectSprite removeActionForKey:@"IdleKey"];
                    NSLog(@"Stopped idleInsectTwo Idle");
                    idleInsectTwo = nil;
                }
                

                
            }
            
        }else{
            _lastTouchedTime = 0;
        }
        
    }
    @catch (NSException *exception) {
        message = [exception description];
    }
    @finally {
        if ([message length] > 0){
            NSLog(@"%@", message);
        }
        message = @"";
        lastTouchedInterval = 0;
    }
}


-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
    if (_lastUpdateTime){
        _dt = currentTime - _lastUpdateTime;
    }
    else{
        _dt = 0;
    }
    _lastUpdateTime = currentTime;
    [self calculateLastTouchedTime];
    //[self moveBg];
}

@end
