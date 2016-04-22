//
//  HITUserViewController.m
//  HITFIT_5
//
//  Created by 蒋晟 on 14-10-14.
//  Copyright (c) 2014年 himyself. All rights reserved.
//

#import "HITUserViewController.h"
#import "HITGuideViewController.h"

#define SEXTAG 1
#define AGETAG 2
#define HEIGHTTAG 3
#define AGEPICKERTAG 4
#define HEIGHTPICKERTAG 5
#define NAMETAG 6

@interface HITUserViewController ()
@property (weak, nonatomic) IBOutlet UIButton *userImageButton;
- (IBAction)userImageButtonClick:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;

@property UIPickerView *agePicker, *heightPicker;
@property NSArray *pickerArrayBai, *pickerArrayShi, *pickerArrayGe, *pickerArrayDian, *pickerArrayShiFen, *pickerArray0To99;
//@property NSMutableArray *pickerArray0To99;
@property (weak, nonatomic) IBOutlet UILabel *sexLabel;
@property (weak, nonatomic) IBOutlet UILabel *heightLabel;
@property (weak, nonatomic) IBOutlet UILabel *birthLabel;

@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneBarButton;
- (IBAction)doneBarButtonClick:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *infoBarButton;
@property UIImagePickerController *imagePickerController;
@end

@implementation HITUserViewController

@synthesize userNameTextField;
@synthesize heightLabel, birthLabel;
@synthesize agePicker, heightPicker;
@synthesize userImageButton, userImageView;
@synthesize pickerArrayBai, pickerArrayShi, pickerArrayGe, pickerArrayDian, pickerArrayShiFen;
@synthesize pickerArray0To99;
@synthesize imagePickerController;

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
    userImageButton.layer.masksToBounds = YES;
    userImageButton.layer.cornerRadius = 80;
    userImageView.layer.masksToBounds =YES;
    userImageView.layer.cornerRadius = 60;
    userImageView.layer.borderWidth = 3.0f;
    userImageView.layer.borderColor = [[UIColor whiteColor]CGColor];
    
    userNameTextField.delegate =self;
    
//    heightPicker = (UIPickerView *)[self.view viewWithTag:HEIGHTPICKERTAG];
//    agePicker = (UIPickerView *)[self.view viewWithTag:AGEPICKERTAG];
//    heightPicker.delegate = self;
//    agePicker.delegate = self;
//    heightPicker.dataSource = self;
//    agePicker.dataSource = self;

    
    pickerArrayBai = [NSArray arrayWithObjects:@"0",@"1",@"2", nil];
    pickerArrayShi = [NSArray arrayWithObjects:@"0",@"1",@"2",@"3", @"4", @"5",@"6",@"7",@"8", @"9", nil];
    pickerArrayGe = [NSArray arrayWithObjects:@"0",@"1",@"2",@"3", @"4", @"5",@"6",@"7",@"8", @"9", nil];
    pickerArrayDian = [NSArray arrayWithObjects:@".", nil];
    pickerArrayShiFen = [NSArray arrayWithObjects:@"0",@"1",@"2",@"3", @"4", @"5",@"6",@"7",@"8", @"9",nil];
//    for (int i = 0; i < 100; i++) {
//        [pickerArray0To99 arrayByAddingObject:[NSString stringWithFormat:@"%d", i]];
//    }
////        [pickerArray0To99 arrayByAddingObject:nil];
    pickerArray0To99 = [NSArray arrayWithObjects:@"0",@"1",@"2",@"3", @"4", @"5",@"6",@"7",@"8", @"9",@"10",@"11",@"12",@"13", @"14", @"15",@"16",@"17",@"18", @"19",@"20",@"21",@"22",@"23", @"24", @"25",@"26",@"27",@"28", @"29",@"30",@"31",@"32",@"33", @"34", @"35",@"36",@"37",@"38", @"39",@"40",@"41",@"42",@"43", @"44", @"45",@"46",@"47",@"48", @"49",@"50",@"51",@"52",@"53", @"54", @"55",@"56",@"57",@"58", @"59",@"60",@"61",@"62",@"63", @"64", @"65",@"66",@"67",@"68", @"69",@"70",@"71",@"72",@"73", @"74", @"75",@"76",@"77",@"78", @"79",@"80",@"81",@"82",@"83", @"84", @"85",@"86",@"87",@"88", @"89",@"90",@"91",@"92",@"93", @"94", @"95",@"96",@"97",@"98", @"99",nil];
    
    [self.toolBar removeFromSuperview];
    [heightPicker removeFromSuperview];
    [agePicker removeFromSuperview];
    
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    NSString *sexString = [defaults stringForKey:@"userSex"];
    if (sexString) {
        self.sexLabel.text = sexString;
    }
    NSData *imageData = [defaults dataForKey:@"userImage"];
    if (imageData) {
        UIImage *image = [UIImage imageWithData:imageData];//NSData转换为UIImage
        userImageView.image = image;
    }
    NSString *name = [defaults stringForKey:@"userName"];
    if (name) {
        userNameTextField.text = name;
    }
    NSString *height = [defaults stringForKey:@"userHeight"];
    if (height) {
        heightLabel.text = height;
    }
    NSString *birth = [defaults stringForKey:@"userAge"];
    if (birth) {
        birthLabel.text = birth;
    }
    
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGr.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGr];
}

-(void)viewTapped:(UITapGestureRecognizer*)tapGr
{
    [userNameTextField resignFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated]; // don't forget to call super, this is important
    [MobClick beginLogPageView:@"用户"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"用户"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (pickerView.tag == HEIGHTPICKERTAG) {
        return 5;
    }else {
        return 1;
    }
}
-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView.tag == HEIGHTPICKERTAG) {
        switch (component) {
            case 0:
                return 3;//百
                break;
            case 1:
                return 10;//十
                break;
            case 2:
                return 10;//个
                break;
            case 3:
                return 1;//点
                break;
            case 4:
                return 10;//点后一位
                break;
            default:
                return 10;
                break;
        }
    }else {
        switch (component) {
            case 0:
                return 100;
                break;
                
            default:
                return 100;
                break;
        }
    }
}

-(NSString*) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView.tag == HEIGHTPICKERTAG) {
        NSLog(@"this is height picker.");
        switch (component) {
            case 0:
                return [pickerArrayBai objectAtIndex:row];
                break;
            case 1:
                return [pickerArrayShi objectAtIndex:row];
                break;
            case 2:
                return [pickerArrayGe objectAtIndex:row];
                break;
            case 3:
                return [pickerArrayDian objectAtIndex:row];
                break;
            case 4:
                return [pickerArrayShiFen objectAtIndex:row];
                break;
            default:
                return @"error";
                break;
        }
    }else {
        return [pickerArray0To99 objectAtIndex:row];
    }
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    NSLog(@"Selected  %li. ",  (long)row);
    /// do it here your queries
    if (thePickerView.tag == HEIGHTPICKERTAG)
    {
        NSInteger rowBai = [heightPicker selectedRowInComponent:0];
        NSInteger rowShi = [heightPicker selectedRowInComponent:1];
        NSInteger rowGe = [heightPicker selectedRowInComponent:2];
        NSInteger rowShiFen = [heightPicker selectedRowInComponent:4];
        NSNumber *height = [[NSNumber alloc] initWithFloat:rowBai*100 + rowShi*10 + rowGe + rowShiFen*0.1];
    } else
    {
        NSNumber *age = [[NSNumber alloc] initWithLong:[agePicker selectedRowInComponent:0]];
        self.infoBarButton.title = [@"年龄: "stringByAppendingString:[age stringValue]];
    }
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    HITGuideViewController *destationController  = [segue destinationViewController];
    //此时的用户信息设置页面不是第一次打开app时的，需要返回到tabview.
    destationController.allowBackToUser = YES;
}


- (IBAction)doneBarButtonClick:(id)sender {

}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField.tag == HEIGHTTAG) {
        self.infoBarButton.title = @"身高";
    }else if(textField.tag == AGETAG)
    {
        self.infoBarButton.title = @"年龄";
    }else if(textField.tag == NAMETAG)
    {
        textField.returnKeyType = UIReturnKeyDone;
    }
}

//当用户按下return键或者按回车键，keyboard消失
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == NAMETAG) {
        [textField resignFirstResponder];
        NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
        [defaults setObject:textField.text forKey:@"userName"];
    }
    return YES;
}

- (IBAction)userImageButtonClick:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从手机相册选择",nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.delegate =self;
    if (buttonIndex == 0) {
        NSLog(@"拍照");
        //判断设备是否能调用摄像头,UIImagePickerControllerCameraDeviceFront前置摄像头
        BOOL isFront = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
        if (!isFront) {
            NSLog(@"没有摄像头");//在真机上不会崩溃
        }
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerController.allowsEditing = YES;//允许对调用摄像头拍摄的照片进行编辑，则选中后调用的方法中objectForKey为UIImagePickerControllerEditedImage
        [self presentViewController:imagePickerController animated:YES completion:NULL];//弹出模态视图
    }else if (buttonIndex == 1) {
        NSLog(@"从手机相册选择");
        imagePickerController.delegate =self;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;//可以访问用户所以相册资源
        imagePickerController.allowsEditing = YES;
        [self presentViewController:imagePickerController animated:YES completion:NULL];//弹出模态视图
    }else if(buttonIndex == 2) {
        NSLog(@"取消");
    }
}

#pragma mark  UIImagePickerController  delegate
//选中后调用
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image   =  [info objectForKey:UIImagePickerControllerEditedImage];//获取到经过编辑后的图片
    
    userImageView.image = image;//将获取到的图片加载到_imageV上
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);//UIImage对象转换成NSData
    [defaults setObject:imageData forKey:@"userImage"];
    [defaults synchronize];//用synchronize方法把数据持久化到standardUserDefaults数据库
    
    [picker dismissViewControllerAnimated:YES completion:NULL];//将模态视图弹回去
}
//取消从相册获取图片时调用
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (IBAction)unwindToUser:(UIStoryboardSegue *)segue
{
//    NSLog(@"已经返回");
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    NSString *sexString = [defaults stringForKey:@"userSex"];
    if (sexString) {
        self.sexLabel.text = sexString;
    }
//    NSData *imageData = [defaults dataForKey:@"userImage"];
//    if (imageData) {
//        UIImage *image = [UIImage imageWithData:imageData];//NSData转换为UIImage
//        userImageView.image = image;
//    }
//    NSString *name = [defaults stringForKey:@"userName"];
//    if (name) {
//        userNameTextField.text = name;
//    }
    NSString *height = [defaults stringForKey:@"userHeight"];
    if (height) {
        heightLabel.text = height;
    }
    NSString *birth = [defaults stringForKey:@"userAge"];
    if (birth) {
        birthLabel.text = birth;
    }

}

@end
