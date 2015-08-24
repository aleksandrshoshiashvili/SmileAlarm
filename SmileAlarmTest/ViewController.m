//
//  ViewController.m
//  SmileAlarmTest
//
//  Created by Александр on 24.08.15.
//  Copyright (c) 2015 Александр. All rights reserved.
//

#import "ViewController.h"
#import "PulsingHaloLayer.h"

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (assign, nonatomic) BOOL isLeftEyeOpen;
@property (assign, nonatomic) BOOL isRightEyeOpen;
@property (assign, nonatomic) BOOL isSmile;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)actionTakePhoto:(UIButton *)sender {
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        
    } else {
        
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
    }
    
}

- (IBAction)actionSendPhoto:(UIButton *)sender {
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        CIImage *image = [CIImage imageWithCGImage:self.imageView.image.CGImage];
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                                  context:nil
                                                  options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
        
        NSDictionary *options = @{
                                  CIDetectorSmile: @(YES),
                                  CIDetectorEyeBlink: @(YES),
                                  };
        
        NSArray *features = [detector featuresInImage:image options:options];
        
        NSMutableString *resultStr = @"DETECTED FACES:\n\n".mutableCopy;
        
        for(CIFaceFeature *feature in features)
        {
            [resultStr appendFormat:@"bounds:%@\n", NSStringFromCGRect(feature.bounds)];
            [resultStr appendFormat:@"hasSmile: %@\n\n", feature.hasSmile ? @"YES" : @"NO"];
            //        NSLog(@"faceAngle: %@", feature.hasFaceAngle ? @(feature.faceAngle) : @"NONE");
            NSLog(@"leftEyeClosed: %@", feature.leftEyeClosed ? @"YES" : @"NO");
            NSLog(@"rightEyeClosed: %@", feature.rightEyeClosed ? @"YES" : @"NO");
            
            self.isLeftEyeOpen = !feature.leftEyeClosed;
            self.isRightEyeOpen = !feature.rightEyeClosed;
            self.isSmile = feature.hasSmile;
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.textView.text = resultStr;
            [self handleResult];
        });
    });
    
}

- (void) handleResult {
    
    if (self.isSmile && self.isRightEyeOpen && self.isLeftEyeOpen) {
        [[[UIAlertView alloc] initWithTitle:@"Awesome" message:@"You woke up, congratulations" delegate:nil cancelButtonTitle:@"Yo!" otherButtonTitles:@"Share it", nil] show];
    } else if (self.isSmile && self.isRightEyeOpen) {
        [[[UIAlertView alloc] initWithTitle:@"So close" message:@"You smiled, but your left eye is closed. Fix it." delegate:nil cancelButtonTitle:@"Yo!" otherButtonTitles:nil, nil] show];
    } else if (self.isSmile && self.isLeftEyeOpen) {
        [[[UIAlertView alloc] initWithTitle:@"So close" message:@"You smiled, but your right eye is closed. Fix it." delegate:nil cancelButtonTitle:@"Yo!" otherButtonTitles:nil, nil] show];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Miss" message:@"Cheer up!" delegate:nil cancelButtonTitle:@"Yo!" otherButtonTitles:nil, nil] show];
    }
    
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

#pragma mark - Touches

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for (id obj in touches) {
        UITouch *touch = (UITouch *)obj;
        CGPoint location = [touch locationInView:self.view];
        CGFloat radius = touch.majorRadius;
        [self createHaloAtLocation:location withRadius:radius];
    }
    
}

- (void) createHaloAtLocation:(CGPoint) location withRadius:(CGFloat) radius {
    
    PulsingHaloLayer *halo = [[PulsingHaloLayer alloc] init];
    halo.repeatCount = 1;
    halo.position = location;
    halo.radius = radius * 2.0;
    halo.fromValueForRadius = 0.5;
    halo.keyTimeForHalfOpacity = 0.7;
    halo.animationDuration = 0.8;
    [self.view.layer addSublayer:halo];
    
}

@end
