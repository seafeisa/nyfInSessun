//
//  DiaryCoverViewController.m
//  grow
//
//  Created by admin on 15-5-7.
//  Copyright (c) 2015年 senssun. All rights reserved.
//

#import "UserList.h"
#import "DiaryCoverViewController.h"
//#import "AppData.h"


@interface DiaryCoverViewController ()

@property (strong, nonatomic) IBOutlet UITextField *m_iboMonth;
@property (strong, nonatomic) IBOutlet UITextField *m_iboCover;
@property (strong, nonatomic) IBOutlet UIImageView *m_iboImage;

@property (strong, nonatomic) IBOutlet PickerView *m_iboDatePicker;

@end

@implementation DiaryCoverViewController
{
    NSArray *m_txtfieldArray;
    
    DiaryBook *m_diaryBook;
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
    //获取对应的文字信息
    _DairyCoverviewcreadtnotes.text = [AppData getString:@"creatOneNote"];
    _m_iboMonth.placeholder = [AppData getString:@"selectMonth"];
    _m_iboCover.placeholder =[AppData getString:@"setcoverpage"];
    
//    NSLog(@"47");
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 1. 配置对象数据
    [self initDiaryBook];
    
    // 2. 设置各输入样域
    [self initTextfield];
    
    // 3.
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
    if (![identifier isEqualToString:SEGUE_SAVE_COVER])
    {
        return YES;
    }
    
    // 校验输入信息
    if (![self isCompleteFill])
    {
        return NO;
    }
    
    // 保存记录
    switch (self.accessMode)
    {
        case ACCESS_MODE_CREATE:
            [self createDiaryBook];
            break;
            
        case ACCESS_MODE_UPDATE:
            [self updateDiaryBook];
            break;
            
        default:
            break;
    }
    
    return YES;
}

- (IBAction)backToPreView:(id)sender
{
    
    [self dismissViewControllerAnimated:NO completion:^{}];
}

- (IBAction)onButtonDone:(id)sender
{
    // 校验输入信息
    if (![self isCompleteFill])
    {
        return;
    }
    
    // 保存记录
    switch (self.accessMode)
    {
        case ACCESS_MODE_CREATE:
            [self createDiaryBook];
            break;
            
        case ACCESS_MODE_UPDATE:
            [self updateDiaryBook];
            break;
            
        default:
            break;
    }

    // 记录到配置文件
    [AppData saveDiaryBook:m_diaryBook forUser:[UserList sharedInstance].currentKid.name];

    // back to previous view
    [self dismissViewControllerAnimated:NO completion:^{}];
}

#pragma mark - Cover Data
- (BOOL)isCompleteFill
{
    // 检查是否填写完整
    if (![self.m_iboMonth.text isEqualToString:@""])
    {
        return YES;
    }
    else
    {
        // 提示
        //获取对应的文字信息 
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[AppData getString:@"information lack"]/*LOCALSTR_INFO_INCOMPLETE*/
                                                        message:[AppData getString:@"enterallprofile"]/*LOCALSTR_FILL_BLANK*/
                                                       delegate:self
                                              cancelButtonTitle:[AppData getString:@"confirm"]/*LOCALSTR_CONFIRM*/
                                              otherButtonTitles:nil, nil];
        [alert show];
        
        return NO;
    }
}

- (void)initDiaryBook
{
    m_diaryBook = [[DiaryBook alloc] init];
    
    if (ACCESS_MODE_UPDATE == self.accessMode)
    {
        DiaryBook *currentData = [[UserList sharedInstance].currentKid getDiaryByIndex:self.selectedItem];
        
        m_diaryBook.month     = currentData.month;
        
        [m_diaryBook setCoverImage:currentData.cover forUser:[UserList sharedInstance].currentKid.name];
        m_diaryBook.imageName = currentData.imageName;
        
        m_diaryBook.diaryList = currentData.diaryList;
    }
}

- (void)createDiaryBook
{
    // 新建
    [self saveAllInput];
    
    // 提示覆盖?
    
    [[UserList sharedInstance].currentKid addDiaryBook:m_diaryBook];
}

- (void)updateDiaryBook
{
    // 修改
    [self saveAllInput];
    
    DiaryBook *old = [[UserList sharedInstance].currentKid getDiaryByIndex:self.selectedItem];
    
    [[UserList sharedInstance].currentKid setDiaryBook:old withNew:m_diaryBook];
}

- (void)saveAllInput
{
    m_diaryBook.month = monthFromString(self.m_iboMonth.text);

    [m_diaryBook saveCoverImage];
}

#pragma mark - Textfield
- (void)initTextfield
{
    m_txtfieldArray = [NSArray arrayWithObjects:
                       self.m_iboMonth,
                       self.m_iboCover,
                       nil];
    
    for (UITextField *textField in m_txtfieldArray)
    {
        textField.delegate = self;
    }
    
    if (ACCESS_MODE_UPDATE == self.accessMode)
    {
        self.m_iboMonth.text = stringFromMonth(m_diaryBook.month);
        //self.m_iboCover.text = m_diaryBook.imageName;
    }
}

- (void)resignAllTextfield
{
    [self.view endEditing:YES];
    
    [self resignAllPicker];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    // 焦点离开，关闭键盘
    [self resignAllTextfield];
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    //NSLog(@"should begin editing");
    [self resignAllTextfield];
    
    // 不弹出键盘
    BOOL shouldKeyboardShown = NO;

    if ([textField.placeholder isEqualToString:[AppData getString:@"selectMonth"]/*LOCALSTR_DIARY_MONTH*/])
    {
         // 弹出picker
        [self popoverPicker:textField];
    }
    else if ([textField.placeholder isEqualToString:[AppData getString:@"setcoverpage"]/*LOCALSTR_DIARY_COVER*/])
    {
        // 弹出photopicker
        PhotoPickerView *picker = [[PhotoPickerView alloc] init];
        picker.delegate = self;
        [picker showInView:self.view];
    }
    
    return shouldKeyboardShown;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    //NSLog(@"did begin editing");
    // 只有shouldBegin里返回yes的能进来
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //NSLog(@"should return editing");
    // 返回前收起键盘
    [textField resignFirstResponder];
    
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
    [self resignAllTextfield];
}


#pragma mark Picker
- (void)initPicker
{
    self.m_iboDatePicker.delegate = self;
}

- (void)popoverPicker:(UITextField *)textField
{
    // 滑出picker
    [UIView beginAnimations:textField.placeholder context:NULL];
    [UIView setAnimationDuration:ANIM_DURATION];
    
    self.m_iboDatePicker.frame = CGRectMake(0, SCREEN_HEIGHT - PICKER_HEIGHT, SCREEN_WIDTH, PICKER_HEIGHT);
    
    [UIView commitAnimations];
}

- (void)resignAllPicker
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:ANIM_DURATION];
    
    self.m_iboDatePicker.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, PICKER_HEIGHT);
    
    [UIView commitAnimations];
}

#pragma mark PickerViewDelegate
- (void)pikerviewDidConfirm:(PickerView *)pickerView selectedDate:(NSDate *)date
{
    //dbgLog(@"picker %@ ok. date:%@", pickerView.title, date);
    
    m_diaryBook.month    = date;
    self.m_iboMonth.text = m_diaryBook.title;
}

#pragma mark - Photo picker delegate
- (void)photoPickerView:(PhotoPickerView *)picker didFinishPickingWithImage:(UIImage *)photo
{
    [m_diaryBook setCoverImage:photo forUser:[UserList sharedInstance].currentKid.name];
    
    self.m_iboImage.image = photo;
}


@end
