//
//  CICropResizeableOverlayView.h
//  CICropView
//
//  Created by Erika Perugachi on 8/24/2015.
//  Copyright (c) 2015 Criptext INC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CICropBorderView.h"
#import "CICropOverlayView.h"

typedef struct {
    int widhtMultiplyer;
    int heightMultiplyer;
    int xMultiplyer;
    int yMultiplyer;
}GKResizeableViewBorderMultiplyer;

@interface CICropResizeableOverlayView : CICropOverlayView

@property (nonatomic, strong) UIView* contentView;
@property (nonatomic, strong, readonly) CICropBorderView *cropBorderView;
@property BOOL isCropping;

/**
 call this method to create a resizable crop view
 @param frame frame
 @param contentSize initial crop size
 @return crop view instance
 */
-(id)initWithFrame:(CGRect)frame andInitialContentSize:(CGSize)contentSize borderX:(float)dx borderY:(float)dy;
-(void)drawPointsToCrop:(BOOL)value;

@end
