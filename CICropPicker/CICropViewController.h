//
//  CICropViewController.h
//  CICropView
//
//  Created by Erika Perugachi on 8/24/2015.
//  Copyright (c) 2015 Criptext INC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CICropPicker.h"
#import "CICropImageView.h"

#define HORIZONTAL_TEXT_PADDING 13.f

@protocol CICropViewControllerDelegate;

@interface CICropViewController : UIViewController{
    UIImage *_croppedImage;
}

@property (nonatomic, strong) UIImage *sourceImage;
@property int imageType;
@property int modeImagePicker;
@property (nonatomic, strong) id<CICropViewControllerDelegate> delegate;

@end

@protocol CICropViewControllerDelegate <NSObject>
@required

- (void)imageCropController:(CICropViewController *)imageCropController didFinishWithCroppedImage:(UIImage *)croppedImage;

@end