//
//  HomeViewController.m
//  grow
//
//  Created by admin on 15-5-7.
//  Copyright (c) 2015年 senssun. All rights reserved.
//

#import "UserList.h"
#import "PhotoPickerView.h"
#import "UIBackgndImageView.h"
#import "HomeViewController.h"
//#import "AppData.h"

@interface HomeViewController ()

@property (strong, nonatomic) IBOutlet UIBackgndImageView *m_ibobackPhoto;

@end

@implementation HomeViewController

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
    [super viewDidLoad];
    
    //获取对应的文字信息
    _Growthcurve.text = [AppData getString:@"growthCurve"];
    _GroethDiary.text = [AppData getString:@"growthNote"];
    _Meadure.text = [AppData getString:@"Tomeasure"];
    _Users.text = [AppData getString:@"user"];
    _Setting.text = [AppData getString:@"setting"];

//    NSLog(@"33333");
    // Do any additional setup after loading the view.
    if (isFirstLogin() || isLogout())
    {
        self.view.hidden = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
//    NSLog(@"44444");
    if (isFirstLogin() || isLogout())
    {
        [self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"UserListViewController"]
                           animated:NO
                         completion:nil];
    }
    else
    {
        self.view.hidden = NO;
    }
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

- (IBAction)onReplaceBackImage:(id)sender
{
    PhotoPickerView *picker = [[PhotoPickerView alloc] init];
    picker.delegate = self;
    
    [picker showInView:self.view];
}

#pragma mark - PhotoPicker delegate
- (void)photoPickerView:(PhotoPickerView *)picker didFinishPickingWithImage:(UIImage *)photo
{
//    NSLog(@"55555");
    self.m_ibobackPhoto.image = photo;
    
    [[AppData sharedInstance] setBackgndImage:photo];
}

@end
