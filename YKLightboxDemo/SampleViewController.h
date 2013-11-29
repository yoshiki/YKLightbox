//
//  SampleViewController.h
//  YKLightboxDemo
//
//  Created by Yoshiki Kurihara on 2013/11/27.
//  Copyright (c) 2013年 Yoshiki Kurihara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YKLightbox.h"
#import "SampleViewCell.h"

@interface SampleViewController : UIViewController <YKLightboxDelegate, UITableViewDelegate, UITableViewDataSource, SampleViewCellDelegate>

@end
