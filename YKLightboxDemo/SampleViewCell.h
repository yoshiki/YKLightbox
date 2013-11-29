//
//  SampleViewCell.h
//  YKLightboxDemo
//
//  Created by Yoshiki Kurihara on 2013/11/29.
//  Copyright (c) 2013年 Yoshiki Kurihara. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SampleViewCell;

@protocol SampleViewCellDelegate <NSObject>

- (void)imageDidTap:(SampleViewCell *)cell;

@end

@interface SampleViewCell : UITableViewCell

@property (unsafe_unretained) id<SampleViewCellDelegate> delegate;
@property (nonatomic, strong) UIImageView *expandableImageView;
@property (nonatomic, strong) UIImage *expandableImage;

@end
