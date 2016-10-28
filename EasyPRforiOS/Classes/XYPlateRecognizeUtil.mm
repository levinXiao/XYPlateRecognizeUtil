//
//  XYPlateRecognizeUtil.m
//  CarPR
//
//  Created by xiaoyu on 2016/10/27.
//  Copyright © 2016年 xiaoyu. All rights reserved.
//

#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#endif

#import "XYPlateRecognizeUtil.h"

#import "UIImageCVMatConverter.h"
#include "easypr.h"
#include "switch.hpp"
#include "GlobalData.hpp"
#include "plate.hpp"

using namespace easypr;

@interface XYPlateRecognizeUtil ()

@end

@implementation XYPlateRecognizeUtil {
    cv::Mat source_image;
    CPlateRecognize pr;
}

//返回值说明
// plateStringArray 识别数组返回
// code 识别结果错误码  -1 标识 参数错误  0 表示没有识别到车牌 1 表示识别成功

//return value explaintion
// plateStringArray   recognize array of NSString
// code  message code  -1 params error
//                     0  no plate to recognize
//                     1  recognize success

-(void)recognizePateWithImage:(UIImage *)image complete:(void (^)(NSArray *plateStringArray,int code))complete {
    if (!image){
        if (complete) complete(nil,-1);
        return;
    }
    NSString* bundlePath=[[NSBundle mainBundle] bundlePath];
    std::string mainPath=[bundlePath UTF8String];
    GlobalData::mainBundle() = mainPath;
    pr.setLifemode(true);
    pr.setDebug(false);
    pr.setMaxPlates(4);
    pr.setDetectType(easypr::PR_DETECT_CMSER);
    
    //conver image to source_image
    //转换图片
    UIImage *temp_image=[UIImageCVMatConverter scaleAndRotateImageBackCamera:image];
    source_image =[UIImageCVMatConverter cvMatFromUIImage:temp_image];
    
    //start recognize
    //开始识别
    vector<CPlate> plateVec;
    pr.plateRecognize(source_image, plateVec);
    if(plateVec.size() == 0){
        if (complete) complete(nil,0);
        return;
    }
    NSMutableArray *rsArratTmp = [NSMutableArray array];
    size_t vecNum = plateVec.size();
    for (size_t i = 0; i < vecNum; i++) {
        string name=plateVec[i].getPlateStr();
        NSString *resultMessage = [NSString stringWithCString:plateVec[i].getPlateStr().c_str()
                                                     encoding:NSUTF8StringEncoding];
        [rsArratTmp addObject:resultMessage];
    }
    if (complete) complete([NSArray arrayWithArray:rsArratTmp],1);
}

@end
