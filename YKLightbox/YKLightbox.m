//
//  YKLightbox.m
//  YKLightboxDemo
//
//  Created by Yoshiki Kurihara on 2013/11/27.
//  Copyright (c) 2013年 Yoshiki Kurihara. All rights reserved.
//

#import "YKLightbox.h"
#import "UIImage+ImageEffects.h"

@interface YKLightbox ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) CGPoint lastOrigin;
@property (nonatomic, assign) CGPoint lastMove;
@property (nonatomic, assign) CGFloat lastAngle;
@property (nonatomic, assign) CGPoint startOrigin;

@end

@implementation YKLightbox

#pragma mark - Public methods

- (id)init {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        _lastOrigin = CGPointZero;
        _lastMove = CGPointZero;
        _lastAngle = 0.0f;
        _startOrigin = CGPointZero;

        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]
                                                        initWithTarget:self
                                                        action:@selector(gestureAction:)];
        panGestureRecognizer.maximumNumberOfTouches = 1;
        [self addGestureRecognizer:panGestureRecognizer];
    }
    return self;
}

- (void)showWithImage:(UIImage *)image originPoint:(CGPoint)originPoint {
    UIImage *blurredScreen = [[self class] blurredScreenImage];
    UIImageView *blurredScreenView = [[UIImageView alloc] initWithImage:blurredScreen];
    [self insertSubview:blurredScreenView atIndex:0];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.delegate = self;
    _scrollView.minimumZoomScale = 1.0f;
    _scrollView.maximumZoomScale = 5.0f;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_scrollView];

    CGFloat imageViewHeight = self.bounds.size.width * image.size.height / image.size.width;
    _imageView = [[UIImageView alloc] initWithFrame:(CGRect){
        CGPointZero,
        self.bounds.size.width, imageViewHeight,
    }];
    _imageView.image = image;
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_scrollView addSubview:_imageView];
    
    _imageView.center = self.center;
    
    _scrollView.contentSize = _imageView.bounds.size;

    id appDelegate = [UIApplication sharedApplication].delegate;
    UIWindow *window = [appDelegate window];
    [window addSubview:self];
    
    CABasicAnimation *posAnim = [CABasicAnimation animationWithKeyPath:@"position"];
    posAnim.fromValue = [NSValue valueWithCGPoint:originPoint];
    posAnim.toValue = [NSValue valueWithCGPoint:self.center];
    
    CABasicAnimation *scaleAnim = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnim.fromValue = @(0.2f);
    scaleAnim.toValue = @(1.0f);

    CAAnimationGroup *showAnim = [CAAnimationGroup animation];
    showAnim.animations = @[ posAnim, scaleAnim ];
    showAnim.duration = 0.2f;
    showAnim.removedOnCompletion = YES;
    showAnim.fillMode = kCAFillModeForwards;
    
    [_imageView.layer addAnimation:showAnim forKey:@"showAnimation"];
}

- (void)hide {
    if ([self.delegate respondsToSelector:@selector(lightbox:willCloseAtIndex:)]) {
        [self.delegate lightbox:self willCloseAtIndex:0];
    }
    
    [_imageView.layer removeAllAnimations];
    [_imageView removeFromSuperview];
    [_scrollView removeFromSuperview];
    [self removeFromSuperview];
    
    if ([self.delegate respondsToSelector:@selector(lightbox:didCloseAtIndex:)]) {
        [self.delegate lightbox:self didCloseAtIndex:0];
    }
}

#pragma mark - Private methods

- (void)gestureAction:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:self];
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        _startOrigin = point;
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGFloat x = _lastMove.x;
        CGFloat y = _lastMove.y;
        CGFloat factor = 20.0f;
        CGAffineTransform transform = CGAffineTransformMakeTranslation(x * factor, y * factor);
        CGRect transformedRect = CGRectApplyAffineTransform(_imageView.frame, transform);
        if (CGRectIntersectsRect(self.frame, transformedRect)) {
            [UIView animateWithDuration:0.1f animations:^{
                _imageView.transform = CGAffineTransformIdentity;
                _imageView.center = self.center;
            }];
        } else {
            CAAnimationGroup *animGroup = [[self class] animationForTranslationWithDelegate:self tx:x ty:y factor:factor angle:_lastAngle];
            [_imageView.layer addAnimation:animGroup forKey:@"translationAnimation"];
        }
        _lastMove = CGPointZero;
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint move = CGPointMake(point.x - _lastOrigin.x, point.y - _lastOrigin.y);
        CGAffineTransform moveTransform = CGAffineTransformMakeTranslation(move.x, move.y);
        _imageView.transform = CGAffineTransformConcat(_imageView.transform, moveTransform);
        
        CGPoint imageViewCenter = CGPointMake(CGRectGetMidX(_imageView.layer.frame), CGRectGetMidY(_imageView.layer.frame));
        CGPoint origin = [[self class] originWithPoint:point center:imageViewCenter];

        CGFloat angle = [[self class] angleWithOriginPosition:origin initialPosition:_lastOrigin currentPosition:point];
        CGPoint rotateAnchorPoint = CGPointMake(point.x - imageViewCenter.x, point.y - imageViewCenter.y);
        CGAffineTransform transform = CGAffineTransformTranslate(_imageView.transform, rotateAnchorPoint.x, rotateAnchorPoint.y);
        transform = CGAffineTransformRotate(transform, angle);
        transform = CGAffineTransformTranslate(transform, -rotateAnchorPoint.x, -rotateAnchorPoint.y);
        
        _imageView.transform = transform;
        _lastMove = move;
        _lastAngle = angle;
    }
    _lastOrigin = point;
}

+ (CAAnimationGroup *)animationForTranslationWithDelegate:(id)deletete tx:(CGFloat)tx ty:(CGFloat)ty factor:(CGFloat)factor angle:(CGFloat)angle {
    CABasicAnimation *animX = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    animX.removedOnCompletion = YES;
    animX.toValue = @(tx * factor);
    CABasicAnimation *animY = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    animY.removedOnCompletion = YES;
    animY.toValue = @(ty * factor);
    CABasicAnimation *animRotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    animRotate.removedOnCompletion = YES;
    animRotate.toValue = @(angle * factor);
    CAAnimationGroup *animGroup = [CAAnimationGroup animation];
    animGroup.delegate = deletete;
    animGroup.duration = 0.5f;
    animGroup.animations = @[ animX, animY, animRotate ];
    animGroup.removedOnCompletion = NO;
    animGroup.fillMode = kCAFillModeForwards;
    return animGroup;
}

+ (CGPoint)originWithPoint:(CGPoint)point center:(CGPoint)center {
    CGFloat originX = ((point.x > center.x)
                       ? point.x - center.x
                       : center.x + point.x);
    CGFloat originY = ((point.y > center.y)
                       ? point.y - center.y
                       : center.y + point.y);
    CGPoint origin = CGPointMake(originX, originY);
    return origin;
}

+ (CGFloat)angleWithOriginPosition:(CGPoint)originPosition initialPosition:(CGPoint)initialPosition currentPosition:(CGPoint)currentPosition {
    CGFloat initialAngle = atan2(initialPosition.y - originPosition.y, initialPosition.x - originPosition.x);
    CGFloat currentAngle = atan2(currentPosition.y - originPosition.y, currentPosition.x - originPosition.x);
    return currentAngle - initialAngle;
}

+ (UIImage *)blurredScreenImage {
    id appDelegate = [UIApplication sharedApplication].delegate;
    UIWindow *window = [appDelegate window];
    UIGraphicsBeginImageContextWithOptions(window.bounds.size, NO, 0.0f);
    
    if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
    } else {
        [window.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIColor *tintColor = [UIColor colorWithWhite:0.0f alpha:0.3f];
    viewImage = [viewImage applyBlurWithRadius:1.0f tintColor:tintColor saturationDeltaFactor:1.8f maskImage:nil];

    UIGraphicsEndImageContext();

    return viewImage;
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (anim == [_imageView.layer animationForKey:@"translationAnimation"]) {
        [self hide];
    }
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return [[scrollView subviews] objectAtIndex:0];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGRect imageViewFrame = _imageView.frame;
    CGRect scrollViewBounds = _scrollView.bounds;
    
    imageViewFrame.origin = CGPointZero;
    if (CGRectGetWidth(imageViewFrame) < CGRectGetWidth(scrollViewBounds)) {
        imageViewFrame.origin.x = floor((CGRectGetWidth(scrollViewBounds) - CGRectGetWidth(imageViewFrame)) * 0.5f);
    }
    if (CGRectGetHeight(imageViewFrame) < CGRectGetHeight(scrollViewBounds)) {
        imageViewFrame.origin.y = floor((CGRectGetHeight(scrollViewBounds) - CGRectGetHeight(imageViewFrame)) * 0.5f);
    }
    
    _imageView.frame = imageViewFrame;
}

@end
