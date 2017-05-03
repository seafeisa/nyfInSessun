//
//  DiaryListViewController.m
//  grow
//
//  Created by admin on 15-5-7.
//  Copyright (c) 2015年 senssun. All rights reserved.
//

#import "UserList.h"
#import "DiaryPageViewController.h"
#import "DiaryListViewController.h"
//#import "AppData.h"


enum
{
    ALERT_REMOVE_ALL = 0x4001,
    ALERT_DEL_SELECTED,
};

@interface DiaryListViewController ()

@property (strong, nonatomic) IBOutlet UITableView  *m_iboDiaryList;
@property (strong, nonatomic) IBOutlet UIView       *m_iboBottomBar;
@property (strong, nonatomic) IBOutlet UIButton     *m_iboEditBtn;
@property (strong, nonatomic) IBOutlet UIImageView *m_iboSelectState;

@end

@implementation DiaryListViewController
{
    DiaryBook *m_superBook;

    BOOL m_isEditing;

    NSMutableDictionary *m_selectedItems;
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
    [_m_iboEditBtn setTitle:[AppData getString:@"editor"] forState:UIControlStateNormal];
    _DiaryListViewgrowthnotename.text = [AppData getString:@"growthNote"];
    [_DiaryListViewwritenotename setTitle:[AppData getString:@"writeNote"]forState:UIControlStateNormal];
    
    [_DiaryViewdeleteAlltitle setTitle:[AppData getString:@"allslect"] forState:UIControlStateNormal];
    [_DiaryViewdeteletitle setTitle:[AppData getString:@"delete"] forState:UIControlStateNormal];
//    _DiaryViewdeleteAlltitle.titleLabel.text =[AppData getString:@"allslect"];
//    _DiaryViewdeteletitle.titleLabel.text = [AppData getString:@"delete"];
    
//    NSLog(@"48");
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initialize];
}

- (void)initialize
{
    m_superBook = [[UserList sharedInstance].currentKid getDiaryByIndex:self.superBook];
    
    m_isEditing = NO;
    
    if (nil == m_selectedItems)
    {
        m_selectedItems = [[NSMutableDictionary alloc] init];
    }
    [m_selectedItems removeAllObjects];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.m_iboDiaryList reloadData];
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
    
    DiaryPageViewController *destVC = [segue destinationViewController];
    if ([segue.identifier isEqualToString:SEGUE_ADD_DIARY])
    {
        destVC.accessMode = ACCESS_MODE_CREATE;
        destVC.superBook  = self.superBook;
    }
    else if ([segue.identifier isEqualToString:SEGUE_EDIT_DIARY])
    {
        NSIndexPath *indexPath = [self.m_iboDiaryList indexPathForCell:sender];
        destVC.selectedItem = indexPath.row;
        
        destVC.accessMode = ACCESS_MODE_UPDATE;
        destVC.superBook  = self.superBook;
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    return m_isEditing ? NO : YES;
}

- (IBAction)backToPreView:(id)sender
{
    if (m_isEditing)
    {
        m_isEditing = NO;
        self.m_iboEditBtn.hidden = NO;
        self.m_iboBottomBar.hidden = YES;
        
        [m_selectedItems removeAllObjects];
        [self.m_iboDiaryList reloadData];
    }
    else
    {
        [self dismissViewControllerAnimated:NO completion:^{}];
    }
}


#pragma mark - TableView datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [m_superBook.diaryList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = @"diaryItemCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    
    // Configure the cell...
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    }
    
//    NSArray *sortKeys = [m_superBook sortedKeys];
//    NSDate  *date     = [sortKeys objectAtIndex:indexPath.row];
//    DiaryPage *diary  = [m_superBook.diaryList objectForKey:date];
//    
//    cell.textLabel.text = [[stringFromDate(date) stringByAppendingString:@"\t\t"] stringByAppendingString:diary.text];

    DiaryPage *page = [m_superBook getSheetByIndex:indexPath.row];
    cell.textLabel.text = [[stringFromDate(page.date) stringByAppendingString:@"\t\t"] stringByAppendingString:page.text];
    
    if (m_isEditing)
    {
        if (nil == [m_selectedItems objectForKey:page.date])
        {
            cell.imageView.image = [UIImage imageNamed:IMG_CHECKKBOX_DS];
        }
        else
        {
            cell.imageView.image = [UIImage imageNamed:IMG_CHECKKBOX_S];
        }
    }
    else
    {
        cell.imageView.image = nil;
    }

    return cell;
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!m_isEditing)
    {
        return;
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    DiaryPage *page = [m_superBook getSheetByIndex:indexPath.row];
    if (nil == [m_selectedItems objectForKey:page.date])
    {
        cell.imageView.image = [UIImage imageNamed:IMG_CHECKKBOX_S];
        
        [m_selectedItems setObject:page forKey:page.date];
    }
    else
    {
        cell.imageView.image = [UIImage imageNamed:IMG_CHECKKBOX_DS];
        
        [m_selectedItems removeObjectForKey:page.date];
    }
}

#pragma mark - Action

- (IBAction)onToggleEditMode:(id)sender
{
    m_isEditing = YES;
    self.m_iboEditBtn.hidden = YES;
    self.m_iboBottomBar.hidden = NO;
    
    [self.m_iboDiaryList reloadData];
}

- (IBAction)onSelectAll:(id)sender
{
    [m_selectedItems removeAllObjects];

    NSString *image = [NSString string];
    NSString *title = [sender titleForState:UIControlStateNormal];
    if ([title isEqualToString:[AppData getString:@"allslect"]/*LOCALSTR_SELECT_ALL*/])
    {
        [m_selectedItems addEntriesFromDictionary:m_superBook.diaryList];
        //获取对应的文字信息 
        title = [AppData getString:@"cancelslect"]/*LOCALSTR_DESELECT_ALL*/;
        image = IMG_EDIT_DESELECT_ALL;
    }
    else
    {
        title = [AppData getString:@"allslect"]/*LOCALSTR_SELECT_ALL*/;
        image = IMG_EDIT_SELECT_ALL;
    }

    [sender setTitle:title forState:UIControlStateNormal];
    [self.m_iboSelectState setImage:[UIImage imageNamed:image]];

    [self.m_iboDiaryList reloadData];
}

- (IBAction)onRemoveAll:(id)sender
{
    // 提示删除
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LOCALSTR_ALERT_DEL
                                                    message:LOCALSTR_DEL_ALL_SHEETS_TIPS
                                                   delegate:self
                                          cancelButtonTitle:LOCALSTR_CANCEL
                                          otherButtonTitles:LOCALSTR_DELETE, nil];
    // 标识待删除对象
    alert.tag = ALERT_REMOVE_ALL;
    [alert show];
}

- (IBAction)onDeleteItems:(id)sender
{
    // 提示删除
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[AppData getString:@"delete"]/*LOCALSTR_ALERT_DEL*/
                                                    message:[AppData getString:@"deletecurrennotes"]/*LOCALSTR_DEL_SHEETS_TIPS*/
                                                   delegate:self
                                          cancelButtonTitle:[AppData getString:@"cancel"]/*LOCALSTR_CANCEL*/
                                          otherButtonTitles:[AppData getString:@"delete"]/*LOCALSTR_DELETE*/, nil];
    // 标识待删除对象
    alert.tag = ALERT_DEL_SELECTED;
    [alert show];
}

#pragma mark - UIAlertView Delegate
// 响应警告框事件
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    // 取消
    if (buttonIndex == alertView.cancelButtonIndex)
    {
        return;
    }
    
    switch (alertView.tag)
    {
        case ALERT_REMOVE_ALL:
            
            [m_superBook.diaryList removeAllObjects];
            break;
            
        case ALERT_DEL_SELECTED:
            
            for (DiaryPage *obj in [m_selectedItems allValues])
            {
                [m_superBook delDiarySheet:obj];
            }
            break;
            
        default:
            break;
    }
    
    [m_selectedItems removeAllObjects];
    [self.m_iboDiaryList reloadData];

    // 记录到配置文件
    [AppData saveDiaryBook:m_superBook forUser:[UserList sharedInstance].currentKid.name];
}

@end