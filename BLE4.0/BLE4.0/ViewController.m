//
//  ViewController.m
//  BLE4.0
//
//  Created by Longma on 17/8/25.
//  Copyright © 2017年 Bozonn. All rights reserved.
//

#import "ViewController.h"
#import "BLEModel.h"
#import "BLEIToll.h"
@interface ViewController ()
@property (nonatomic,strong) BLEModel *manager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initNavTitle];
    [self BluetoothConnection];
}

/**
 设计导航
 */
- (void)initNavTitle{
    self.navigationItem.title = @"空气质量";
    //蓝牙图标
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 50, 20)];
    titleLabel.textColor = [BLEIToll  colorWithHexString:@"#6ccc8f"];
    titleLabel.text = @"未连接";
    titleLabel.font = [UIFont systemFontOfSize:12];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:titleLabel];
}

/**
 蓝牙初始化
 */
- (void)BluetoothConnection{
    WeakSelf;
    _manager = [[BLEModel alloc]init];
    _manager.BLEName = @"Bozonn-Air01";
    _manager.BLEServiceID = @"FFE0";
    _manager.BLEServiceReadID = @"0000ffe1-0000-1000-8000-00805f9b34fb";
    _manager.BLEServiceWriteID = @"0000ffe1-0000-1000-8000-00805f9b34fb";
    _manager.linkBlcok = ^(NSString *state){
        
        NSLog(@"%@",state);
    };
    _manager.dataBlock = ^(NSMutableArray *array){
        //   NSLog(@"%@",array);
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
        NSLog(@"%d",number);
        [weakSelf BLEStateInt:number];
    };
    /*
     发送一个  0xFA 0xE4 Ox33 的命令
     
     */
    /*
     NSData *data = [[BLEIToll alloc] stringToByte:@"FAE433"];
     NSLog(@"写入数据%@",data);
     [_manager sendData:data];
     */
    
}


- (void)BLEStateInt:(int) state{
    switch (state) {
        case BLEState_Successful:
        {
            //连接成功
            UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 50, 20)];
            titleLabel.textColor = [BLEIToll  colorWithHexString:@"#6ccc8f"];
            titleLabel.text = @"已连接";
            titleLabel.font = [UIFont systemFontOfSize:12];
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:titleLabel];
        }
            break;
        case BLEState_Disconnect:
        {
            //外设断开连接
            UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 50, 20)];
            titleLabel.textColor = [BLEIToll  colorWithHexString:@"#6ccc8f"];
            titleLabel.text = @"未连接";
            titleLabel.font = [UIFont systemFontOfSize:12];
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:titleLabel];
        }
            break;
            
        default:
            break;
    }
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
