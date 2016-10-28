# XYPlateRecognizeUtil
基于easyPR iOS版封装的工具库 使用block捕捉识别后的数据并传递,使用简单,高封装

# easyPR介绍
EasyPR是一个中文的开源车牌识别系统,其目标是成为一个简单、灵活、准确的车牌识别引擎。

相比于其他的车牌识别系统，EasyPR有如下特点：

* 它基于openCV这个开源库。这意味着你可以获取全部源代码，并且移植到opencv支持的所有平台。
* 它能够识别中文。例如车牌为苏EUK722的图片，它可以准确地输出std:string类型的"苏EUK722"的结果。
* 它的识别率较高。图片清晰情况下，车牌检测与字符识别可以达到80%以上的精度。

最重要的是 这个是由**国人**开源的

[easyPR github地址](https://github.com/liuruoze/EasyPR)

后来又有一个**国人** 基于easyPR开发出来基于iOS版本的EasyPR-iOS

[EasyPR-iOS github地址](https://github.com/zhoushiwei/EasyPR-iOS)

本文章也是在**EasyPR-iOS**基础上封装 使其易用性更高


# 用法

[XYPlateRecognizeUtil](https://github.com/levinXiao/XYPlateRecognizeUtil)

## 代码
**XYPlateRecognizeUtil.h**

```
@interface XYPlateRecognizeUtil : NSObject

- (void)recognizePateWithImage:(UIImage *)image complete:(void (^)(NSArray *plateStringArray,int code))complete;

@end

```

**XYPlateRecognizeUtil.m**

```
//返回值说明
// plateStringArray 识别数组返回
// code 识别结果错误码  -1 标识 参数错误  0 表示没有识别到车牌 1 表示识别成功

//return value explaintion
// plateStringArray   recognize array of NSString
// code  message code  -1 params error
//                     0  no plate to recognize
//                     1  recognize success

- (void)recognizePateWithImage:(UIImage *)image complete:(void (^)(NSArray *plateStringArray,int code))complete {
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

```

另外在本项目中 使用了两种方法识别 分别是 **拍照** 和 **选取图片**
在本质上,这两种方法的识别是一致,都是使用图片识别

推荐做法
```
//assetImage 需要被识别的图片
[[XYPlateRecognizeUtil new] recognizePateWithImage:assetImage complete:^(NSArray *plateStringArray,int code){
	dispatch_async(dispatch_get_main_queue(), ^{
	    NSString *plateRecognizeResult;
	    if (code != 1) {
	        [BYToastView showToastWithMessage:@"没有识别到车牌号码"];
	        return;
	    }else{
	        plateRecognizeResult = [plateStringArray componentsJoinedByString:@","];
	    }
	    if (!plateRecognizeResult) {
	        [BYToastView showToastWithMessage:@"没有识别到车牌号码"];
	        return;
	    }
	    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"车牌识别" message:plateRecognizeResult delegate:nil cancelButtonTitle:@"返回" otherButtonTitles:@"完成", nil];
	    [alertView show];
	});
}];
```

