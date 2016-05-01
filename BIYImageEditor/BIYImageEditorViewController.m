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

@property (strong, nonatomic) UIImage *originalImage;
@property (strong, nonatomic) UIImageView *originalImageView;

@end

@implementation BIYImageEditorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _originalImage = [UIImage imageNamed:@"1.jpg"];
    _originalImageView = [UIImageView new];
    
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
    
    _areaView.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:.8f].CGColor;
    _areaView.layer.borderWidth = 2.f / [UIScreen mainScreen].scale;
    
    //
    CGFloat scaleToFit = 1.f;
    if (_originalImage.size.width > _originalImage.size.height)
    {
        scaleToFit = CGRectGetHeight(_areaView.frame) / _originalImage.size.height;
        
        CGRect originalImageViewFrame = _originalImageView.frame;
        originalImageViewFrame.size.width = _originalImage.size.width * scaleToFit;
        originalImageViewFrame.size.height = CGRectGetHeight(_areaView.frame);
        _originalImageView.frame = originalImageViewFrame;
    }
    else
    {
        scaleToFit = CGRectGetWidth(_areaView.frame) / _originalImage.size.width;
        
        CGRect originalImageViewFrame = _originalImageView.frame;
        originalImageViewFrame.size.width = CGRectGetHeight(_areaView.frame);
        originalImageViewFrame.size.height = _originalImage.size.height * scaleToFit;
        _originalImageView.frame = originalImageViewFrame;
    }
    
    _originalImageView.image = _originalImage;
    _originalImageView.center = _scrollView.center;
    _originalImageView.userInteractionEnabled = NO;
    
    [_scrollView addSubview:_originalImageView];
    
    _scrollView.contentSize = _originalImageView.bounds.size;
    
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
    
    CGRect originalImageViewFrame = _originalImageView.frame;
    originalImageViewFrame.origin.x = _scrollView.contentSize.width / 2.f - _originalImageView.frame.size.width / 2.f;
    originalImageViewFrame.origin.y = _scrollView.contentSize.height / 2.f - _originalImageView.frame.size.height / 2.f;
    _originalImageView.frame = originalImageViewFrame;
    
    if (_originalImage.size.width > _originalImage.size.height)
        [_scrollView setContentOffset:CGPointMake(CGRectGetWidth(_originalImageView.frame) / 2 - CGRectGetWidth(_areaView.frame) / 2, _scrollView.contentOffset.y)];
    else
        [_scrollView setContentOffset:CGPointMake(_scrollView.contentOffset.x, CGRectGetHeight(_originalImageView.frame) / 2 - CGRectGetHeight(_areaView.frame) / 2)];
    
    [self.view.layer addSublayer:[[UIImageView alloc] initWithImage:[self createMaskImage]].layer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - User Default Mathods

- (UIImage *)createMaskImage
{
    UIView *rectView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    rectView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    
    UIView *circleView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_areaView.frame) + 2.0,
                                                                  CGRectGetMinY(_areaView.frame) + 2.0,
                                                                  CGRectGetWidth(_areaView.frame) - 2.0,
                                                                  CGRectGetHeight(_areaView.frame) - 2.0)];
    circleView.layer.masksToBounds = YES;
    circleView.layer.cornerRadius = CGRectGetWidth(_areaView.frame) / 2.0;
    circleView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1.f];
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
    return _originalImageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
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

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    if (scrollView.zoomScale > maximumScale)
    {
        [scrollView setZoomScale:maximumScale animated:YES];
    }
}

@end
