//
//  UIView+LCToast.h
//  LCToast (https://github.com/iLiuChang/LCToast)
//
//  Created by 刘畅 on 2022/6/7.
//  Copyright © 2022 LiuChang. All rights reserved.
//

#if __has_include(<LCToast/LCToastManager.h>)
#import <LCToast/LCToastManager.h>
#else
#import "LCToastManager.h"
#endif
NS_ASSUME_NONNULL_BEGIN

@interface UIView (LCToast)

- (void)lc_showToast:(NSString *)message;
- (void)lc_showToast:(NSString *)message position:(LCToastPosition)position;
- (void)lc_showToast:(nullable NSString *)message image:(nullable UIImage *)image position:(LCToastPosition)position;
- (void)lc_dismissToast;
- (void)lc_dismissQueueToasts; // only removes the all toasts in the queue.

- (void)lc_dismissAllToasts; // remove all toasts.

@end

@interface UIView (LCActivityToast)

- (void)lc_showActivityToast;
- (void)lc_showActivityToast:(nullable NSString *)message;
- (void)lc_showDisabledActivityToast; // `self` will not be able to respond to interaction events
- (void)lc_showDisabledActivityToast:(nullable NSString *)message; // `self` will not be able to respond to interaction events
- (void)lc_showActivityToast:(nullable NSString *)message position:(LCToastPosition)position disabled:(BOOL)disabled;
- (void)lc_dismissActivityToast;

@end

@interface UIView (LCProgressToast)

- (void)lc_showProgressToast:(CGFloat)progress;
- (void)lc_showProgressToast:(CGFloat)progress message:(nullable NSString *)message;
- (void)lc_showProgressToast:(CGFloat)progress message:(nullable NSString *)message position:(LCToastPosition)position;
- (void)lc_dismissProgressToast;

@end

NS_ASSUME_NONNULL_END
