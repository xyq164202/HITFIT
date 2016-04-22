//
//  HITReportViewController.m
//  HITFIT_5
//
//  Created by 蒋晟 on 14-10-12.
//  Copyright (c) 2014年 himyself. All rights reserved.
//

#import "HITReportViewController.h"

#define SCROLLVIEWWIDTH 320
#define SCROLLVIEWHEIGHT 284

#define SEG_WEEK 0
#define SEG_MONTH 1
#define SEG_SEASON 2
#define SEG_YEAR 3

#define WALKWEBVIEW 1
#define WEIGHTWEBVIEW 2
#define FATWEBVIEW 3

@interface HITReportViewController ()
@property HITAppDelegate *appDelegate;

@property NSArray *weekArray;
@property NSMutableString * chartData;
@property (weak, nonatomic) IBOutlet UISegmentedControl *periodSegmentedControl;
- (IBAction)periodSegmentedChange:(id)sender;

@property (weak, nonatomic) IBOutlet UIPageControl *reportPageControl;

@property UIWebView *walkWebView;
@property UIWebView *weightWebView;
@property UIWebView *fatWebView;

@property UIScrollView *reportScrollView;

@property (weak, nonatomic) IBOutlet UILabel *reportTitleLabel1;
@property (weak, nonatomic) IBOutlet UILabel *reportTitleLabel2;
@property (weak, nonatomic) IBOutlet UILabel *reportValueLabel1;
@property (weak, nonatomic) IBOutlet UILabel *reportValueLabel2;
@property NSString *averageSteps;
@property NSString *sumSteps;
@property NSString *averageWeight;
@property NSString *weightRate;
@property NSString *averageFat;
@property NSString *fatRate;

@end

@implementation HITReportViewController
@synthesize appDelegate;

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
    
    self.weekArray = [NSArray arrayWithObjects:@"周日", @"周一", @"周二", @"周三", @"周四", @"周五", @"周六", nil];
    
    appDelegate=(HITAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    // Do any additional setup after loading the view.
    _reportScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 136, 320,284)];
    //第二个参数设为0，禁止scroll垂直滑动
    [_reportScrollView setContentSize:CGSizeMake(SCROLLVIEWWIDTH * 3, 284)];
    //开启滚动分页功能，如果不需要这个功能关闭即可
    [_reportScrollView setPagingEnabled:YES];
    //隐藏横向与纵向的滚动条
    [_reportScrollView setShowsVerticalScrollIndicator:NO];
    [_reportScrollView setShowsHorizontalScrollIndicator:NO];
    _reportScrollView.delegate = self;
    

    _walkWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, SCROLLVIEWWIDTH, SCROLLVIEWHEIGHT)];
    _weightWebView = [[UIWebView alloc]initWithFrame:CGRectMake(SCROLLVIEWWIDTH, 0, SCROLLVIEWWIDTH, SCROLLVIEWHEIGHT)];
    _fatWebView = [[UIWebView alloc]initWithFrame:CGRectMake(2*SCROLLVIEWWIDTH, 0, SCROLLVIEWWIDTH, SCROLLVIEWHEIGHT)];
    
    [_reportScrollView addSubview:_walkWebView];
    [_reportScrollView addSubview:_weightWebView];
    [_reportScrollView addSubview:_fatWebView];
    
    _walkWebView.delegate = self;
    _walkWebView.tag = WALKWEBVIEW;
    _weightWebView.delegate = self;
    _weightWebView.tag = WEIGHTWEBVIEW;
    _fatWebView.delegate =self;
    _fatWebView.tag = FATWEBVIEW;
    
    [self.view addSubview:_reportScrollView];
    
    [_reportPageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    
    
    //载入步行简报html
    NSMutableString *htmlContentWalk = [[NSMutableString alloc] init];
    NSString *htmlFileWalk = [[NSBundle mainBundle] pathForResource:@"HITReportWalkChart" ofType:@"html"];
    NSURL *baseURLWalk = [NSURL fileURLWithPath:htmlFileWalk];
    [htmlContentWalk appendString:[NSString stringWithContentsOfFile:htmlFileWalk encoding:NSUTF8StringEncoding error:nil]];
    _walkWebView.scrollView.scrollEnabled = NO;
    _walkWebView.scrollView.bounces = NO;
    [_walkWebView loadHTMLString:htmlContentWalk baseURL:baseURLWalk];
    
    //载入体重简报html
    NSMutableString *htmlContentWeight = [[NSMutableString alloc] init];
    NSString *htmlFileWeight = [[NSBundle mainBundle] pathForResource:@"HITReportWeightChart" ofType:@"html"];
    NSURL *baseURLWeight = [NSURL fileURLWithPath:htmlFileWeight];
    [htmlContentWeight appendString:[NSString stringWithContentsOfFile:htmlFileWeight encoding:NSUTF8StringEncoding error:nil]];
    _weightWebView.scrollView.scrollEnabled = NO;
    _weightWebView.scrollView.bounces = NO;
    [_weightWebView loadHTMLString:htmlContentWeight baseURL:baseURLWeight];
    
    //载入体脂简报html
    NSMutableString *htmlContentFat = [[NSMutableString alloc] init];
    NSString *htmlFileFat = [[NSBundle mainBundle] pathForResource:@"HITReportFatChart" ofType:@"html"];
    NSURL *baseURLFat = [NSURL fileURLWithPath:htmlFileFat];
    [htmlContentFat appendString:[NSString stringWithContentsOfFile:htmlFileFat encoding:NSUTF8StringEncoding error:nil]];
    _fatWebView.scrollView.scrollEnabled = NO;
    _fatWebView.scrollView.bounces = NO;
    [_fatWebView loadHTMLString:htmlContentFat baseURL:baseURLFat];
}

- (void)changePage:(id)sender
{
    //得到当前页面的ID
    //int page = [sender currentPage];
    
    //在这里写你需要执行的代码
    //......
}


//手指离开屏幕后ScrollView还会继续滚动一段时间只到停止
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self reloadChartDataAccordingToCurrentPageWithPeriodIndex:_periodSegmentedControl.selectedSegmentIndex];
}

-(void)reloadChartDataAccordingToCurrentPageWithPeriodIndex:(NSInteger)index
{
    switch (_reportPageControl.currentPage) {
        case 0:
            self.navigationItem.title = @"步行";
            self.reportTitleLabel1.text = @"平均步数";
            self.reportTitleLabel2.text = @"总步数";
            self.reportValueLabel1.text = self.averageSteps;
            self.reportValueLabel2.textColor = [UIColor colorWithRed:51.0/255 green:204.0/255 blue:204.0/255 alpha:1.0];
            self.reportValueLabel2.text = self.sumSteps;
            if (appDelegate.walkChartShouldRefresh) {
                appDelegate.walkChartShouldRefresh = NO;
                [self reloadWebViewWithDataTable:@"walkTable" Type:@"walk" Timestamp:@"walkTimeStamp" PeriodIndex:index InthisWebview:_walkWebView];
            }
            break;
        case 1:
            self.navigationItem.title = @"体重";
            self.reportTitleLabel1.text = @"平均体重";
            self.reportTitleLabel2.text = @"增长率";
            self.reportValueLabel1.text = self.averageWeight;
            [self rateLabelColorSetWithIncreaseRate:[self.weightRate floatValue]];
            self.reportValueLabel2.text = [self.weightRate stringByAppendingString:@" %"];
            if (appDelegate.weightChartShouldRefresh) {
                appDelegate.weightChartShouldRefresh = NO;
                [self reloadWebViewWithDataTable:@"weightTable" Type:@"weight" Timestamp:@"weightTimeStamp" PeriodIndex:index InthisWebview:_weightWebView];
            }
            break;
        case 2:
            self.navigationItem.title = @"脂肪";
            self.reportTitleLabel1.text = @"平均体脂";
            self.reportTitleLabel2.text = @"增长率";
            self.reportValueLabel1.text = self.averageFat;
            [self rateLabelColorSetWithIncreaseRate:[self.fatRate floatValue]];
            self.reportValueLabel2.text = [self.fatRate stringByAppendingString:@" %"];
            if (appDelegate.fatChartShouldRefresh) {
                appDelegate.fatChartShouldRefresh = NO;
                [self reloadWebViewWithDataTable:@"fatTable" Type:@"fat" Timestamp:@"fatTimeStamp" PeriodIndex:index InthisWebview:_fatWebView];
            }
            break;
        default:
            break;
    }
}

-(void) scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    
//    NSLog(@"结束滚动后开始缓冲滚动时调用");
}

-(void)scrollViewDidScroll:(UIScrollView*)scrollView

{
    //页面滚动时调用，设置当前页面的ID
    [_reportPageControl setCurrentPage:fabs(scrollView.contentOffset.x/self.view.frame.size.width)];
//    NSLog(@"视图滚动中X轴坐标%f",scrollView.contentOffset.x);
//    NSLog(@"视图滚动中X轴坐标%f",scrollView.contentOffset.y);
}

-(void)scrollViewWillBeginDragging:(UIScrollView*)scrollView
{
//    NSLog(@"滚动视图开始滚动，它只调用一次");
}

-(void)scrollViewDidEndDragging:(UIScrollView*)scrollView willDecelerate:(BOOL)decelerate
{
//    NSLog(@"滚动视图结束滚动，它只调用一次");
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"封装后的方法");
    switch (webView.tag) {
        case 0:
            break;
        case 1:
                [self reloadWebViewWithDataTable:@"walkTable" Type:@"walk" Timestamp:@"walkTimeStamp" PeriodIndex:SEG_WEEK InthisWebview:_walkWebView];
            break;
        case 2:
//                [self reloadWebViewWithDataTable:@"weightTable" Type:@"weight" Timestamp:@"weightTimeStamp" PeriodIndex:SEG_WEEK InthisWebview:_weightWebView];
            break;
        case 3:
//                [self reloadWebViewWithDataTable:@"fatTable" Type:@"fat" Timestamp:@"fatTimeStamp" PeriodIndex:SEG_WEEK InthisWebview:_fatWebView];
            break;
        default:
            break;
    }
}

-(void)reloadWebViewWithDataTable:(NSString *)tableName Type:(NSString*)type Timestamp:(NSString*)timestamp PeriodIndex:(NSInteger)index InthisWebview:(UIWebView*) webView
{
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSTimeInterval a=[date timeIntervalSince1970];
    NSString *periodLimitTime;
    
    switch (index) {
        case 0:
            periodLimitTime = [NSString stringWithFormat:@"%.0f", (a + interval - 604800)];
            break;
        case 1:
            periodLimitTime = [NSString stringWithFormat:@"%.0f", (a + interval - 2592000)];
            break;
        case 2:
            periodLimitTime = [NSString stringWithFormat:@"%.0f", (a + interval - 7776000)];
            break;
        case 3:
            periodLimitTime = [NSString stringWithFormat:@"%.0f", (a + interval - 31104000)];
            break;
        default:
            break;
    }
    FMDatabase* database=[FMDatabase databaseWithPath:[self databasePath]];
    if (![database open]) {
        //add return value to solve problem
        NSLog(@"database open failed");
    }
    if ([database tableExists:tableName])
    {
        FMResultSet* resultSet=[database executeQuery:[NSString stringWithFormat:@"select * from (select * from %@ where %@ > %@ ) order by %@", tableName, timestamp, periodLimitTime, timestamp]];
        
        NSString *excuteJs;
        //用于计算平均值和增长率的变量
        unsigned int tmpSumValues = 0;
        unsigned int tmpSumDays = 0;
        float tmpFirstValue = 0.0;
        float tmpLastValue = 0.0;
        
        self.chartData = [[NSMutableString alloc]initWithUTF8String:"["];
        if ((SEG_WEEK == index) && ([type isEqualToString:@"walk"]))
        {
            while ([resultSet next]) {
                [self.chartData appendFormat:@"%@, ", [resultSet stringForColumn:type]];
                tmpSumValues = tmpSumValues + [[resultSet stringForColumn:type] integerValue];
                tmpSumDays++;
            }
            [self.chartData appendString:@"]"];
            self.averageSteps = [NSString stringWithFormat:@"%d", tmpSumValues / tmpSumDays];
            self.reportValueLabel1.text = self.averageSteps;
            self.sumSteps = [NSString stringWithFormat:@"%d", tmpSumValues];
            self.reportValueLabel2.text = self.sumSteps;
            
            NSDate *currentDate = [NSDate dateWithTimeIntervalSinceNow:0];
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *currentDateComponent = [calendar components:NSCalendarUnitWeekday fromDate:currentDate];
            NSInteger currentWeek = [currentDateComponent weekday];
            NSMutableString *walkChartXCategories = [[NSMutableString alloc]initWithUTF8String:"["];
            for (int i = 0; i<=6; i++) {
                currentWeek = currentWeek % 7;
                [walkChartXCategories appendFormat:@"'%@', ", self.weekArray[currentWeek]];
                currentWeek ++;
            }
            [walkChartXCategories appendString:@"]"];
            excuteJs = [[NSString alloc]initWithFormat:@"startDrawWeek(%@, %@)", walkChartXCategories, self.chartData];
        }else
        {
            while ([resultSet next]) {
                //延长时间戳到13位
                NSString *string = [[NSString alloc]initWithFormat:@"[%@000,%@]", [resultSet stringForColumn:timestamp], [resultSet stringForColumn:type]];
                NSLog(@"chartData is %@", string);
                [self.chartData appendFormat:@"%@,", string];
                tmpSumValues = tmpSumValues + [[resultSet stringForColumn:type] integerValue];
                tmpSumDays++;
                if (0 == tmpFirstValue) {
                    tmpFirstValue = [[resultSet stringForColumn:type] integerValue];
                }
                tmpLastValue = [[resultSet stringForColumn:type] integerValue];
            }
            [self.chartData appendString:@"]"];
            if ([type isEqualToString:@"walk"]) {
                self.averageSteps = [NSString stringWithFormat:@"%d", tmpSumValues / tmpSumDays];
                self.reportValueLabel1.text = self.averageSteps;
                self.sumSteps = [NSString stringWithFormat:@"%d", tmpSumValues];
                self.reportValueLabel2.text = self.sumSteps;
            }else if ([type isEqualToString:@"weight"])
            {
                self.averageWeight = [[NSString stringWithFormat:@"%.1f", (float)tmpSumValues / tmpSumDays] stringByAppendingString:@" kg"];
                self.reportValueLabel1.text = self.averageWeight;
                self.weightRate = [NSString stringWithFormat:@"%.2f", (tmpLastValue - tmpFirstValue) / tmpFirstValue * 100];
                [self rateLabelColorSetWithIncreaseRate:[self.weightRate floatValue]];
                self.reportValueLabel2.text = [self.weightRate stringByAppendingString:@" %"];
            }else if ([type isEqualToString:@"fat"])
            {
                self.averageFat = [[NSString stringWithFormat:@"%.1f", (float)tmpSumValues / tmpSumDays] stringByAppendingString:@" %"];
                self.reportValueLabel1.text = self.averageFat;
                self.fatRate = [NSString stringWithFormat:@"%.2f", (tmpLastValue - tmpFirstValue) / tmpFirstValue * 100];
                [self rateLabelColorSetWithIncreaseRate:[self.fatRate floatValue]];
                self.reportValueLabel2.text = [self.fatRate stringByAppendingString:@" %"];
            }
            excuteJs = [[NSString alloc]initWithFormat:@"startDraw(%@)", self.chartData];
        }
        NSLog(@"chartData is %@", self.chartData);
        [webView stringByEvaluatingJavaScriptFromString:excuteJs];
    }
    [database close];
}

-(void)rateLabelColorSetWithIncreaseRate:(float)rate
{
    if (rate > 0) {
        self.reportValueLabel2.textColor = [UIColor redColor];
    }else
    {
        self.reportValueLabel2.textColor = [UIColor colorWithRed:51.0/255 green:204.0/255 blue:204.0/255 alpha:1.0];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"简报"];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"简报"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated]; // don't forget to call super, this is important
    [self reloadChartDataAccordingToCurrentPageWithPeriodIndex:_periodSegmentedControl.selectedSegmentIndex];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString* )databasePath
{
    NSString* path=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* dbPath=[path stringByAppendingPathComponent:@"user.db"];
    return dbPath;
    
}

- (IBAction)periodSegmentedChange:(id)sender {
    switch (_reportPageControl.currentPage) {
        case 0:
        {
            [self reloadWebViewWithDataTable:@"walkTable" Type:@"walk" Timestamp:@"walkTimeStamp" PeriodIndex:_periodSegmentedControl.selectedSegmentIndex InthisWebview:_walkWebView];
        }
            break;
        case 1:
            [self reloadWebViewWithDataTable:@"weightTable" Type:@"weight" Timestamp:@"weightTimeStamp" PeriodIndex:_periodSegmentedControl.selectedSegmentIndex InthisWebview:_weightWebView];
            break;
        case 2:
            [self reloadWebViewWithDataTable:@"fatTable" Type:@"fat" Timestamp:@"fatTimeStamp" PeriodIndex:_periodSegmentedControl.selectedSegmentIndex InthisWebview:_fatWebView];
            break;
        default:
            break;
    }
    appDelegate.walkChartShouldRefresh = YES;
    appDelegate.weightChartShouldRefresh = YES;
    appDelegate.fatChartShouldRefresh = YES;
}

@end
