//
//  AMSViewController.h
//  ECrush
//

//  Copyright (c) 2017 Agile Mobile Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import "AMSAppDelegate.h"
#import <GameKit/GameKit.h>
#import <VungleSDK/VungleSDK.h>

@interface AMSViewController : UIViewController<GKGameCenterControllerDelegate,VungleSDKDelegate>
@property (strong, nonatomic) IBOutlet UILabel *gameStatusLabel;

@property (assign, nonatomic) NSUInteger movesLeft;
@property (assign, nonatomic) NSUInteger score;
@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (weak, nonatomic) IBOutlet UILabel *targetLabel;
@property (weak, nonatomic) IBOutlet UILabel *movesLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (strong, nonatomic) IBOutlet UIImageView *gameOverPanel;
@property (strong, nonatomic) IBOutlet UIButton *btnShuffle;

- (IBAction)shuffleAction:(UIButton *)sender;

-(void)startMusic;
-(void)stopMusic;

@end
