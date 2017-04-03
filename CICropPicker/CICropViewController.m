//
//  CICropViewController.m
//  CICropView
//
//  Created by Erika Perugachi on 8/24/2015.
//  Copyright (c) 2015 Criptext INC. All rights reserved.
//

#import "CICropViewController.h"

@interface CICropViewController ()

@property (nonatomic, strong) CICropImageView *imageCropView;
@property (nonatomic, strong) UIView *toolbarView;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *trashButton;
@property (nonatomic, strong) UIButton *cropButton;
@property (nonatomic, strong) UIButton *useButton;
@property (nonatomic, strong) NSMutableArray *buttonsArray;

- (void)_setupCropView;
- (void)_setupToolbar;
- (void)_actionCancel;
- (void)_actionUse;

@end

@implementation CICropViewController

@synthesize sourceImage, delegate;
@synthesize imageCropView;
@synthesize cancelButton, useButton, imageType, modeImagePicker;

#pragma mark - Super Class Methods

- (id)init{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    
    [self _setupCropView];
    [self _setupToolbar];
    
//    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidUnload{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Private Methods

- (void)_setupCropView{
    float height = [[UIScreen mainScreen] bounds].size.height - TOOLBAR_HEIGHT + [[UIScreen mainScreen] bounds].origin.y;

    self.imageCropView = [[CICropImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, height)];
    self.imageCropView.modeImagePicker = self.modeImagePicker;
    [self.imageCropView setImageToCrop:self.sourceImage];
    
    switch (self.modeImagePicker) {
        case CIEditionImageMode:{
            [self.imageCropView setCropSize:[self normalizedCropSizeForRect:self.imageCropView.imageViewFrameToCrop]];
            break;
        }
        case CICircularProfileMode:{
            [self.imageCropView setCropSize:CGSizeMake([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.width)];
            break;
        }
        default:
            break;
    }
    self.imageCropView.clipsToBounds = YES;
    [self.view addSubview:self.imageCropView];
    
    
}

- (void)_setupToolbar{
    
    float yPosition = self.view.bounds.size.height - TOOLBAR_HEIGHT;
    
    if ([UIApplication sharedApplication].statusBarFrame.size.height == 0) {
        yPosition -= 20;
    }else if([UIApplication sharedApplication].statusBarFrame.size.height == 40){
        yPosition += 20;
    }
    self.toolbarView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                self.imageCropView.frame.size.height,
                                                                self.view.frame.size.width,
                                                                TOOLBAR_HEIGHT)];
    self.toolbarView.backgroundColor = [UIColor colorWithRed:23./255. green:23./255. blue:23./255. alpha:1.];
    [self.view addSubview:self.toolbarView];
    
    [self _setupCancelButton];
    [self _setupUseButton];
    
    [self.toolbarView addSubview:self.cancelButton];
    [self.toolbarView addSubview:self.useButton];
    
    if (self.modeImagePicker == CIEditionImageMode){
        [self _setupTrashButton];
        [self _setupCropButton];
        
        [self.toolbarView addSubview:self.trashButton];
        [self.toolbarView addSubview:self.cropButton];
    }
}


- (void)_setupCancelButton{
    CGSize buttonSize = [self sizeForString:NSLocalizedString(@"cancel", @"")
                                   withFont:[self buttonFont]];
    
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [[self.cancelButton titleLabel] setFont:[self buttonFont]];
    [self.cancelButton setFrame:CGRectMake(HORIZONTAL_TEXT_PADDING, 0, buttonSize.width, buttonSize.height)];
    [self.cancelButton setTitle:NSLocalizedString(@"cancel", @"") forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.cancelButton  addTarget:self action:@selector(_actionCancel) forControlEvents:UIControlEventTouchUpInside];
}

- (void)_setupUseButton{
    CGSize buttonSize = [self sizeForString:NSLocalizedString(@"use",@"")
                                   withFont:[self buttonFont]];
    
    self.useButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [[self.useButton titleLabel] setFont:[self buttonFont]];
    [self.useButton setFrame:CGRectMake(self.view.frame.size.width - (buttonSize.width + HORIZONTAL_TEXT_PADDING), 0, buttonSize.width, buttonSize.height)];
    [self.useButton setTitle:NSLocalizedString(@"use",@"") forState:UIControlStateNormal];
    [self.useButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.useButton  addTarget:self action:@selector(_actionUse) forControlEvents:UIControlEventTouchUpInside];
}

- (void)_setupTrashButton{
    NSBundle * bundle = [NSBundle bundleForClass:[CICropPicker class]];
    
    CGSize buttonSize = CGSizeMake(TOOLBAR_HEIGHT - 4, TOOLBAR_HEIGHT - 4);
    
    self.trashButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.trashButton setImage:[UIImage imageNamed:@"icon_trash" inBundle:bundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.trashButton setFrame:CGRectMake(HORIZONTAL_TEXT_PADDING+self.cancelButton.bounds.size.width+((self.view.frame.size.width-HORIZONTAL_TEXT_PADDING-self.cancelButton.bounds.size.width-self.useButton.bounds.size.width-HORIZONTAL_TEXT_PADDING-(2*buttonSize.width))/3), 2, buttonSize.width, buttonSize.height)];
    [self.trashButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.trashButton  addTarget:self action:@selector(_actionTrash) forControlEvents:UIControlEventTouchUpInside];
}

- (void)_setupCropButton{
    NSBundle * bundle = [NSBundle bundleForClass:[CICropPicker class]];
    
    CGSize buttonSize = CGSizeMake(TOOLBAR_HEIGHT - 4, TOOLBAR_HEIGHT - 4);
    
    self.cropButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    
    [self.cropButton setImage:[[UIImage imageNamed:@"icon_crop" inBundle:bundle compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.cropButton setFrame:CGRectMake(self.view.frame.size.width-HORIZONTAL_TEXT_PADDING-self.useButton.bounds.size.width-((self.view.frame.size.width-HORIZONTAL_TEXT_PADDING-self.cancelButton.bounds.size.width-self.useButton.bounds.size.width-HORIZONTAL_TEXT_PADDING-(2*buttonSize.width))/3)-buttonSize.width, 2, buttonSize.width, buttonSize.height)];
    [self.cropButton  addTarget:self action:@selector(_actionCrop) forControlEvents:UIControlEventTouchUpInside];
    [self.cropButton setTintColor:[UIColor whiteColor]];
}

- (UIFont *)buttonFont{
    return  [UIFont systemFontOfSize:16.f];
}

- (CGSize)sizeForString:(NSString *)string withFont:(UIFont *)font{
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    attributes[NSFontAttributeName] = font;
    
    CGSize constrainedSize = CGSizeMake(self.view.frame.size.width, TOOLBAR_HEIGHT);
    CGSize neededSize = CGSizeMake(0, 0);
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    neededSize = [string boundingRectWithSize:constrainedSize
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:attributes
                                      context:nil].size;
#else
    neededSize = [string sizeWithFont:font
                    constrainedToSize:constrainedSize
                        lineBreakMode:NSLineBreakByTruncatingMiddle];
#endif
    return CGSizeMake(neededSize.width, TOOLBAR_HEIGHT);
}

- (void)_actionCancel{
    if (self.imageCropView.onResizeableCrop) {
        self.imageCropView.onResizeableCrop = !self.imageCropView.onResizeableCrop;
        [self.imageCropView showCrop:self.imageCropView.onResizeableCrop frame:self.imageCropView.imageViewFrameToCrop];
        [self.trashButton setEnabled:!self.imageCropView.onResizeableCrop];
        [self.cropButton setTintColor:[UIColor whiteColor]];
    }else if(self.imageType == ImageFromLibrary){
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)_actionTrash{
    if(self.imageType == ImageFromLibrary){
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)_actionCrop{
    self.imageCropView.onResizeableCrop = !self.imageCropView.onResizeableCrop;
    [self.imageCropView showCrop:self.imageCropView.onResizeableCrop frame:self.imageCropView.imageViewFrameToCrop];
    [self.trashButton setEnabled:!self.imageCropView.onResizeableCrop];
    if (self.imageCropView.onResizeableCrop) {
        [self.cropButton setTintColor:[UIColor colorWithHue:210.0f / 360.0f saturation:0.94f brightness:1.0f alpha:1.0f]];
    }else{
        [self.cropButton setTintColor:[UIColor whiteColor]];
    }
}

- (void)_actionUse{
    if (self.imageCropView.onResizeableCrop || self.modeImagePicker == CICircularProfileMode) {
        _croppedImage = [self.imageCropView croppedImage];
        [self.delegate imageCropController:self didFinishWithCroppedImage:_croppedImage];
    }else{
        [self.delegate imageCropController:self didFinishWithCroppedImage:sourceImage];
    }
}

#pragma mark - Crop Rect Normalizing

- (CGSize)normalizedCropSizeForRect:(CGRect)rect{
    CGSize normalizedSize = CGSizeMake(rect.size.width, rect.size.height);
    return normalizedSize;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
