//
//  BLEIToll.m
//  BLEDemo
//
//  Created by Longma on 17/5/11.
//  Copyright © 2017年 ZhangK. All rights reserved.
//

#import "BLEIToll.h"

@interface BLEIToll ()

@property (nonatomic,strong) NSMutableArray *BLEFistArr;
@property (nonatomic,strong) NSMutableArray *BLETwoArr;

@end


@implementation BLEIToll

-(NSMutableArray *)BLETwoArr{
    if (!_BLETwoArr) {
        _BLETwoArr = [NSMutableArray array];
    }
    return _BLETwoArr;
}


-(NSMutableArray *)BLEFistArr{
    if (!_BLEFistArr) {
        _BLEFistArr = [NSMutableArray array];
    }
    return _BLEFistArr;
}


/**
 十六进制数据转化为数组
 
 @param data 十六进制数据
 @return 转化后的数组
 */
+ (NSMutableArray *)convertDataToHexStr:(NSData *)data {
    if (!data || [data length] == 0) {
        return nil;
    }
    // NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    
    /**
     将切割好的十六进制数塞入一个可变数组
     */
    NSMutableArray *dataArr = [NSMutableArray new];
    
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        
        for (NSInteger i = 0; i < byteRange.length; i++) {
            
            /**
             将byte数组切割成一个个字符串
             */
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            // NSLog(@"%@",hexStr);
            /**
             因十六进制数据为 0X XXXX 以两字节为一位数,所以需要在切割出来的数据进行补零操作
             */
            
            if ([hexStr length] == 2) {
                // [string appendString:hexStr];
                [dataArr addObject:hexStr];
            } else {
                //[string appendFormat:@"0%@", hexStr];
                
                [dataArr addObject:[NSString stringWithFormat:@"0%@",hexStr]];
            }
        }
    }];
    // NSLog(@"-------->%@",dataArr);
    
    
    return dataArr;
}

/**
 *  设备给蓝牙传输数据 必须以十六进制数据传给蓝牙 蓝牙设备才会执行
 因为iOS 蓝牙库中方法 传输书记是以NSData形式 这个方法 字符串 ---> 十六进制数据 ---> NSData数据
 *
 *  @param string 传入字符串命令
 *
 *  @return 将字符串 ---> 十六进制数据 ---> NSData数据
 */

-(NSData*)stringToByte:(NSString*)string
{
    NSString *hexString=[[string uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([hexString length]%2!=0) {
        return nil;
    }
    Byte tempbyt[1]={0};
    NSMutableData* bytes=[NSMutableData data];
    for(int i=0;i<[hexString length];i++)
    {
        unichar hex_char1 = [hexString characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
        int int_ch1;
        if(hex_char1 >= '0' && hex_char1 <='9')
            int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
        else
            return nil;
        i++;
        
        unichar hex_char2 = [hexString characterAtIndex:i]; ///两位16进制数中的第二位(低位)
        int int_ch2;
        if(hex_char2 >= '0' && hex_char2 <='9')
            int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
        else if(hex_char2 >= 'A' && hex_char2 <='F')
            int_ch2 = hex_char2-55; //// A 的Ascll - 65
        else
            return nil;
        
        tempbyt[0] = int_ch1+int_ch2;  ///将转化后的数放入Byte数组里
        [bytes appendBytes:tempbyt length:1];
    }
    return bytes;
}

/**
 十六进制字符串 转化颜色
 
 @param hexString 十六进制字符串
 @return 换算的颜色
 */
+ (UIColor *) colorWithHexString: (NSString *) hexString {
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString: @"#" withString: @""] uppercaseString];
    CGFloat alpha, red, blue, green;
    switch ([colorString length]) {
        case 3: // #RGB
            alpha = 1.0f;
            
            red   = [self colorComponentFrom: colorString start: 0 length: 1];
            green = [self colorComponentFrom: colorString start: 1 length: 1];
            blue  = [self colorComponentFrom: colorString start: 2 length: 1];
            break;
        case 4: // #ARGB
            alpha = [self colorComponentFrom: colorString start: 0 length: 1];
            red   = [self colorComponentFrom: colorString start: 1 length: 1];
            green = [self colorComponentFrom: colorString start: 2 length: 1];
            blue  = [self colorComponentFrom: colorString start: 3 length: 1];
            break;
        case 6: // #RRGGBB
            alpha = 1.0f;
            red   = [self colorComponentFrom: colorString start: 0 length: 2];
            green = [self colorComponentFrom: colorString start: 2 length: 2];
            blue  = [self colorComponentFrom: colorString start: 4 length: 2];
            break;
        case 8: // #AARRGGBB
            alpha = [self colorComponentFrom: colorString start: 0 length: 2];
            red   = [self colorComponentFrom: colorString start: 2 length: 2];
            green = [self colorComponentFrom: colorString start: 4 length: 2];
            blue  = [self colorComponentFrom: colorString start: 6 length: 2];
            break;
        default:
            [NSException raise:@"Invalid color value" format: @"Color value %@ is invalid.  It should be a hex value of the form #RBG, #ARGB, #RRGGBB, or #AARRGGBB", hexString];
            break;
    }
    return [UIColor colorWithRed: red green: green blue: blue alpha: alpha];
}

+ (CGFloat) colorComponentFrom: (NSString *) string start: (NSUInteger) start length: (NSUInteger) length {
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}

/**
 将十六进制数 转化十进制数
 
 @param str 高八位
 @param str2 低八位
 @return 返回的数据
 */
+ (NSString *)handStrtoulStr1:(NSString *)str andStr2:(NSString *)str2{
    /*
     确保十六进制数每个数为两位
     */
    NSString *st1 = [self addZero:str withLength:2];
    NSString *st2 = [self addZero:str2 withLength:2];
    
    NSString *rechargeInfo =  [NSString stringWithFormat:@"%@%@",st1,st2];
    
    NSString *cardId2 = [rechargeInfo substringWithRange:NSMakeRange(0,4)];
    cardId2 = [NSString stringWithFormat:@"%ld",strtoul([cardId2 UTF8String],0,16)];
    
    return cardId2;
}


//字符串补零操作
+ (NSString *)addZero:(NSString *)str withLength:(int)length{
    NSString *string = nil;
    if (str.length==length) {
        return str;
    }
    if (str.length<length) {
        NSUInteger inter = length-str.length;
        for (int i=0;i< inter; i++) {
            string = [NSString stringWithFormat:@"0%@",str];
            str = string;
        }
    }
    return string;
}


/**
 换国标AQI PM2.5
 
 @param value 输入污染物的值
 @return 返回国标数据
 */


- (NSUInteger)conversionPM2ChinaValue:(NSString *)value{
    /*
     https://www.zhihu.com/question/22206538
     */
    NSUInteger switchValue = [self intervalValueCNPM2:value];
    
    static  NSUInteger valuePM;
    switch (switchValue) {
        case 10:
        {
            
            valuePM = ((50.0 - 0)/(35.0 - 0))*(value.integerValue - 0) + 0;
            
            
        }
            break;
        case 11:
        {
            valuePM = ((100.0 - 51.0)/(75 - 36))*(value.integerValue - 36) + 51;
            
        }
            break;
        case 12:
        {
            valuePM = ((150.0 - 101.0)/(115.0 - 76.0))*(value.integerValue - 75) + 101;
            
        }
            break;
        case 13:
        {
            valuePM = ((200.0 - 151.0)/(150.0 - 116.0))*(value.integerValue - 116) + 151;
            
        }
            break;
        case 14:
        {
            valuePM = ((300.0 - 201.0)/(250.0 - 151.0))*(value.integerValue - 151) + 201;
            
        }
            break;
        case 15:
        {
            valuePM = ((400.0 - 301.0)/(350.0 - 251.0))*(value.integerValue - 251) + 301;
            
        }
            break;
        case 16:{
            valuePM = ((500.0 - 401.0)/(500.0 - 351.0))*(value.integerValue - 351) + 401;
            
        }
            break;
        case 17:{
            valuePM = 600;
        }
            break;
        default:
            break;
    }
    return valuePM;
    
}


/**
 换国标AQI PM10
 
 @param value 输入污染物的值
 @return 返回国标数据
 */


- (NSUInteger)conversionPM10ChinaValue:(NSString *)value{
    /*
     https://www.zhihu.com/question/22206538
     */
    NSUInteger switchValue = [self intervalValueCNPM10:value];
    
    static  NSUInteger valuePM;
    switch (switchValue) {
        case 0:
        {
            
            valuePM = ((50.0 - 0)/(50.0 - 0))*(value.integerValue - 0) + 0;
            
        }
            break;
        case 1:
        {
            valuePM = ((100.0 - 51.0)/(150.0 - 51.0))*(value.integerValue - 51) + 51;
            
        }
            break;
        case 2:
        {
            valuePM = ((150.0 - 101.0)/(250.0 - 151.0))*(value.integerValue - 151) + 101;
            
        }
            break;
        case 3:
        {
            valuePM = ((200.0 - 151.0)/(350.0 - 251.0))*(value.integerValue - 251) + 151;
            
        }
            break;
        case 4:
        {
            valuePM = ((300.0 - 201.0)/(420.0 - 351.0))*(value.integerValue - 351) + 201;
            
        }
            break;
        case 5:
        {
            valuePM = ((400.0 - 301.0)/(500.0 - 421.0))*(value.integerValue - 421) + 301;
            
        }
            break;
        case 6:{
            valuePM = ((500.0 - 401.0)/(600.0 - 501.0))*(value.integerValue - 501) + 401;
            
        }
            break;
        case 7:{
            valuePM = 601;
        }
            break;
        default:
            break;
    }
    return valuePM;
    
}


/**
 换美标标AQI PM2.5
 
 @param value 输入污染物的值
 @return 返回国标数据
 */


- (NSUInteger)conversionPM2USAValue:(NSString *)value{
    /*
     https://www.zhihu.com/question/22206538
     */
    NSUInteger switchValue = [self intervalValueUsaPM2:value];
    
    static  NSUInteger valuePM;
    switch (switchValue) {
        case 0:
        {
            
            valuePM = ((50.0 - 0)/(12.0 - 0.0))*(value.integerValue - 0) + 0;
            
        }
            break;
        case 1:
        {
            valuePM = ((100.0 - 51.0)/(35.4 - 12.1))*(value.integerValue - 12.1) + 51;
            
        }
            break;
        case 2:
        {
            valuePM = ((150.0 - 101.0)/(55.4 - 35.5))*(value.integerValue - 35.5) + 101;
            
        }
            break;
        case 3:
        {
            valuePM = ((200.0 - 151.0)/(150.4 - 55.5))*(value.integerValue - 55.5) + 151;
            
        }
            break;
        case 4:
        {
            valuePM = ((300.0 - 201.0)/(250.4 - 150.5))*(value.integerValue - 150.5) + 201;
            
        }
            break;
        case 5:
        {
            valuePM = ((400.0 - 301.0)/(350.4 - 250.5))*(value.integerValue - 250.5) + 301;
            
        }
            break;
        case 6:{
            valuePM = ((500.0 - 401.0)/(500.4 - 350.4))*(value.integerValue - 350.4) + 401;
            
        }
            break;
        case 7:{
            valuePM = 601;
        }
            break;
        default:
            break;
    }
    return valuePM;
    
}


/**
 换美标标AQI PM10
 
 @param value 输入污染物的值
 @return 返回国标数据
 */


- (NSUInteger)conversionPM10USAValue:(NSString *)value{
    /*
     https://www.zhihu.com/question/22206538
     */
    NSUInteger switchValue = [self intervalValueUsaPM10:value];
    
    static  NSInteger valuePM;
    switch (switchValue) {
        case 0:
        {
            
            valuePM = ((50.0 - 0)/(54.0 - 0))*(value.integerValue - 0) + 0;
        }
            break;
        case 1:
        {
            valuePM = ((100.0 - 51.0)/(154.0 - 55.0))*(value.integerValue - 12.1) + 51;
            
        }
            break;
        case 2:
        {
            valuePM = ((150.0 - 101.0)/(254.0 - 155.0))*(value.integerValue - 151) + 101;
            
        }
            break;
        case 3:
        {
            valuePM = ((200.0 - 151.0)/(354.0 - 255.0))*(value.integerValue - 251) + 151;
            
        }
            break;
        case 4:
        {
            valuePM = ((300.0 - 201.0)/(424.0 - 355.0))*(value.integerValue - 351) + 201;
            
        }
            break;
        case 5:
        {
            valuePM = ((400.0 - 301.0)/(504.0 - 425.0))*(value.integerValue - 421) + 301;
            
        }
            break;
        case 6:{
            valuePM = ((500.0 - 401.0)/(604.0 - 505.0))*(value.integerValue - 501) + 401;
            
        }
            break;
        case 7:{
            valuePM = 601;
        }
            break;
        default:
            break;
    }
    return valuePM;
    
}







/**
 http://www.cnblogs.com/tiandi/p/6158576.html
 输入一个污染值 确定该值在那个单位 pm2.5[国标]
 
 @param value 输入污染值
 @return 返回档位
 */
- (NSInteger )intervalValueCNPM2:(NSString *)value{
    NSInteger valueInt = value.intValue;
    /**
     国标和美标具有一定的差别 主要是在多污染值确定的区间
     */
    
    if (valueInt >=  0 & valueInt <= 35) {
        
        return 10;
    }else if (valueInt >= 36 & valueInt <= 75){
        return 11;
    }else if (valueInt >= 76 & valueInt <= 115){
        return 12;
    }else if (valueInt >= 116 & valueInt <= 150){
        return 13;
    }else if (valueInt >= 151 & valueInt <= 250){
        return 14;
    }else if (valueInt >= 251 & valueInt <= 350){
        return 15;
    }else if (valueInt >= 351 & valueInt <= 500){
        return 16;
    }else {
        return 17;
    }
    
    
}

/**
 http://www.cnblogs.com/tiandi/p/6158576.html
 输入一个污染值 确定该值在那个单位 pm10[国标]
 
 @param value 输入污染值
 @return 返回档位
 */
- (NSInteger )intervalValueCNPM10:(NSString *)value{
    NSInteger valueInt = value.intValue;
    /**
     国标和美标具有一定的差别 主要是在多污染值确定的区间
     */
    
    if (valueInt >=  0 & valueInt <= 50) {
        return 0;
    }else if (valueInt >= 51 & valueInt <= 150){
        return 1;
    }else if (valueInt >= 151 & valueInt <= 250){
        return 2;
    }else if (valueInt >= 251 & valueInt <= 350){
        return 3;
    }else if (valueInt >= 351 & valueInt <= 420){
        return 4;
    }else if (valueInt >= 421 & valueInt <= 500){
        return 5;
    }else if (valueInt >= 501 & valueInt <= 600){
        return 6;
    }else {
        return 7;
    }
    
    
}





/**
 http://www.cnblogs.com/tiandi/p/6158576.html
 输入一个污染值 确定该值在那个单位  pm2.5 [美标]
 
 @param value 输入污染值
 @return 返回档位
 */
- (NSInteger )intervalValueUsaPM2:(NSString *)value{
    NSInteger valueInt = value.intValue;
    
    if (valueInt >=  0 & valueInt <= 12) {
        return 0;
    }else if (valueInt >= 12.1 & valueInt <= 35.4){
        return 1;
    }else if (valueInt >= 35.5 & valueInt <= 55.4){
        return 2;
    }else if (valueInt >= 55.5 & valueInt <= 150.4){
        return 3;
    }else if (valueInt >= 150.5 & valueInt <= 250.4){
        return 4;
    }else if (valueInt >= 250.5 & valueInt <= 350.4){
        return 5;
    }else if (valueInt >= 350.5 & valueInt <= 500.4){
        return 6;
    }else {
        return 7;
    }
    
    
}

/**
 http://www.cnblogs.com/tiandi/p/6158576.html
 输入一个污染值 确定该值在那个单位  pm10 [美标]
 
 @param value 输入污染值
 @return 返回档位
 */
- (NSInteger )intervalValueUsaPM10:(NSString *)value{
    NSInteger valueInt = value.intValue;
    if (valueInt >=  0 & valueInt <= 54) {
        return 0;
    }else if (valueInt >= 55 & valueInt <= 154){
        return 1;
    }else if (valueInt >= 155 & valueInt <= 254){
        return 2;
    }else if (valueInt >= 255 & valueInt <= 354){
        return 3;
    }else if (valueInt >= 355 & valueInt <= 424){
        return 4;
    }else if (valueInt >= 425 & valueInt <= 504){
        return 5;
    }else if (valueInt >= 505 & valueInt <= 604){
        return 6;
    }else {
        return 7;
    }
    
    
}
/**
 通过输入的甲醛值 判断当前甲醛颜色等级
 
 @param value 甲醛值
 @return 等级值
 
 */
- (UIColor *)colorFormaldehydeLevel:(float)value{
    
    if (value >=0.00 & value <=0.05) {
        return [BLEIToll colorWithHexString:@"#75c349"];
    }else if (value > 0.05 & value<= 0.1){
        return [BLEIToll colorWithHexString:@"#f1bb33"];
    }else if (value >0.1 & value <=0.3){
        return [BLEIToll colorWithHexString:@"#ff9c50"];
    }else if (value > 0.3 & value <= 0.8){
        return [BLEIToll colorWithHexString:@"#f27649"];
    }else if (value >0.8 & value <= 1.0){
        return [BLEIToll colorWithHexString:@"#4f0039"];
    }else{
        return [BLEIToll colorWithHexString:@"#ff1717"];
        
    }
}



/**
 根据PM2.5的数值 变化其所在表格的背景颜色
 */

- (UIColor *) colorWithStr:(NSUInteger ) value{
    
    if (value >= 0 & value<= 50) {
        return [BLEIToll colorWithHexString:@"#75c349"];
    }else if (value >= 51 & value <= 100){
        return [BLEIToll colorWithHexString:@"#f1bb33"];
        
    }else if (value >= 101 & value <= 150){
        return [BLEIToll colorWithHexString:@"#ff9c50"];
    }else if (value >= 151 & value <= 200){
        return [BLEIToll colorWithHexString:@"#f27649"];
        
    }else if (value >= 201 & value <= 300){
        return [BLEIToll colorWithHexString:@"#ab3f56"];
        
    }else if (value >= 301 & value <= 500){
        return [BLEIToll colorWithHexString:@"#7c1b39"];
        
    }else {
        return [BLEIToll colorWithHexString:@"#ff1717"];
    }
}


/**
 处理外设传来的数据以 424d 开头的书
 
 @param dataArr 数据源
 */

- (NSMutableArray *) handleTheBLEFirstData:(NSMutableArray *)dataArr{
    /**
     传入字符串为分割后十六进制数据
     42,  ---->固定
     4d,  ---->固定
     00,
     1c,  ---->长度
     00,
     2e,  ---->数据一 pm1.0
     00,
     4c,  ---->数据二 pm2.5
     00,
     55,  ---->数据三 pm10
     00,
     20,  ---->数据四 PM1.0 浓度(大气环境下)
     00,
     33,  ---->数据五 PM2.5 浓度(大气环境下)
     00,
     42,  ---->数据六 PM10 浓度 (大气环境下)
     31,
     38,  ---->数据七  0.1 升空气中直径在 0.3um 以上 颗粒物个数
     09,
     fc   ---->数据八   0.1 升空气中直径在 0.5um 以上 颗粒物个数
     */
    WeakSelf;
   [weakSelf.BLEFistArr removeAllObjects];
    
    NSString *str1 = [BLEIToll handStrtoulStr1:dataArr[4] andStr2:dataArr[5]];
    NSString *str2 = [BLEIToll handStrtoulStr1:dataArr[6] andStr2:dataArr[7]];
    NSString *str3 = [BLEIToll handStrtoulStr1:dataArr[8] andStr2:dataArr[9]];
    NSString *str4 = [BLEIToll handStrtoulStr1:dataArr[10] andStr2:dataArr[11]];
    NSString *str5 = [BLEIToll handStrtoulStr1:dataArr[12] andStr2:dataArr[13]];
    NSString *str6 = [BLEIToll handStrtoulStr1:dataArr[14] andStr2:dataArr[15]];
    
    NSUInteger pm2V = [[BLEIToll alloc] conversionPM2USAValue:str5];
    NSUInteger pm10V = [[BLEIToll alloc] conversionPM10USAValue:str6];
    NSUInteger pm2VC = [[BLEIToll alloc] conversionPM2ChinaValue:str5];
    NSUInteger pm10VC = [[BLEIToll alloc] conversionPM10ChinaValue:str6];
    
    
    [weakSelf.BLEFistArr addObject:str1];
    [weakSelf.BLEFistArr addObject:str2];
    [weakSelf.BLEFistArr addObject:str3];
    [weakSelf.BLEFistArr addObject:str4];
    [weakSelf.BLEFistArr addObject:str5];
    [weakSelf.BLEFistArr addObject:str6];
    [weakSelf.BLEFistArr addObject:[NSString stringWithFormat:@"%lu",(unsigned long)pm2VC]];
    [weakSelf.BLEFistArr addObject:[NSString stringWithFormat:@"%lu",(unsigned long)pm10VC]];
    [weakSelf.BLEFistArr addObject:[NSString stringWithFormat:@"%lu",(unsigned long)pm2V]];
    [weakSelf.BLEFistArr addObject:[NSString stringWithFormat:@"%lu",(unsigned long)pm10V]];
    return weakSelf.BLEFistArr;    
    
}

/**
 处理外设传来的数据 蓝牙数据长度限制,蓝牙数据分两段传来
 
 @param dataArr 传进来的数据
 @return 处理好的数据
 */
- (NSMutableArray *) handleTheBLETWOData:(NSMutableArray *)dataArr{
    /**
     传入字符串为分割后十六进制数据
     没有温度 湿度 版本数据长度为12
     
     01,
     d4,   --->数据九 0.1 升空气中直径在 1.0um 以上 颗粒物个数
     00,
     35,   ---> 数据十 0.1 升空气中直径在 2.5um 以上 颗粒物个数
     00,
     09,   --->数据十一  0.1 升空气中直径在 5.0um 以上 颗粒物个数
     00,
     06,   ---> 数据十二 0.1 升空气中直径在 10um 以上 颗粒物个数
     91,
     00,   ---> 数据十三  甲醛浓度数值  注:真实甲醛浓度值=本数值/1000
     05,
     27    ---->检验位
     
     有温度甲醛长度 为 20
     
     00,
     4f,  --->数据九 0.1 升空气中直径在 1.0um 以上 颗粒物个数
     
     00,
     03,  ---> 数据十 0.1 升空气中直径在 2.5um 以上 颗粒物个数
     
     00,
     01,  --->数据十一  0.1 升空气中直径在 5.0um 以上 颗粒物个数
     
     00,
     00,   ---> 数据十二 0.1 升空气中直径在 10um 以上 颗粒物个数
     00,
     1b,   ---> 数据十三  甲醛浓度数值  注:真实甲醛浓度值=本数值/1000
     
     00,
     f5,   ---->数据十四  温度 注:真实温度值=本数值/10 单位:°C
     01,
     5f,   ---->数据十五  湿度 注:真实湿度值=本数值/10 单位:%
     00,
     00,   ----> 保留
     91,   ----> 版本号
     00,   ----> 错误码
     04,
     72    ----> 校验码
     */
    
    //  NSLog(@"%@",dataArr);
    [self.BLETwoArr removeAllObjects];
    NSString *jia = [BLEIToll handStrtoulStr1:dataArr[8] andStr2:dataArr[9]];
 
    NSString * humidity = [BLEIToll handStrtoulStr1:dataArr[10] andStr2:dataArr[11]];
    NSString * tempdity = [BLEIToll handStrtoulStr1:dataArr[12] andStr2:dataArr[13]];
    
    [self.BLETwoArr addObject:jia];
    [self.BLETwoArr addObject:humidity];
    [self.BLETwoArr addObject:tempdity];
    return self.BLETwoArr;
}

@end
