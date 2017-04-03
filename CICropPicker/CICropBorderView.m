//
//  PCICropBorderView.m
//  CICropView
//
//  Created by Erika Perugachi on 8/24/2015.
//  Copyright (c) 2015 Criptext INC. All rights reserved.
//

#import "CICropBorderView.h"

#define kNumberOfBorderHandles 8
#define kHandleDiameter 24
#define kStrokeCorner 2.0f

@interface CICropBorderView()

@property UIColor *cornerColor;
@property float dx;
@property float dy;

-(NSMutableArray*)_calculateAllNeededHandleRects;

@end

@implementation CICropBorderView

- (id)initWithFrame:(CGRect)frame borderX:(float)dx borderY:(float)dy {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.cornerColor = [UIColor colorWithHue:210.0f / 360.0f saturation:0.94f brightness:1.0f alpha:1.0f];
        self.dx = dx;
        self.dy = dy;
    }
    return self;
}

#pragma mark -
#pragma drawing
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect{
    // Drawing code
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRed:1. green:1. blue:1. alpha:1].CGColor);
    CGContextSetLineWidth(ctx, 1.0f);
    CGContextAddRect(ctx, CGRectMake(self.dx, self.dy, rect.size.width-self.dx*2, rect.size.height-self.dy*2));
    CGContextStrokePath(ctx);
    
    NSMutableArray* handleRectArray = [self _calculateAllNeededHandleRects];
    for (NSValue* value in handleRectArray){
        CGRect currentHandleRect = [value CGRectValue];
        CGContextSetStrokeColorWithColor(ctx, self.cornerColor.CGColor);
        CGContextSetLineWidth(ctx, kStrokeCorner);
        CGContextAddRect(ctx,currentHandleRect);
        CGContextStrokePath(ctx);
    }
}


#pragma mark -
#pragma private
-(NSMutableArray*)_calculateAllNeededHandleRects{
    
    NSMutableArray* a = [NSMutableArray new];
    //starting with the upper left corner and then following clockwise
    CGRect verticalFrame, horizontalFrame;
    verticalFrame = (CGRect){self.dx-kStrokeCorner,self.dy-kStrokeCorner,kStrokeCorner,kHandleDiameter};
    horizontalFrame = (CGRect){self.dx-kStrokeCorner,self.dy-kStrokeCorner,kHandleDiameter,kStrokeCorner};
    [a addObject:[NSValue valueWithCGRect:verticalFrame]];
    [a addObject:[NSValue valueWithCGRect:horizontalFrame]];
    
    verticalFrame = (CGRect){self.frame.size.width-self.dx,self.dy-kStrokeCorner,kStrokeCorner,kHandleDiameter};
    horizontalFrame = (CGRect){self.frame.size.width-self.dx-kHandleDiameter,self.dy-kStrokeCorner,kHandleDiameter,kStrokeCorner};
    [a addObject:[NSValue valueWithCGRect:verticalFrame]];
    [a addObject:[NSValue valueWithCGRect:horizontalFrame]];
    
    verticalFrame = (CGRect){self.frame.size.width-self.dx,self.frame.size.height-self.dy-kHandleDiameter+kStrokeCorner,kStrokeCorner,kHandleDiameter};
    horizontalFrame = (CGRect){self.frame.size.width-self.dx-kHandleDiameter+kStrokeCorner,self.frame.size.height-self.dy,kHandleDiameter,kStrokeCorner};
    [a addObject:[NSValue valueWithCGRect:verticalFrame]];
    [a addObject:[NSValue valueWithCGRect:horizontalFrame]];
    
    verticalFrame = (CGRect){self.dx-kStrokeCorner,self.frame.size.height-self.dy-kHandleDiameter,kStrokeCorner,kHandleDiameter};
    horizontalFrame = (CGRect){self.dx-kStrokeCorner,self.frame.size.height-self.dy,kHandleDiameter,kStrokeCorner};
    [a addObject:[NSValue valueWithCGRect:verticalFrame]];
    [a addObject:[NSValue valueWithCGRect:horizontalFrame]];
    
    return a;
}

@end