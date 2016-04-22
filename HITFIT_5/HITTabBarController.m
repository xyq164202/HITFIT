//
//  HITTabBarController.m
//  HITFIT_5
//
//  Created by 蒋晟 on 14/10/19.
//  Copyright (c) 2014年 himyself. All rights reserved.
//

#import "HITTabBarController.h"

@interface HITTabBarController ()

@end

@implementation HITTabBarController

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
    [self.tabBar setTintColor:[UIColor colorWithRed:51/255.0 green: 204/255.0 blue:204/255.0 alpha:1]];
//    for(UITabBarItem *tbItem in [[self tabBar] items])
//    {
////        [tabBarItems addObject:tbItem];
//        [tbItem setFinishedSelectedImage:[self imageForTabBarItem:[tbItem tag] selected:YES]
//             withFinishedUnselectedImage:[self imageForTabBarItem:[tbItem tag] selected:NO]];
//    }
    UITabBarItem *todayTabBarItem = [self.tabBar.items objectAtIndex:0];
    [todayTabBarItem setSelectedImage:[[UIImage imageNamed:@"today_on.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    UITabBarItem *reportTabBarItem = [self.tabBar.items objectAtIndex:1];
    [reportTabBarItem setSelectedImage:[[UIImage imageNamed:@"report_on.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    UITabBarItem *userTabBarItem = [self.tabBar.items objectAtIndex:2];
    [userTabBarItem setSelectedImage:[[UIImage imageNamed:@"user_on.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end
