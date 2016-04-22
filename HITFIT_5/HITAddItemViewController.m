//
//  HITAddItemViewController.m
//  HITBasic
//
//  Created by 蒋晟 on 14-9-26.
//  Copyright (c) 2014年 himyself. All rights reserved.
//

#import "HITAddItemViewController.h"

@interface HITAddItemViewController ()
{
    NSArray *pickerArrayBai, *pickerArrayShi, *pickerArrayGe, *pickerArrayDian, *pickerArrayShiFen;
    NSInteger rowBai, rowShi, rowGe, rowShiFen;
    UIPickerView *weightPicker, *fatPicker;
}
@property (weak, nonatomic) IBOutlet UIToolbar *doneToolBar;
@property (weak, nonatomic) IBOutlet UILabel *itemLabel;
@property (weak, nonatomic) IBOutlet UITextField *itemTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

- (IBAction)selectButtonClick:(id)sender;

@end

@implementation HITAddItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    weightPicker = (UIPickerView *)[self.view viewWithTag:10];
    fatPicker = (UIPickerView *)[self.view viewWithTag:20];
    weightPicker.delegate = self;
    fatPicker.delegate = self;
    weightPicker.dataSource = self;
    fatPicker.dataSource = self;
    self.itemTextField.inputAccessoryView = self.doneToolBar;
    self.itemTextField.delegate = self;
    self.itemString = @"0";
    
    switch (self.segmentedControllerIndex) {
        case 0:
            self.itemLabel.text = @"步行";
            self.itemTextField.hidden = YES;
            break;
        case 1:
            self.itemLabel.text = @"体重";
            self.itemTextField.placeholder = @"0kg";
            self.itemTextField.hidden = NO;
            self.itemTextField.inputView = weightPicker;
            break;
        case 2:
            self.itemLabel.text = @"体脂率";
            self.itemTextField.placeholder = @"0%";
            self.itemTextField.hidden = NO;
            self.itemTextField.inputView = fatPicker;
            break;
        default:
            break;
    }
    
    pickerArrayBai = [NSArray arrayWithObjects:@"0",@"1",@"2",@"3", @"4", nil];
    pickerArrayShi = [NSArray arrayWithObjects:@"0",@"1",@"2",@"3", @"4", @"5",@"6",@"7",@"8", @"9", nil];
    pickerArrayGe = [NSArray arrayWithObjects:@"0",@"1",@"2",@"3", @"4", @"5",@"6",@"7",@"8", @"9", nil];
    pickerArrayDian = [NSArray arrayWithObjects:@".", nil];
    pickerArrayShiFen = [NSArray arrayWithObjects:@"0",@"1",@"2",@"3", @"4", @"5",@"6",@"7",@"8", @"9",nil];
    
    [self.doneToolBar removeFromSuperview];
    [weightPicker removeFromSuperview];
    [fatPicker removeFromSuperview];
    
    [self.itemTextField becomeFirstResponder];
    
    if (![_lastValue isEqualToString:@"0"])
    {
        _itemString = _lastValue;
        float lastValueFloat =  [_lastValue floatValue];
        NSLog(@"LASTVALUE IS %f", lastValueFloat);
        NSInteger lastBai = lastValueFloat / 100;
        NSInteger lastShi = lastValueFloat / 10 - lastBai * 10;
        NSInteger lastGe = lastValueFloat -lastBai * 100 - lastShi * 10;
        NSInteger lastShifen = lastValueFloat * 10 - lastGe * 10 - lastShi * 100 - lastBai * 1000;
        NSLog(@"seperate value is %d, %d, %d, %d", lastBai, lastShi, lastGe, lastShifen);
        if (_segmentedControllerIndex == 1) {
            [weightPicker selectRow:lastBai inComponent:0 animated:YES];
            [weightPicker selectRow:lastShi inComponent:1 animated:YES];
            [weightPicker selectRow:lastGe inComponent:2 animated:YES];
            [weightPicker selectRow:lastShifen inComponent:4 animated:YES];
            _itemTextField.text = [_lastValue stringByAppendingString:@"kg"];
        }else if(_segmentedControllerIndex == 2)
        {
            [fatPicker selectRow:lastShi inComponent:0 animated:YES];
            [fatPicker selectRow:lastGe inComponent:1 animated:YES];
            [fatPicker selectRow:lastShifen inComponent:3 animated:YES];
            _itemTextField.text = [_lastValue stringByAppendingString:@"%"];
        }
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"添加体重和体脂"];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"添加体重和体脂"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (pickerView.tag == 10) {
        return 5;
    }else {
        return 4;
    }
}
-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView.tag == 10) {
        switch (component) {
            case 0:
                return 5;//百
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
                return 10;//百
                break;
            case 1:
                return 10;//十
                break;
            case 2:
                return 1;//点
                break;
            case 3:
                return 10;//点后一位
                break;
            default:
                return 10;
                break;
        }
    }
}

-(NSString*) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView.tag == 10) {
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
        switch (component) {
            case 0:
                return [pickerArrayShi objectAtIndex:row];
                break;
            case 1:
                return [pickerArrayGe objectAtIndex:row];
                break;
            case 2:
                return [pickerArrayDian objectAtIndex:row];
                break;
            case 3:
                return [pickerArrayShiFen objectAtIndex:row];
                break;
            default:
                return @"error";
                break;
        }
    }
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    NSLog(@"Selected  %li. ",  (long)row);
    /// do it here your queries
    if (self.segmentedControllerIndex == 1)
    {
        rowBai = [weightPicker selectedRowInComponent:0];
        rowShi = [weightPicker selectedRowInComponent:1];
        rowGe = [weightPicker selectedRowInComponent:2];
        rowShiFen = [weightPicker selectedRowInComponent:4];
        NSNumber *weight = [[NSNumber alloc] initWithFloat:rowBai*100 + rowShi*10 + rowGe + rowShiFen*0.1];
        self.itemTextField.text = [[weight stringValue] stringByAppendingString:@"kg"];
        _itemString =[weight stringValue];
    } else if (self.segmentedControllerIndex == 2)
    {
        rowShi = [fatPicker selectedRowInComponent:0];
        rowGe = [fatPicker selectedRowInComponent:1];
        rowShiFen = [fatPicker selectedRowInComponent:3];
        NSNumber *fat = [[NSNumber alloc] initWithFloat:rowShi*10 + rowGe + rowShiFen*0.1];
        self.itemTextField.text = [[fat stringValue] stringByAppendingString:@"%"];
        _itemString =[fat stringValue];
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    //待定
}

- (IBAction)selectButtonClick:(id)sender
{
    [self.itemTextField endEditing:YES];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (sender != self.doneButton)
    {
        self.itemString = nil;
        return;
    }
}

@end
