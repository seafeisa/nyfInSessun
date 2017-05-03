//
//  DeviceListViewController.m
//  grow
//
//  Created by admin on 15-7-1.
//  Copyright (c) 2015年 senssun. All rights reserved.
//

#import "BthMgr.h"
#import "DeviceListViewController.h"
//#import "AppData.h"


@interface DeviceListViewController ()

@property (strong, nonatomic) IBOutlet UITableView *m_iboDeviceTable;

@end

@implementation DeviceListViewController
{
    BthMgr              *m_bleMgr;
    NSMutableDictionary *m_RSSIs;
    NSMutableDictionary *m_peripherals;
    NSString            *m_currentPeer;
}




- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    _DeviceViewdevicemanage.text = [AppData getString:@"managedevice"];
//    NSLog(@"51");
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    m_RSSIs       = [[NSMutableDictionary alloc] init];
    m_peripherals = [[NSMutableDictionary alloc] init];
//    [m_peripherals setObject:@"test0" forKey:@"1234-5678-90"];
//    [m_peripherals setObject:@"test1" forKey:@"1234-5678-91"];
//    [m_peripherals setObject:@"test2" forKey:@"1234-5678-92"];
//    [m_peripherals setObject:@"test3" forKey:@"1234-5678-93"];
//    [m_peripherals setObject:@"test4" forKey:@"1234-5678-94"];
//    [m_peripherals setObject:@"test5" forKey:@"1234-5678-95"];
//    [m_peripherals setObject:@"test6" forKey:@"1234-5678-96"];
//    [m_peripherals setObject:@"test7" forKey:@"1234-5678-97"];
//    [m_peripherals setObject:@"test8" forKey:@"1234-5678-98"];
//    [m_peripherals setObject:@"test9" forKey:@"1234-5678-99"];
//    [m_peripherals setObject:@"testA" forKey:@"1234-5678-9A"];
//    [m_peripherals setObject:@"testB" forKey:@"1234-5678-9B"];
//    [m_peripherals setObject:@"testC" forKey:@"1234-5678-9C"];
//    [m_peripherals setObject:@"testD" forKey:@"1234-5678-9D"];
//    [m_peripherals setObject:@"testE" forKey:@"1234-5678-9E"];
//    [m_peripherals setObject:@"testF" forKey:@"1234-5678-9F"];
    
    if (nil == m_bleMgr)
    {
        m_bleMgr = [BthMgr sharedInstance];
        m_bleMgr.delegate = self;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [m_bleMgr keepScannig];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //[m_bleMgr stopConnect];
    [m_bleMgr stopScan];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backToPreView:(id)sender
{
    
    [self dismissViewControllerAnimated:NO completion:^{}];
}

#pragma mark - BluetoothMgr delegate
- (void)bluetoothDidDiscoverPeripheral:(CBPeripheral *)peripheral RSSI:(NSNumber *)RSSI
{
//    NSString *deviceName = [m_peripherals objectForKey:peripheral.identifier.UUIDString];
//    if (nil == deviceName)
//    {
//    }
    //dbgLog(@"add %@, UUID:%@, RSSI:%@", peripheral.name, peripheral.identifier.UUIDString, RSSI);
    
    [m_RSSIs setObject:RSSI forKey:peripheral.identifier.UUIDString];
    [m_peripherals setObject:peripheral.name forKey:peripheral.identifier.UUIDString];

    [self.m_iboDeviceTable reloadData];
}

#pragma mark - TableView datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [m_peripherals count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *reuseIdentifier = @"peripheralsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    NSString *deviceName      = [self deviceNameAtIndexPath:indexPath];
    NSString *deviceUUID      = [self deviceUUIDAtIndexPath:indexPath];
    NSNumber *deviceRSSI      = [self deviceRSSIAtIndexPath:indexPath];
    cell.textLabel.text       = [NSString stringWithFormat:@"%@\t\t\t%@", deviceName, deviceRSSI];
    cell.detailTextLabel.text = deviceUUID;
    cell.imageView.image=[UIImage imageNamed:@""];
    
    if ([deviceUUID isEqualToString:m_currentPeer])
    {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    else
    {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    return cell;
}

#pragma mark - TableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //dbgLog(@"select %ld",indexPath.row);
    [m_bleMgr stopScan];
    m_currentPeer = [self deviceUUIDAtIndexPath:indexPath];
    [m_bleMgr appointPeripheralWithUUID:m_currentPeer];

    [self.m_iboDeviceTable reloadData];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [m_bleMgr keepScannig];
    
    m_currentPeer = nil;
    [m_RSSIs removeAllObjects];
    [m_peripherals removeAllObjects];
    [self.m_iboDeviceTable reloadData];
}

#pragma mark - Utility
- (NSString *)deviceUUIDAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *UUIDs = [[m_peripherals allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSString *deviceUUID = [UUIDs objectAtIndex:indexPath.row];

    return deviceUUID;
}

- (NSString *)deviceNameAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *deviceUUID = [self deviceUUIDAtIndexPath:indexPath];
    NSString *deviceName = [m_peripherals objectForKey:deviceUUID];
    
    return deviceName;
}

- (NSNumber *)deviceRSSIAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *deviceUUID = [self deviceUUIDAtIndexPath:indexPath];
    NSNumber *deviceRSSI = [m_RSSIs objectForKey:deviceUUID];
    
    return deviceRSSI;
}
@end
