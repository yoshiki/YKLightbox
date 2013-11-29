//
//  SampleViewCell.m
//  YKLightboxDemo
//
//  Created by Yoshiki Kurihara on 2013/11/29.
//  Copyright (c) 2013年 Yoshiki Kurihara. All rights reserved.
//

#import "SampleViewCell.h"

@implementation SampleViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _expandableImageView = [[UIImageView alloc] initWithFrame:(CGRect){
            CGPointZero,
            44.0f, 44.0f,
        }];
        _expandableImageView.contentMode = UIViewContentModeScaleToFill;
        _expandableImageView.userInteractionEnabled = YES;
        [self addSubview:_expandableImageView];
        
        UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)];
        [_expandableImageView addGestureRecognizer:gr];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect textLabelFrame = self.textLabel.frame;
    textLabelFrame.origin.x = CGRectGetMaxX(_expandableImageView.frame) + 10.0f;
    self.textLabel.frame = textLabelFrame;
}

- (void)setExpandableImage:(UIImage *)expandableImage {
    _expandableImage = expandableImage;
    _expandableImageView.image = _expandableImage;
}

- (void)tapImage:(id)sender {
    if ([self.delegate respondsToSelector:@selector(imageDidTap:)]) {
        [self.delegate imageDidTap:self];
    }
}

@end
