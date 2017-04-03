//
//  AMSGameKitHelper.m
//  ECrush
//
//  Created by Engel Alipio on 8/18/14.
//  Copyright (c) 2017 Agile Mobile Solutions. All rights reserved.
//

#import "AMSGameKitHelper.h"
#import "AMSAppDelegate.h"
#import <GameKit/GameKit.h>
#import "AMSViewController.h"



@interface AMSGameKitHelper () <GKGameCenterControllerDelegate> {
    BOOL _gameCenterFeaturesEnabled;
    AMSAppDelegate *appDelegate;
}
@end


@implementation AMSGameKitHelper
@synthesize lastError = _lastError;



-(void) gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController{
    
    NSLog(@"Done with GameCenter");
    
}

-(void) showLeaderBoard:(NSString *) leaderboardID{
    
    NSString *message = @"";
    
    GKGameCenterViewController *gameCenterController = nil;
    
    AMSViewController *viewController = nil;
    @try{
       
        gameCenterController = [[GKGameCenterViewController alloc] init];
        
        viewController = (AMSViewController*) [self getRootViewController];
        
        if (gameCenterController != nil){
            [gameCenterController setGameCenterDelegate:viewController];
            [gameCenterController setViewState:GKGameCenterViewControllerStateLeaderboards];
            [gameCenterController setLeaderboardCategory:leaderboardID];
            [gameCenterController setLeaderboardTimeScope:GKLeaderboardTimeScopeToday];
            
            if (viewController != nil){
                [viewController presentViewController:gameCenterController animated:YES completion:^(void){
                    [appDelegate setIsGameOver:YES];
                }];
            }
        }
        
    }
    @catch(NSException *exception){
        
        message = [exception description];
        
    }
    @finally{
        NSLog(@"%@",message);
        message = @"";
        viewController = nil;
    }
}



-(void) reportAchievement:(NSDictionary *) achievementData {
    
    GKAchievement *achievement = nil;
    
    NSString *playerName        = @"",
                   *achievementStatus = @"";
    
    NSArray *keys = nil;
    NSArray *achievements = nil;
    
    NSInteger achievementProgress  = 0.0;
    @try {
        
        if (achievementData != nil){
            
            keys = [achievementData allKeys];
            
            
            for (NSString *achivementName in keys ){
                
                 achievementProgress = [[achievementData objectForKey:achivementName] intValue];
                
                achievement = [[GKAchievement alloc] initWithIdentifier:achivementName];
                
                [achievement setPercentComplete:100.0];
                [achievement setShowsCompletionBanner:YES];
        
                achievements = [[NSArray alloc] initWithObjects:achievement, nil];
                
                [GKAchievement reportAchievements:achievements withCompletionHandler:^(NSError *error){
                   
                    [self setLastError:error];
                    
                }];
                
                achievementStatus = [NSString stringWithFormat:@"Sucessfully completed the %@ achievement", achivementName];
                
            }
        }
    
    }
    @catch (NSException *exception) {
        achievementStatus = [exception description];
    }
    @finally {
        NSLog(@"%@",achievementStatus);
        achievementStatus = @"";
        achievements = nil;
    }
    
}

-(void) submitScore:(int64_t)score category:(NSString*)category {
    
    NSString *message    = @"Game Center Features are not Enabled",
                    *playerName = @"";
    
    GKScore  *gkScore  = nil;
    
    NSArray *scores    = nil;
  
    int intScore = 0;
    
    @try{
        //1: Check if Game Center
        //   features are enabled
        if (!_gameCenterFeaturesEnabled) {
            NSLog(@"%@",message);
            return;
        }
        
        intScore = score;
 
        playerName  = [[GKLocalPlayer localPlayer] playerID];

        
        //2: Create a GKScore object
        gkScore = [[GKScore alloc] initWithLeaderboardIdentifier:category];
        
        
        //3: Set the score value
        [gkScore setValue:intScore];
        [gkScore setContext:0];
 
        if ([category isEqualToString:kHighScoreLeaderboardCategory]){
            [gkScore setShouldSetDefaultLeaderboard:YES];
        }
        
        scores = [[NSArray alloc] initWithObjects:gkScore, nil];
    
        [GKScore reportScores:scores withCompletionHandler:^(NSError *error){
           
            [self setLastError:error];
            
        }];

        //4: Send the score to Game Center
        message = [NSString stringWithFormat:@"Sucessfully submitted %lld for %@", gkScore.value,category];
        
    }
    @catch(NSException *exception){
        message = [exception description];
    }
    @finally{
        NSLog(@"%@",message);
        message = @"";
        gkScore = nil;
        scores = nil;
    }

}

+ (id) sharedGameKitHelper{
    
        static AMSGameKitHelper *sharedGameKitHelper;
        static dispatch_once_t onceToken;
        static NSString *message = @"";
    
    @try{
        
        dispatch_once(&onceToken, ^{
            message = @"Sucessfully started sharedGameKitHelper singleton class...";
            sharedGameKitHelper =[[AMSGameKitHelper alloc] init];
        });
    }@catch(NSException *exception){
        message = [exception description];
    }@finally{
        NSLog(@"%@",message);
        message = @"";
    }
    
    return sharedGameKitHelper;
}

#pragma mark Property setters

-(void) setLastError:(NSError*)error {
    _lastError = [error copy];
    if (_lastError) {
        NSLog(@"AMSGameKitHelper ERROR: %@", [[_lastError userInfo]
                                           description]);
    }
}




#pragma mark UIViewController stuff

-(UIViewController*) getRootViewController {
    return [UIApplication sharedApplication].keyWindow.rootViewController;
}

-(void)presentViewController:(UIViewController*)vc {
    
    if (! appDelegate){
        appDelegate = [AMSAppDelegate currentDelegate];
    }

    
    UIViewController* rootVC = [self getRootViewController];
    
    [rootVC presentViewController:vc
                         animated:YES
                       completion:nil];
    
}

// Player authentication, info
-(void) authenticateLocalPlayer{
    
   
        AMSAppDelegate *appDelegate = nil;
        
        appDelegate = [AMSAppDelegate currentDelegate];
    

        GKLocalPlayer *localPlayer  = [GKLocalPlayer localPlayer];
    

        localPlayer.authenticateHandler =^(UIViewController *viewController, NSError *error) {
            
        NSString *message  = (error != nil ? error.description : @"" ),
                        *userName = localPlayer.displayName;
            
        BOOL bAuthenticated =  localPlayer.authenticated;
            
        [self setLastError:error];
            
            if (bAuthenticated) {
                _gameCenterFeaturesEnabled = YES;
                  message = [NSString stringWithFormat: @"%@ is already authenticated in Game Center",userName];
            } else if(viewController) {
              [self presentViewController:viewController];
              message = [NSString stringWithFormat: @"Sucessfully authenticated %@",userName];
            } else {
                _gameCenterFeaturesEnabled = NO;
                message = [NSString stringWithFormat: @"Unable to authenticate %@",userName];
            }
             NSLog(@"%@",message);
        };
        
        localPlayer  = nil;
    
        if (! [appDelegate isAuthenticated]){
            [appDelegate setIsAuthenticated:YES];
        }
    
    
}

@end
