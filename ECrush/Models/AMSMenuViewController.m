//
//  AMSMenuViewController.m
//  ECrush
//
//  Created by Engel Alipio on 8/20/14.
//  Copyright (c) 2017 Agile Mobile Solutions. All rights reserved.
//

#import "AMSMenuViewController.h"
#import "AMSViewController.h"
#import "AMSAppDelegate.h"

@interface AMSMenuViewController ()
{
    AMSAppDelegate *appDelegate;
}
@end

@implementation AMSMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated{
    if (appDelegate == nil){
        appDelegate = [AMSAppDelegate currentDelegate] ;
    }
    [self.soundSwitch setOn:appDelegate.isMusicOn];
}

-(void) viewDidAppear:(BOOL)animated{

}

-(void) viewDidDisappear:(BOOL)animated{
   [appDelegate setIsMusicOn:self.soundSwitch.isOn];
    appDelegate = nil;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)soundAction:(UISwitch *)sender {
    BOOL bSound = YES;
    AMSViewController *viewController = nil;
    @try {

        bSound = [sender isOn];
        
        viewController =  self.presentingViewController;
        if (viewController){
            if (bSound){
                [viewController startMusic];
            }else{
                [viewController stopMusic];
            }
        }

    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
        bSound = NO;
        viewController = nil;
    }

}

- (IBAction)closeAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
