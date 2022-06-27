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
@property (weak, nonatomic) UILabel *messageLabel;

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
        
        if (message) {
            messageLabel = [[UILabel alloc] init];
            messageLabel.numberOfLines = style.messageNumberOfLines;
            messageLabel.font = style.messageFont;
            messageLabel.textAlignment = style.messageAlignment;
            messageLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            messageLabel.textColor = style.messageColor;
            messageLabel.backgroundColor = [UIColor clearColor];
            messageLabel.alpha = 1.0;
            messageLabel.text = message;
            messageLabel.adjustsFontSizeToFitWidth = YES;
            
            CGSize maxSizeMessage = CGSizeMake(viewSize.width * style.maxWidthPercentage - style.horizontalSpacing * 2.0, (viewSize.height * style.maxHeightPercentage) - style.verticalSpacing * 2.0);
            CGSize expectedSizeMessage = [messageLabel sizeThatFits:maxSizeMessage];
            expectedSizeMessage = CGSizeMake(MIN(maxSizeMessage.width, expectedSizeMessage.width), MIN(maxSizeMessage.height, expectedSizeMessage.height));
            messageLabel.frame = CGRectMake(0.0, style.verticalSpacing, expectedSizeMessage.width, expectedSizeMessage.height);
        }
       
        CGFloat newImageWidth = 0.0;
        CGFloat newImageHeight = 0.0;
        if (imageView) {
            newImageWidth = MIN(viewSize.width * style.maxWidthPercentage - style.horizontalSpacing * 2.0, imageView.frame.size.width);
            newImageHeight = MIN(viewSize.height * style.maxHeightPercentage - style.verticalSpacing * 2.0, imageView.frame.size.height);
        }

        CGFloat wrapperWidth = MAX((newImageWidth + (style.horizontalSpacing * 2.0)), (messageLabel.frame.size.width + style.horizontalSpacing * 2.0));
        CGFloat wrapperHeight = style.verticalSpacing * 2.0 + newImageHeight + messageLabel.frame.size.height;
        if (imageView && messageLabel) {
            wrapperHeight += style.messageSpacing;
        }
        self.frame = CGRectMake(0.0, 0.0, wrapperWidth, wrapperHeight);
        
        if(imageView) {
            imageView.frame = CGRectMake((wrapperWidth - newImageWidth)/2.0, style.verticalSpacing, newImageWidth, newImageHeight);
            [self addSubview:imageView];
            self.imageView = imageView;
        }
        
        if(messageLabel) {
            CGPoint center = messageLabel.center;
            center.x = wrapperWidth/2.0;
            messageLabel.center = center;
            if (imageView) {
                CGRect frame = messageLabel.frame;
                frame.origin.y = CGRectGetMaxY(imageView.frame) + style.messageSpacing;
                messageLabel.frame = frame;
            }
            [self addSubview:messageLabel];
            self.messageLabel = messageLabel;
        }
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if (!newSuperview) {
        [self removeTimer];
    }
}

- (void)dealloc {
    [self removeTimer];
}

- (void)removeTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}
@end

@interface LCToastTimerUserInfo : NSObject
@property (weak, nonatomic) LCToastWrapper *toast;
@property (copy, nonatomic) void (^actionBlock)(NSTimer *timer);
@end
@implementation LCToastTimerUserInfo
@end
@interface NSTimer (LCToastTimer)
@end
@implementation NSTimer (LCToastTimer)

+ (void)_timerActionBlock:(NSTimer *)timer {
    if ([timer.userInfo isKindOfClass:LCToastTimerUserInfo.class]) {
        LCToastTimerUserInfo *info = (LCToastTimerUserInfo *)timer.userInfo;
        if (info.actionBlock) {
            info.actionBlock(timer);
        }
    }
}

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)seconds wrapper:(LCToastWrapper *)toast action:(void (^)(NSTimer *timer))action {
    LCToastTimerUserInfo *userInfo = [[LCToastTimerUserInfo alloc] init];
    userInfo.toast = toast;
    userInfo.actionBlock = action;
    return [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(_timerActionBlock:) userInfo:userInfo repeats:NO];
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

- (void)lc_showToast:(NSString *)message {
    [self lc_showToast:message image:nil position:LCToastManager.sharedManager.position];
}

- (void)lc_showToast:(NSString *)message position:(LCToastPosition)position {
    [self lc_showToast:message image:nil position:position];
}

- (void)lc_showToast:(NSString *)message image:(UIImage *)image position:(LCToastPosition)position {
    if (LCToastManager.sharedManager.dismissActivityWhenToastShown) {
        [self lc_dismissActivityToast];
    }

    if (!message && !image) return;

    UIImageView *imageView;
    if(image) {
        LCToastStyle *style = [LCToastManager sharedManager].sharedStyle;
        imageView = [[UIImageView alloc] initWithImage:image];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.frame = CGRectMake(0, 0, style.imageSize.width, style.imageSize.height);
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
        [self lc_dismissQueueToasts];
        [self showToastWithWrapper:toast];
    }
}

- (void)lc_dismissToast {
    [self removeToastWrapper:[[self activeToasts] firstObject]];
}

- (void)lc_dismissQueueToasts {
    for (LCToastWrapper *toast in [self activeToasts]) {
        [toast removeTimer];
        [toast removeFromSuperview];
    }
    [[self activeToasts] removeAllObjects];
}

- (void)lc_dismissAllToasts {
    [self lc_dismissQueueToasts];
    [self lc_dismissActivityToast];
    [self lc_dismissProgressToast];
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
                         __weak __typeof__(self) weakSelf = self;
                         toast.timer = [NSTimer scheduledTimerWithTimeInterval:duration wrapper:toast action:^(NSTimer *timer) {
                             __strong __typeof__(weakSelf) strongSelf = weakSelf;
                             [strongSelf toastTimerDidFinish:timer];
                         }];
                     }];
}

- (void)removeToastWrapper:(LCToastWrapper *)toast {
    if (!toast) {
        return;
    }
    [toast removeTimer];
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
    [self removeToastWrapper:((LCToastTimerUserInfo *)timer.userInfo).toast];
}

- (void)handleToastTapped:(UITapGestureRecognizer *)recognizer {
    LCToastWrapper *toast = (LCToastWrapper *)recognizer.view;
    [toast removeTimer];
    [self removeToastWrapper:toast];
}

@end

#pragma mark -

static const NSString * LCActivityToastViewKey      = @"LCToastActivityViewKey";
static const NSString * LCActivityToastDisabledViewKey      = @"LCToastActivityDisabledViewKey";
@implementation UIView (LCActivityToast)

- (void)lc_showActivityToast {
    [self lc_showActivityToast:nil position:LCToastManager.sharedManager.position disabled:NO];
}

- (void)lc_showActivityToast:(NSString *)message {
    [self lc_showActivityToast:message position:LCToastManager.sharedManager.position disabled:NO];
}

- (void)lc_showDisabledActivityToast {
    [self lc_showActivityToast:nil position:LCToastManager.sharedManager.position disabled:YES];
}

- (void)lc_showDisabledActivityToast:(NSString *)message {
    [self lc_showActivityToast:message position:LCToastManager.sharedManager.position disabled:YES];
}

- (void)lc_showActivityToast:(NSString *)message position:(LCToastPosition)position disabled:(BOOL)disabled {
    UIView *existingActivityView = (UIView *)objc_getAssociatedObject(self, &LCActivityToastViewKey);
    if (existingActivityView != nil) {
        return;
    }
    
    if (disabled) {
        UIView *disabledView = objc_getAssociatedObject(self, &LCActivityToastDisabledViewKey);
        if (disabledView) {
            [disabledView removeFromSuperview];
        }
        disabledView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:disabledView];
        objc_setAssociatedObject(self, &LCActivityToastDisabledViewKey, disabledView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    LCToastStyle *style = [LCToastManager sharedManager].sharedStyle;
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style.activityIndicatorViewStyle];
    [activityIndicatorView startAnimating];
    LCToastWrapper *activityView = [[LCToastWrapper alloc] initWithMessage:message imageView:activityIndicatorView viewSize:self.bounds.size];
    CGFloat newActivityWidth = MIN(self.frame.size.width * style.maxWidthPercentage - style.horizontalSpacing * 2.0, MAX(style.activitySize.width, activityIndicatorView.frame.size.width + style.horizontalSpacing * 2.0));
    CGFloat newActivityHeight = MIN(self.frame.size.height * style.maxHeightPercentage - style.verticalSpacing * 2.0, MAX(style.activitySize.height, activityIndicatorView.frame.size.height + style.verticalSpacing * 2.0));
    CGRect newActivityFrame = activityView.frame;
    BOOL isUpdateFrame = NO;
    if (activityView.frame.size.width < newActivityWidth) {
        isUpdateFrame = YES;
        // 1. set new width
        newActivityFrame.size.width = newActivityWidth;
        // 2. update image horizontal center
        CGPoint imageCenter = activityView.imageView.center;
        imageCenter.x = newActivityWidth / 2.0;
        activityView.imageView.center = imageCenter;
        // 3. update message horizontal center
        if (message) {
            CGPoint msgCenter = activityView.messageLabel.center;
            msgCenter.x = newActivityWidth / 2.0;
            activityView.messageLabel.center = msgCenter;
        }
    }
    if (activityView.frame.size.height < newActivityHeight) {
        isUpdateFrame = YES;
        // 1. set new height
        newActivityFrame.size.height = newActivityHeight;
        // 2. update image top
        CGRect newImageFrame = activityView.imageView.frame;
        newImageFrame.origin.y += (newActivityHeight-activityView.frame.size.height) / 2.0;
        activityView.imageView.frame = newImageFrame;
        // 3. update message top
        if (message) {
            CGRect newMsgFrame = activityView.messageLabel.frame;
            newMsgFrame.origin.y = CGRectGetMaxY(activityView.imageView.frame) + style.messageSpacing;
            activityView.messageLabel.frame = newMsgFrame;
        }
    }
    if (isUpdateFrame) {
        activityView.frame = newActivityFrame;
    }
    activityView.center = [self centerPointForPosition:position withToast:activityView];
    [self addSubview:activityView];
    objc_setAssociatedObject (self, &LCActivityToastViewKey, activityView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
    activityView.alpha = 0.0;
    [UIView animateWithDuration:style.fadeDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         activityView.alpha = 1.0;
                     } completion:nil];
   
}

- (void)lc_dismissActivityToast {
    UIView *existingActivityView = (UIView *)objc_getAssociatedObject(self, &LCActivityToastViewKey);
    if (existingActivityView != nil) {
        [UIView animateWithDuration:[[LCToastManager sharedManager].sharedStyle fadeDuration]
                              delay:0.0
                            options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)
                         animations:^{
                             existingActivityView.alpha = 0.0;
                         } completion:^(BOOL finished) {
                             [existingActivityView removeFromSuperview];
                             objc_setAssociatedObject (self, &LCActivityToastViewKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                             
                             UIView *disabledView = objc_getAssociatedObject(self, &LCActivityToastDisabledViewKey);
                             if (disabledView) {
                                 [disabledView removeFromSuperview];
                                 objc_setAssociatedObject(self, &LCActivityToastDisabledViewKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                             }
                         }];
    }
}

@end

#pragma mark - 

static const NSString * LCProgressToastViewKey = @"LCProgressToastViewKey";
@implementation UIView (LCProgressToast)

- (void)lc_showProgressToast:(CGFloat)progress {
    [self lc_showProgressToast:progress message:nil position:LCToastManager.sharedManager.position];
}

- (void)lc_showProgressToast:(CGFloat)progress message:(NSString *)message {
    [self lc_showProgressToast:progress message:message position:LCToastManager.sharedManager.position];
}

- (void)lc_showProgressToast:(CGFloat)progress message:(NSString *)message position:(LCToastPosition)position {
    UIView *existingActivityView = (UIView *)objc_getAssociatedObject(self, &LCProgressToastViewKey);
    if (existingActivityView) {
        UIProgressView *progressView = (UIProgressView *)((LCToastWrapper *)existingActivityView).imageView;
        [progressView setProgress:progress animated:YES];
        return;
    }
    
    LCToastStyle *style = [LCToastManager sharedManager].sharedStyle;
    UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width * style.maxWidthPercentage - style.horizontalSpacing*2, 5)];
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
    objc_setAssociatedObject (self, &LCProgressToastViewKey, activityView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [progressView setProgress:progress animated:YES];
    activityView.alpha = 0.0;
    [UIView animateWithDuration:style.fadeDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         activityView.alpha = 1.0;
                     } completion:nil];
}

- (void)lc_dismissProgressToast {
    UIView *existingActivityView = (UIView *)objc_getAssociatedObject(self, &LCProgressToastViewKey);
    if (existingActivityView != nil) {
        [UIView animateWithDuration:[[LCToastManager sharedManager].sharedStyle fadeDuration]
                              delay:0.0
                            options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)
                         animations:^{
                             existingActivityView.alpha = 0.0;
                         } completion:^(BOOL finished) {
                             [existingActivityView removeFromSuperview];
                             objc_setAssociatedObject (self, &LCProgressToastViewKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                         }];
    }
}

@end
