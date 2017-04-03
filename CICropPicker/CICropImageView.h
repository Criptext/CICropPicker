//
//  CICropImageView.h
//  CICropView
//
//  Created by Erika Perugachi on 8/24/2015.
//  Copyright (c) 2015 Criptext INC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CICropPicker.h"
#import "CICropOverlayView.h"
#import "CICropResizeableOverlayView.h"

#define TOOLBAR_HEIGHT      44.f

@interface CICropImageView : UIView

@property (nonatomic, strong) UIImage *imageToCrop;
@property (nonatomic, assign) CGSize cropSize;
@property (nonatomic, assign) int modeImagePicker;
@property (nonatomic, assign) BOOL onResizeableCrop;
@property (nonatomic, strong) UIScrollView *scrollView;

- (UIImage *)croppedImage;
- (CGRect)imageViewFrameToCrop;
- (void)showCrop:(BOOL)value frame:(CGRect)frame;

@end