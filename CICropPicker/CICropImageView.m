//
//  CICropImageView.m
//  CICropView
//
//  Created by Erika Perugachi on 8/24/2015.
//  Copyright (c) 2015 Criptext INC. All rights reserved.
//

#import "CICropImageView.h"

#import <QuartzCore/QuartzCore.h>

#define rad(angle) ((angle) / 180.0 * M_PI)
#define padding 10

static CGRect GKScaleRect(CGRect rect, CGFloat scale){
	return CGRectMake(rect.origin.x * scale, rect.origin.y * scale, rect.size.width * scale, rect.size.height * scale);
}

@interface ScrollView : UIScrollView
@end

@implementation ScrollView

- (void)layoutSubviews{
    [super layoutSubviews];

    UIView *zoomView = [self.delegate viewForZoomingInScrollView:self];
    
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = zoomView.frame;
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    zoomView.frame = frameToCenter;
//    zoomView.frame = CGRectMake(0, 0, 200, 200);
}

@end

@interface CICropImageView ()<UIScrollViewDelegate>
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) CICropOverlayView *cropOverlayView;
@property (nonatomic, assign) CGFloat xOffset;
@property (nonatomic, assign) CGFloat yOffset;
@property (nonatomic, assign) CGRect imageViewFrame;

@property (nonatomic, assign) float dxZoomIn;
@property (nonatomic, assign) float dyZoomIn;

@property (nonatomic, strong) UIView *backgroundContainerView;

- (CGRect)_calcVisibleRectForResizeableCropArea;
- (CGRect)_calcVisibleRectForCropArea;
- (CGAffineTransform)_orientationTransformedRectOfImage:(UIImage *)image;

@end

@implementation CICropImageView

#pragma mark -
#pragma Getter/Setter

@synthesize scrollView, imageView, cropOverlayView, modeImagePicker, xOffset, yOffset;

- (void)setImageToCrop:(UIImage *)imageToCrop{
    
    float porView = self.scrollView.frame.size.width / self.scrollView.frame.size.height;
    float porImage = imageToCrop.size.width / imageToCrop.size.height;
    float resetImageW = 0;
    float resetImageH = 0;
    
    if (porView < 1) { // vertical screen
        switch (self.modeImagePicker) {
            case CIEditionImageMode:{
                self.scrollView.bounces = NO;
                if (porImage < 1 && porView > porImage) { // vertical image
                    resetImageH= self.scrollView.frame.size.height;
                    resetImageW = self.scrollView.frame.size.height * porImage;
                    self.dxZoomIn = padding * porImage;
                    self.dyZoomIn = padding;
                    
                }else{ // horizontal image
                    resetImageW = self.scrollView.frame.size.width;
                    resetImageH = self.scrollView.frame.size.width / porImage;
                    self.dxZoomIn = padding;
                    self.dyZoomIn = padding / porImage;
                }
                break;
            }
            case CICircularProfileMode:{
                resetImageW = self.scrollView.frame.size.width;
                resetImageH = self.scrollView.frame.size.width / porImage;
                self.dxZoomIn = 0;
                self.dyZoomIn = 0;
                break;
            }
            default:
                break;
        }
    }
    
    //CGRect frameImage = CGRectMake( (self.frame.size.width-resetImageW) / 2,0, resetImageW, resetImageH);
    CGRect frameImage = CGRectMake( (self.frame.size.width-resetImageW) / 2, (self.frame.size.height-resetImageH) / 2, resetImageW, resetImageH);

    self.imageViewFrame = frameImage;
    self.imageView.frame = frameImage;
    self.imageView.image = imageToCrop;
}

- (UIImage *)imageToCrop{
    return self.imageView.image;
}

- (CGRect)imageViewFrameToCrop{
    return self.imageViewFrame;
}

- (void)setCropSize:(CGSize)cropSize{
    if (self.cropOverlayView == nil){
        switch (self.modeImagePicker) {
            case CIEditionImageMode:{
                self.cropOverlayView = [[CICropResizeableOverlayView alloc] initWithFrame:self.frame andInitialContentSize:CGSizeMake(cropSize.width, cropSize.height) borderX:self.dxZoomIn borderY:self.dyZoomIn];
                break;
            }
            case CICircularProfileMode:{
                self.cropOverlayView = [[CICropOverlayView alloc] initWithFrame:self.frame];
                break;
            }
            default:
                break;
        }
        self.cropOverlayView.imageView = self.imageView;
        [self addSubview:self.cropOverlayView];
    }
    self.cropOverlayView.cropSize = cropSize;
}

- (CGSize)cropSize{
    return self.cropOverlayView.cropSize;
}

- (void)showCrop:(BOOL)value frame:(CGRect)frame{
    
    if (value) {
        [UIView animateWithDuration:0.7 animations:^{
            self.scrollView.zoomScale = 1.0f;
            self.imageView.frame = CGRectInset(frame, self.dxZoomIn, self.dyZoomIn);
        }];
        ((CICropResizeableOverlayView*)self.cropOverlayView).isCropping = true;
        [self.cropOverlayView setNeedsDisplay];
        [UIView transitionWithView:self.cropOverlayView duration:0.7 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
           [self.cropOverlayView.layer displayIfNeeded];
        } completion:nil];
    }else{
        [UIView animateWithDuration:0.7 animations:^{
            self.scrollView.zoomScale = 1.0f;
            [self.imageView setFrame:frame];
        }];
        ((CICropResizeableOverlayView*)self.cropOverlayView).isCropping = false;
        [self.cropOverlayView setNeedsDisplay];
        
        [UIView transitionWithView:self.cropOverlayView duration:0.7 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [self.cropOverlayView.layer displayIfNeeded];
        } completion:nil];
    }
    [(CICropResizeableOverlayView*)self.cropOverlayView drawPointsToCrop:value];
}

#pragma mark -
#pragma Public Methods

- (UIImage *)croppedImage{
    
    //Calculate rect that needs to be cropped
    CGRect visibleRect = self.onResizeableCrop ? [self _calcVisibleRectForResizeableCropArea] : [self _calcVisibleRectForCropArea];
    
    //transform visible rect to image orientation
    CGAffineTransform rectTransform = [self _orientationTransformedRectOfImage:self.imageToCrop];
    visibleRect = CGRectApplyAffineTransform(visibleRect, rectTransform);
    
    //finally crop image
    CGImageRef imageRef = CGImageCreateWithImageInRect([self.imageToCrop CGImage], visibleRect);
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:self.imageToCrop.scale orientation:self.imageToCrop.imageOrientation];
    CGImageRelease(imageRef);
    return result;
}

- (CGRect)_calcVisibleRectForResizeableCropArea{
    CICropResizeableOverlayView* resizeableView = (CICropResizeableOverlayView*)self.cropOverlayView;
    
    //first of all, get the size scale by taking a look at the real image dimensions. Here it doesn't matter if you take
    //the width or the hight of the image, because it will always be scaled in the exact same proportion of the real image
    CGFloat sizeScale = self.imageView.image.size.width / self.imageView.frame.size.width;
    sizeScale *= self.scrollView.zoomScale;
    
    //then get the postion of the cropping rect inside the image
    CGRect visibleRect = [resizeableView.contentView convertRect:resizeableView.contentView.bounds toView:imageView];
    return visibleRect = GKScaleRect(visibleRect, sizeScale);
}

-(CGRect)_calcVisibleRectForCropArea{
    CICropOverlayView* circleView = (CICropOverlayView*)self.cropOverlayView;
    
    CGFloat sizeScale = self.imageView.image.size.width / self.imageView.frame.size.width;
    sizeScale *= self.scrollView.zoomScale;
    
    //extract visible rect from scrollview and scale it
    CGRect visibleRect = [circleView.contentView convertRect:circleView.contentView.bounds toView:imageView];
    return visibleRect = GKScaleRect(visibleRect, sizeScale);
}

- (CGAffineTransform)_orientationTransformedRectOfImage:(UIImage *)img{
	CGAffineTransform rectTransform;
	switch (img.imageOrientation)
	{
		case UIImageOrientationLeft:
			rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(90)), 0, -img.size.height);
			break;
		case UIImageOrientationRight:
			rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-90)), -img.size.width, 0);
			break;
		case UIImageOrientationDown:
			rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-180)), -img.size.width, -img.size.height);
			break;
		default:
			rectTransform = CGAffineTransformIdentity;
	};
	
	return CGAffineTransformScale(rectTransform, img.scale, img.scale);
}

#pragma mark -
#pragma Override Methods

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {

        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor colorWithRed:22./255. green:22./255. blue:22./255. alpha:1.];
        self.scrollView = [[ScrollView alloc] initWithFrame:frame];
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.delegate = self;
        self.scrollView.clipsToBounds = NO;
        self.scrollView.decelerationRate = 0.0; 
        self.scrollView.backgroundColor = [UIColor colorWithRed:22./255. green:22./255. blue:22./255. alpha:1.];
        [self addSubview:self.scrollView];
        
        self.imageView = [[UIImageView alloc] initWithFrame:frame];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.backgroundColor = [UIColor colorWithRed:22./255. green:22./255. blue:22./255. alpha:1.];
        [self.scrollView addSubview:self.imageView];
        
        self.scrollView.minimumZoomScale = CGRectGetWidth(self.scrollView.frame) / CGRectGetWidth(self.imageView.frame);
        self.scrollView.maximumZoomScale = 20.0;
        [self.scrollView setZoomScale:1.0];
        
        self.onResizeableCrop = false;
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    if (self.modeImagePicker == CICircularProfileMode)
        return self.scrollView;

    CICropResizeableOverlayView* resizeableCropView = (CICropResizeableOverlayView*)self.cropOverlayView;
    
    CGRect outerFrame = CGRectInset(resizeableCropView.cropBorderView.frame, -10 , -10);
    if (CGRectContainsPoint(outerFrame, point)){
        
        if (resizeableCropView.cropBorderView.frame.size.width < 60 || resizeableCropView.cropBorderView.frame.size.height < 60 )
            return [super hitTest:point withEvent:event];
        
        CGRect innerTouchFrame = CGRectInset(resizeableCropView.cropBorderView.frame, 30, 30);
        if (CGRectContainsPoint(innerTouchFrame, point))
            return self.scrollView;
        
        CGRect outBorderTouchFrame = CGRectInset(resizeableCropView.cropBorderView.frame, -10, -10);
        if (CGRectContainsPoint(outBorderTouchFrame, point))
            return [super hitTest:point withEvent:event];
        
        return [super hitTest:point withEvent:event];
    }
    return self.scrollView;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    if (self.modeImagePicker == CICircularProfileMode) {
        CGSize size = self.cropSize;
        self.xOffset = floor((CGRectGetWidth(self.bounds) - size.width) * 0.5);
        self.yOffset = floor((CGRectGetHeight(self.bounds) - size.height) * 0.5); //fixed
        
        CGFloat height = self.imageToCrop.size.height;
        CGFloat width = self.imageToCrop.size.width;
        
        CGFloat factor = 0.f, widthFactor = 0.f, heightFactor = 0.f;
        CGFloat factoredHeight = 0.f;
        CGFloat factoredWidth = 0.f;
        
        widthFactor = width / size.width;
        heightFactor = height / size.height;
        factor = MIN(widthFactor, heightFactor);
        factoredWidth = width / factor;
        factoredHeight = height / factor;
        
        self.cropOverlayView.frame = self.bounds;
        self.scrollView.frame = CGRectMake(xOffset, yOffset, size.width, size.height);
        self.scrollView.contentSize = CGSizeMake(size.width, size.height);
        self.imageView.frame = CGRectMake(0, floor((size.height - factoredHeight) * 0.5), factoredWidth, factoredHeight);
        
        /* TODO
         implement a feature that allows restricting the zoom scale to the max available
         (based on image's resolution), to prevent pixelation. We simply have to deteremine the
         max zoom scale and place it here
         */
        [self.scrollView setContentOffset:CGPointMake((factoredWidth - size.width) * 0.5, (factoredHeight - size.height) * 0.5)];
    }
    
    [self.scrollView setZoomScale:1.0];
}

#pragma mark -
#pragma UIScrollViewDelegate Methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}

@end