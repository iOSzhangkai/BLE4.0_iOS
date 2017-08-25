# BLE4.0_iOS
iOS 引用蓝牙4.0的小demo
使用方法:

#import "BLEModel.h"
#import "BLEIToll.h"

_manager = [[BLEModel alloc]init];
_manager.BLEName = @"Bozonn-Air01";  //蓝牙硬设名称
_manager.BLEServiceID = @"FFE0";     //蓝牙硬设设备ID
_manager.BLEServiceReadID = @"0000ffe1-0000-1000-8000-00805f9b34fb";  //蓝牙硬设读取权限ID
_manager.BLEServiceWriteID = @"0000ffe1-0000-1000-8000-00805f9b34fb"; //蓝牙硬设写入信息ID
_manager.linkBlcok = ^(NSString *state){
    //蓝牙状态回调
    NSLog(@"%@",state);
};
_manager.dataBlock = ^(NSMutableArray *array){
     //蓝牙硬设返回数据
    if (array.count >= 20) {
           
        BLEIToll *itool = [[BLEIToll alloc]init];
         if ([array[0] isEqualToString:@"42"] && [array[1] isEqualToString:@"4d"]) {
           NSLog(@"%@",[itool handleTheBLEFirstData:array]);
         }else{
          NSLog(@"%@",[itool handleTheBLEFirstData:array]);
        }
       }
};
_manager.stateBlock = ^(int number){
       //蓝牙连接成功失败
       NSLog(@"%d",number);
       [weakSelf BLEStateInt:number];
};
