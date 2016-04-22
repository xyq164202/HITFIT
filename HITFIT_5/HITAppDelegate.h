//
//  HITAppDelegate.h
//  HITFIT_5
//
//  Created by 蒋晟 on 14-10-10.
//  Copyright (c) 2014年 himyself. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HITAppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;

@property BOOL walkChartShouldRefresh;
@property BOOL weightChartShouldRefresh;
@property BOOL fatChartShouldRefresh;
@end
