//
//  ViewController.m
//  BIYImageEditor
//
//  Created by mulberry on 2016. 4. 29..
//  Copyright © 2016년 bisolby. All rights reserved.
//

#import "ViewController.h"
#import "BIYImageEditorViewController.h"

static NSString * const biyImageEditorSegue = @"showImageEditor";

@interface ViewController () <BIYImageEditorDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)thumbnailControlTapped:(UIControl *)sender
{
    [self performSegueWithIdentifier:biyImageEditorSegue sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:biyImageEditorSegue]) {
        BIYImageEditorViewController *imvc = segue.destinationViewController;
        imvc.delegate = self;
    }
}

#pragma mark - BIYImageEditorDelegate

- (void)clipImageFromEditor:(UIImage *)clipImage
{
    _thumbnailImageView.image = clipImage;
}

@end
