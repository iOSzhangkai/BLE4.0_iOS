//
//  BLEModel.m
//  BLEDemo
//
//  Created by Longma on 17/5/11.
//  Copyright © 2017年 ZhangK. All rights reserved.
//

#import "BLEModel.h"
#import "BLEIToll.h"

@interface BLEModel ()<CBCentralManagerDelegate,CBPeripheralDelegate>
/**
 *  蓝牙连接必要对象
 */
@property (nonatomic, strong) CBCentralManager *centralMgr;
@property (nonatomic, strong) CBPeripheral *discoveredPeripheral;
@property (strong, nonatomic) CBCharacteristic* writeCharacteristic;

@property (nonatomic,assign) BOOL isInitiativeDisconnect;//主动断开连接



@end


@implementation BLEModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _centralMgr = [[CBCentralManager alloc]initWithDelegate:self queue:nil];

    }
    return self;
}

/**
 *  开始扫描
 */

- (void)startScan{
    _centralMgr = [[CBCentralManager alloc]initWithDelegate:self queue:nil];

}

/**
 *  停止扫描
 */
-(void)stopScan
{
    [_centralMgr stopScan];
    
  
}


#pragma mark -- CBCentralManagerDelegate
#pragma mark- 扫描设备，连接

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"name:%@",peripheral);
    /**
     当扫描到蓝牙数据为空时,停止扫描
     */
    if (!peripheral || !peripheral.name || ([peripheral.name isEqualToString:@""])) {
        return;
    }
    
    
    /**
     当扫描到服务UUID与设备UUID相等时,进行蓝牙与设备链接
     */
    
    if ((!self.discoveredPeripheral || (self.discoveredPeripheral.state == CBPeripheralStateDisconnected))&&([peripheral.name isEqualToString:_BLEName])) {
        self.discoveredPeripheral = [peripheral copy];
        //self.peripheral.delegate = self;
        NSLog(@"connect peripheral:  %@",peripheral);
        [self.centralMgr connectPeripheral:peripheral options:nil];
    }

}


#pragma mark - 蓝牙的状态
-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    switch (central.state) {
        case CBManagerStateUnknown:
        {
            //NSLog(@"无法获取设备的蓝牙状态");
            self.connectState = kCONNECTED_UNKNOWN_STATE;
        }
            break;
        case CBManagerStateResetting:
        {
            //NSLog(@"蓝牙重置");
            self.connectState = kCONNECTED_RESET;
        }
            break;
        case CBManagerStateUnsupported:
        {
            //NSLog(@"该设备不支持蓝牙");
            self.connectState = kCONNECTED_UNSUPPORTED;
        }
            break;
        case CBManagerStateUnauthorized:
        {
            //NSLog(@"未授权蓝牙权限");
            self.connectState = kCONNECTED_UNAUTHORIZED;
        }
            break;
        case CBManagerStatePoweredOff:
        {
            //NSLog(@"蓝牙已关闭");
            self.connectState = kCONNECTED_POWERED_OFF;
        }
            break;
        case CBManagerStatePoweredOn:
        {
            //NSLog(@"蓝牙已打开");
            self.connectState = kCONNECTED_POWERD_ON;
            [_centralMgr scanForPeripheralsWithServices:nil options:nil];
        }
            break;
            
        default:
        {
            //NSLog(@"未知的蓝牙错误");
            self.connectState = kCONNECTED_ERROR;
        }
            break;
    }
    self.linkBlcok(self.connectState);
    //[self getConnectState];
    
}
#pragma park- 连接成功,扫描services
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    if (!peripheral) {
        return;
    }
    [self.centralMgr stopScan];
    
    self.stateBlock(BLEState_Successful);
    
    NSLog(@"peripheral did connect:  %@",peripheral);
    [self.discoveredPeripheral setDelegate:self];
    [self.discoveredPeripheral discoverServices:nil];
     
}




#pragma mark - 扫描service
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSArray *services = nil;
    
    if (peripheral != self.discoveredPeripheral) {
        NSLog(@"Wrong Peripheral.\n");
        return ;
    }
    
    if (error != nil) {
        NSLog(@"Error %@\n", error);
        return ;
    }
    
    services = [peripheral services];
    NSLog(@"%@",services);
    if (!services || ![services count]) {
        NSLog(@"No Services");
        return ;
    }
    
    for (CBService *service in services) {
        NSLog(@"该设备的service:%@",service);
        /*
         >
         
         */
        if ([[service.UUID UUIDString] isEqualToString:_BLEServiceID]) {
            [peripheral discoverCharacteristics:nil forService:service];
            return ;
        }
    }
    
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error)
    {
        NSLog(@"didDiscoverCharacteristicsForService error : %@", [error localizedDescription]);
        return;
    }
    
    for (CBCharacteristic *c in service.characteristics)
    {
        NSLog(@"\n>>>\t特征UUID FOUND(in 服务UUID:%@): %@ (data:%@)",service.UUID.description,c.UUID,c.UUID.data);
        /**
         >>>	特征UUID FOUND(in 服务UUID:FFE0): FFE1 (data:<ffe1>)
         
         >>>	特征UUID FOUND(in 服务UUID:FFE0): FFE2 (data:<ffe2>)
         
         */
        /*
         根据特征不同属性去读取或者写
         if (c.properties==CBCharacteristicPropertyRead) {
         }
         if (c.properties==CBCharacteristicPropertyWrite) {
         }
         if (c.properties==CBCharacteristicPropertyNotify) {
         }
         */
        
        /*
         设备读取UUID
        */
        if ([c.UUID isEqual:[CBUUID UUIDWithString:_BLEServiceReadID]]) {
            self.writeCharacteristic = c;
            [_discoveredPeripheral setNotifyValue:YES forCharacteristic:self.writeCharacteristic];
        }
        
        /**
         设备写入UUID
         */
        if ([c.UUID isEqual:[CBUUID UUIDWithString:_BLEServiceWriteID]]) {
            self.writeCharacteristic = c;
            [_discoveredPeripheral setNotifyValue:YES forCharacteristic:self.writeCharacteristic];
        }
        
        
    }
}

#pragma mark - 读取数据
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
    if (error)
    {
        NSLog(@"didUpdateValueForCharacteristic error : %@", error.localizedDescription);
        return;
    }
    NSData *data = characteristic.value;
    NSMutableArray *dataArr = [BLEIToll convertDataToHexStr:data];
    self.dataBlock(dataArr);
    
}


#pragma mark- 外设断开连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error{
    NSLog(@"外设断开连接 %@: %@\n", [peripheral name], [error localizedDescription]);
    
    self.stateBlock(BLEState_Disconnect);
    //重连外设
    if (!self.isInitiativeDisconnect) {
        [self.centralMgr connectPeripheral:peripheral options:nil];
    }
    
}
#pragma mark - 主动断开连接
-(void)cancelPeripheralConnection{
    
    self.isInitiativeDisconnect = YES;
    if (self.discoveredPeripheral) {//已经连接外设，则断开
        [self.centralMgr cancelPeripheralConnection:self.discoveredPeripheral];
    }else{//未连接，则停止搜索外设
        [self.centralMgr stopScan];
    }
    
}

/**
 发送命令
 */
- (void) sendData:(NSData *)data{
    
     /**
      通过CBPeripheral 类 将数据写入蓝牙外设中,蓝牙外设所识别的数据为十六进制数据,在ios系统代理方法中将十六进制数据改为 NSData 类型 ,但是该数据形式必须为十六进制数 0*ff 0*ff格式 在iToll中有将 字符串转化为 十六进制 再转化为 NSData的方法
      
      */
    [self.discoveredPeripheral writeValue:data forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithoutResponse];
    
}

//向peripheral中写入数据后的回调函数
- (void)peripheral:(CBPeripheral*)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    //该方法可以监听到写入外设数据后的状态
    if (error) {
        NSLog(@"didWriteValueForCharacteristic error : %@", error.localizedDescription);
        return;
        
    }
    
    NSLog(@"write value success : %@", characteristic);
}



@end
