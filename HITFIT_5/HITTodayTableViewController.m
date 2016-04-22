//
//  HITTodayTableViewController.m
//  HITBasic
//
//  Created by 蒋晟 on 14-9-26.
//  Copyright (c) 2014年 himyself. All rights reserved.
//

#import "HITTodayTableViewController.h"
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

@interface HITTodayTableViewController ()

- (IBAction)stepCountOnOff:(id)sender;

@property HITAppDelegate* appDelegate;

@property (nonatomic) float g_up;
@property (nonatomic) float g_low;
@property (nonatomic) int steps;
@property (nonatomic) NSMutableData *writer;
@property (nonatomic,strong) CMMotionManager *motionManager;
@property BOOL locationIsUpdating;
@property (nonatomic,strong) CLLocationManager* locationManager;

@property (nonatomic, strong) NSTimer *dataSaveTimer;
//30秒前后的步数
@property NSInteger calaryLastSteps;
@property NSInteger calaryCurrentSteps;
@end

@implementation HITTodayTableViewController

@synthesize appDelegate;
@synthesize locationManager, motionManager;

- (void)viewDidLoad {
    [super viewDidLoad];

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    appDelegate=(HITAppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.walkChartShouldRefresh = YES;
    appDelegate.weightChartShouldRefresh = YES;
    appDelegate.fatChartShouldRefresh = YES;
    
    //获取设备的宽和高
//    CGRect sizeRect = [UIScreen mainScreen].applicationFrame;
//    int width = sizeRect.size.width;
//    int height = sizeRect.size.height;
//      NSLog(@"device width: %d, height: %d.", width, height);
    
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
}

- (void)dataSaveOnTimer:(NSTimer*)theTimer {
    NSLog(@"Timer here");
    [self saveUserWalkSteps];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"今天"];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"今天"];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    if (((UISwitch*)[self.tableView viewWithTag:WALKONOFFTAG]).on && (!_locationIsUpdating)) {
        NSLog(@"SWITCH on");
        [self startStandardLocationUpdates];
        [self startStepCount];
        _locationIsUpdating = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    switch ([indexPath row]) {
        case 0:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"walkCellIdentifier" forIndexPath:indexPath];
            [self updateWalkStepsAfterSwicthOn];
            NSString *userCalories = [defaults stringForKey:@"userLastCalories"];
            if (userCalories) {
                ((UILabel *)[tableView viewWithTag:WALKCALORIESTAG]).text = userCalories;
            }
        }
            break;
        case 1:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"weightCellIdentifier" forIndexPath:indexPath];
            [self getWeightOrFatFromDatabaseWithTable:@"weightTable" Type:@"weight" Timestamp:@"weightTimeStamp" LabelTag:WEIGHTTAG];
            NSString *userBMI = [defaults stringForKey:@"userBMI"];
            if (userBMI) {
                ((UILabel *)[tableView viewWithTag:BMITAG]).text = userBMI;
            }
        }
            break;
        case 2:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"fatCellIdentifier" forIndexPath:indexPath];
            [self getWeightOrFatFromDatabaseWithTable:@"fatTable" Type:@"fat" Timestamp:@"fatTimeStamp" LabelTag:FATTAG];
            NSString *userThinWeight = [defaults stringForKey:@"userThinWeight"];
            if (userThinWeight) {
                ((UILabel *)[tableView viewWithTag:THINWEIGHTTAG]).text = userThinWeight;
            }
        }
            break;
        default:
            cell = [tableView dequeueReusableCellWithIdentifier:@"weightCellIdentifier" forIndexPath:indexPath];
            break;
    }
    // Configure the cell...
    return cell;
}

-(void)getWeightOrFatFromDatabaseWithTable:(NSString*)table Type:(NSString *)type Timestamp:(NSString*)timestamp LabelTag:(NSInteger)tag
{
    FMDatabase* database=[FMDatabase databaseWithPath:[self databasePath]];
    if (![database open]) {
        //add return value to solve problem
        NSLog(@"database open failed");
    }
    if ([database tableExists:table]) {
        FMResultSet* resultSet=[database executeQuery:[NSString stringWithFormat:@"select %@ from %@ order by %@ desc limit 1", type, table, timestamp]];
        NSString* str=@"0";
        while ([resultSet next]) {
            str = [resultSet stringForColumn:type];
        }
        NSLog(@"%@ is %@.", type, str);
        ((UILabel *)[self.tableView viewWithTag:tag]).text=str;
    }
    [database close];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height;
    switch ([indexPath row]) {
        case 0:
            height = 160;
            break;
        case 1:
            height = 130;
            break;
        case 2:
            height = 130;
            break;
        default:
            height = 0;
            break;
    }
    return height;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


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
        modalDestinationController.lastValue = ((UILabel*)[self.tableView viewWithTag:WEIGHTTAG]).text;
        NSLog(@"Segue weight");
    }else if([segue.identifier isEqualToString:@"fatModalSegue"])
    {
        navController = [segue destinationViewController];
        modalDestinationController = (HITAddItemViewController *)[navController topViewController];
        modalDestinationController.segmentedControllerIndex = 2;
        modalDestinationController.lastValue = ((UILabel*)[self.tableView viewWithTag:FATTAG]).text;
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
        //下面注释的也能实现数据的插入,只不过它是传入了字典
        //    NSMutableDictionary* argsDict=[NSMutableDictionary dictionary];
        //    [argsDict setObject:_nameText.text forKey:@"name"];
        //    [argsDict setObject:_ageText.text forKey:@"age"];
        //    [argsDict setObject:_sexText.text forKey:@"sex"];
        //    BOOL insert=[database executeUpdate:@"insert into user (name,age,sex) values (:name,:age,:sex)" withParameterDictionary:argsDict];
        BOOL insert;
        switch (sourceController.segmentedControllerIndex) {
            case 0:
                //计步器
                break;
            case 1:
                ((UILabel *)[self.tableView viewWithTag:WEIGHTTAG]).text = sourceController.itemString;
                insert=[database executeUpdate:@"insert into weightTable (weight, weightTimeStamp) values (?, ?)",sourceController.itemString, timeString];
                if (insert) {
                    appDelegate.weightChartShouldRefresh = YES;
                    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
                    //保存用户最新的体重
                    [defaults setObject:sourceController.itemString forKey:@"userLastWeight"];
                    NSString *height = [defaults stringForKey:@"userHeight"];
                    if (height) {
                        NSString *userBMI = [NSString stringWithFormat:@"%.1f", [sourceController.itemString integerValue] / powf([height floatValue] / 100, 2)];
                        ((UILabel *)[self.tableView viewWithTag:BMITAG]).text = userBMI;
                        [defaults setObject:userBMI forKey:@"userBMI"];
                    }
                    [defaults synchronize];
                }else{
                    NSLog(@"insert weight failed");
                }
                break;
            case 2:
                ((UILabel *)[self.tableView viewWithTag:FATTAG]).text = sourceController.itemString;
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
                        ((UILabel *)[self.tableView viewWithTag:THINWEIGHTTAG]).text = userThinWeight;
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
    // If it's a relatively recent event, turn off updates to save power.
//    CLLocation* location = [locations lastObject];
//    NSDate* eventDate = location.timestamp;
//    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
//    if (abs(howRecent) < 15.0) {
//        // If the event is recent, do something with it.
//        NSLog(@"latitude %+.6f, longitude %+.6f\n",
//              location.coordinate.latitude,
//              location.coordinate.longitude);
//    }
    NSLog(@"地理位置上报.");
    
}


- (IBAction)stepCountOnOff:(id)sender {
    if (((UISwitch*)sender).on) {
        [self updateWalkStepsAfterSwicthOn];
        [self startStandardLocationUpdates];
        [self startStepCount];
        _locationIsUpdating = YES;
        NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
        self.dataSaveTimer = [[NSTimer alloc] initWithFireDate:fireDate
                                                      interval:30
                                                        target:self
                                                      selector:@selector(dataSaveOnTimer:)
                                                      userInfo:nil
                                                       repeats:YES];
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addTimer:self.dataSaveTimer forMode:NSDefaultRunLoopMode];
    }else {
        [locationManager stopUpdatingLocation];
        [motionManager stopAccelerometerUpdates];
        _locationIsUpdating = NO;
        [self saveUserWalkSteps];
        [self.dataSaveTimer invalidate];
        self.dataSaveTimer = nil;
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
            ((UILabel*)[self.tableView viewWithTag:WALKSTEPSTAG]).text = @"0";
            query=[database executeUpdate:@"insert into walkTable (walk, walkTimeStamp) values (?, ?)",@"0", currentWalkTimeString];
            NSLog(@"插入新纪录");
            if (!query) {
                NSLog(@"walk insert failed.");
            }
            //将热量值，progress，完成状态清零。
            ((UILabel*)[self.tableView viewWithTag:WALKCALORIESTAG]).text = @"0";
            NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
            [defaults setObject:@"0" forKey:@"userLastCalories"];
            ((UIProgressView *)[self.tableView viewWithTag:WALKPROGRESSTAG]).progress = 0;
            ((UILabel *)[self.tableView viewWithTag:WALKFINISHEDTAG]).text = @"0";
        }else
        {
            NSString *currentSteps = ((UILabel*)[self.tableView viewWithTag:WALKSTEPSTAG]).text;
            query = [database executeUpdate:@"UPDATE walkTable SET walk = ?, walkTimeStamp = ? WHERE walkTimeStamp = ?", currentSteps, currentWalkTimeString, lastWalkTimeStamp];
            if (!query) {
                NSLog(@"walk update failed.");
            }
            NSLog(@"更新上一条");
             //更新热量值，progressbar, 完成状态
            [self updateWalkCalaries];
            ((UIProgressView *)[self.tableView viewWithTag:WALKPROGRESSTAG]).progress = [currentSteps integerValue] / 10000.0;
            ((UILabel *)[self.tableView viewWithTag:WALKFINISHEDTAG]).text = [NSString stringWithFormat:@"%.1f", [currentSteps integerValue] / 100.0];
        }
        appDelegate.walkChartShouldRefresh = YES;
    }
}

//被定时器调用，计算30秒内的步行消耗热量
-(void)updateWalkCalaries
{
    _calaryCurrentSteps = [((UILabel *)[self.tableView viewWithTag:WALKSTEPSTAG]).text integerValue];
    NSInteger periodSteps = _calaryCurrentSteps - _calaryLastSteps;
    NSLog(@"periodSteps is %d.", periodSteps);
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
   
    //文献上的公式和身高，体重有关，但是不符合目前的实时要求，暂不考虑。
//     NSString *userHeight = [defaults stringForKey:@"userHeight"];
//    if (!userHeight) {
//        return;
//    }
//    NSString *userLastWeight = [defaults stringForKey:@"userLastWeight"];
//    if (!userLastWeight) {
//        return;
//    }
    float calariesConsumed = periodSteps / 75.0 * 2.0;
    if (calariesConsumed >=0) {
        NSString *currentCalories = ((UILabel *)[self.tableView viewWithTag:WALKCALORIESTAG]).text;
        ((UILabel *)[self.tableView viewWithTag:WALKCALORIESTAG]).text = [NSString stringWithFormat:@"%.1f",[currentCalories floatValue] + calariesConsumed];
        [defaults setObject:((UILabel *)[self.tableView viewWithTag:WALKCALORIESTAG]).text forKey:@"userLastCalories"];
        [defaults synchronize];
    }else
    {
        NSLog(@"calaries < 0. somtthing wrong.");
    }
    _calaryLastSteps = _calaryCurrentSteps;
}

-(void)updateWalkStepsAfterSwicthOn
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
            ((UILabel *)[self.tableView viewWithTag:WALKSTEPSTAG]).text=@"0";
            _calaryLastSteps = 0;
            _calaryCurrentSteps = 0;
        }else
        {
            ((UILabel *)[self.tableView viewWithTag:WALKSTEPSTAG]).text=lastWalkSteps;
            _calaryLastSteps = [lastWalkSteps integerValue];
            _calaryCurrentSteps = [lastWalkSteps integerValue];
        }
        
    }
}

-(void)startStepCount
{
    self.g_up=1;
    self.g_low=1;
    self.steps =[((UILabel*)[self.tableView viewWithTag:WALKSTEPSTAG]).text intValue]*2;
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
                 ((UILabel*)[self.tableView viewWithTag:WALKSTEPSTAG]).text=[NSString stringWithFormat:@"%d",tmp];
        }];
    }
}
@end
