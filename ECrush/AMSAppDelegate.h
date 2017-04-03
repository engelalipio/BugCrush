//
//  AMSAppDelegate.h
//  ECrush
//
//  Created by Engel Alipio on 8/15/14.
//  Copyright (c) 2017 Agile Mobile Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AMSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong,nonatomic) UIWindow  *window;
@property (strong,nonatomic) NSString  *currentLevel;
@property (strong,nonatomic) NSArray   *levels;
@property (assign,nonatomic) BOOL      isAuthenticated;
@property (assign,nonatomic) BOOL      isGameOver;
@property (assign,nonatomic) BOOL      isMusicOn;
+ (AMSAppDelegate *)currentDelegate;
-(NSString *) randomLevel;
@end
