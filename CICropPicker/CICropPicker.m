//
//  CICropPicker.m
//  CICropView
//
//  Created by Erika Perugachi on 8/24/2015.
//  Copyright (c) 2015 Criptext INC. All rights reserved.
//

#import "CICropPicker.h"
#import "CICropViewController.h"

@interface CICropPicker ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, CICropViewControllerDelegate>
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property ImageType imageType;

@end

@implementation CICropPicker

#pragma mark -
#pragma mark Getter/Setter

@synthesize delegate, modeImagePicker;

#pragma mark -
#pragma mark Init Methods

- (id)initMode:(ImagePickerMode)mode{
    if (self = [super init]) {
        self.modeImagePicker = mode;
    }
    return self;
}

#pragma mark - Class Methods

+ (UIImage *)scaleImage:(UIImage *)image resolution:(int)res{
    
    int kMaxResolution = res; // Or whatever 1920 PEPA
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height_ = CGImageGetHeight(imgRef);
    CGSize imageSize = CGSizeMake(width, height_);
    
    //NSLog(@"w:%f, h:%f",width,height_);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height_);
    
    if (width > kMaxResolution || height_ > kMaxResolution) {
        CGFloat ratio = width/height_;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    
    //CGFloat scaleRatio = 1;
    
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height_, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height_);
    }
    
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height_), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageCopy;
}


# pragma mark -
# pragma mark Private Methods

#pragma mark -
#pragma mark UIImagePickerDelegate Methods

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    if ([self.delegate respondsToSelector:@selector(imagePickerDidCancel:)]) {
        [self.delegate imagePickerDidCancel:picker];
        return;
    }
    
    [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{

    CICropViewController *cropController = [[CICropViewController alloc] init];
    //cropController.view.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - 44);
    cropController.preferredContentSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - 44);
    cropController.imageType = self.imageType;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    cropController.preferredContentSize = picker.preferredContentSize;
#else
    cropController.contentSizeForViewInPopover = picker.contentSizeForViewInPopover;
#endif
    
    cropController.sourceImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    cropController.modeImagePicker = self.modeImagePicker;
    cropController.delegate = self;
    [picker pushViewController:cropController animated:YES];
}

#pragma mark -
#pragma GKImagePickerDelegate

- (void)imageCropController:(CICropViewController *)imageCropController didFinishWithCroppedImage:(UIImage *)croppedImage{
    
    if ([self.delegate respondsToSelector:@selector(imagePicker:pickedImage:)]) {
        [self.delegate imagePicker:self.imagePickerController pickedImage:croppedImage];
        return;
    }
    
    [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Action Sheet and Image Pickers

- (void)showActionSheetOnViewController:(UIViewController *)viewController onPopoverFromView:(UIView *)popoverView{
    self.presentingViewController = viewController;
    
    UIAlertController *alertcontroller= [UIAlertController alertControllerWithTitle:nil
                                                                            message:nil
                                                                     preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* pickPhoto = [UIAlertAction
                                actionWithTitle:NSLocalizedString(@"escogerFotoKey", @"")
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    [alertcontroller dismissViewControllerAnimated:YES completion:nil];
                                    [self presentGalleryPickerFrom:viewController];
                                }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:NSLocalizedString(@"cancelarKey", @"")
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction * action)
                             {
                                 [alertcontroller dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertAction* takePhoto = [UIAlertAction
                                    actionWithTitle:NSLocalizedString(@"tomarFotoKey", @"")
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        [alertcontroller dismissViewControllerAnimated:YES completion:nil];
                                        [self presentCameraPickerFrom:viewController];
                                    }];
        [alertcontroller addAction:takePhoto];
    }
    
    [alertcontroller addAction:pickPhoto];
    [alertcontroller addAction:cancel];
    
    alertcontroller.popoverPresentationController.sourceView = self.presentingViewController.view;
    alertcontroller.popoverPresentationController.sourceRect = popoverView.frame;
    [self.presentingViewController presentViewController:alertcontroller animated:YES completion:nil];
}

- (void)presentImagePickerController{
    self.imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.presentingViewController presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (void)presentCameraPickerFrom:(UIViewController *)presenter {
    self.presentingViewController = presenter;

#if TARGET_IPHONE_SIMULATOR
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Simulator" message:@"Camera not available." preferredStyle:UIAlertControllerStyleAlert];
    
    
    [self.presentingViewController presentViewController:alert animated:true completion:nil];
    
#elif TARGET_OS_IPHONE
    
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.imagePickerController.delegate = self;
    self.imagePickerController.allowsEditing = NO;
    self.imageType = ImageFromCamera;

    [self presentImagePickerController];
#endif

}

- (void)presentGalleryPickerFrom:(UIViewController *)presenter{
    self.presentingViewController = presenter;
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePickerController.delegate = self;
    self.imagePickerController.allowsEditing = NO;
    self.imageType = ImageFromLibrary;

    [self presentImagePickerController];
}

- (void)backController{
    [self.imagePickerController popViewControllerAnimated:YES];
    [self.imagePickerController popViewControllerAnimated:YES];
}

@end
