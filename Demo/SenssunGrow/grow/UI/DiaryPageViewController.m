//
//  DiaryPageViewController.m
//  grow
//
//  Created by admin on 15-5-7.
//  Copyright (c) 2015年 senssun. All rights reserved.
//

#import "UITextViewNote.h"
#import "UserList.h"
#import "DiaryPageViewController.h"
#import "DiaryListViewController.h"
//#import "AppData.h"


#define MAX_PHOTO_ADAY 6

@implementation PhotoViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

@end

@interface DiaryPageViewController ()

@property (strong, nonatomic) IBOutlet UITextField      *m_iboDate;
@property (strong, nonatomic) IBOutlet UITextField      *m_iboNotePlaceholder;
@property (strong, nonatomic) IBOutlet UITextViewNote   *m_iboNote;
@property (strong, nonatomic) IBOutlet UICollectionView *m_iboPhotos;

@property (strong, nonatomic) IBOutlet PickerView       *m_iboDatePicker;

@end

@implementation DiaryPageViewController
{
    NSArray *m_txtfieldArray;
    //NSMutableArray *m_photosArray;

    DiaryBook *m_superBook;
    DiaryPage *m_diarySheet;
    
    ENAccessMode m_photoOpcode;
    NSUInteger   m_currentPhotoIndex;
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
   
    _DairyPageViewgrowthnote.text = [AppData getString:@"growthNote"];
    _m_iboDate.placeholder = [AppData getString:@"time"];
    _m_iboNotePlaceholder.placeholder = [AppData getString:@"notes"];
    _DairyPageViewButtonConfirm.titleLabel.text = [AppData getString:@"done"];
    [_DairyPageViewButtonConfirm setTitle:[AppData getString:@"done"] forState:UIControlStateNormal];
    _DairyPageViewCanceltitle.title = [AppData getString:@"cancel"];
    _DairypageViewConfirmtitle.title = [AppData getString:@"confirm"];
    _DairyPageViewmeasure.title = [AppData getString:@"time"];
//    NSLog(@"49");
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 1. 配置对象数据
    [self initDiarySheet];
    
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
    if ([segue.identifier isEqualToString:SEGUE_SAVE_DIARY])
    {
        DiaryListViewController *destVC = [segue destinationViewController];
        destVC.superBook = self.superBook;
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if (![identifier isEqualToString:SEGUE_SAVE_DIARY])
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
            [self createDiary];
            break;
            
        case ACCESS_MODE_UPDATE:
            [self updateDiary];
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
            [self createDiary];
            break;
            
        case ACCESS_MODE_UPDATE:
            [self updateDiary];
            break;
            
        default:
            break;
    }

    // 记录到配置文件
    [AppData saveDiaryBook:m_superBook forUser:[UserList sharedInstance].currentKid.name];
    
    // back to previous view
    [self dismissViewControllerAnimated:NO completion:^{}];
}

#pragma mark - Diary Data
- (BOOL)isCompleteFill
{
    // 检查是否填写完整
    if (![self.m_iboDate.text isEqualToString:@""])
    {
        return YES;
    }
    else
    {
        // 提示
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[AppData getString:@"information lack"]/*LOCALSTR_INFO_INCOMPLETE*/
                                                        message:[AppData getString:@"enterallprofile"]/*LOCALSTR_FILL_BLANK*/
                                                       delegate:self
                                              cancelButtonTitle:[AppData getString:@"confirm"]/*LOCALSTR_CONFIRM*/
                                              otherButtonTitles:nil, nil];
        [alert show];
        
        return NO;
    }
}

- (void)initDiarySheet
{
    if (NSNotFound != self.superBook)
    {
        m_superBook = [[UserList sharedInstance].currentKid getDiaryByIndex:self.superBook];
    }

    m_diarySheet = [[DiaryPage alloc] init];

    if (ACCESS_MODE_UPDATE == self.accessMode)
    {
        DiaryPage *currentData = [m_superBook getSheetByIndex:self.selectedItem];
        
        m_diarySheet.date = currentData.date;
        m_diarySheet.text = currentData.text;
        
        m_diarySheet.imageList = [NSMutableArray arrayWithArray:currentData.imageList];
        [m_diarySheet copyPhotosFromOther:currentData];
    }
    
    [m_diarySheet.imageList addObject:IMG_ADD_PICTURE];
}

- (void)createDiary
{
    // 新建
    [self saveAllInput];
    
    // TODO: 提示覆盖?
    
    // 创建的笔记和当前笔记本不同月，查找目标笔记本，没有就添加一个新笔记本
    if ((NSNotFound == self.superBook) || (!isSameMonth(m_diarySheet.date, m_superBook.month)))
    {
        DiaryBook *book = [[UserList sharedInstance].currentKid getDiaryByKey:m_diarySheet.date];
        if (nil == book)
        {
            book = [[DiaryBook alloc] init];
            book.month = m_diarySheet.date;
            
            if (0 != [m_diarySheet.imageList count])
            {
                [book setCoverImage:[m_diarySheet photoAtIndex:0] forUser:[UserList sharedInstance].currentKid.name];
                [book saveCoverImage];
            }
            
            [[UserList sharedInstance].currentKid addDiaryBook:book];
            //dbgLog(@"create book:%@",book.title);
        }
        
        m_superBook = book;
    }

    //dbgLog(@"superbook:%@",m_superBook.title);
    [m_superBook addDiarySheet:m_diarySheet];
}

- (void)updateDiary
{
    // 修改
    [self saveAllInput];
    
    DiaryPage *old = [m_superBook getSheetByIndex:self.selectedItem];
    
    [m_superBook setDiarySheet:old withNew:m_diarySheet];
}

- (void)saveAllInput
{
    m_diarySheet.date = dateFromString(self.m_iboDate.text);
    m_diarySheet.text = self.m_iboNote.text;
    
    // TODO: save imagelist
    // remove 'add' item
    [m_diarySheet.imageList removeLastObject];
    [m_diarySheet savePhotos];
}

#pragma mark - Textfield
- (void)initTextfield
{
    m_txtfieldArray = [NSArray arrayWithObjects:
                       self.m_iboDate,
                       nil];
    
    for (UITextField *textField in m_txtfieldArray)
    {
        textField.delegate = self;
    }
    
    if (ACCESS_MODE_UPDATE == self.accessMode)
    {
        self.m_iboDate.text = stringFromDate(m_diarySheet.date);

        if (![m_diarySheet.text isEqualToString:@""])
        {
            self.m_iboNotePlaceholder.hidden = YES;
        }
        self.m_iboNote.text = m_diarySheet.text;
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
    
    NSString *noteTime = [AppData getString:@"time"];
    
    if ([textField.placeholder isEqualToString:noteTime/*LOCALSTR_TIME*/])
    {
        // 弹出picker
        [self popoverPicker:textField];
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
    
    m_diarySheet.date = date;
    self.m_iboDate.text = stringFromDate(date);
}

#pragma mark - TextView

#pragma mark UITextViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.m_iboNote setNeedsDisplay];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self resignAllTextfield];
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.m_iboNotePlaceholder.hidden = YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""])
    {
        self.m_iboNotePlaceholder.hidden = NO;
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    UITextViewNote *note = (id)textView;
    [note setParagraphStyle];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSUInteger cnt = [m_diarySheet.imageList count];
    return MIN(cnt, MAX_PHOTO_ADAY);
}

//每个UICollectionView展示的内容
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"dairyPhotoCell";
    PhotoViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    //cell.photo.contentMode = UIViewContentModeScaleAspectFill;
    
    NSString *imageName = [m_diarySheet.imageList objectAtIndex:indexPath.row];
    if ([imageName isEqualToString:IMG_ADD_PICTURE])
    {
        cell.layer.borderWidth = 2;
        cell.layer.borderColor = RGB(244,244,244).CGColor;
        
        cell.photo.image = [UIImage imageNamed:imageName];
    }
    else
    {
        UIImage *photo = [m_diarySheet photoAtIndex:indexPath.row];
        if (nil != photo)
        {
            cell.photo.image = photo;
        }
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    m_currentPhotoIndex = indexPath.row;

    QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
    imagePickerController.delegate = self;

    NSString *imageName = [m_diarySheet.imageList objectAtIndex:m_currentPhotoIndex];
    if ([imageName isEqualToString:IMG_ADD_PICTURE])
    {
        m_photoOpcode = ACCESS_MODE_CREATE;

        imagePickerController.allowsMultipleSelection = YES;
        imagePickerController.limitsMaximumNumberOfSelection = YES;
        imagePickerController.maximumNumberOfSelection = 6 - (m_diarySheet.imageList.count - 1);
    }
    else
    {
        m_photoOpcode = ACCESS_MODE_UPDATE;
    }

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
    [self presentViewController:navigationController animated:NO completion:NULL];

//    PhotoPickerView *picker = [[PhotoPickerView alloc] init];
//    picker.delegate = self;
//    [picker showInView:self.view];
}

#pragma mark - PhotoPicker delegate
- (void)photoPickerView:(PhotoPickerView *)picker didFinishPickingWithImage:(UIImage *)photo
{
    if (ACCESS_MODE_UPDATE == m_photoOpcode)
    {
        [m_diarySheet setPhoto:photo atIndex:m_currentPhotoIndex];
    }
    else
    {
        [m_diarySheet addPhoto:photo forUser:[UserList sharedInstance].currentKid.name];
    }
    
    [self.m_iboPhotos reloadData];
    //[self.m_iboPhotos performSelector:@selector(reloadData) withObject:nil afterDelay:2];
}

#pragma mark - QBImagePickerControllerDelegate

- (void)imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingMediaWithInfo:(id)info
{
    if(imagePickerController.allowsMultipleSelection)
    {
        NSArray *mediaInfoArray = (NSArray *)info;
        //dbgLog(@"Selected %zu photos:%@", mediaInfoArray.count, mediaInfoArray);

        for (NSDictionary *mediaInfo in mediaInfoArray)
        {
            UIImage *photo = [imagePickerController imageFromMediaInfo:mediaInfo];

            [m_diarySheet addPhoto:photo forUser:[UserList sharedInstance].currentKid.name];
        }
    }
    else
    {
        NSDictionary *mediaInfo = (NSDictionary *)info;
        //dbgLog(@"Selected: %@", mediaInfo);

        UIImage *photo = [imagePickerController imageFromMediaInfo:mediaInfo];

        [m_diarySheet setPhoto:photo atIndex:m_currentPhotoIndex];
    }

    [self.m_iboPhotos reloadData];

    [self dismissViewControllerAnimated:NO completion:NULL];
}

- (void)imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController
{
    [self dismissViewControllerAnimated:NO completion:NULL];
}

- (NSString *)imagePickerController:(QBImagePickerController *)imagePickerController descriptionForNumberOfPhotos:(NSUInteger)numberOfPhotos
{
    return [NSString stringWithFormat:@"%zu %@", (unsigned long)numberOfPhotos, [AppData getString:@"photos"]/*LOCALSTR_MULTI_PHOTOS*/];
}


@end
