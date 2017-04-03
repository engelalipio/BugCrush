//
//  AMSAppDelegate.m
//  ECrush
//
//  Created by Engel Alipio on 8/15/14.
//  Copyright (c) 2017 Agile Mobile Solutions. All rights reserved.
//

#import "AMSAppDelegate.h"
#import <VungleSDK/VungleSDK.h>

@implementation AMSAppDelegate

@synthesize currentLevel = _currentLevel;
@synthesize levels = _levels;
@synthesize isMusicOn = _isMusicOn;
@synthesize isGameOver = _isGameOver;
@synthesize isAuthenticated = _isAuthenticated;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.

    if (self.levels == nil){
        _levels = [[NSArray alloc] initWithObjects:@"Level_0",@"Level_1",@"Level_2",@"Level_3",@"Level_4",
                   @"Level_5",@"Level_6",@"Level_7",@"Level_8",@"Level_9",nil];
    }
    
    
    [self randomLevel];
    [self setIsMusicOn:YES];
    [self IniVungleNetWork];
    return YES;
}

-(NSString *) randomLevel{
    NSString *levelName = @"",
                    *message   = @"";
    
    int rndLevel = 0;
    bool notSet = false;
    
    @try {
    
        
        while (! notSet) {
            
                rndLevel = arc4random_uniform(self.levels.count);
                levelName = [self.levels objectAtIndex:rndLevel];
            
                if (! self.currentLevel){
                    _currentLevel = levelName;
                    message = [NSString  stringWithFormat:@"Set Initial Random Level to -> %@",levelName];
                    notSet = true;
                }else{
                    if (self.currentLevel != levelName ){
                        self.currentLevel = levelName;
                        message = [NSString  stringWithFormat:@"Set Next Random Level to -> %@",levelName];
                        notSet = true;
                    }
            }
            
        }
    
        
    } @catch (NSException *exception) {
        message = exception.description;
    } @finally {
        if (message){
            NSLog(@"randomLevel->%@",message);
        }
        message = @"";
        notSet = false;
        rndLevel = 0;
    }
    
    return levelName;
}

-(void) IniVungleNetWork{
    NSString *vungleId = @"";
    VungleSDK *sdk = nil;
    
    @try {
        
        vungleId = kVungleId;
        
        sdk = [VungleSDK sharedSDK];
        
        [sdk startWithAppId:vungleId];
        
        NSLog(@"Sucessfully Initialized Vungle Network");
        
    } @catch (NSException *exception) {
        NSLog(@"Unable to Initialize Vungle Network");
    } @finally {
        sdk = nil;
        vungleId = @"";
    }
}

+ (AMSAppDelegate *)currentDelegate
{
    return (AMSAppDelegate *)[[UIApplication sharedApplication] delegate];
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
