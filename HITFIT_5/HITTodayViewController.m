//
//  HITTodayViewController.m
//  HITFIT_5
//
//  Created by 蒋晟 on 14/10/30.
//  Copyright (c) 2014年 himyself. All rights reserved.
//

#import "HITTodayViewController.h"
#import "QuartzCurves.h"
#import "HITAddItemViewController.h"
#import <CoreMotion/CoreMotion.h>

#define WALKSTEPSTAG 1
#define WALKCALORIESTAG 2
#define WALKPROGRESSTAG 3
#define WALKFINISHEDTAG 4

#define WEIGHTTAG 5
#define BMITAG 6
#define FATTAG 7
#define THINWEIGHTTAG 8

#define WALKONOFFTAG 9

@interface HITTodayViewController ()

@property HITAppDelegate* appDelegate;
@property (nonatomic) float g_up;
@property (nonatomic) float g_low;
@property (nonatomic) int steps;
@property (nonatomic) NSMutableData *writer;
@property (nonatomic,strong) CMMotionManager *motionManager;
@property BOOL locationIsUpdating;
@property (nonatomic,strong) CLLocationManager* locationManager;
@property (nonatomic, strong) NSTimer *dataSaveTimer;

@property (weak, nonatomic) IBOutlet QuartzEllipseArcView *ArcProgressView;

@end

@implementation HITTodayViewController
@synthesize appDelegate;
@synthesize locationManager, motionManager;

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
    
    appDelegate=(HITAppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.walkChartShouldRefresh = YES;
    appDelegate.weightChartShouldRefresh = YES;
    appDelegate.fatChartShouldRefresh = YES;
    
    NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
    self.dataSaveTimer = [[NSTimer alloc] initWithFireDate:fireDate
                                                  interval:30
                                                    target:self
                                                  selector:@selector(dataSaveOnTimer:)
                                                  userInfo:nil
                                                   repeats:YES];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:self.dataSaveTimer forMode:NSDefaultRunLoopMode];
    
    _locationIsUpdating = NO;
    
    [self updateWalkStepsAfterViewDidLoad];
    [self startStandardLocationUpdates];
    [self startStepCount];
    _locationIsUpdating = YES;
}

- (void)dataSaveOnTimer:(NSTimer*)theTimer {
    NSLog(@"Timer here");
    [self saveUserWalkSteps];
    if ([((UILabel*)[self.view viewWithTag:WALKSTEPSTAG]).text intValue] <= 10000) {
        self.ArcProgressView.steps = ((UILabel*)[self.view viewWithTag:WALKSTEPSTAG]).text;
        [self.ArcProgressView setNeedsDisplay];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSLog(@"prepareForSegue");
    
    //modal有两个，载入前进行不同的设置
    UINavigationController *navController;
    HITAddItemViewController *modalDestinationController;
    //push只有一个，所以不需要特别区分
    if([segue.identifier isEqualToString:@"walkPushSegue"])
    {
        NSLog(@"Segue walk");
    }else if([segue.identifier isEqualToString:@"weightModalSegue"])
    {
        navController = [segue destinationViewController];
        modalDestinationController = (HITAddItemViewController *)[navController topViewController];
        modalDestinationController.segmentedControllerIndex = 1;
        modalDestinationController.lastValue = ((UILabel*)[self.view viewWithTag:WEIGHTTAG]).text;
        NSLog(@"Segue weight");
    }else if([segue.identifier isEqualToString:@"fatModalSegue"])
    {
        navController = [segue destinationViewController];
        modalDestinationController = (HITAddItemViewController *)[navController topViewController];
        modalDestinationController.segmentedControllerIndex = 2;
        modalDestinationController.lastValue = ((UILabel*)[self.view viewWithTag:FATTAG]).text;
        NSLog(@"Segue fat");
    }
}


- (IBAction)unwindToToday:(UIStoryboardSegue *)segue
{
    NSLog(@"segue unwind.");
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSTimeInterval a=[date timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%.0f", (a + interval)];//转为字符型
    NSLog(@"timeString:%@",timeString);
    
    HITAddItemViewController *sourceController  = [segue sourceViewController];
    if (sourceController.itemString != nil) {
        //如果传来的数据不是nil，则将数据存入sqlite.
        FMDatabase* database=[FMDatabase databaseWithPath:[self databasePath]];
        if (![database open]) {
            NSLog(@"Open database failed");
            return;
        }
        if (![database tableExists:@"weightTable"]) {
            [database executeUpdate:@"create table weightTable (weight text, weightTimeStamp text)"];
        }
        if (![database tableExists:@"fatTable"]) {
            [database executeUpdate:@"create table fatTable (fat text, fatTimeStamp text)"];
        }
        
        BOOL insert;
        switch (sourceController.segmentedControllerIndex) {
            case 0:
                //计步器
                break;
            case 1:
                ((UILabel *)[self.view viewWithTag:WEIGHTTAG]).text = sourceController.itemString;
                insert=[database executeUpdate:@"insert into weightTable (weight, weightTimeStamp) values (?, ?)",sourceController.itemString, timeString];
                if (insert) {
                    appDelegate.weightChartShouldRefresh = YES;
                    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
                    //保存用户最新的体重
                    [defaults setObject:sourceController.itemString forKey:@"userLastWeight"];
                    NSString *height = [defaults stringForKey:@"userHeight"];
                    if (height) {
                        NSString *userBMI = [NSString stringWithFormat:@"%.1f", [sourceController.itemString integerValue] / powf([height floatValue] / 100, 2)];
                        ((UILabel *)[self.view viewWithTag:BMITAG]).text = userBMI;
                        [defaults setObject:userBMI forKey:@"userBMI"];
                    }
                    [defaults synchronize];
                }else{
                    NSLog(@"insert weight failed");
                }
                break;
            case 2:
                ((UILabel *)[self.view viewWithTag:FATTAG]).text = sourceController.itemString;
                insert=[database executeUpdate:@"insert into fatTable (fat, fatTimeStamp) values (?, ?)",sourceController.itemString, timeString];
                if (insert) {
                    appDelegate.fatChartShouldRefresh = YES;
                    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
                    //保存用户最新的体脂率
                    [defaults setObject:sourceController.itemString forKey:@"userLastFat"];
                    NSString *userLastWeight = [defaults stringForKey:@"userLastWeight"];
                    if (userLastWeight) {
                        NSLog(@"fat rate is %f", [sourceController.itemString floatValue]);
                        NSString *userThinWeight = [NSString stringWithFormat:@"%.1f", [userLastWeight floatValue] * (1 - [sourceController.itemString floatValue] / 100)];
                        ((UILabel *)[self.view viewWithTag:THINWEIGHTTAG]).text = userThinWeight;
                        [defaults setObject:userThinWeight forKey:@"userThinWeight"];
                    }
                    [defaults synchronize];
                }else{
                    NSLog(@"insert fat failed");
                }
                break;
            default:
                break;
        }
        
        [database close];
    }
}

-(NSString* )databasePath
{
    NSString* path=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* dbPath=[path stringByAppendingPathComponent:@"user.db"];
    return dbPath;
    
}

-(CMMotionManager *)motionManager
{
    if (!motionManager){
        motionManager = [[CMMotionManager alloc]init];
        motionManager.accelerometerUpdateInterval=0.2;   }
    return motionManager;
}

- (void)startStandardLocationUpdates
{
    // Create the location manager if this object does not
    // already have one.
    if (nil == locationManager)
        locationManager = [[CLLocationManager alloc] init];
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    
    locationManager.pausesLocationUpdatesAutomatically = NO;
    
    // Set a movement threshold for new events.
    locationManager.distanceFilter = 1000; // meters
    [locationManager startUpdatingLocation];
}

// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    NSLog(@"地理位置上报.");
    
}

-(void)startStepCount
{
    self.g_up=1;
    self.g_low=1;
    self.steps =[((UILabel*)[self.view viewWithTag:WALKSTEPSTAG]).text intValue]*2;
    if (!self.motionManager.isAccelerometerActive){
        [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
            //                    BOOL __block query;
            float x = accelerometerData.acceleration.x;
            float y = accelerometerData.acceleration.y;
            float z = accelerometerData.acceleration.z;
            float g = sqrtf(x*x + y*y + z*z);
            
            if (g>self.g_up) {
                self.g_up=g;
            }
            if (g<self.g_low) {
                self.g_low=g;
            }
            if (g>1.35) {
                self.steps=self.steps+1;
            }
            if (g<0.9) {
                self.steps=self.steps+1;
            }
            int tmp=self.steps/2;
            ((UILabel*)[self.view viewWithTag:WALKSTEPSTAG]).text=[NSString stringWithFormat:@"%d",tmp];
        }];
    }
}

-(void)saveUserWalkSteps
{
    BOOL query;
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSTimeInterval a=[date timeIntervalSince1970];
    NSString *currentWalkTimeString = [NSString stringWithFormat:@"%.0f", a + interval];
    //保存用户的步行数据
    FMDatabase* database=[FMDatabase databaseWithPath:[self databasePath]];
    if (![database open]) {
        NSLog(@"Open database failed");
        return;
    }
    //表不存在，新建表并插入一条0记录
    if (![database tableExists:@"walkTable"]) {
        [database executeUpdate:@"create table walkTable (walk text, walkTimeStamp text)"];
        query=[database executeUpdate:@"insert into walkTable (walk, walkTimeStamp) values (?, ?)",@"0", currentWalkTimeString];
        if (!query) {
            NSLog(@"walk insert failed.");
        }
    }else
    {
        FMResultSet* resultSet=[database executeQuery:@"select walkTimeStamp from walkTable order by walkTimeStamp desc limit 1"];
        NSString* lastWalkTimeStamp=@"0";
        while ([resultSet next]) {
            lastWalkTimeStamp = [resultSet stringForColumn:@"walkTimeStamp"];
        }
        NSLog(@"LAST IS %@ toInt %ld", lastWalkTimeStamp, (long)[lastWalkTimeStamp integerValue]);
        //比较两个时间戳，判断是否是在同一天，同一天就update纪录，不同就insert.
        NSDate *currentDate = [NSDate dateWithTimeIntervalSinceNow:0];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *currentDateComponent = [calendar components:NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:currentDate];
        NSInteger currentHour = [currentDateComponent hour];
        NSInteger currentMinute = [currentDateComponent minute];
        NSInteger currentSecond = [currentDateComponent second];
        NSLog(@"lasttimeint is %ld , currentDayTime is %ld.",(long)[lastWalkTimeStamp integerValue], (long)[currentWalkTimeString integerValue] - currentHour*3600 - currentMinute*60 - currentSecond);
        if ([lastWalkTimeStamp integerValue] < ([currentWalkTimeString integerValue] - currentHour*3600 - currentMinute*60 - currentSecond)) {
            //        if ([lastWalkTimeStamp integerValue] < ([currentWalkTimeString integerValue] - 20)) {
            //之前就是这玩意儿没有被清零。
            self.steps = 0;
            ((UILabel*)[self.view viewWithTag:WALKSTEPSTAG]).text = @"0";
            query=[database executeUpdate:@"insert into walkTable (walk, walkTimeStamp) values (?, ?)",@"0", currentWalkTimeString];
            NSLog(@"插入新纪录");
            if (!query) {
                NSLog(@"walk insert failed.");
            }
            //将热量值，progress，完成状态清零。
//            ((UILabel*)[self.view viewWithTag:WALKCALORIESTAG]).text = @"0";
//            NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
//            [defaults setObject:@"0" forKey:@"userLastCalories"];
//            ((UIProgressView *)[self.view viewWithTag:WALKPROGRESSTAG]).progress = 0;
//            ((UILabel *)[self.view viewWithTag:WALKFINISHEDTAG]).text = @"0";
        }else
        {
            NSString *currentSteps = ((UILabel*)[self.view viewWithTag:WALKSTEPSTAG]).text;
            query = [database executeUpdate:@"UPDATE walkTable SET walk = ?, walkTimeStamp = ? WHERE walkTimeStamp = ?", currentSteps, currentWalkTimeString, lastWalkTimeStamp];
            if (!query) {
                NSLog(@"walk update failed.");
            }
            NSLog(@"更新上一条");
            //更新热量值，progressbar, 完成状态
//            [self updateWalkCalaries];
//            ((UIProgressView *)[self.view viewWithTag:WALKPROGRESSTAG]).progress = [currentSteps integerValue] / 10000.0;
//            ((UILabel *)[self.view viewWithTag:WALKFINISHEDTAG]).text = [NSString stringWithFormat:@"%.1f", [currentSteps integerValue] / 100.0];
        }
        appDelegate.walkChartShouldRefresh = YES;
    }
}

-(void)updateWalkStepsAfterViewDidLoad
{
    NSLog(@"update walk steps after switch on.");
    FMDatabase* database=[FMDatabase databaseWithPath:[self databasePath]];
    if (![database open]) {
        //add return value to solve problem
        NSLog(@"database open failed");
    }
    
    if ([database tableExists:@"walkTable"]) {
        //如果是前一天的数据，则计步要清零。
        //((UILabel*)[self.tableView viewWithTag:WALKSTEPSTAG]).text = @"0";
        FMResultSet* resultSet=[database executeQuery:@"select walk, walkTimeStamp from walkTable order by walkTimeStamp desc limit 1"];
        NSString* lastWalkSteps=@"0";
        NSString *lastWalkTimeStamp = @"0";
        while ([resultSet next]) {
            lastWalkSteps = [resultSet stringForColumn:@"walk"];
            lastWalkTimeStamp = [resultSet stringForColumn:@"walkTimeStamp"];
        }
        NSLog(@"LAST WALK STAMP = %@ and steps is %@", lastWalkTimeStamp, lastWalkSteps);
        NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeZone *zone = [NSTimeZone systemTimeZone];
        NSInteger interval = [zone secondsFromGMTForDate: date];
        NSTimeInterval a=[date timeIntervalSince1970];
        NSString *currentWalkTimeString = [NSString stringWithFormat:@"%.0f", a + interval];
        //比较两个时间戳，判断是否是在同一天，同一天就继续计步，不同就从0开始计步。
        NSDate *currentDate = [NSDate dateWithTimeIntervalSince1970:[currentWalkTimeString integerValue]];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *currentDateComponent = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:currentDate];
        NSInteger currentHour = [currentDateComponent hour];
        NSInteger currentMinute = [currentDateComponent minute];
        NSInteger currentSecond = [currentDateComponent second];
        if ([lastWalkTimeStamp floatValue] < ([currentWalkTimeString floatValue] - currentHour*3600 - currentMinute*60 - currentSecond)) {
            ((UILabel *)[self.view viewWithTag:WALKSTEPSTAG]).text=@"0";
//            _calaryLastSteps = 0;
//            _calaryCurrentSteps = 0;
        }else
        {
            ((UILabel *)[self.view viewWithTag:WALKSTEPSTAG]).text=lastWalkSteps;
//            _calaryLastSteps = [lastWalkSteps integerValue];
//            _calaryCurrentSteps = [lastWalkSteps integerValue];
        }
        
    }
}

@end
