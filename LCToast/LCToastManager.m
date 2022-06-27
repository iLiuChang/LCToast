//
//  LCToastManager.m
//  LCToast (https://github.com/iLiuChang/LCToast)
//
//  Created by 刘畅 on 2022/6/8.
//  Copyright © 2022 LiuChang. All rights reserved.
//

#import "LCToastManager.h"

@implementation LCToastShadow
@end

@implementation LCToastStyle

#pragma mark - Constructors

- (instancetype)initWithDefaultStyle {
    self = [super init];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        self.messageColor = [UIColor whiteColor];
        self.maxWidthPercentage = 0.8;
        self.maxHeightPercentage = 0.8;
        self.horizontalSpacing = 10.0;
        self.verticalSpacing = 10.0;
        self.messageSpacing = 8.0;
        self.cornerRadius = 10.0;
        self.messageFont = [UIFont systemFontOfSize:16.0];
        self.messageAlignment = NSTextAlignmentCenter;
        self.messageNumberOfLines = 0;
        self.imageSize = CGSizeMake(30.0, 30.0);
        self.activitySize = CGSizeMake(100.0, 100.0);
        self.fadeDuration = 0.2;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        self.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
#pragma clang diagnostic pop
    }
    return self;
}

- (void)setMaxWidthPercentage:(CGFloat)maxWidthPercentage {
    _maxWidthPercentage = MAX(MIN(maxWidthPercentage, 1.0), 0.0);
}

- (void)setMaxHeightPercentage:(CGFloat)maxHeightPercentage {
    _maxHeightPercentage = MAX(MIN(maxHeightPercentage, 1.0), 0.0);
}

@end


@implementation LCToastManager

#pragma mark - Constructors

+ (instancetype)sharedManager {
    static LCToastManager *_sharedManager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _sharedStyle = [[LCToastStyle alloc] initWithDefaultStyle];
        _tapToDismissEnabled = YES;
        _minimumDismissTimeInterval = 3.0;
        _maximumDismissTimeInterval = CGFLOAT_MAX;
        _position = LCToastPositionCenter;
        _dismissActivityWhenToastShown = YES;
    }
    return self;
}

@end

