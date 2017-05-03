//
//  CommonDef.h
//  ChildGrowth
//
//  Created by admin on 14-10-22.
//  Copyright (c) 2014年 camry. All rights reserved.
//


#ifndef __ChildGrowth_CommonDef_h__
#define __ChildGrowth_CommonDef_h__

/************************************/
#pragma mark - LOG

#if (1 == DEBUG)
    #define dbgLog(format, ...) NSLog(@"[%@:%d]%@", [@__FILE__ lastPathComponent], __LINE__, [NSString stringWithFormat:format, ## __VA_ARGS__])
#else
    #define dbgLog(format, ...)
#endif

/************************************/
#pragma mark - Size

#define SCREEN_WIDTH  ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define SCREEN_WIDTH_PIXELS  ([UIScreen mainScreen].bounds.size.width * [UIScreen mainScreen].scale)
#define SCREEN_HEIGHT_PIXELS ([UIScreen mainScreen].bounds.size.height * [UIScreen mainScreen].scale)

#define PICKER_HEIGHT 216

#define ANIM_DURATION 0.2

#define isIOS6Later [[UIDevice currentDevice].systemVersion floatValue] >= 6.0
#define isIOS7Later [[UIDevice currentDevice].systemVersion floatValue] >= 7.0
#define isIOS8Later [[UIDevice currentDevice].systemVersion floatValue] >= 8.0

#define URL_ITUNES_SELF  @"https://itunes.apple.com/cn/app/senssun/id965683200"

/************************************/
#pragma mark - Enumeration

typedef enum
{
    ACCESS_MODE_QUERY,
    ACCESS_MODE_CREATE = 1,
    ACCESS_MODE_UPDATE,
    
    ACCESS_MODE_BUTT
} ENAccessMode;

#define DEV_SPEC_WEIGHT_MIN 1.0
#define DEV_SPEC_WEIGHT_MAX 25.0
#define DEV_SPEC_HEIGHT_MIN 46.0
#define DEV_SPEC_HEIGHT_MAX 80.0
#define DEV_SPEC_HEADCL_MIN 31.0
#define DEV_SPEC_HEADCL_MAX 54.0
#define DEV_SPEC_HEIGHTLBOZ_MAX 31.5
#define DEV_SPEC_HEIGHTLBOZ_MIN 18.0
#define DEV_SPEC_HEADCLLBOZ_MAX 21.3
#define DEV_SPEC_HEADCLLBOZ_MIN 12.0
//const float DEV_SPEC_WEIGHT_MIN = 1.0;
//const float DEV_SPEC_WEIGHT_MAX = 25.0;
//const float DEV_SPEC_HEIGHT_MIN = 46.0;
//const float DEV_SPEC_HEIGHT_MAX = 80.0;
//const float DEV_SPEC_HEADCL_MIN = 31.0;
//const float DEV_SPEC_HEADCL_MAX = 54.0;

/************************************/
#pragma mark - Color

#define RGB(r, g, b)    [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]

#define COLOR_WEIGHT            RGB(0x99, 0xB6, 0xF0)
#define COLOR_HEIGHT            RGB(0x56, 0xBC, 0xAA)
#define COLOR_HEADCIRCLE        RGB(0x79, 0xC0, 0x6C)
#define COLOR_WEIGHT_FOR_HEIGHT RGB(0xF0, 0x9C, 0x16)
#define COLOR_DEFAULT_FONT      RGB(0x4D, 0x4D, 0x4D)
#define COLOR_THEME_PURPLE      RGB(0x8A, 0xA8, 0xE6)
#define COLOR_THEME_GREEN       RGB(0xA0, 0xCA, 0x3C)
#define COLOR_THEME_YELLOW      RGB(0xF8, 0xC3, 0x87)
//#define COLOR_WEIGHT            [UIColor colorWithRed:0x99/255.0 green:0xB6/255.0 blue:0xF0/255.0 alpha:1.0]
//#define COLOR_HEIGHT            [UIColor colorWithRed:0x56/255.0 green:0xBC/255.0 blue:0xAA/255.0 alpha:1.0]
//#define COLOR_HEADCIRCLE        [UIColor colorWithRed:0x79/255.0 green:0xC0/255.0 blue:0x6C/255.0 alpha:1.0]
//#define COLOR_WEIGHT_FOR_HEIGHT [UIColor colorWithRed:0xF0/255.0 green:0x9C/255.0 blue:0x16/255.0 alpha:1.0]
//#define COLOR_DEFAULT_FONT      [UIColor colorWithRed:0x4D/255.0 green:0x4D/255.0 blue:0x4D/255.0 alpha:1.0]
//#define COLOR_THEME_PURPLE      [UIColor colorWithRed:0x8A/255.0 green:0xA8/255.0 blue:0xE6/255.0 alpha:1.0]
//#define COLOR_THEME_GREEN       [UIColor colorWithRed:0xA0/255.0 green:0xCA/255.0 blue:0x3C/255.0 alpha:1.0]
//#define COLOR_THEME_YELLOW      [UIColor colorWithRed:0xF8/255.0 green:0xC3/255.0 blue:0x87/255.0 alpha:1.0]

/************************************/
#pragma mark - Segue

#define SEGUE_ADD_USER      @"addUser"
#define SEGUE_EDIT_USER     @"editUser"
#define SEGUE_SAVE_USERINFO @"saveUserinfo"
#define SEGUE_GOGOGO        @"startWorking"
#define SEGUE_ADD_RECORD    @"addRecord"
#define SEGUE_EDIT_RECORD   @"editRecord"
#define SEGUE_SAVE_RECORD   @"saveRecord"
#define SEGUE_ADD_COVER     @"addCover"
#define SEGUE_EDIT_COVER    @"editCover"
#define SEGUE_SAVE_COVER    @"saveCover"
#define SEGUE_ADD_DIARY_DIRECTLY    @"addDiaryDirectly"
#define SEGUE_EDIT_SHELF    @"editDiaryShelf"
#define SEGUE_OPEN_BOOK     @"openBook"
#define SEGUE_ADD_DIARY     @"addDiary"
#define SEGUE_EDIT_DIARY    @"editDiary"
#define SEGUE_SAVE_DIARY    @"saveDiary"
#define SEGUE_ZOOMIN_WFA    @"zoomInWFA"
#define SEGUE_ZOOMIN_HFA    @"zoomInHFA"
#define SEGUE_ZOOMIN_HCFA   @"zoomInHCFA"
#define SEGUE_ZOOMIN_WFH    @"zoomInWFH"

/************************************/
#pragma mark - Localize

#define LOCALSTR_YEAR          NSLocalizedString(@"Year", nil)
#define LOCALSTR_MONTH         NSLocalizedString(@"Month", nil)
#define LOCALSTR_DAY           NSLocalizedString(@"Day", nil)

#define LOCALSTR_TIME          NSLocalizedString(@"Time", nil)
#define LOCALSTR_WEIGHT        NSLocalizedString(@"Weight", nil)
#define LOCALSTR_HEIGHT        NSLocalizedString(@"Height", nil)
#define LOCALSTR_HEADCIRCLE    NSLocalizedString(@"HeadSize", nil)

#define LOCALSTR_CONFIRM       NSLocalizedString(@"Confirm", nil)
#define LOCALSTR_CANCEL        NSLocalizedString(@"Cancel", nil)
#define LOCALSTR_DELETE        NSLocalizedString(@"Delete", nil)
#define LOCALSTR_EDIT          NSLocalizedString(@"Edit", nil)
#define LOCALSTR_DONE          NSLocalizedString(@"Done", nil)
#define LOCALSTR_SELECT_ALL    NSLocalizedString(@"Select all", nil)
#define LOCALSTR_DESELECT_ALL  NSLocalizedString(@"Deselect all", nil)

#define LOCALSTR_FROM_ALBUMS   NSLocalizedString(@"Select from album", nil)
#define LOCALSTR_TAKE_PHOTOS   NSLocalizedString(@"Take photo", nil)

#define LOCALSTR_INFO_INCOMPLETE NSLocalizedString(@"profile incompelted", nil)
#define LOCALSTR_FILL_TIPS       NSLocalizedString(@"To ensure the profile should be complete, which will have effect on the final result.", nil)
#define LOCALSTR_FILL_BLANK      NSLocalizedString(@"Please enter comprehensive profile.", nil)

#define LOCALSTR_ALERT_DEL              NSLocalizedString(@"Delete", nil)
#define LOCALSTR_DEL_USER_TIPS          NSLocalizedString(@"Delete current users?", nil)
#define LOCALSTR_DEL_ALL_DIARYS_TIPS    NSLocalizedString(@"Delete all journals?", nil)
#define LOCALSTR_DEL_DIARYS_TIPS        NSLocalizedString(@"Delete current journals?", nil)
#define LOCALSTR_DEL_ALL_SHEETS_TIPS    NSLocalizedString(@"Delete all diaries in this month?", nil)
#define LOCALSTR_DEL_SHEETS_TIPS        NSLocalizedString(@"Delete current diaries?", nil)
#define LOCALSTR_CHANGE_COVERS          NSLocalizedString(@"Change cover", nil)
#define LOCALSTR_CHANGE_COVERS_TIPS     NSLocalizedString(@"Do you want to change the cover of current diaries?", nil)

#define LOCALSTR_PRIVACY_UNAUTHORIZED NSLocalizedString(@"Privacy unauthorized", nil)
#define LOCALSTR_PHOTOS_PRIVACY_TIPS  NSLocalizedString(@"BabyGrowing does not have access to your photos or video. To enable access, tap Settings and turn on Photos in privacy option.", nil)
#define LOCALSTR_CAMERA_PRIVACY_TIPS  NSLocalizedString(@"BabyGrowing does not have access to your camera. To enable access, tap Settings and turn on Camera in privacy option.", nil)
//#define LOCALSTR_PRIVACY_TIPS         NSLocalizedString(@"请在iPhone的“设置-隐私-相机”选项中，允许本应用访问您的相机。", nil)

#define LOCALSTR_RECORD_SAVED    NSLocalizedString(@"Record saved", nil)
#define LOCALSTR_INVALID_WEIGHT  NSLocalizedString(@"Invalid value, please measure again", nil)

#define LOCALSTR_SHARE_ERROR   NSLocalizedString(@"Share failed,", nil)

#define LOCALSTR_AGE_YEAR      NSLocalizedString(@"Year-old", nil)
#define LOCALSTR_AGE_MONTH     NSLocalizedString(@"month", nil)
#define LOCALSTR_AGE_MONTHS     NSLocalizedString(@"months", nil)
#define LOCALSTR_AGE_DAY       NSLocalizedString(@"Days", nil)

#define LOCALSTR_USRINFO_NICKNAME NSLocalizedString(@"Name", nil)
#define LOCALSTR_USRINFO_GENDER   NSLocalizedString(@"Gender", nil)
#define LOCALSTR_USRINFO_BIRTHDAY NSLocalizedString(@"Date of Birth", nil)
#define LOCALSTR_USRINFO_THEME    NSLocalizedString(@"Theme", nil)
#define LOCALSTR_USRINFO_DEVMSLOT NSLocalizedString(@"User No.", nil)

#define LOCALSTR_GENDER_GIRL   NSLocalizedString(@"Bady Girl", nil)
#define LOCALSTR_GENDER_BOY    NSLocalizedString(@"Baby Boy", nil)

#define LOCALSTR_THEME_PURPLE  NSLocalizedString(@"Purple", nil)
#define LOCALSTR_THEME_GREEN   NSLocalizedString(@"Green", nil)
#define LOCALSTR_THEME_YELLOW  NSLocalizedString(@"Yellow", nil)

#define LOCALSTR_DEVMEM_SLOT1  NSLocalizedString(@"User 1", nil)
#define LOCALSTR_DEVMEM_SLOT2  NSLocalizedString(@"User 2", nil)
#define LOCALSTR_DEVMEM_SLOT3  NSLocalizedString(@"User 3", nil)
#define LOCALSTR_DEVMEM_SLOT4  NSLocalizedString(@"User 4", nil)
#define LOCALSTR_DEVMEM_SLOT5  NSLocalizedString(@"User 5", nil)
#define LOCALSTR_DEVMEM_SLOT6  NSLocalizedString(@"User 6", nil)
#define LOCALSTR_DEVMEM_SLOT7  NSLocalizedString(@"User 7", nil)
#define LOCALSTR_DEVMEM_SLOT8  NSLocalizedString(@"User 8", nil)

#define LOCALSTR_DIARY_MONTH   NSLocalizedString(@"Select Month", nil)
#define LOCALSTR_DIARY_COVER   NSLocalizedString(@"Set cover", nil)

#define LOCALSTR_WEIGHT_FOR_AGE     NSLocalizedString(@"Weight-for-age", nil)
#define LOCALSTR_HEIGHT_FOR_AGE     NSLocalizedString(@"Height-for-age", nil)
#define LOCALSTR_HEADCIRCLE_FOR_AGE NSLocalizedString(@"Head size-for-age", nil)
#define LOCALSTR_WEIGHT_FOR_HEIGHT  NSLocalizedString(@"Weight-for-height", nil)
#define LOCALSTR_AGE_FOR_MONTH      NSLocalizedString(@"Months", nil)

#define LOCALSTR_DEV_MGR        NSLocalizedString(@"Devices", nil)
#define LOCALSTR_ABOUT          NSLocalizedString(@"About", nil)
#define LOCALSTR_VERSION        NSLocalizedString(@"Version", nil)
#define LOCALSTR_CHECK_VERSION  NSLocalizedString(@"Check new version", nil)
#define LOCALSTR_LATEST_VERSION NSLocalizedString(@"The latest version currently", nil)

#define LOCALSTR_SYNC_GOING     NSLocalizedString(@"Synching data...", nil)
#define LOCALSTR_SYNC_DONE      NSLocalizedString(@"Synched successfully", nil)
#define LOCALSTR_SYNC_FAIL      NSLocalizedString(@"Synchronization failed", nil)

#define LOCALSTR_DESC_BABY      NSLocalizedString(@"Baby is", nil)
#define LOCALSTR_DESC_LA        NSLocalizedString(@"!", nil)
#define LOCALSTR_DESC_WEIGHT    NSLocalizedString(@"Weight is", nil)
#define LOCALSTR_DESC_HEIGHT    NSLocalizedString(@"height is", nil)
#define LOCALSTR_DESC_HEADCRCL  NSLocalizedString(@"head size is", nil)
#define LOCALSTR_DESC_HEATHY    NSLocalizedString(@"growing heathily.", nil)
#define LOCALSTR_DESC_SLOW      NSLocalizedString(@"growing slower than usual.", nil)
#define LOCALSTR_DESC_FAST      NSLocalizedString(@"growing faster than usual.", nil)

#define LOCALSTR_PHOTO_SELECTED         NSLocalizedString(@"Selected", nil)
#define LOCALSTR_MULTI_PHOTOS           NSLocalizedString(@"photos", nil)
#define LOCALSTR_PHOTOS                 NSLocalizedString(@"Photos", nil)
#define LOCALSTR_PHOTOS_YEARS           NSLocalizedString(@"Years", nil)
#define LOCALSTR_PHOTOS_COLLECTIONS     NSLocalizedString(@"Collections", nil)
#define LOCALSTR_PHOTOS_MOMENTS         NSLocalizedString(@"Moments", nil)
#define LOCALSTR_ALBUMS                 NSLocalizedString(@"Albums", nil)
//#define LOCALSTR_ALBUMS_CAMERA_ROLL    NSLocalizedString(@"相机胶卷", nil)
//#define LOCALSTR_ALBUMS_RECENTLY_DELD  NSLocalizedString(@"最近删除", nil)
#define LOCALSTR_ALBUMS_CAMERA_ROLL     NSLocalizedString(@"Camera Roll", nil)
#define LOCALSTR_ALBUMS_RECENTLY_DELD   NSLocalizedString(@"Recently Deleted", nil)
#define LOCALSTR_ALBUMS_PHOTO_LIBRARY   NSLocalizedString(@"Photo Library", nil)

/************************************/
#pragma mark - Image filename

#define IMG_DEFAULT_BACKGROUNG  @"DefaultBackground.jpg"
#define IMG_DEFAULT_USERICON_L  @"DefaultUserImageBig.png"
#define IMG_DEFAULT_USERICON_S  @"DefaultUserImageSmall.png"
#define IMG_PROFILE_NAME        @"Name.png"
#define IMG_PROFILE_BIRTHDAY    @"Age.png"
#define IMG_PROFILE_GIRL        @"Woman.png"
#define IMG_PROFILE_BOY         @"Man.png"
#define IMG_PROFILE_THEME       @"Topic.png"
#define IMG_PROFILE_DEVMSLOT    @"LinkUserPhoneNumber.png"
#define IMG_BTN_HOME            @"HomePage.png"
#define IMG_BTN_HISTORY         @"History.png"
#define IMG_BTN_SHARE           @"Share.png"
#define IMG_BTN_ADDUSER         @"AddUser.png"
#define IMG_BTN_BACK            @"Return.png"
#define IMG_BTN_FORWARD         @"Advance.png"
#define IMG_BTN_DEL_DARK        @"Delete-Deep.png"
#define IMG_BTN_DEL_LIGHT       @"Delete-Shallow.png"
#define IMG_THEME_PURPLE        @"Topic-Purple.png"
#define IMG_THEME_GREEN         @"Topic-Green.png"
#define IMG_THEME_YELLOW        @"Topic-Yellow.png"
#define IMG_CAMARA              @"Camera.png"
#define IMG_COLOR_SEPARATOR     @"HeadPage-CutLine.png"
#define IMG_MEASURE             @"HeadPage-Measure.png"
#define IMG_GROWTH_DIARY        @"HeadPage-GrowthNotes.png"
#define IMG_USERS               @"HeadPage-User.png"
#define IMG_GROWTH_CURVE        @"HeadPage-GrowthCurve.png"
#define IMG_SETTINGS            @"HeadPage-Setting.png"
#define IMG_CHANGING_ARC        @"ChangeCircleLine.png"
#define IMG_SLIDER_INDICATOR    @"SliderInstruction.png"
#define IMG_TIPS                @"InformationPrompt.png"
#define IMG_ADD_PICTURE         @"AddPhoto.png"
#define IMG_LIST_SEPARATOR      @"ListCutLine.png"
#define IMG_QUIT                @"QuitButton.png"
#define IMG_UNBIND              @"UntieButton.png"
#define IMG_CANCEL              @"CancelButton.png"
#define IMG_BACKGROUND_PURPLE   @"Background-Purple.png"
#define IMG_BACKGROUND_GREEN    @"Background-Green.png"
#define IMG_BACKGROUND_YELLOW   @"Background-Yellow.png"
#define IMG_EDIT_SELECT_ALL     @"Editor-SelectAll.png"
#define IMG_EDIT_DESELECT_ALL   @"Editor-CancelSelectAll.png"
#define IMG_CHECKKBOX_SELECT    @"Editor-Select.png"
#define IMG_CHECKKBOX_DESELECT  @"Editor-NoSelect.png"
#define IMG_CHECKKBOX_S         @"Editor-SelectSmall.png"
#define IMG_CHECKKBOX_DS        @"Editor-NoSelectSmall.png"
#define IMG_SYCHRONIZE_DONE     @"DataSynDone.png"
#define IMG_SYCHRONIZE_FAIL     @"DataSynFail.png"
#define IMG_SYCHRONIZE_GOING    @"DataSynWorking.png"


#endif /* defined(__ChildGrowth_CommonDef_h__) */
