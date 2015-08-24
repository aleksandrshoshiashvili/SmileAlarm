//
//  ViewController.h
//  SmileAlarmTest
//
//  Created by Александр on 24.08.15.
//  Copyright (c) 2015 Александр. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *textView;

- (IBAction)actionTakePhoto:(UIButton *)sender;
- (IBAction)actionSendPhoto:(UIButton *)sender;


@end

