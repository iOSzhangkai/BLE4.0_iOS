//
//  BLEIToll.h
//  BLEDemo
//
//  Created by Longma on 17/5/11.
//  Copyright © 2017年 ZhangK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


typedef void (^BLEProcessBLock)(NSMutableArray *dataArr);


@interface BLEIToll : NSObject

@property (nonatomic,copy) BLEProcessBLock processsBlock;

/**
 十六进制数据转化为数组
 @param data 十六进制数据
 @return 转化后的数组
 */
+ (NSMutableArray *)convertDataToHexStr:(NSData *)data;

/**
 *  设备给蓝牙传输数据 必须以十六进制数据传给蓝牙 蓝牙设备才会执行
 因为iOS 蓝牙库中方法 传输书记是以NSData形式 这个方法 字符串 ---> 十六进制数据 ---> NSData数据
 *
 *  @param string 传入字符串命令
 *
 *  @return 将字符串 ---> 十六进制数据 ---> NSData数据
 */

-(NSData*)stringToByte:(NSString*)string;

/**
 十六进制字符串 转化颜色
 
 @param hexString 十六进制字符串
 @return 换算的颜色
 */
+ (UIColor *) colorWithHexString: (NSString *) hexString;
/**
 将十六进制数 转化十进制数
 
 @param str 高位
 @param str2 低位
 @return 返回的数据
 */
+ (NSString *)handStrtoulStr1:(NSString *)str andStr2:(NSString *)str2;

/****************PM2.5 PM10 甲醛 计算方法 ********************/
/**
 通过输入的甲醛值 判断当前甲醛颜色等级
 
 @return 等级值
 
 */
- (UIColor *)colorFormaldehydeLevel:(float)valu;

/**
 根据PM2.5的数值 变化其所在表格的背景颜色
 */

- (UIColor *) colorWithStr:(NSUInteger ) value;
/**
 换国标AQI PM2.5
 
 @param value 输入污染物的值
 @return 返回国标数据
 */


- (NSUInteger)conversionPM2ChinaValue:(NSString *)value;
/**
 换国标AQI PM10
 
 @param value 输入污染物的值
 @return 返回国标数据
 */


- (NSUInteger)conversionPM10ChinaValue:(NSString *)value;


/**
 换美标标AQI PM2.5
 
 @param value 输入污染物的值
 @return 返回国标数据
 */


- (NSUInteger)conversionPM2USAValue:(NSString *)value;
/**
 换美标标AQI PM10
 
 @param value 输入污染物的值
 @return 返回国标数据
 */


- (NSUInteger)conversionPM10USAValue:(NSString *)value;



/**
 处理外设传来的数据以 424d 开头的书

 @param dataArr 数据源
 */
- (NSMutableArray *) handleTheBLEFirstData:(NSMutableArray *)dataArr;


/**
 处理外设传来的数据 蓝牙数据长度限制,蓝牙数据分两段传来

 @param dataArr 传进来的数据
 @return 处理好的数据
 */
- (NSMutableArray *) handleTheBLETWOData:(NSMutableArray *)dataArr;

@end
