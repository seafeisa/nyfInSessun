//
//  PhotoPickerView.m
//  grow
//
//  Created by admin on 15-6-10.
//  Copyright (c) 2015年 senssun. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "PhotoPickerView.h"

enum
{
    ACTION_PICKPHOTO = 0,
    ACTION_USECAMERA,
    
    ACTION_BTNID_BUTT
};

@implementation PhotoPickerView

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.delegate = nil;
}

- (UIViewController *)viewController
{
//    NSLog(@"54");
    for (UIView* next = [self superview]; next; next = next.superview)
    {
        UIResponder *nextResponder = [next nextResponder];
        
        if ([nextResponder isKindOfClass:[UIViewController class]])
        {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

- (void)showInView:(UIView *)view
{
    if (nil == view)
    {
        return;
    }
    
    [view addSubview:self];
    
    [self showActionSheet];
}

- (void)showActionSheet
{
    //提示
    //获取对应的文字信息
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:[AppData getString:@"cancel"]/*LOCALSTR_CANCEL*/
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:[AppData getString:@"select in album"]/*LOCALSTR_FROM_ALBUMS*/, [AppData getString:@"takephto"]/*LOCALSTR_TAKE_PHOTOS*/, nil];
    [choiceSheet showInView:self];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    // 设置相机支持的图像类型，图片
    imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    
    // 指定使用图像模式，相机/图片库/相册
    //imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    // 设置相机支持的图像类型，图片/录像
    //imagePicker.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
    
    BOOL shouldPresentImagePicker = NO;
    switch (buttonIndex)
    {
            // 从相册中选取
        case ACTION_PICKPHOTO:
            if (![self isAlbumAuthorized])
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[AppData getString:@"noprivacyauthorized"]/*LOCALSTR_PRIVACY_UNAUTHORIZED*/
                                                                message:[AppData getString:@"noaccess toset"]/*LOCALSTR_PHOTOS_PRIVACY_TIPS*/
                                                               delegate:self
                                                      cancelButtonTitle:[AppData getString:@"confirm"]/*LOCALSTR_CONFIRM*/
                                                      otherButtonTitles:nil, nil];
                [alert show];
                break;
            }
            
            if ([self isPhotoLibraryAvailable])
            {
                shouldPresentImagePicker = YES;
                // 使用图片库模式
                imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            }
            break;
            
            // 拍照
        case ACTION_USECAMERA:
            if (![self isCameraAuthorized])
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[AppData getString:@"noprivacyauthorized"]/*LOCALSTR_PRIVACY_UNAUTHORIZED*/
                                                                message:[AppData getString:@"noaccess tosetting"]/*LOCALSTR_CAMERA_PRIVACY_TIPS*/
                                                               delegate:self
                                                      cancelButtonTitle:[AppData getString:@"confirm"]/*LOCALSTR_CONFIRM*/
                                                      otherButtonTitles:nil, nil];
                [alert show];
                break;
            }
            
            if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos])
            {
                shouldPresentImagePicker = YES;
                // 使用相机模式
                imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                // 注意：含cameraXXX的属性需sourceType是UIImagePickerControllerSourceTypeCamera才有效，否则会有异常
                // 设置显示/隐藏拍照工具栏
                //imagePicker.showsCameraControls = YES;
                // 设置图像选定后是否进入编辑模式进行图片裁剪。只有当 showsCameraControls = YES 时生效
                //imagePicker.allowsEditing = YES;
                // 选择前置/后置摄像头
                //imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
                // 设置闪光灯模式
                //imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
                // 拍摄时旋转、缩放
                //imagePicker.cameraViewTransform = CGAffineTransformMakeRotation(M_PI*45/180);   // 旋转45度
                //imagePicker.cameraViewTransform = CGAffineTransformMakeScale(1.5, 1.5);
            }
            break;
            
        default:
            break;
            //return;
    }
    
    if (!shouldPresentImagePicker)
    {
        return;
    }
    
    UIViewController *vc = [self viewController];
    if (nil != vc)
    {
        [self setHeaderStyle:UIStatusBarStyleDefault];
        
        [vc presentViewController:imagePicker animated:NO completion:^(void){}];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:NO
                               completion:^()
     {
         //NSString *type      = [info objectForKey:UIImagePickerControllerMediaType];
         //UIImage  *edit      = [info objectForKey:UIImagePickerControllerEditedImage];
         //UIImage  *crop      = [info objectForKey:UIImagePickerControllerCropRect];
         //NSURL    *url       = [info objectForKey:UIImagePickerControllerMediaURL];
         //UIImage  *orig      = [info objectForKey:UIImagePickerControllerOriginalImage];
         UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
         image = [self imageByScalingToMaxSize:image];
         
         UIViewController *vc = [self viewController];
         if (nil != vc)
         {
             // 裁剪
             CGRect cropRect = CGRectMake(0, (vc.view.frame.size.height - vc.view.frame.size.width) / 2, vc.view.frame.size.width, vc.view.frame.size.width);
             VPImageCropperViewController *cropper = [[VPImageCropperViewController alloc] initWithImage:image cropFrame:cropRect limitScaleRatio:3.0];
             cropper.delegate = self;
             
             [vc presentViewController:cropper animated:NO completion:^{}];
         }
         
         //         if ([self.delegate respondsToSelector:@selector(photoPickerView:didFinishPickingWithImage:)])
         //         {
         //             [self.delegate photoPickerView:self didFinishPickingWithImage:image];
         //         }
     }];
    
    [self setHeaderStyle:UIStatusBarStyleLightContent];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:NO
                               completion:^()
     {
         if ([self.delegate respondsToSelector:@selector(photoPickerDidCancel)])
         {
             [self.delegate photoPickerDidCancel];
         }
     }];
    
    [self setHeaderStyle:UIStatusBarStyleLightContent];
}

#pragma mark - VPImageCropperDelegate
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage
{
    [cropperViewController dismissViewControllerAnimated:NO
                                              completion:^()
     {
         if ([self.delegate respondsToSelector:@selector(photoPickerView:didFinishPickingWithImage:)])
         {
             [self.delegate photoPickerView:self didFinishPickingWithImage:editedImage];
         }
     }];
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController
{
    [cropperViewController dismissViewControllerAnimated:NO completion:^()
     {
     }];
}

#pragma mark - ImageScale utility
- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage
{
    CGFloat ORIGINAL_MAX_WIDTH = SCREEN_WIDTH_PIXELS;
    if (sourceImage.size.width <= ORIGINAL_MAX_WIDTH)
    {
        return sourceImage;
    }
    
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height)
    {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    }
    else
    {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize
{
    UIImage *newImage = nil;
    CGSize  imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
        {
            scaleFactor = widthFactor; // scale to fit height
        }
        else
        {
            scaleFactor = heightFactor; // scale to fit width
        }
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
    {
        dbgLog(@"could not scale image");
    }
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - Camera utility
- (BOOL)isCameraAuthorized
{
    // 当前应用的相机隐私设置是否授权
    BOOL isAuthorized = YES;
    
    if (isIOS7Later)
    {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        //if (AVAuthorizationStatusAuthorized != status)
        if ((AVAuthorizationStatusRestricted == status) || (AVAuthorizationStatusDenied == status))
        {
            isAuthorized = NO;
        }
    }
    
    return isAuthorized;
}

- (BOOL)isAlbumAuthorized
{
    // 当前应用的照片隐私设置是否授权
    BOOL isAuthorized = YES;
    
    if (isIOS6Later)
    {
        ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
        //if (ALAuthorizationStatusAuthorized != status)
        if ((ALAuthorizationStatusRestricted == status) || (ALAuthorizationStatusDenied == status))
        {
            isAuthorized = NO;
        }
    }
    
    return isAuthorized;
}

- (BOOL) isCameraAvailable
{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isPhotoLibraryAvailable
{
    return [UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) doesCameraSupportTakingPhotos
{
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType
{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop)
     {
         NSString *mediaType = (NSString *)obj;
         if ([mediaType isEqualToString:paramMediaType])
         {
             result = YES;
             *stop= YES;
         }
     }];
    
    return result;
}

- (void)setHeaderStyle:(UIStatusBarStyle)style
{
    //    UIStatusBarStyle barStyle = UIStatusBarStyleLightContent;
    //    UIColor *color = [UIColor whiteColor];
    //
    //    if (UIStatusBarStyleLightContent != style)
    //    {
    //        barStyle = UIStatusBarStyleDefault;
    //        color    = [UIColor blackColor];
    //    }
    
    // 设置状态栏风格
    [[UIApplication sharedApplication] setStatusBarStyle:style];
    
    //    // 设置导航栏标题字体颜色
    //    [[UINavigationBar appearance] setTitleTextAttributes:
    //     [NSDictionary dictionaryWithObjectsAndKeys:color, NSForegroundColorAttributeName, nil]
    //     ];
    //
    //    // 设置导航栏按钮区
    //    [[UINavigationBar appearance] setTintColor:color];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
