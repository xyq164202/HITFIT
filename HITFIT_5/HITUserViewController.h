//
//  HITUserViewController.h
//  HITFIT_5
//
//  Created by 蒋晟 on 14-10-14.
//  Copyright (c) 2014年 himyself. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HITUserViewController : UIViewController <UIPickerViewDelegate, UITextFieldDelegate,UIPickerViewDataSource, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

- (IBAction)unwindToUser:(UIStoryboardSegue *)segue;

@end
