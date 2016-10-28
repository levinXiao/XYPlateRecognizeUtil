//
//  MVSPhotoPickerManager.m
//  MVS
//
//  Created by xiaoyu on 16/5/19.
//  Copyright © 2016年 litsoft. All rights reserved.
//

#import "UIViewController+MVSPhotoPickerManager.h"

//照片相关
#import <Photos/Photos.h>
#import "PHImageManager+CTAssetsPickerController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <objc/runtime.h>
#import "UIActionSheet+Blocks.h"

/**
 *  该类低于 8.0版本下不能运行 不兼容8.0下版本
 */
typedef void (^MVSPhotoPickerManagerCompleteBlock)(NSArray *imageArray);
MVSPhotoPickerManagerCompleteBlock completeBlock;

@implementation UIViewController (MVSPhotoPickerManager)

@dynamic maxSelectedPhotoAssets;
-(int)maxSelectedPhotoAssets{
    id i = objc_getAssociatedObject(self, @selector(maxSelectedPhotoAssets));
    if (i) {
        return [i intValue];
    }
    return 0;
}
-(void)setMaxSelectedPhotoAssets:(int)params{
    objc_setAssociatedObject(self, @selector(maxSelectedPhotoAssets),@(params), OBJC_ASSOCIATION_ASSIGN);
}

-(void)showPhotoPickerSheetTitle:(NSString *)title message:(NSString *)message needOpenFrontCamera:(BOOL)needOpen cameraActionTitle:(NSString *)cameraActionTitle photoLibraryActionTitle:(NSString *)photoActionTitle canOpenLibrary:(BOOL)canOpenLibrary complete:(void (^)(NSArray *assetsArray))complete{
    if (complete) {
        completeBlock = complete;
    }else{
        completeBlock = nil;
    }
    
    title = title ? title : @"选择来源";
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];
    alertController.popoverPresentationController.sourceView = self.view;
    alertController.popoverPresentationController.sourceRect = self.view.bounds;
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        if (completeBlock) {
            completeBlock(nil);
        }
    }];
    [alertController addAction:cancelAction];
    
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:cameraActionTitle ? cameraActionTitle : @"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self openCameraControllerNeedOpen:needOpen];
    }];
    [alertController addAction:cameraAction];
    
    if (canOpenLibrary) {
        UIAlertAction *phAction = [UIAlertAction actionWithTitle:photoActionTitle ? photoActionTitle : @"从相册中选取" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [self openPhotoPickController];
        }];
        [alertController addAction:phAction];
    }
    
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)openCameraControllerNeedOpen:(BOOL)needOpen{
#if TARGET_IPHONE_SIMULATOR//模拟器
    NSLog(@"模拟器不能调用相机");
#elif TARGET_OS_IPHONE//真机
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.mediaTypes = @[(NSString *)kUTTypeImage];
    picker.showsCameraControls  = YES;
    if (needOpen) {
        picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    }else{
        picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }
    [self presentViewController:picker animated:YES completion:nil];
#endif
}

-(void)openPhotoPickController{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
        dispatch_async(dispatch_get_main_queue(), ^{
            // init picker
            CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
            // set delegate
            picker.delegate = self;
            
            // create options for fetching photo only
            PHFetchOptions *fetchOptions = [PHFetchOptions new];
            fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeImage];
            // assign options
            picker.assetsFetchOptions = fetchOptions;
            
            // present picker
            [self presentViewController:picker animated:YES completion:nil];
        });
    }];
}

-(void)showPhotoPickerSheetCanOpenLibrary:(BOOL)canOpenLibrary complete:(void (^)(NSArray *assetsArray))complete{
    [self showPhotoPickerSheetTitle:nil message:nil needOpenFrontCamera:NO cameraActionTitle:nil photoLibraryActionTitle:nil canOpenLibrary:canOpenLibrary complete:complete];
}

#pragma mark - Assets Picker Delegate
- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldSelectAsset:(PHAsset *)asset {
    if (self.maxSelectedPhotoAssets == 0) {
        return YES;
    }
    NSInteger max = self.maxSelectedPhotoAssets;
    // show alert gracefully
    if (picker.selectedAssets.count >= max) {
        PHAsset *assFirst = picker.selectedAssets.firstObject;
        [picker deselectAsset:assFirst];
    }
    // limit selection to max
    return YES;
}

static PHImageRequestOptions *requestOptions;
- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets{
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (completeBlock) {
        NSMutableArray *resultImageArray = [NSMutableArray array];
        if (assets.count == 0) {
            completeBlock(resultImageArray);
            return;
        }
        [assets enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
            PHImageManager *manager = [PHImageManager defaultManager];
            CGFloat scale = UIScreen.mainScreen.scale;
            CGSize targetSize = CGSizeMake([UIScreen mainScreen].bounds.size.width * scale, [UIScreen mainScreen].bounds.size.height * scale);
            
            if (!requestOptions) {
                requestOptions = [[PHImageRequestOptions alloc] init];
                requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
                requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            }
            [manager ctassetsPickerRequestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:requestOptions resultHandler:^(UIImage *image, NSDictionary *info){
                if (image) {
                    [resultImageArray addObject:image];
                }
                if (resultImageArray.count == assets.count) {
                    completeBlock(resultImageArray);
                }
            }];
        }];
    }
}

- (void)assetsPickerControllerDidCancel:(CTAssetsPickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (completeBlock) {
        completeBlock(nil);
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    if (completeBlock && chosenImage) {
        completeBlock(@[chosenImage]);
    }
}



@end
