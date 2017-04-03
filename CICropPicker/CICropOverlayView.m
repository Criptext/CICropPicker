//
//  CICropOverlayView.m
//  CICropView
//
//  Created by Erika Perugachi on 8/24/2015.
//  Copyright (c) 2015 Criptext INC. All rights reserved.
//

#import "CICropOverlayView.h"

@interface CICropOverlayView ()

@end

@implementation CICropOverlayView

#pragma mark -
#pragma Getter/Setter

@synthesize cropSize;

#pragma mark -
#pragma Overriden

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

- (void)drawRect:(CGRect)rect{
    
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    
    CGFloat heightSpan = floor(height / 2 - self.cropSize.height / 2);
    CGFloat widthSpan = floor(width / 2 - self.cropSize.width  / 2);
    
    CGRect screenRect = CGRectMake(widthSpan, heightSpan, self.cropSize.width, self.cropSize.height);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor( context, [UIColor colorWithRed:22./255. green:22./255. blue:22./255. alpha:0.5].CGColor );
    CGContextFillRect( context, rect );
    
    CGRectIntersection( screenRect, rect );
    
    CGContextSetFillColorWithColor( context, [UIColor clearColor].CGColor );
    CGContextSetBlendMode(context, kCGBlendModeClear);
    
    CGContextFillEllipseInRect( context, screenRect );
    
    [self _addContentViews];
}

-(void)_addContentViews{
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.size.width / 2 - self.cropSize.width  / 2  , (self.bounds.size.height) / 2 - self.cropSize.height / 2 , self.cropSize.width, self.cropSize.height)];
    self.contentView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.contentView];
}

@end