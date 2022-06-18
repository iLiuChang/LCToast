//
//  UIView+LCToast.m
//  LCToast (https://github.com/iLiuChang/LCToast)
//
//  Created by 刘畅 on 2022/6/7.
//  Copyright © 2022 LiuChang. All rights reserved.
//

#import "UIView+LCToast.h"
#import <objc/runtime.h>

@interface LCToastWrapper : UIView
@property (copy, nonatomic) NSString *message;
@property (assign, nonatomic) LCToastPosition position;
@property (strong, nonatomic) NSTimer *timer;
@property (weak, nonatomic) UIView *imageView;

@end
@implementation LCToastWrapper
- (instancetype)initWithMessage:(NSString *)message imageView:(UIView *)imageView viewSize:(CGSize)viewSize
{
    self = [super init];
    if (self) {
        if (message == nil && imageView == nil) return self;

        _message = message;
        LCToastStyle *style = [LCToastManager sharedManager].sharedStyle;

        UILabel *messageLabel = nil;
        self.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
        self.layer.cornerRadius = style.cornerRadius;
        
        if (style.shadow) {
            self.layer.shadowColor = style.shadow.shadowColor.CGColor;
            self.layer.shadowOpacity = style.shadow.shadowOpacity;
            self.layer.shadowRadius = style.shadow.shadowRadius;
            self.layer.shadowOffset = style.shadow.shadowOffset;
        }
        
        self.backgroundColor = style.backgroundColor;
        
        if (message != nil) {
            messageLabel = [[UILabel alloc] init];
            messageLabel.numberOfLines = style.messageNumberOfLines;
            messageLabel.font = style.messageFont;
            messageLabel.textAlignment = style.messageAlignment;
            messageLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            messageLabel.textColor = style.messageColor;
            messageLabel.backgroundColor = [UIColor clearColor];
            messageLabel.alpha = 1.0;
            messageLabel.text = message;
            
            CGSize maxSizeMessage = CGSizeMake(viewSize.width * style.maxWidthPercentage, (viewSize.height * style.maxHeightPercentage) - style.imageSize.height);

            CGSize expectedSizeMessage = [messageLabel sizeThatFits:maxSizeMessage];
            // UILabel can return a size larger than the max size when the number of lines is 1
            expectedSizeMessage = CGSizeMake(MIN(maxSizeMessage.width, expectedSizeMessage.width), MIN(maxSizeMessage.height, expectedSizeMessage.height));
            messageLabel.frame = CGRectMake(0.0, style.verticalSpacing, expectedSizeMessage.width, expectedSizeMessage.height);
        }
       
        CGFloat wrapperWidth = MAX((imageView.frame.size.width + (style.horizontalSpacing * 2.0)), (messageLabel.frame.size.width + style.horizontalSpacing * 2.0));
        CGFloat wrapperHeight = style.verticalSpacing * 2.0 + imageView.frame.size.height + messageLabel.frame.size.height;
        if (imageView && messageLabel) {
            wrapperHeight += style.messageSpacing;
        }
        self.frame = CGRectMake(0.0, 0.0, wrapperWidth, wrapperHeight);
        
        if(imageView != nil) {
            CGPoint center = imageView.center;
            center.x = wrapperWidth/2.0;
            imageView.center = center;
            [self addSubview:imageView];
            self.imageView = imageView;
        }
        
        if(messageLabel != nil) {
            CGPoint center = messageLabel.center;
            center.x = wrapperWidth/2.0;
            messageLabel.center = center;
            if (imageView) {
                CGRect frame = messageLabel.frame;
                frame.origin.y = CGRectGetMaxY(imageView.frame) + style.messageSpacing;
                messageLabel.frame = frame;
            }
            [self addSubview:messageLabel];
        }
    }
    return self;
}

@end

@interface UIView (ToastHelper)
@end
@implementation UIView (ToastHelper)
- (CGPoint)centerPointForPosition:(LCToastPosition)position withToast:(UIView *)toast {
    LCToastStyle *style = [LCToastManager sharedManager].sharedStyle;
    
    UIEdgeInsets safeInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        safeInsets = self.safeAreaInsets;
    }
    
    CGFloat topPadding = style.verticalSpacing + safeInsets.top;
    CGFloat bottomPadding = style.verticalSpacing + safeInsets.bottom;
    switch (position) {
        case LCToastPositionTop:
            return CGPointMake(self.bounds.size.width / 2.0, (toast.frame.size.height / 2.0) + topPadding);

        case LCToastPositionCenter:
            return CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0);
        default:
            return CGPointMake(self.bounds.size.width / 2.0, (self.bounds.size.height - (toast.frame.size.height / 2.0)) - bottomPadding);
    }
}

- (NSTimeInterval)displayDurationForString:(NSString*)string {
    CGFloat minimum = MAX((CGFloat)string.length * 0.06 + 0.5, [LCToastManager sharedManager].minimumDismissTimeInterval);
    return MIN(minimum, [LCToastManager sharedManager].maximumDismissTimeInterval);
}
@end

@implementation UIView (LCToast)

- (void)lc_showToastWithMessage:(NSString *)message {
    [self lc_showToastWithMessage:message image:nil position:LCToastManager.sharedManager.position];
}

- (void)lc_showToastWithMessage:(NSString *)message position:(LCToastPosition)position {
    [self lc_showToastWithMessage:message image:nil position:position];
}

- (void)lc_showToastWithMessage:(NSString *)message image:(UIImage *)image position:(LCToastPosition)position {
    if (LCToastManager.sharedManager.dismissLoadingWhenToastShown) {
        [self lc_dismissLoading];
    }

    if (!message && !image) return;

    UIImageView *imageView;
    if(image) {
        LCToastStyle *style = [LCToastManager sharedManager].sharedStyle;
        imageView = [[UIImageView alloc] initWithImage:image];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.frame = CGRectMake(0, style.verticalSpacing, style.imageSize.width, style.imageSize.height);
    }
    LCToastWrapper *toast = [[LCToastWrapper alloc] initWithMessage:message imageView:imageView viewSize:self.bounds.size];
    toast.position = position;
    if ([LCToastManager sharedManager].toastQueueEnabled) {
        if ([self.activeToasts count] > 0) {
            [self.activeToasts addObject:toast];
        } else {
            [self showToastWithWrapper:toast];
        }
    } else {
        [self lc_dismissAllToasts];
        [self showToastWithWrapper:toast];
    }
}

- (void)lc_dismissToast {
    [self removeToastWrapper:[[self activeToasts] firstObject]];
}

- (void)lc_dismissAllToasts {
    for (LCToastWrapper *toast in [self activeToasts]) {
        [toast.timer invalidate];
        toast.timer = nil;
        [toast removeFromSuperview];
    }
    [[self activeToasts] removeAllObjects];
}

- (void)lc_dismissAllPopups {
    [self lc_dismissAllToasts];
    [self lc_dismissLoading];
    [self lc_dismissProgress];
}

- (void)showToastWithWrapper:(LCToastWrapper *)toast {
    NSTimeInterval duration = [self displayDurationForString:toast.message];
    LCToastPosition position = toast.position;
    toast.center = [self centerPointForPosition:position withToast:toast];
    toast.alpha = 0.0;
    
    if ([LCToastManager sharedManager].tapToDismissEnabled) {
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleToastTapped:)];
        [toast addGestureRecognizer:recognizer];
        toast.userInteractionEnabled = YES;
        toast.exclusiveTouch = YES;
    }
    
    [[self activeToasts] addObject:toast];
    
    [self addSubview:toast];
    
    [UIView animateWithDuration:[[LCToastManager sharedManager].sharedStyle fadeDuration]
                          delay:0.0
                        options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         toast.alpha = 1.0;
                     } completion:^(BOOL finished) {
                         NSTimer *timer = [NSTimer timerWithTimeInterval:duration target:self selector:@selector(toastTimerDidFinish:) userInfo:toast repeats:NO];
                         [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
                         toast.timer = timer;
                     }];
}

- (void)removeToastWrapper:(LCToastWrapper *)toast {
    if (!toast) {
        return;
    }
    [toast.timer invalidate];
    toast.timer = nil;
    
    [UIView animateWithDuration:[[LCToastManager sharedManager].sharedStyle fadeDuration]
                          delay:0.0
                        options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)
                     animations:^{
                         toast.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         [toast removeFromSuperview];
                         // remove
                         [[self activeToasts] removeObject:toast];
                         if ([self.activeToasts count] > 0) {
                             LCToastWrapper *nextToast = [[self activeToasts] firstObject];
                             [self showToastWithWrapper:nextToast];
                         }
                     }];
}

#pragma mark - Storage

static const NSString * LCToastActiveKey = @"LCToastActiveKey";
- (NSMutableArray *)activeToasts {
    NSMutableArray *activeToasts = objc_getAssociatedObject(self, &LCToastActiveKey);
    if (activeToasts == nil) {
        activeToasts = [[NSMutableArray alloc] init];
        objc_setAssociatedObject(self, &LCToastActiveKey, activeToasts, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return activeToasts;
}

#pragma mark - Events

- (void)toastTimerDidFinish:(NSTimer *)timer {
    [self removeToastWrapper:(LCToastWrapper *)timer.userInfo];
}

- (void)handleToastTapped:(UITapGestureRecognizer *)recognizer {
    LCToastWrapper *toast = (LCToastWrapper *)recognizer.view;
    [toast.timer invalidate];
    toast.timer = nil;
    [self removeToastWrapper:toast];
}

@end

#pragma mark - Activity-Loading
static const NSString * LCActivityLoadingViewKey      = @"LCToastActivityViewKey";
static const NSString * LCActivityLoadingDisabledViewKey      = @"LCToastActivityDisabledViewKey";
@implementation UIView (LCActivityLoading)

- (void)lc_showLoading {
    [self lc_showLoadingWithMessage:nil position:LCToastManager.sharedManager.position disabled:NO];
}

- (void)lc_showLoadingWithMessage:(NSString *)message {
    [self lc_showLoadingWithMessage:message position:LCToastManager.sharedManager.position disabled:NO];
}

- (void)lc_showDisabledLoading {
    [self lc_showLoadingWithMessage:nil position:LCToastManager.sharedManager.position disabled:YES];
}

- (void)lc_showDisabledLoadingWithMessage:(NSString *)message {
    [self lc_showLoadingWithMessage:message position:LCToastManager.sharedManager.position disabled:YES];
}

- (void)lc_showLoadingWithMessage:(NSString *)message position:(LCToastPosition)position disabled:(BOOL)disabled {
    UIView *existingActivityView = (UIView *)objc_getAssociatedObject(self, &LCActivityLoadingViewKey);
    if (existingActivityView != nil) {
        return;
    }
    
    if (disabled) {
        UIView *disabledView = objc_getAssociatedObject(self, &LCActivityLoadingDisabledViewKey);
        if (disabledView) {
            [disabledView removeFromSuperview];
        }
        disabledView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:disabledView];
        objc_setAssociatedObject(self, &LCActivityLoadingDisabledViewKey, disabledView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    LCToastStyle *style = [LCToastManager sharedManager].sharedStyle;
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style.activityIndicatorViewStyle];
    CGRect frame = activityIndicatorView.frame;
    frame.origin.y = style.verticalSpacing;
    if (!message) {
        frame.size = style.activitySize;
    }
    activityIndicatorView.frame = frame;
    [activityIndicatorView startAnimating];
    LCToastWrapper *activityView = [[LCToastWrapper alloc] initWithMessage:message imageView:activityIndicatorView viewSize:self.bounds.size];
    activityView.center = [self centerPointForPosition:position withToast:activityView];
    [self addSubview:activityView];
    objc_setAssociatedObject (self, &LCActivityLoadingViewKey, activityView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (!disabled && [LCToastManager sharedManager].tapToDismissEnabled) {
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lc_dismissLoading)];
        [activityView addGestureRecognizer:recognizer];
        activityView.userInteractionEnabled = YES;
        activityView.exclusiveTouch = YES;
    }
    
    activityView.alpha = 0.0;
    [UIView animateWithDuration:style.fadeDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         activityView.alpha = 1.0;
                     } completion:nil];
   
}

- (void)lc_dismissLoading {
    UIView *existingActivityView = (UIView *)objc_getAssociatedObject(self, &LCActivityLoadingViewKey);
    if (existingActivityView != nil) {
        [UIView animateWithDuration:[[LCToastManager sharedManager].sharedStyle fadeDuration]
                              delay:0.0
                            options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)
                         animations:^{
                             existingActivityView.alpha = 0.0;
                         } completion:^(BOOL finished) {
                             [existingActivityView removeFromSuperview];
                             objc_setAssociatedObject (self, &LCActivityLoadingViewKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                             
                             UIView *disabledView = objc_getAssociatedObject(self, &LCActivityLoadingDisabledViewKey);
                             if (disabledView) {
                                 [disabledView removeFromSuperview];
                                 objc_setAssociatedObject(self, &LCActivityLoadingDisabledViewKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                             }
                         }];
    }
}

@end

#pragma mark - Activity-Progress

static const NSString * LCActivityProgressViewKey = @"LCActivityProgressViewKey";
@implementation UIView (LCActivityProgress)

- (void)lc_showProgress:(CGFloat)progress {
    [self lc_showProgress:progress message:nil position:LCToastManager.sharedManager.position];
}

- (void)lc_showProgress:(CGFloat)progress message:(NSString *)message {
    [self lc_showProgress:progress message:message position:LCToastManager.sharedManager.position];
}

- (void)lc_showProgress:(CGFloat)progress message:(NSString *)message position:(LCToastPosition)position {
    UIView *existingActivityView = (UIView *)objc_getAssociatedObject(self, &LCActivityProgressViewKey);
    if (existingActivityView) {
        UIProgressView *progressView = (UIProgressView *)((LCToastWrapper *)existingActivityView).imageView;
        [progressView setProgress:progress animated:YES];
        return;
    }
    
    LCToastStyle *style = [LCToastManager sharedManager].sharedStyle;
    UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, style.verticalSpacing, self.frame.size.width * style.maxWidthPercentage - style.horizontalSpacing*2, 5)];
    progressView.userInteractionEnabled = NO;
    if (style.progressColor) {
        progressView.progressTintColor = style.progressColor;
    }
    if (style.progressTrackColor) {
        progressView.trackTintColor = style.progressTrackColor;
    }
    LCToastWrapper *activityView = [[LCToastWrapper alloc] initWithMessage:message imageView:progressView viewSize:self.bounds.size];
    activityView.center = [self centerPointForPosition:position withToast:activityView];
    [self addSubview:activityView];
    objc_setAssociatedObject (self, &LCActivityProgressViewKey, activityView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [progressView setProgress:progress animated:YES];
    activityView.alpha = 0.0;
    [UIView animateWithDuration:style.fadeDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         activityView.alpha = 1.0;
                     } completion:nil];
}

- (void)lc_dismissProgress {
    UIView *existingActivityView = (UIView *)objc_getAssociatedObject(self, &LCActivityProgressViewKey);
    if (existingActivityView != nil) {
        [UIView animateWithDuration:[[LCToastManager sharedManager].sharedStyle fadeDuration]
                              delay:0.0
                            options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)
                         animations:^{
                             existingActivityView.alpha = 0.0;
                         } completion:^(BOOL finished) {
                             [existingActivityView removeFromSuperview];
                             objc_setAssociatedObject (self, &LCActivityProgressViewKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                         }];
    }
}

@end
