//
//  BIYImageEditorViewController.h
//  BIYImageEditor
//
//  Created by mulberry on 2016. 4. 29..
//  Copyright © 2016년 bisolby. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BIYImageEditorDelegate <NSObject>

- (void)clipImageFromEditor:(UIImage *)clipImage;

@end

@interface BIYImageEditorViewController : UIViewController

@property (weak, nonatomic) id<BIYImageEditorDelegate> delegate;

@end
