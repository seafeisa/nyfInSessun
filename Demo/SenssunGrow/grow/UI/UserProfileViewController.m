//
//  UserProfileViewController.m
//  grow
//
//  Created by admin on 15-3-16.
//  Copyright (c) 2015年 senssun. All rights reserved.
//
#import <MobileCoreServices/MobileCoreServices.h>

#import "UserList.h"
#import "UserProfileViewController.h"
//#import "AppData.h"
//extern NSString *g_sandboxDir;

@interface UserProfileViewController ()

@property (strong, nonatomic) IBOutlet UIButton    *m_iboBackBtn;
@property (strong, nonatomic) IBOutlet UIImageView *m_iboBackIcon;
@property (strong, nonatomic) IBOutlet UIButton    *m_iboPortrait;

@property (strong, nonatomic) IBOutlet UIView      *m_iboProfileView;
@property (strong, nonatomic) IBOutlet UITextField *m_iboNickName;
@property (strong, nonatomic) IBOutlet UITextField *m_iboGender;
@property (strong, nonatomic) IBOutlet UITextField *m_iboBirthday;
@property (strong, nonatomic) IBOutlet UITextField *m_iboTheme;
@property (strong, nonatomic) IBOutlet UITextField *m_iboDevUserID;
@property (strong, nonatomic) IBOutlet UIImageView *m_iboGenderIcon;

@property (strong, nonatomic) IBOutlet PickerView  *m_iboPicker;
@property (strong, nonatomic) IBOutlet PickerView  *m_iboDatePicker;

@end

@implementation UserProfileViewController
{
    NSArray *m_txtfieldArray;
    
    CGRect  m_profileViewRect;
    
    UserProfile *m_userProfile;
    
    NSString *userInfonickName;// = [AppData getString:@"name"];
    NSString *userInfogender;// = [AppData getString:@"gender"];
    NSString *userInfoBirthday;// = [AppData getString:@"babybirth"];
    NSString *userInfoTheme;// = [AppData getString:@"theme"];
    NSString *userInfoDevSlot;// = [AppData getString:@"user num"];
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
    [super viewDidLoad];
//    NSLog(@"20");
    
    //获取对应的文字信息
    
    userInfonickName = [AppData getString:@"name"];
    userInfogender = [AppData getString:@"gender"];
    userInfoBirthday = [AppData getString:@"babybirth"];
    userInfoTheme = [AppData getString:@"theme"];
    userInfoDevSlot = [AppData getString:@"user num"];
    
    _BabyInformation.text = [AppData getString:@"babyInformation"];
    [_ButtonTitleDone setTitle:[AppData getString:@"done"] forState:UIControlStateNormal];
    _m_iboNickName.placeholder =[AppData getString:@"name"];
    _m_iboGender.placeholder = [AppData getString:@"gender"];
    _m_iboBirthday.placeholder =[AppData getString:@"babybirth"];
    _m_iboTheme.placeholder = [AppData getString:@"theme"];
    _m_iboDevUserID.placeholder = [AppData getString:@"user num"];
    
    _NameCancel.title = [AppData getString:@"cancel"];
    _NameConfirm.title = [AppData getString:@"confirm"];
    _NameBabyBirth.title = [AppData getString:@"babybirth"];
    
    _TitleCancel.title = [AppData getString:@"cancel"];
    _TitleConfirm.title = [AppData getString:@"confirm"];
    _TitleBabySex.title = [AppData getString:@"babyGender"];
    
    // Do any additional setup after loading the view.
    if (isFirstLogin())
    {
        // 禁用返回按钮
        self.m_iboBackBtn.hidden  = YES;
        self.m_iboBackIcon.hidden = YES;
        
        self.accessMode = ACCESS_MODE_CREATE;
    }
    
    // 1. 配置用户特征
    [self initUserProfile];

    // 2. 设置用户头像，依赖userProfile
    [self initPortrait];
    
    // 3. 设置各特征域，依赖userProfile
    [self initTextfield];
    
    // 4.
    [self initPicker];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
//    NSLog(@"21");
    if (![identifier isEqualToString:SEGUE_SAVE_USERINFO])
    {
        return YES;
    }
    
    // 校验用户信息
    if (![self isUserInfoComplete])
    {
        return NO;
    }
    
    // 保存个人信息
    switch (self.accessMode)
    {
        case ACCESS_MODE_CREATE:
            [self createUser];
            break;
            
        case ACCESS_MODE_UPDATE:
            [self updateUser];
            break;
            
        default:
            break;
    }
    
    return YES;
}

- (IBAction)backToPreView:(id)sender
{
//    NSLog(@"22");
    [self dismissViewControllerAnimated:NO completion:^{}];
}

- (IBAction)onButtonDone:(id)sender
{
//    NSLog(@"23");
    // 校验用户信息
    if (![self isUserInfoComplete])
    {
        return;
    }
    
    // 保存记录
    switch (self.accessMode)
    {
        case ACCESS_MODE_CREATE:
            [self createUser];
            break;
            
        case ACCESS_MODE_UPDATE:
            [self updateUser];
            break;
            
        default:
            break;
    }
    
    // back to previous view
    [self dismissViewControllerAnimated:NO completion:^{}];
}

#pragma mark - User Profile
- (BOOL)isUserInfoComplete
{
//    NSLog(@"24");
    // 检查是否填写完整
    if ((![self.m_iboNickName.text isEqualToString:@""])
        && (![self.m_iboGender.text isEqualToString:@""])
        && (![self.m_iboBirthday.text isEqualToString:@""]))
    {
        return YES;
    }
    else
    {
        // 提示
        
        NSString *confirm = [AppData getString:@"confirm"];
        NSString *Incomplete = [AppData getString:@"information lack"];
        NSString *Tips = [AppData getString:@"completeprofile-noeffect"];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Incomplete/*LOCALSTR_INFO_INCOMPLETE*/
                                                        message:Tips/*LOCALSTR_FILL_TIPS*/
                                                       delegate:self
                                              cancelButtonTitle:confirm/*LOCALSTR_CONFIRM*/
                                              otherButtonTitles:nil, nil];
        [alert show];
        
        return NO;
    }
}

- (void)initUserProfile
{
//    NSLog(@"25");
    m_userProfile = [[UserProfile alloc] initWithName:@"NewUser"];
    
    if (ACCESS_MODE_UPDATE == self.accessMode)
    {
        m_userProfile.name       = [UserList sharedInstance].currentKid.name;
        m_userProfile.gender     = [UserList sharedInstance].currentKid.gender;
        m_userProfile.birthday   = [UserList sharedInstance].currentKid.birthday;
        m_userProfile.themeIndex = [UserList sharedInstance].currentKid.themeIndex;
        m_userProfile.devMSlot   = [UserList sharedInstance].currentKid.devMSlot;

        [m_userProfile setPortraitImage:[UserList sharedInstance].currentKid.portraitImage];
        m_userProfile.portrait   = [UserList sharedInstance].currentKid.portrait;
        
        m_userProfile.recordList = [UserList sharedInstance].currentKid.recordList;
    }
}

- (void)createUser
{
//    NSLog(@"26");
    // 新建
    m_userProfile.name = self.m_iboNickName.text;
    [m_userProfile savePortraitImage];
    
    [[UserList sharedInstance] addKid:m_userProfile];
    [[UserList sharedInstance] setCurrentKid:m_userProfile.name];
}

- (void)updateUser
{
//    NSLog(@"27");
    // 修改
    [m_userProfile savePortraitImage];
    m_userProfile.name = self.m_iboNickName.text;
    [[UserList sharedInstance] setCurrentKid:m_userProfile.name];
    [[UserList sharedInstance] mdfKid:[UserList sharedInstance].currentKid.name withObject:m_userProfile];
}

#pragma mark - Textfield
- (void)initTextfield
{
//    NSLog(@"28");
    m_txtfieldArray = [NSArray arrayWithObjects:
                       self.m_iboNickName,
                       self.m_iboGender,
                       self.m_iboBirthday,
                       self.m_iboTheme,
                       self.m_iboDevUserID,
                       nil];
    
    for (UITextField *textField in m_txtfieldArray)
    {
        textField.delegate = self;
    }
    
    m_profileViewRect = self.m_iboProfileView.frame;
    
    if (ACCESS_MODE_UPDATE == self.accessMode)
    {
        // 不支持修改名字
        [self.m_iboNickName setUserInteractionEnabled:NO];
//        [self.m_iboNickName setTextColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1]];
        self.m_iboNickName.text = m_userProfile.name;
        
        [self setM_iboNickName:self.m_iboNickName];
        [self.m_iboNickName setUserInteractionEnabled:YES];
        m_userProfile.name = self.m_iboNickName.text;
        
        
        [self setGenderFieldWithValue:m_userProfile.gender];
        [self setBirthdayFieldWithDate:m_userProfile.birthday];
        [self setThemeFieldWithValue:m_userProfile.themeIndex];
        [self setDevMSlotFieldWithValue:m_userProfile.devMSlot];
    }
    
    // 注册键盘事件, 以便弹出时滑动视图
    [self registerKeyboardNotifications];
}

- (void)resignAllTextfield
{
//    NSLog(@"29");
    [self.view endEditing:YES];
    
    [self resignAllPicker];
}

- (void)scrollTextview:(UITextField *)textField withPickerHeight:(CGFloat)pickerHeight
{
//    NSLog(@"30");
    //将textField坐标系转换成整个屏幕的坐标系,注意必须是bounds
    CGRect  rectText  = [textField convertRect:textField.bounds toView:nil];
    
    //横竖屏四种情况，分别算出在屏幕坐标系中textField和键盘的y坐标
    CGFloat yText     = 0.0;
    CGFloat yKeyboard = 0.0;
    switch (self.interfaceOrientation)
    {
        case UIInterfaceOrientationPortrait:
            yText = CGRectGetMaxY(rectText);
            yKeyboard = SCREEN_HEIGHT - pickerHeight;
            break;
            
        case UIInterfaceOrientationPortraitUpsideDown:
            yText = SCREEN_HEIGHT - rectText.origin.y;
            yKeyboard = SCREEN_HEIGHT - pickerHeight;
            break;
            
        case UIDeviceOrientationLandscapeRight:
            yText = rectText.origin.x + rectText.size.width ;
            yKeyboard = SCREEN_WIDTH - pickerHeight;
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            yText = SCREEN_WIDTH - rectText.origin.x;
            yKeyboard = SCREEN_WIDTH - pickerHeight;
            break;
            
        default:
            break;
    }
    
    //当键盘能遮盖时做处理
    if (yText > yKeyboard)
    {
        CGFloat offsetY  = yText - yKeyboard;
        CGRect  rectView = textField.superview.frame;
        rectView.origin.y -= offsetY;
        
        [self moveTextview:textField toRect:rectView];
    }
}

- (void)repositionTextview//:(UITextField *)textField
{
//    NSLog(@"31");
    // 关闭所有键盘
    [self resignAllTextfield];
    
    // textfield退回原位
    //[self moveTextview:textField toRect:m_profileViewRect];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:ANIM_DURATION];
    
    self.m_iboProfileView.frame = m_profileViewRect;
    
    [UIView commitAnimations];
}

- (void)moveTextview:(UITextField *)textField toRect:(CGRect)rect
{
//    NSLog(@"32");
    [UIView beginAnimations:textField.placeholder context:NULL];
    [UIView setAnimationDuration:ANIM_DURATION];
    
    textField.superview.frame = rect;
    
    [UIView commitAnimations];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//    NSLog(@"33");
    [super touchesBegan:touches withEvent:event];
    
    // 焦点离开，关闭键盘
    // textfield退回原位
    [self repositionTextview];
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
//    NSLog(@"34");
    //NSLog(@"should begin editing");
    // textfield退回原位
    [self repositionTextview];
    
    BOOL shouldKeyboardShown = NO;
    if ([textField.placeholder isEqualToString:userInfonickName/*LOCALSTR_USRINFO_NICKNAME*/])
    {
        // 弹出键盘
        shouldKeyboardShown = YES;
    }
    else
    {
        // 不弹出当前对象键盘
        shouldKeyboardShown = NO;
        
        // 弹出picker
        [self popoverPicker:textField];
    }
    
    return shouldKeyboardShown;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    //NSLog(@"did begin editing");
    // 只有shouldBegin里返回yes的能进来
    
    // 滑动textfield避免被键盘覆盖
    //[self scrollTextview:textField forPickerHeight:m_keyboardHeight];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
//    NSLog(@"35");
    //NSLog(@"should return editing");
    // 返回前收起键盘
    [textField resignFirstResponder];
    
    if ([textField.placeholder isEqualToString:userInfonickName/*LOCALSTR_USRINFO_NICKNAME*/])
    {
        m_userProfile.name = textField.text;
        
        //[self writePlist:@"config" content:@{@"currentUser": m_userProfile.name}];
    }
    
    return  YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    //NSLog(@"should end editing");
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    //NSLog(@"did end editing");
    // textfield退回原位
    [self repositionTextview];
}

#pragma mark Keyboard Notification
- (void)registerKeyboardNotifications
{
//    NSLog(@"36");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *) notif
{
//    NSLog(@"37");
    NSDictionary *info = [notif userInfo];
    
    NSValue *value = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    
    //NSLog(@"keyboardWillShow height:%.1f", keyboardSize.height);  //216
    
    for (UITextField *textField in m_txtfieldArray)
    {
        if (NO == textField.isEditing)
        {
            continue;
        }
        
        // 滑动textfield避免被键盘覆盖
        [self scrollTextview:textField withPickerHeight:keyboardSize.height];
        break;
    }
}

#pragma mark Picker
- (void)initPicker
{
    self.m_iboPicker.delegate = self;
    self.m_iboDatePicker.delegate = self;
}

- (void)popoverPicker:(UITextField *)textField
{
//    NSLog(@"38");
    // 滑出picker
    [UIView beginAnimations:textField.placeholder context:NULL];
    [UIView setAnimationDuration:ANIM_DURATION];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(pickerDidShow:finished:context:)];
    
    if ([textField.placeholder isEqualToString:userInfoBirthday/*LOCALSTR_USRINFO_BIRTHDAY*/])
    {
        [self.m_iboDatePicker changeMode:textField.placeholder];
        self.m_iboDatePicker.frame = CGRectMake(0, SCREEN_HEIGHT - PICKER_HEIGHT, SCREEN_WIDTH, PICKER_HEIGHT);
    }
    else
    {
        // 修改picker模式
        [self.m_iboPicker changeMode:textField.placeholder];
        
        self.m_iboPicker.frame = CGRectMake(0, SCREEN_HEIGHT - PICKER_HEIGHT, SCREEN_WIDTH, PICKER_HEIGHT);
    }
    
    [UIView commitAnimations];
}

- (void)pickerDidShow:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
//    NSLog(@"39");
    for (UITextField *textField in m_txtfieldArray)
    {
        if (![textField.placeholder isEqualToString:animationID])
        {
            continue;
        }
        
        // 滑动textfield避免被键盘覆盖
        [self scrollTextview:textField withPickerHeight:PICKER_HEIGHT];
        break;
    }
}

- (void)resignAllPicker
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:ANIM_DURATION];
    
    self.m_iboDatePicker.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, PICKER_HEIGHT);
    self.m_iboPicker.frame     = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, PICKER_HEIGHT);
    
    [UIView commitAnimations];
}

#pragma mark PickerViewDelegate
- (void)pikerviewDidHide:(PickerView *)pickerView
{
    //dbgLog(@"picker hide");
    [self repositionTextview];
}

- (void)pikerviewDidShow:(PickerView *)pickerView
{
    //dbgLog(@"picker show");
}

- (void)pikerviewDidCancel:(PickerView *)pickerView
{
    //dbgLog(@"picker cancel");
}

- (void)pikerviewDidConfirm:(PickerView *)pickerView selectedRowTitle:(NSString *)rowTitle forRow:(NSInteger)row
{
    //dbgLog(@"picker %@ ok. row:%d title:%@", pickerView.title, row, rowTitle);
    
    [self setFieldContent:rowTitle value:row forField:pickerView.title];
}

- (void)pikerviewDidConfirm:(PickerView *)pickerView selectedDate:(NSDate *)date
{
    //dbgLog(@"picker %@ ok. date:%@", pickerView.title, date);
    
    m_userProfile.birthday = date;
    self.m_iboBirthday.text = stringFromDate(date);
}

#pragma mark - FieldContent
- (void)setFieldContent:(NSString *)fieldTitle value:(NSInteger)value forField:(NSString *)fieldID
{
    //dbgLog(@"%@:%@",fieldID,fieldTitle);
    if ([fieldID isEqualToString:userInfonickName/*LOCALSTR_USRINFO_NICKNAME*/])
    {
        // NA this time
    }
    else if ([fieldID isEqualToString:userInfogender/*LOCALSTR_USRINFO_GENDER*/])
    {
        [self setGenderField:fieldTitle value:value];
    }
    else if ([fieldID isEqualToString:userInfoBirthday/*LOCALSTR_USRINFO_BIRTHDAY*/])
    {
        [self setBirthdayField:fieldTitle value:value];
    }
    else if ([fieldID isEqualToString:userInfoTheme/*LOCALSTR_USRINFO_THEME*/])
    {
        [self setThemeField:fieldTitle value:value];
    }
    else if ([fieldID isEqualToString:userInfoDevSlot/*LOCALSTR_USRINFO_DEVMSLOT*/])
    {
        [self setDevMSlotField:fieldTitle value:value];
    }
    else
    {
        // invalid case
    }
}

- (void)setGenderField:(NSString *)title value:(NSInteger)value
{
    [self.m_iboGender setText:title];
    
    // 设置域图标
    [self.m_iboGenderIcon setImage:[UserProfile iconOfGender:(ENGender)value]];
    
    // 保存用户信息
    m_userProfile.gender = (ENGender)value;
}

- (void)setGenderFieldWithValue:(ENGender)gender
{
    [self.m_iboGender setText:[UserProfile titleOfGender:gender]];
    [self.m_iboGenderIcon setImage:[UserProfile iconOfGender:gender]];
}

- (void)setBirthdayField:(NSString *)title value:(NSInteger)value
{
    [self.m_iboBirthday setText:title];
    
    // 保存用户信息
    m_userProfile.birthday = dateFromString(title);
    //m_userProfile.birthday = [NSDate dateWithTimeIntervalSinceReferenceDate:value];
}

- (void)setBirthdayFieldWithDate:(NSDate *)date
{
    [self.m_iboBirthday setText:stringFromDate(date)];
}

- (void)setThemeField:(NSString *)title value:(NSInteger)value
{
    [self.m_iboTheme setText:title];
    
    // 设置文本区左视图
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [icon setImage:[UserProfile iconOfTheme:(ENThemeID)value]];
    [self.m_iboTheme setLeftView:icon];
    [self.m_iboTheme setLeftViewMode:UITextFieldViewModeAlways];
    [self.m_iboTheme.leftView setContentMode:UIViewContentModeScaleAspectFit];
    
    // 保存用户信息
    m_userProfile.themeIndex = (ENThemeID)value;
}

- (void)setThemeFieldWithValue:(ENThemeID)theme
{
    [self.m_iboTheme setText:[UserProfile titleOfTheme:theme]];
    
    // 设置文本区左视图
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [icon setImage:[UserProfile iconOfTheme:theme]];
    [self.m_iboTheme setLeftView:icon];
    [self.m_iboTheme setLeftViewMode:UITextFieldViewModeAlways];
    [self.m_iboTheme.leftView setContentMode:UIViewContentModeScaleAspectFit];
}

- (void)setDevMSlotField:(NSString *)title value:(NSInteger)value
{
    [self.m_iboDevUserID setText:title];
    
    // 保存用户信息
    m_userProfile.devMSlot = (ENDevMSlot)(value + 1);
}

- (void)setDevMSlotFieldWithValue:(ENDevMSlot)slot
{
    [self.m_iboDevUserID setText:[UserProfile titleOfDevMSlot:slot]];
}

#pragma mark - Portrait
- (void)initPortrait
{
    self.m_iboPortrait.layer.cornerRadius  = self.m_iboPortrait.frame.size.height/2;
    self.m_iboPortrait.layer.masksToBounds = YES;
    self.m_iboPortrait.layer.borderColor   = [[UIColor whiteColor] CGColor];
    self.m_iboPortrait.layer.borderWidth   = 2.0f;
    self.m_iboPortrait.contentMode         = UIViewContentModeScaleAspectFill;
    self.m_iboPortrait.clipsToBounds       = YES;
    //self.m_iboPortrait.userInteractionEnabled = YES;
    //self.m_iboPortrait.backgroundColor     = [UIColor clearColor];
    
    if (![m_userProfile isDefaultPortrait])
    {
        self.m_iboPortrait.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.m_iboPortrait setImage:m_userProfile.portraitImage forState:UIControlStateNormal];
    }
}

// 修改头像
- (IBAction)editPortrait:(id)sender
{
    [self resignAllTextfield];

    PhotoPickerView *picker = [[PhotoPickerView alloc] init];
    picker.delegate = self;
    [picker showInView:self.view];
}

#pragma mark - PhotoPicker delegate
- (void)photoPickerView:(PhotoPickerView *)picker didFinishPickingWithImage:(UIImage *)photo
{
    [m_userProfile setPortraitImage:photo];

    self.m_iboPortrait.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.m_iboPortrait setImage:photo forState:UIControlStateNormal];
}

@end