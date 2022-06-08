//
//  UIView+LCToast.h
//  LCToast (https://github.com/iLiuChang/LCToast)
//
//  Created by 刘畅 on 2022/6/7.
//  Copyright © 2022 LiuChang. All rights reserved.
//

#import "LCToastManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIView (LCToast)

- (void)lc_showToast:(NSString *)message;
- (void)lc_showToast:(NSString *)message position:(LCToastPosition)position;
- (void)lc_showToast:(NSString *)message image:(nullable UIImage *)image position:(LCToastPosition)position;
- (void)lc_showToast:(NSString *)message image:(nullable UIImage *)image position:(LCToastPosition)position style:(nullable LCToastStyle *)style;

- (void)lc_dismissToast;
- (void)lc_dismissToast:(UIView *)toast;
- (void)lc_dismissAllToasts; 

- (void)lc_dismissAllActivities;

@end

@interface UIView (LCLoading)

- (void)lc_showLoading;
- (void)lc_showDisabledLoading; // `self` will not be able to respond to interaction events
- (void)lc_showLoadingWithPosition:(LCToastPosition)position disabled:(BOOL)disabled;
- (void)lc_dismissLoading;

@end



NS_ASSUME_NONNULL_END
