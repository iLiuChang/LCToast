//
//  LCToastManager.h
//  LCToast (https://github.com/iLiuChang/LCToast)
//
//  Created by 刘畅 on 2022/6/8.
//  Copyright © 2022 LiuChang. All rights reserved.
//
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, LCToastPosition) {
    LCToastPositionCenter,
    LCToastPositionTop,
    LCToastPositionBottom,
};

@interface LCToastShadow : NSObject
@property (strong, nonatomic) UIColor *shadowColor;
@property (assign, nonatomic) CGFloat shadowOpacity;
@property (assign, nonatomic) CGFloat shadowRadius;
@property (assign, nonatomic) CGSize shadowOffset;
@end

@interface LCToastStyle : NSObject
@property (strong, nonatomic) UIColor *backgroundColor; /// default is `[UIColor blackColor]` at 80% opacity
@property (strong, nonatomic) UIColor *messageColor; // default is `[UIColor whiteColor]`
@property (strong, nonatomic) UIFont *messageFont; // default is `[UIFont systemFontOfSize:16.0]`
@property (assign, nonatomic) NSTextAlignment messageAlignment; // default is `NSTextAlignmentCenter`
@property (assign, nonatomic) NSInteger messageNumberOfLines; // default is 0 (no limit)
@property (assign, nonatomic) CGFloat maxWidthPercentage; // the value from 0.0 to 1.0, default is 0.8 (80% of the superview's width)
@property (assign, nonatomic) CGFloat maxHeightPercentage; // the value from 0.0 to 1.0, default is 0.8 (80% of the superview's height)
@property (assign, nonatomic) CGFloat horizontalSpacing; // the spacing from the horizontal edge of the toast view to the content/toast-superview, default is 10.0
@property (assign, nonatomic) CGFloat verticalSpacing; // the spacing from the vertical edge of the toast view to the content/toast-superview, default is 10.0
@property (assign, nonatomic) CGFloat messageSpacing; // the spacing from image/loading/progress/ to the message, default is 8.0
@property (assign, nonatomic) CGFloat cornerRadius; // default is 10.0
@property (assign, nonatomic) CGSize imageSize; // default is `CGSizeMake(80.0, 80.0)`
@property (assign, nonatomic) NSTimeInterval fadeDuration; // default is 0.2
@property (strong, nonatomic, nullable) LCToastShadow *shadow; // default is nil
@property (assign, nonatomic) CGSize activitySize; // default is `CGSizeMake(100.0, 100.0)`. If message has a value then this parameter is invalid, its value will be the size of `UIActivityIndicatorView`.
@property (assign, nonatomic) UIActivityIndicatorViewStyle activityIndicatorViewStyle; // default is `UIActivityIndicatorViewStyleWhiteLarge`
@property (strong, nonatomic, nullable) UIColor* progressColor; // default is nil
@property (strong, nonatomic, nullable) UIColor* progressTrackColor; // default is nil

@end


@interface LCToastManager : NSObject
@property (strong, nonatomic) LCToastStyle *sharedStyle;
@property (assign, nonatomic) BOOL tapToDismissEnabled;                  // default is YES
@property (assign, nonatomic) BOOL toastQueueEnabled;                    // default is NO
@property (assign, nonatomic) LCToastPosition position;                  // default is LCToastPositionCenter
@property (assign, nonatomic) NSTimeInterval minimumDismissTimeInterval; // default is 3.0 seconds
@property (assign, nonatomic) NSTimeInterval maximumDismissTimeInterval; // default is CGFLOAT_MAX
@property (assign, nonatomic) BOOL dismissLoadingWhenToastShown;         // default is YES

+ (instancetype)sharedManager;
@end

NS_ASSUME_NONNULL_END
