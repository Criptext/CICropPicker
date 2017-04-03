//
//  CICropPicker.h
//  CICropView
//
//  Created by Erika Perugachi on 8/24/2015.
//  Copyright (c) 2015 Criptext INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    CIEditionImageMode = 0,
    CICircularProfileMode = 1
}ImagePickerMode;

typedef enum {
    ImageFromLibrary = 0,
    ImageFromCamera = 1
}ImageType;

@protocol CICropPickerDelegate;

@interface CICropPicker : NSObject

@property (nonatomic, weak) id<CICropPickerDelegate> delegate;
@property ImagePickerMode modeImagePicker;
@property (nonatomic, weak) UIViewController *presentingViewController;

- (id)initMode:(ImagePickerMode)mode;
- (void)showActionSheetOnViewController:(UIViewController *)viewController onPopoverFromView:(UIView *)popoverView;
- (void)presentGalleryPickerFrom:(UIViewController *)presenter;
- (void)presentCameraPickerFrom:(UIViewController *)presenter;
- (void)backController;
/**
 * @method scaleImage:resolution:
 * @param image  image to be modified
 * @param res    resolution to be downsized to
 *
 * @return imaged downsized
 *
 * @discussion
 * Handy method to downsize an image taken
 */
+ (UIImage *)scaleImage:(UIImage *)image resolution:(int)res;

@end

@protocol CICropPickerDelegate <NSObject>

@optional

/**
 * @method imagePicker:pickedImage:
 * @param imagePicker  the image picker instance
 * @param image        the picked and cropped image
 *
 * @discussion
 * Gets called when a user has chosen an image
 */
- (void)imagePicker:(UIImagePickerController *)imagePicker pickedImage:(UIImage *)image;


/**
 * @method imagePickerDidCancel:
 * @param imagePicker  the image picker instance
 * 
 * @discussion
 * Gets called when the user taps the cancel button
 */
- (void)imagePickerDidCancel:(UIImagePickerController *)imagePicker;

@end
