//
//  UIView+LCToast.m
//  LCToast (https://github.com/iLiuChang/LCToast)
//
//  Created by 刘畅 on 2022/6/7.
//  Copyright © 2022 LiuChang. All rights reserved.
//

#import "UIView+LCToast.h"
#import <objc/runtime.h>

static const NSString * LCToastTimerKey             = @"LCToastTimerKey";
static const NSString * LCToastActiveKey            = @"LCToastActiveKey";
static const NSString * LCToastQueueKey             = @"LCToastQueueKey";

@interface LCToastWrapper : UIView
@property (copy, nonatomic) NSString *message;
@property (assign, nonatomic) LCToastPosition position;
@end
@implementation LCToastWrapper
- (instancetype)initWithMessage:(NSString *)message image:(UIImage *)image style:(LCToastStyle *)style viewSize:(CGSize)viewSize
{
    self = [super init];
    if (self) {
        if (message == nil && image == nil) return self;

        _message = message;
        // default to the shared style
        if (style == nil) {
            style = [LCToastManager sharedManager].sharedStyle;
        }
        
        UILabel *messageLabel = nil;
        UIImageView *imageView = nil;
        
        self.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
        self.layer.cornerRadius = style.cornerRadius;
        
        if (style.shadow) {
            self.layer.shadowColor = style.shadow.shadowColor.CGColor;
            self.layer.shadowOpacity = style.shadow.shadowOpacity;
            self.layer.shadowRadius = style.shadow.shadowRadius;
            self.layer.shadowOffset = style.shadow.shadowOffset;
        }
        
        self.backgroundColor = style.backgroundColor;
        
        if(image != nil) {
            imageView = [[UIImageView alloc] initWithImage:image];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.frame = CGRectMake(0, style.verticalSpacing, style.imageSize.width, style.imageSize.height);
        }
        
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
            wrapperHeight += style.imageToMessageSpacing;
        }
        self.frame = CGRectMake(0.0, 0.0, wrapperWidth, wrapperHeight);
        
        if(imageView != nil) {
            CGPoint center = imageView.center;
            center.x = wrapperWidth/2.0;
            imageView.center = center;
            [self addSubview:imageView];
        }
        
        if(messageLabel != nil) {
            CGPoint center = messageLabel.center;
            center.x = wrapperWidth/2.0;
            messageLabel.center = center;
            if (imageView) {
                CGRect frame = messageLabel.frame;
                frame.origin.y = CGRectGetMaxY(imageView.frame) + style.imageToMessageSpacing;
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

#pragma mark - Show Toast Methods

- (void)lc_showToast:(NSString *)message {
    [self lc_showToast:message image:nil position:LCToastManager.sharedManager.position style:nil];
}

- (void)lc_showToast:(NSString *)message position:(LCToastPosition)position {
    [self lc_showToast:message image:nil position:position style:nil];
}

- (void)lc_showToast:(NSString *)message image:(UIImage *)image position:(LCToastPosition)position {
    [self lc_showToast:message image:image position:position style:nil];
}

- (void)lc_showToast:(NSString *)message image:(UIImage *)image position:(LCToastPosition)position style:(LCToastStyle *)style {
    if (LCToastManager.sharedManager.dismissLoadingWhenToastShown) {
        [self lc_dismissLoading];
    }
    if (message == nil) return;
    LCToastWrapper *toast = [[LCToastWrapper alloc] initWithMessage:message image:image style:style viewSize:self.bounds.size];
    toast.position = position;
    if ([LCToastManager sharedManager].queueEnabled && [self.activeToasts count] > 0) {
        // enqueue
        [self.toastQueue addObject:toast];
    } else {
        // present
        [self showToastWithWrapper:toast];
    }
}

#pragma mark - Hide Toast Methods

- (void)lc_dismissToast {
    [self lc_dismissToast:[[self activeToasts] firstObject]];
}

- (void)lc_dismissToast:(UIView *)toast {
    if (!toast || ![[self activeToasts] containsObject:toast]) return;
    [self removeToastWrapper:toast];
}

- (void)lc_dismissAllToasts {
    [self clearToastQueue];
    for (UIView *toast in [self activeToasts]) {
        [self removeToastWrapper:toast];
    }
}

- (void)lc_dismissAllActivities {
    [self lc_dismissAllToasts];
    [self lc_dismissLoading];
}


#pragma mark - Private Show/Hide Methods

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
                         objc_setAssociatedObject(toast, &LCToastTimerKey, timer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                     }];
}

- (void)removeToastWrapper:(UIView *)toast {
    NSTimer *timer = (NSTimer *)objc_getAssociatedObject(toast, &LCToastTimerKey);
    [timer invalidate];
    
    [UIView animateWithDuration:[[LCToastManager sharedManager].sharedStyle fadeDuration]
                          delay:0.0
                        options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)
                     animations:^{
                         toast.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         [toast removeFromSuperview];
                         // remove
                         [[self activeToasts] removeObject:toast];
                         if ([self.toastQueue count] > 0) {
                             // dequeue
                             LCToastWrapper *nextToast = [[self toastQueue] firstObject];
                             [[self toastQueue] removeObjectAtIndex:0];
                             [self showToastWithWrapper:nextToast];
                         }
                     }];
}

- (void)clearToastQueue {
    [[self toastQueue] removeAllObjects];
}
#pragma mark - Storage

- (NSMutableArray *)activeToasts {
    NSMutableArray *activeToasts = objc_getAssociatedObject(self, &LCToastActiveKey);
    if (activeToasts == nil) {
        activeToasts = [[NSMutableArray alloc] init];
        objc_setAssociatedObject(self, &LCToastActiveKey, activeToasts, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return activeToasts;
}

- (NSMutableArray *)toastQueue {
    NSMutableArray *toastQueue = objc_getAssociatedObject(self, &LCToastQueueKey);
    if (toastQueue == nil) {
        toastQueue = [[NSMutableArray alloc] init];
        objc_setAssociatedObject(self, &LCToastQueueKey, toastQueue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return toastQueue;
}

#pragma mark - Events

- (void)toastTimerDidFinish:(NSTimer *)timer {
    [self removeToastWrapper:(UIView *)timer.userInfo];
}

- (void)handleToastTapped:(UITapGestureRecognizer *)recognizer {
    UIView *toast = recognizer.view;
    NSTimer *timer = (NSTimer *)objc_getAssociatedObject(toast, &LCToastTimerKey);
    [timer invalidate];
    
    [self removeToastWrapper:toast];
}

@end

static const NSString * LCToastLoadingViewKey      = @"LCToastLoadingViewKey";
static const NSString * LCToastLoadingDisabledViewKey      = @"LCToastLoadingDisabledViewKey";

@implementation UIView (LCLoading)

- (void)lc_showLoading {
    [self lc_showLoadingWithPosition:LCToastManager.sharedManager.position disabled:NO];
}

- (void)lc_showDisabledLoading {
    [self lc_showLoadingWithPosition:LCToastManager.sharedManager.position disabled:YES];
}

- (void)lc_showLoadingWithPosition:(LCToastPosition)position disabled:(BOOL)disabled {
    UIView *existingActivityView = (UIView *)objc_getAssociatedObject(self, &LCToastLoadingViewKey);
    if (existingActivityView != nil) return;
    
    if (disabled) {
        UIView *disabledView = objc_getAssociatedObject(self, &LCToastLoadingDisabledViewKey);
        if (disabledView) {
            [disabledView removeFromSuperview];
        }
        disabledView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:disabledView];
        objc_setAssociatedObject(self, &LCToastLoadingDisabledViewKey, disabledView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    LCToastStyle *style = [LCToastManager sharedManager].sharedStyle;
    
    UIView *activityView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, style.activitySize.width, style.activitySize.height)];
    activityView.center = [self centerPointForPosition:position withToast:activityView];
    activityView.backgroundColor = style.backgroundColor;
    activityView.alpha = 0.0;
    activityView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
    activityView.layer.cornerRadius = style.cornerRadius;
    
    if (style.shadow) {
        activityView.layer.shadowColor = style.shadow.shadowColor.CGColor;
        activityView.layer.shadowOpacity = style.shadow.shadowOpacity;
        activityView.layer.shadowRadius = style.shadow.shadowRadius;
        activityView.layer.shadowOffset = style.shadow.shadowOffset;
    }
    
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style.activityIndicatorViewStyle];
    activityIndicatorView.center = CGPointMake(activityView.bounds.size.width / 2, activityView.bounds.size.height / 2);
    [activityView addSubview:activityIndicatorView];
    [activityIndicatorView startAnimating];
    
    objc_setAssociatedObject (self, &LCToastLoadingViewKey, activityView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (!disabled && [LCToastManager sharedManager].tapToDismissEnabled) {
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLoadingTapped:)];
        [activityView addGestureRecognizer:recognizer];
        activityView.userInteractionEnabled = YES;
        activityView.exclusiveTouch = YES;
    }
    [self addSubview:activityView];
    
    [UIView animateWithDuration:style.fadeDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         activityView.alpha = 1.0;
                     } completion:nil];
}

- (void)lc_dismissLoading {
    UIView *existingActivityView = (UIView *)objc_getAssociatedObject(self, &LCToastLoadingViewKey);
    if (existingActivityView != nil) {
        [UIView animateWithDuration:[[LCToastManager sharedManager].sharedStyle fadeDuration]
                              delay:0.0
                            options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)
                         animations:^{
                             existingActivityView.alpha = 0.0;
                         } completion:^(BOOL finished) {
                             [existingActivityView removeFromSuperview];
                             objc_setAssociatedObject (self, &LCToastLoadingViewKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                             
                             UIView *disabledView = objc_getAssociatedObject(self, &LCToastLoadingDisabledViewKey);
                             if (disabledView) {
                                 [disabledView removeFromSuperview];
                                 objc_setAssociatedObject(self, &LCToastLoadingDisabledViewKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                             }
                         }];
    }
}

- (void)handleLoadingTapped:(UITapGestureRecognizer *)recognizer {
    [self lc_dismissLoading];
}

@end
