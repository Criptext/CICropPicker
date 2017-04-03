//
//  CICropOverlayView.h
//  CICropView
//
//  Created by Erika Perugachi on 8/24/2015.
//  Copyright (c) 2015 Criptext INC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CICropOverlayView : UIView

@property (nonatomic, assign) CGSize cropSize;
@property (nonatomic, strong) UIView* contentView;
@property (nonatomic, strong) UIImageView* imageView;

@end
