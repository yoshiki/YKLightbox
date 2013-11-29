//
//  SampleViewController.m
//  YKLightboxDemo
//
//  Created by Yoshiki Kurihara on 2013/11/27.
//  Copyright (c) 2013年 Yoshiki Kurihara. All rights reserved.
//

#import "SampleViewController.h"

@interface SampleViewController ()

@property (nonatomic, strong) YKLightbox *lightbox;
@property (nonatomic, strong) UIButton *showButton;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation SampleViewController

- (void)loadView {
    [super loadView];
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];

    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];

    _lightbox = [[YKLightbox alloc] init];
    _lightbox.delegate = self;
    _lightbox.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Lightbox Demo";
    
//    _showButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    _showButton.titleLabel.font = [UIFont boldSystemFontOfSize:20.0f];
//    [_showButton setTitle:@"Show" forState:UIControlStateNormal];
//    [_showButton sizeToFit];
//    [_showButton addTarget:self action:@selector(imageDidTap:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:_showButton];
//    
//    CGRect showButtonFrame = _showButton.frame;
//    showButtonFrame.origin = CGPointMake(9.0f, 9.0f);
//    _showButton.frame = showButtonFrame;
}

#pragma mark - YKLightboxDelegate

- (void)lightbox:(YKLightbox *)lightbox willCloseAtIndex:(NSInteger)index {
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    SampleViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[SampleViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.delegate = self;
    }
    
    NSInteger index = indexPath.row % 3 + 1;
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"image%02d", index]];
    [cell setExpandableImage:image];
    
    cell.textLabel.text = [NSString stringWithFormat:@"Row %d", indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - SampleViewCellDelegate

- (void)imageDidTap:(SampleViewCell *)cell {
    CGPoint originPoint = [cell convertPoint:cell.expandableImageView.layer.position toView:self.view.window];
    [_lightbox showWithImage:cell.expandableImage originPoint:originPoint];
}

@end
