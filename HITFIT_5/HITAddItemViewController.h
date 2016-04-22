//
//  HITAddItemViewController.h
//  HITBasic
//
//  Created by 蒋晟 on 14-9-26.
//  Copyright (c) 2014年 himyself. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HITAddItemViewController : UIViewController <UIPickerViewDelegate, UITextFieldDelegate,UIPickerViewDataSource>

@property (nonatomic) NSInteger  segmentedControllerIndex;
@property (nonatomic, strong)NSString *itemString;
@property (nonatomic, strong) NSString *lastValue;

@end
