//
//  AMSMenuViewController.h
//  ECrush
//
//  Created by Engel Alipio on 8/20/14.
//  Copyright (c) 2017 Agile Mobile Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

@interface AMSMenuViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *btnClose;
@property (strong, nonatomic) IBOutlet UISwitch *soundSwitch;

- (IBAction)soundAction:(UISwitch *)sender;

- (IBAction)closeAction:(UIButton *)sender;

@end
