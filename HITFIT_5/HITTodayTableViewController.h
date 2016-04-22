//
//  HITTodayTableViewController.h
//  HITBasic
//
//  Created by 蒋晟 on 14-9-26.
//  Copyright (c) 2014年 himyself. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface HITTodayTableViewController : UITableViewController <CLLocationManagerDelegate>

- (IBAction)unwindToToday:(UIStoryboardSegue *)segue;

@end
