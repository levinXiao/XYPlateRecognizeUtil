//
//  ViewController.m
//  CarPR
//
//  Created by xiaoyu on 2016/10/27.
//  Copyright © 2016年 xiaoyu. All rights reserved.
//

#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#endif

#import "ViewController.h"

#import "UIViewController+MVSPhotoPickerManager.h"
#import "XYPlateRecognizeUtil.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *button = [[UIButton alloc] init];
    button.frame = (CGRect){100,300,100,100};
    button.backgroundColor = [UIColor blueColor];
    [button setTitle:@"click" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

-(void)buttonClick{
    [self showPhotoPickerSheetTitle:@"go" message:nil needOpenFrontCamera:NO cameraActionTitle:@"拍照" photoLibraryActionTitle:@"从相册中选取" canOpenLibrary:YES complete:^(NSArray *assetsImageArray) {
        
        if (!assetsImageArray || assetsImageArray.count == 0) {
            return;
        }
        UIImage *assetImage = assetsImageArray.firstObject;
        
        [[XYPlateRecognizeUtil new] recognizePateWithImage:assetImage complete:^(NSArray *plateStringArray,int code){
            NSLog(@"%@",plateStringArray);
        }];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
