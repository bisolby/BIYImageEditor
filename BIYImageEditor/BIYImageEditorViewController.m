//
//  BIYImageEditorViewController.m
//  BIYImageEditor
//
//  Created by mulberry on 2016. 4. 29..
//  Copyright © 2016년 bisolby. All rights reserved.
//

#import "BIYImageEditorViewController.h"

static CGFloat maximumScale = 10.f;

@interface BIYImageEditorViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *areaView;

@property (strong, nonatomic) UIImageView *imageView;

@property (strong, nonatomic) UIImage *originalImage;

@end

@implementation BIYImageEditorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _originalImage = [UIImage imageNamed:@"5.jpg"];
    
    _imageView = [UIImageView new];
    [_scrollView addSubview:_imageView];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _scrollView.minimumZoomScale = 1;
    _scrollView.maximumZoomScale = 100;
    
    _areaView.userInteractionEnabled = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _areaView.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:1.f].CGColor;
    _areaView.layer.borderWidth = 2.f / [UIScreen mainScreen].scale;
    
    [self configureImageView];
    _scrollView.contentSize = _imageView.bounds.size;
    [self configureContentSizeOfScrollView];
    [self configureCenterOfScrollView];
    
    [self.view.layer addSublayer:[[UIImageView alloc] initWithImage:[self createMaskImage]].layer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Configure Objects

- (void)configureImageView
{
    CGFloat scaleToFit = 1.f;
    if ((_originalImage.size.width / _originalImage.size.height) > CGRectGetWidth(_areaView.frame) / CGRectGetHeight(_areaView.frame)) {
        scaleToFit = _originalImage.size.height / CGRectGetHeight(_areaView.frame);
        
        CGRect imageViewFrame = _imageView.frame;
        imageViewFrame.origin.x = _areaView.frame.origin.x;
        imageViewFrame.origin.y = _areaView.frame.origin.y;
        imageViewFrame.size.width = _originalImage.size.width / scaleToFit;
        imageViewFrame.size.height = CGRectGetHeight(_areaView.frame);
        _imageView.frame = imageViewFrame;
    }
    else {
        scaleToFit = _originalImage.size.width / CGRectGetWidth(_areaView.frame);
        
        CGRect imageViewFrame = _imageView.frame;
        imageViewFrame.origin.x = _areaView.frame.origin.x;
        imageViewFrame.origin.y = _areaView.frame.origin.y;
        imageViewFrame.size.width = CGRectGetWidth(_areaView.frame);
        imageViewFrame.size.height = _originalImage.size.height / scaleToFit;
        _imageView.frame = imageViewFrame;
    }
    
    _imageView.image = _originalImage;
    _imageView.userInteractionEnabled = NO;
}

- (void)configureContentSizeOfScrollView
{
    CGFloat overWidth = _scrollView.contentSize.width - _areaView.frame.size.width;
    if (overWidth > 0)
        [_scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width + overWidth, _scrollView.contentSize.height)];
    else
        [_scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width, _scrollView.contentSize.height)];
    
    CGFloat overHeight = _scrollView.contentSize.height - _areaView.frame.size.height;
    if (overHeight > 0)
        [_scrollView setContentSize:CGSizeMake(_scrollView.contentSize.width, _scrollView.frame.size.height + overHeight)];
    else
        [_scrollView setContentSize:CGSizeMake(_scrollView.contentSize.width, _scrollView.frame.size.height)];
}

- (void)configureCenterOfScrollView
{
    [_scrollView setContentOffset:CGPointMake(CGRectGetWidth(_imageView.frame)/2 - CGRectGetWidth(_areaView.frame)/2,
                                              CGRectGetHeight(_imageView.frame)/2 - CGRectGetHeight(_areaView.frame)/2)];
}

#pragma mark - User Default Mathods

- (UIImage *)createMaskImage
{
    UIView *rectView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    rectView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    
    UIView *circleView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_areaView.frame) + 1.0,
                                                                  CGRectGetMinY(_areaView.frame) + 1.0,
                                                                  CGRectGetWidth(_areaView.frame) - 2.0,
                                                                  CGRectGetHeight(_areaView.frame) - 2.0)];
    circleView.layer.masksToBounds = YES;
    circleView.layer.cornerRadius = 0.f; //CGRectGetWidth(_areaView.frame) / 2.0;
    circleView.backgroundColor = [UIColor whiteColor];
    circleView.center = rectView.center;
    
    [rectView addSubview:circleView];

    UIGraphicsBeginImageContextWithOptions([UIScreen mainScreen].bounds.size, false, 0.0);
    [rectView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *maskImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRef masked = CGImageCreateWithMask(maskImage.CGImage, CGImageMaskCreate(CGImageGetWidth(maskImage.CGImage),
                                                                                   CGImageGetHeight(maskImage.CGImage),
                                                                                   CGImageGetBitsPerComponent(maskImage.CGImage),
                                                                                   CGImageGetBitsPerPixel(maskImage.CGImage),
                                                                                   CGImageGetBytesPerRow(maskImage.CGImage),
                                                                                   CGImageGetDataProvider(maskImage.CGImage), nil, false));
    
    UIImage *image = [[UIImage alloc] initWithCGImage:masked scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    
    return image;
}

- (UIImage *)clipImage
{
    UIGraphicsBeginImageContextWithOptions([UIScreen mainScreen].bounds.size, false, 0.0);
    
//    self.imageView.hidden = YES;
    
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
//    self.imageView.hidden = NO;
    
    UIImage *baseImage = UIGraphicsGetImageFromCurrentImageContext();
    CGFloat scale = [UIScreen mainScreen].scale;
    CGRect rect = CGRectMake(CGRectGetMinX(_areaView.frame) * scale,
                             CGRectGetMinY(_areaView.frame) * scale,
                             CGRectGetWidth(_areaView.frame) * scale,
                             CGRectGetHeight(_areaView.frame) * scale);
    CGImageRef clipImage = CGImageCreateWithImageInRect(baseImage.CGImage, rect);
    
    UIGraphicsEndImageContext();
    
    return [[UIImage alloc] initWithCGImage:clipImage];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self configureContentSizeOfScrollView];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    if (scrollView.zoomScale > maximumScale)
    {
        [scrollView setZoomScale:maximumScale animated:YES];
    }
}

@end
