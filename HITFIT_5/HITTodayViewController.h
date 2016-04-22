//
//  HITTodayViewController.h
//  HITFIT_5
//
//  Created by 蒋晟 on 14/10/30.
//  Copyright (c) 2014年 himyself. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface HITTodayViewController : UIViewController <CLLocationManagerDelegate>

- (IBAction)unwindToToday:(UIStoryboardSegue *)segue;

@end
