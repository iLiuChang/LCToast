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
@property (strong, nonatomic) UIColor *backgroundColor; // default is `[UIColor blackColor]` at 80% opacity
@property (assign, nonatomic) CGFloat cornerRadius; // default is 10.0
@property (strong, nonatomic, nullable) LCToastShadow *shadow; // default is nil
@property (assign, nonatomic) NSTimeInterval fadeDuration; // default is 0.2

@property (strong, nonatomic) UIColor *messageColor; // default is `[UIColor whiteColor]`
// If the size of the message is larger than the maximum, the font will be automatically reduced.
@property (strong, nonatomic) UIFont *messageFont; // default is `[UIFont systemFontOfSize:16.0]`
@property (assign, nonatomic) NSTextAlignment messageAlignment; // default is `NSTextAlignmentCenter`
@property (assign, nonatomic) NSInteger messageNumberOfLines; // default is 0 (no limit)
// the spacing from image/activity/progress/ to the message.
@property (assign, nonatomic) CGFloat messageSpacing; // default is 8.0

@property (assign, nonatomic) CGFloat maxWidthPercentage; // (0 ~ 1) default is 0.8 (80% of the superview's width)
@property (assign, nonatomic) CGFloat maxHeightPercentage; //(0 ~ 1) default is 0.8 (80% of the superview's height).

// the spacing from the horizontal edge of the content to the wrapper or the wrapper to the wrapper's superview.
@property (assign, nonatomic) CGFloat horizontalSpacing; // default is 10.0
// the spacing from the vertical edge of the content to the wrapper or the wrapper to the wrapper's superview.
@property (assign, nonatomic) CGFloat verticalSpacing; // default is 10.0

// If the width of the image is greater than the maximum width, then this width will be the maximum width.
@property (assign, nonatomic) CGSize imageSize; // default is `CGSizeMake(30.0, 30.0)`

// the size of the activity wrapper.
// If the size of the message is larger than this value, then the size of the wrapper will be changed according to the size of the message.
@property (assign, nonatomic) CGSize activitySize; // default is `CGSizeMake(100.0, 100.0)`
@property (assign, nonatomic) UIActivityIndicatorViewStyle activityIndicatorViewStyle; // default is `UIActivityIndicatorViewStyleWhiteLarge`

@property (strong, nonatomic, nullable) UIColor* progressColor; // default is nil
@property (strong, nonatomic, nullable) UIColor* progressTrackColor; // default is nil

@end


@interface LCToastManager : NSObject
@property (strong, nonatomic) LCToastStyle *sharedStyle;
@property (assign, nonatomic) BOOL tapToDismissEnabled;                  // default is YES
@property (assign, nonatomic) BOOL toastQueueEnabled;                    // default is NO, `activity` and `progress` do not have queues.
@property (assign, nonatomic) LCToastPosition position;                  // default is LCToastPositionCenter
@property (assign, nonatomic) NSTimeInterval minimumDismissTimeInterval; // default is 3.0 seconds
@property (assign, nonatomic) NSTimeInterval maximumDismissTimeInterval; // default is CGFLOAT_MAX
@property (assign, nonatomic) BOOL dismissActivityWhenToastShown;         // default is YES

+ (instancetype)sharedManager;
@end

NS_ASSUME_NONNULL_END
