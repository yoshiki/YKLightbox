//
//  YKLightbox.h
//  YKLightboxDemo
//
//  Created by Yoshiki Kurihara on 2013/11/27.
//  Copyright (c) 2013年 Yoshiki Kurihara. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YKLightbox;

@protocol YKLightboxDelegate <NSObject>

@optional
- (void)lightbox:(YKLightbox *)lightbox willCloseAtIndex:(NSInteger)index;
- (void)lightbox:(YKLightbox *)lightbox didCloseAtIndex:(NSInteger)index;

@end

@interface YKLightbox : UIView

@property (unsafe_unretained) id<YKLightboxDelegate> delegate;
@property (nonatomic, strong) UIImage *image;

- (void)showWithImage:(UIImage *)image originPoint:(CGPoint)originPoint;
- (void)hide;

@end
