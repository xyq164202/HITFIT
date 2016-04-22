//
//  HITGuideViewController.m
//  HITFIT_5
//
//  Created by 蒋晟 on 14/10/31.
//  Copyright (c) 2014年 himyself. All rights reserved.
//

#import "HITGuideViewController.h"

#define HEIGHTSCROLL 1
#define BIRTHSCROLL 2

typedef enum : NSUInteger {
    SexSet,
    HeightSet,
    BirthSet,
}  PersonInfoState;

@interface HITGuideViewController ()

@property PersonInfoState currentState;

- (IBAction)backButtonClick:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
- (IBAction)nextButtonClick:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UILabel *personInfoTitle;


//性别选择相关控件
- (IBAction)sexClickMen:(id)sender;
- (IBAction)sexClickWomen:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *sexMenButton;
@property (weak, nonatomic) IBOutlet UIButton *sexWomenButton;
@property (weak, nonatomic) IBOutlet UILabel *MenLabel;
@property (weak, nonatomic) IBOutlet UILabel *WomenLabel;

//身高选择
@property (weak, nonatomic) IBOutlet UILabel *heightTitleLabel;
@property UIScrollView *heightScrollView;
@property (weak, nonatomic) IBOutlet UILabel *heightLabel;
@property (weak, nonatomic) IBOutlet UIImageView *horizonRedLine;

//出生年份选择
@property UIScrollView *birthScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *verticalRedLine;
@property (weak, nonatomic) IBOutlet UILabel *birthLabel;
@property (weak, nonatomic) IBOutlet UILabel *birthTitleLabel;

//完成最后处理并返回到User界面
@property (weak, nonatomic) IBOutlet UIButton *finishButton;
- (IBAction)finishButtonClick:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *backToUserButton;


@end

@implementation HITGuideViewController
@synthesize  heightScrollView, birthScrollView;
@synthesize heightLabel;

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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    if (self.allowBackToUser) {
        [self.backToUserButton setHidden:NO];
    }
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

-(void)scrollViewDidScroll:(UIScrollView*)scrollView
{
//    NSLog(@"视图滚动中X轴坐标%f",scrollView.contentOffset.x);
    NSLog(@"视图滚动中Y轴坐标%f",scrollView.contentOffset.x);
    switch (scrollView.tag) {
        case HEIGHTSCROLL:
        {
            int height;
            if ((scrollView.contentOffset.y >= 0) && (scrollView.contentOffset.y <= 1600)) {
                height = -0.125*scrollView.contentOffset.y + 300;
            }else if (scrollView.contentOffset.y < 0)
            {
                height = 300;
            }else
            {
                height = 100;
            }
            self.heightLabel.text = [NSString stringWithFormat:@"%.0f", round(height)];
        }
            break;
         case BIRTHSCROLL:
        {
            int birth;
            if ((scrollView.contentOffset.x >= 0) && (scrollView.contentOffset.x <= 700)) {
                birth = 9.0 / 70.0 *scrollView.contentOffset.x + 1930;
            }else if (scrollView.contentOffset.x < 0)
            {
                birth = 1930;
            }else
            {
                birth = 2020;
            }
            self.birthLabel.text = [NSString stringWithFormat:@"%.0f", round(birth)];
        }
            break;
        default:
            break;
    }
}
- (IBAction)sexClickMen:(id)sender {
    [self sexClearUI];
    [self heightSetUIConfig];
    self.currentState++;
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    [defaults setObject:@"男" forKey:@"userSex"];
    [defaults synchronize];
}

- (IBAction)sexClickWomen:(id)sender {
    [self sexClearUI];
    [self heightSetUIConfig];
    self.currentState++;
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    [defaults setObject:@"女" forKey:@"userSex"];
    [defaults synchronize];
}

-(void)sexSetUIConfig
{
    [self.sexMenButton setHidden:NO];
    [self.sexWomenButton setHidden:NO];
    [self.MenLabel setHidden:NO];
    [self.WomenLabel setHidden:NO];
    [self.personInfoTitle setHidden:NO];
    
    [self.backButton setHidden:YES];
    [self.nextButton setHidden:YES];
}

-(void)sexClearUI
{
    [self.sexMenButton setHidden:YES];
    [self.sexWomenButton setHidden:YES];
    [self.MenLabel setHidden:YES];
    [self.WomenLabel setHidden:YES];
    [self.personInfoTitle setHidden:YES];
    
    [self.backButton setHidden:NO];
    [self.nextButton setHidden:NO];
}

-(void)heightSetUIConfig
{
    [self.heightTitleLabel setHidden:NO];
    [heightLabel setHidden:NO];
    [self.horizonRedLine setHidden:NO];
    //绘制身高选择标尺
    heightScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(190, 40, 75, 400)];
    [heightScrollView setContentSize:CGSizeMake(0, 2000)];
    [heightScrollView setPagingEnabled:NO];
    [heightScrollView setShowsHorizontalScrollIndicator:NO];
    [heightScrollView setShowsVerticalScrollIndicator:NO];
    [heightScrollView.layer setBorderWidth:1];
    [heightScrollView.layer setBorderColor:[[UIColor colorWithRed:51.0/255 green:204.0/255 blue:204.0/255 alpha:1.0] CGColor]];
    [heightScrollView.layer setMasksToBounds:YES];
    [heightScrollView.layer setCornerRadius:5];
    [self.view addSubview:heightScrollView];
    heightScrollView.delegate = self;
    [heightScrollView setTag:HEIGHTSCROLL];
    UIImageView *heightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 191, 75, 1617)];
    heightImageView.image = [UIImage imageNamed:@"身高.png"];
    [heightScrollView addSubview:heightImageView];
    [heightScrollView setContentOffset:CGPointMake(0, 1200)];
}

-(void)heightClearUI
{
    [self.heightTitleLabel setHidden:YES];
    [heightLabel setHidden:YES];
    [self.horizonRedLine setHidden:YES];
    [heightScrollView setHidden:YES];
}

-(void)birthSetUIConfig
{
    [self.birthTitleLabel setHidden:NO];
    [self.birthLabel setHidden:NO];
    //绘制出生年份选择标尺
    birthScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 340, 300, 75)];
    [birthScrollView setContentSize:CGSizeMake(1000, 0)];
    [birthScrollView setPagingEnabled:NO];
    [birthScrollView setShowsHorizontalScrollIndicator:NO];
    [birthScrollView setShowsVerticalScrollIndicator:NO];
    [birthScrollView.layer setBorderWidth:1];
    [birthScrollView.layer setBorderColor:[[UIColor colorWithRed:51.0/255 green:204.0/255 blue:204.0/255 alpha:1.0] CGColor]];
    [birthScrollView.layer setMasksToBounds:YES];
    [birthScrollView.layer setCornerRadius:5];
    [self.view addSubview:birthScrollView];
    birthScrollView.delegate = self;
    [birthScrollView setTag:BIRTHSCROLL];
    UIImageView *birthImageView = [[UIImageView alloc] initWithFrame:CGRectMake(140, 0, 732, 75)];
    birthImageView.image = [UIImage imageNamed:@"年龄.png"];
    [birthScrollView addSubview:birthImageView];
    [birthScrollView setContentOffset:CGPointMake(400, 0)];
    [self.verticalRedLine setHidden:NO];
}

-(void)birthClearUI
{
    [self.birthTitleLabel setHidden:YES];
    [self.birthLabel setHidden:YES];
    [birthScrollView setHidden:YES];
    [self.verticalRedLine setHidden:YES];
}

- (IBAction)nextButtonClick:(id)sender {
    switch (self.currentState) {
        case SexSet:
            break;
        case HeightSet:
        {
            [self heightClearUI];
            [self birthSetUIConfig];
            self.currentState++;
            NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
            [defaults setObject:self.heightLabel.text forKey:@"userHeight"];
            [defaults synchronize];
            if (self.allowBackToUser) {
                [self.finishButton setHidden:NO];
                [self.nextButton setHidden:YES];
            }
        }
            break;
        case BirthSet:
        {
            UIStoryboard *mainStoryBoard  = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            HITTabBarController *initView = [mainStoryBoard instantiateViewControllerWithIdentifier:@"mainViewController"];
            [self presentViewController:initView animated:YES completion:nil];
            self.currentState++;
            NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
            [defaults setObject:self.birthLabel.text forKey:@"userAge"];
            [defaults synchronize];
        }
            break;
        default:
            break;
    }
}
- (IBAction)backButtonClick:(id)sender {
    switch (self.currentState) {
        case SexSet:
            break;
        case HeightSet:
        {
            [self heightClearUI];
            [self sexSetUIConfig];
            self.currentState--;
        }
            break;
        case BirthSet:
        {
            [self birthClearUI];
            [self heightSetUIConfig];
            self.currentState--;
            if (!self.finishButton.hidden) {
                [self.finishButton setHidden:YES];
                [self.nextButton setHidden:NO];
            }
        }
            break;
        default:
            break;
    }
}

- (IBAction)finishButtonClick:(id)sender {
//    NSLog(@"完成用户信息重置");
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    [defaults setObject:self.birthLabel.text forKey:@"userAge"];
    [defaults synchronize];
}
@end
