//
//  MVSPhotoPickerManager.h
//  MVS
//
//  Created by xiaoyu on 16/5/19.
//  Copyright © 2016年 litsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CTAssetsPickerController.h"

@interface UIViewController (MVSPhotoPickerManager) <UINavigationControllerDelegate,CTAssetsPickerControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic,assign) int maxSelectedPhotoAssets;

-(void)showPhotoPickerSheetTitle:(NSString *)title message:(NSString *)message needOpenFrontCamera:(BOOL)needOpen cameraActionTitle:(NSString *)cameraActionTitle photoLibraryActionTitle:(NSString *)photoActionTitle canOpenLibrary:(BOOL)canOpenLibrary complete:(void (^)(NSArray *assetsArray))complete;

-(void)showPhotoPickerSheetCanOpenLibrary:(BOOL)canOpenLibrary complete:(void (^)(NSArray *assetsArray))complete;

@end
