//
//  XYPlateRecognizeUtil.h
//  CarPR
//
//  Created by xiaoyu on 2016/10/27.
//  Copyright © 2016年 xiaoyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface XYPlateRecognizeUtil : NSObject

-(void)recognizePateWithImage:(UIImage *)image complete:(void (^)(NSArray *plateStringArray,int code))complete;

@end
