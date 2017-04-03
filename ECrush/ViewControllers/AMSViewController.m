//
//  AMSViewController.m
//  ECrush
//
//  Created by Engel Alipio on 8/15/14.
//  Copyright (c) 2017 Agile Mobile Solutions. All rights reserved.
//

#import "AMSViewController.h"
#import "AMSMyScene.h"
#import "AMSLevel.h"
#import "AMSGameKitHelper.h"
#import "AMSMenuViewController.h"
#import <VungleSDK/VungleSDK.h>
#import "AMSAppDelegate.h"
@import AVFoundation;

@interface AMSViewController()

@property(strong,nonatomic) AMSLevel *level;
@property(strong,nonatomic) AMSMyScene *scene;
@property(strong,nonatomic) AVAudioPlayer *backgroundMusic;
@property(strong,nonatomic) AMSAppDelegate *amsDelegate;
@property(assign,nonatomic) BOOL levelComplete;
@property(assign,nonatomic) NSTimeInterval interval;
@end

@implementation AMSViewController

@synthesize movesLeft = _movesLeft;
@synthesize score = _score;


-(void) gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController{
    NSString *message = @"";
    
    @try{
        
    
        [self dismissViewControllerAnimated:YES completion:nil];
      
        message = @"gameCenterViewControllerDidFinish Invoked...";
        

    }@catch(NSException *exception){
        message = [exception description];
    }@finally{
        NSLog(@"%@",message);
        message = @"";
      
    }
}


-(void) resumeMusic{
    if (self.backgroundMusic != nil){
        if (! [self.backgroundMusic isPlaying]){
            NSTimeInterval playbackDelay = self.interval; //Must be >= 0
            if (playbackDelay <= 0){
                playbackDelay = 3.0;
            }
             [self.backgroundMusic playAtTime:self.backgroundMusic.deviceCurrentTime - playbackDelay];
        }
    }
}

-(void) pauseMusic{
    if (self.backgroundMusic != nil){
        [self setInterval:self.backgroundMusic.deviceCurrentTime];
        if ([self.backgroundMusic isPlaying]){
            [self.backgroundMusic pause];
        }
    }
}

-(void) stopMusic{
    if (self.backgroundMusic != nil){
        if ([self.backgroundMusic isPlaying]){
            [self.backgroundMusic stop];
        }
    }
}


-(void) startMusic{
    
 //   NSURL *url = [[NSBundle mainBundle] URLForResource:@"Mining by Moonlight" withExtension:@"mp3"];
       NSURL *url = [[NSBundle mainBundle] URLForResource:@"Ukulele" withExtension:@"wav"];
    self.backgroundMusic = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    self.backgroundMusic.numberOfLoops = -1;
    
    [self.backgroundMusic play];
}

-(void) beginGame{
    
    self.movesLeft = self.level.maximumMoves;
    self.score = 0;
    
    [self.level resetComboMultiplier];
    [self updateLabels];
    [self.scene animateBeginGame];
    [self shuffle];
}

-(void) shuffle{
    [self.scene removeAllinsectSprites];
    NSSet *newCookies = [self.level shuffle];
    [self.scene addSpriteForInsects:newCookies];
}

- (void)showGameOver {

    
    [self.scene animateGameOver];
    self.gameOverPanel.hidden = NO;
    self.gameStatusLabel.hidden = NO;
    self.scene.userInteractionEnabled = NO;
    self.btnShuffle.hidden = YES;
    
    //Submit Score
    [[AMSGameKitHelper sharedGameKitHelper] submitScore:(int64_t)[self.scoreLabel text] category:kHighScoreLeaderboardCategory];
    
    //Submit Moves
    [[AMSGameKitHelper sharedGameKitHelper] submitScore:(int64_t)[self.movesLabel text] category:kMoveSaverLeaderboardCategory];

    //Submit Combos
    [[AMSGameKitHelper sharedGameKitHelper] submitScore:(int64_t)[self.movesLabel text] category:kComboMultiplierLeaderboardCategory];
    
    //See if user will unlock the Saved by Hair Achievement
    
    if ([[self.movesLabel text] isEqualToString:@"1"] ){
        NSString  *SavedByHairProgress = @"100";
        NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:SavedByHairProgress, kSavedByHairAchievementCategory, nil];
        [[AMSGameKitHelper sharedGameKitHelper] reportAchievement:data];
    }
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideGameOver)];
    [self.view addGestureRecognizer:self.tapGestureRecognizer];
}

- (void)hideGameOver {
    [self.view removeGestureRecognizer:self.tapGestureRecognizer];
    self.tapGestureRecognizer = nil;
    self.btnShuffle.hidden = NO;
    self.gameOverPanel.hidden = YES;
    self.gameStatusLabel.hidden = YES;
    self.scene.userInteractionEnabled = YES;
    if (self.levelComplete){
        [self.amsDelegate randomLevel];
    }else{
        [self displayAdd];
    }
    
    [self loadLevel];
    [self beginGame];

}

-(void) displayAdd{
    
    VungleSDK *sdk =nil;
    NSError *error = nil;

    @try {
        
        sdk = [VungleSDK sharedSDK];
        
        if (sdk){
            [sdk playAd:self error:&error];
        }
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    } @finally {
        sdk = nil;
        error = nil;
    }
}

-(void)loadLevel{
    

        
        if (! [self.amsDelegate isAuthenticated]){
            [[AMSGameKitHelper sharedGameKitHelper] authenticateLocalPlayer];
        }
        
        self.levelComplete = NO;
   
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    //skView.showsFPS = YES;
    //skView.showsNodeCount = YES;
    [skView setMultipleTouchEnabled:NO];
    
    // Create and configure the scene.
    self.scene = [AMSMyScene sceneWithSize:skView.bounds.size];
    self.scene.scaleMode = SKSceneScaleModeAspectFill;
    

    self.level = [[AMSLevel alloc] initWithFile:[self.amsDelegate currentLevel]];
    
    self.scene.level = self.level;
    [self.scene addTiles];
    // Present the scene.
    
    id block = ^(AMSSwap *swap) {
        
        self.view.userInteractionEnabled = NO;
        
        if ([self.level isPossibleSwap:swap]){
            [self.level performSwap:swap];
            [self.scene animateSwap:swap completion:^{
                [self handleMatches];
            }];
        }else{
            [self.scene animateInvalidSwap:swap completion:^{
                self.view.userInteractionEnabled = YES;
            }];
        }
    };
    
    self.scene.swipeHandler = block;
    
    [skView presentScene:self.scene];
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (! self.amsDelegate){
        _amsDelegate = [AMSAppDelegate currentDelegate];
    }
    
    [[VungleSDK sharedSDK] setDelegate:self];
    
    if ([self.amsDelegate isMusicOn]){
        [self startMusic];
    }else{
        [self stopMusic];
    }
    
    self.gameOverPanel.hidden = YES;
    self.gameStatusLabel.hidden = YES;
    [self loadLevel];
    
    [self beginGame];
}

- (void)updateLabels {
    self.targetLabel.text = [NSString stringWithFormat:@"%lu", (long)self.level.targetScore];
    self.movesLabel.text =  [NSString stringWithFormat:@"%lu", (long)self.movesLeft];
    
    switch (self.movesLeft) {
        case 5:
        case 4:
        case 3:
            self.movesLabel.textColor = [UIColor orangeColor];
            break;
            
        case 2:
        case 1:
        case 0:
           self.movesLabel.textColor = [UIColor redColor];
            break;
        default:
            self.movesLabel.textColor = [UIColor yellowColor];
            break;
    }
    
    self.scoreLabel.text =  [NSString stringWithFormat:@"%lu", (long)self.score];
}

- (void)beginNextTurn {
    [self.level resetComboMultiplier];
    [self.level detectPossibleSwaps];
    [self decrementMoves];
    self.view.userInteractionEnabled = YES;
}

- (void)decrementMoves{
    NSString *message = @"";
    
    @try {
        
        self.movesLeft--;
        [self updateLabels];
        
        if (self.score >= self.level.targetScore) {
            self.gameOverPanel.image = [UIImage imageNamed:@"ButtonOther"];
            [self.gameStatusLabel setText:[NSString stringWithFormat:@"%@ Completed.",@"Level "]];
            message = [NSString stringWithFormat:@"Sucessfully completed %@ with %@ points and %@ moves left.",
                                [self.amsDelegate currentLevel],[self.scoreLabel text],
                                [self.movesLabel text]];
            self.levelComplete = YES;
            [self showGameOver];
        } else if (self.movesLeft == 0) {
            self.gameOverPanel.image = [UIImage imageNamed:@"Button"];
            [self.gameStatusLabel setText:@"Game Over."];
            self.levelComplete = NO;
            [self showGameOver];
            
        }

        
    }
    @catch (NSException *exception) {
        message = [exception description];
    }
    @finally {
        NSLog(@"%@", message);
        message = @"";
    }
    
}

- (void)handleMatches {
    
    NSSet *chains = [self.level removeMatches];
    
    if ([chains count] == 0) {
        [self beginNextTurn];
        return;
    }
    
    [self.scene animateMatchedInsects:chains completion:^{
        
        for (AMSChain *chain in chains) {
            self.score += chain.score;
        }
        
        [self updateLabels];
        NSArray *columns = [self.level fillHoles];
        [self.scene animateFallingInsects:columns completion:^{
            NSArray *columns = [self.level topUpInsects];
            [self.scene animateNewInsects:columns completion:^{
                [self handleMatches];
            }];
        }];
    }];
    
}

- (BOOL)shouldAutorotate
{
    return YES;
}

-(BOOL) prefersStatusBarHidden{
    return YES;
}

-(void) vungleSDKwillShowAd{
    [self pauseMusic];
}


-(void) vungleSDKwillCloseAdWithViewInfo:(NSDictionary *)viewInfo willPresentProductSheet:(BOOL)willPresentProductSheet{
    [self resumeMusic];
    [[AMSGameKitHelper sharedGameKitHelper] showLeaderBoard:kHighScoreLeaderboardCategory];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [[VungleSDK sharedSDK] setDelegate:nil];
}

- (IBAction)shuffleAction:(UIButton *)sender {
    AMSMenuViewController *menuView = nil;
    
    UIStoryboard *storyboard = nil;
    
    @try{
        
        menuView = [[AMSMenuViewController alloc] init];
        
        storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        menuView = [storyboard instantiateViewControllerWithIdentifier:@"sbMenu"];
        
        if (menuView){
        
        [self presentViewController:menuView animated:YES completion:^(void){
            
        }];
        }

    }
    @catch(NSException *exception){
        
    }
    @finally{
        menuView = nil;
        storyboard = nil;
    }
 
}

 
@end
