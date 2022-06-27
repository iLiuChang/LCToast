//
//  ViewController.m
//  LCToast
//
//  Created by 刘畅 on 2022/6/8.
//

#import "ViewController.h"
#import "UIView+LCToast.h"
#import "SceneDelegate.h"
@interface ViewController ()
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger count;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *buttonTop = [[UIButton alloc] initWithFrame:CGRectMake(20, 100, 100, 30)];
    [buttonTop setTitle:@"top" forState:(UIControlStateNormal)];
    [buttonTop setTitleColor:UIColor.blueColor forState:(UIControlStateNormal)];
    [buttonTop addTarget:self action:@selector(didTop) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:buttonTop];
    
    UIButton *buttonCenter = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(buttonTop.frame), 100, 100, 30)];
    [buttonCenter setTitle:@"center" forState:(UIControlStateNormal)];
    [buttonCenter setTitleColor:UIColor.blueColor forState:(UIControlStateNormal)];
    [buttonCenter addTarget:self action:@selector(didCenter) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:buttonCenter];
    
    
    UIButton *buttonBottom = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(buttonCenter.frame), 100, 100, 30)];
    [buttonBottom setTitle:@"bottom" forState:(UIControlStateNormal)];
    [buttonBottom setTitleColor:UIColor.blueColor forState:(UIControlStateNormal)];
    [buttonBottom addTarget:self action:@selector(didBottom) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:buttonBottom];
    
    UIButton *loading = [[UIButton alloc] initWithFrame:CGRectMake(20, 150, 100, 30)];
    [loading setTitle:@"loading" forState:(UIControlStateNormal)];
    [loading setTitleColor:UIColor.blueColor forState:(UIControlStateNormal)];
    [loading addTarget:self action:@selector(didLoading) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:loading];

    UIButton *image = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(loading.frame), 150, 100, 30)];
    [image setTitle:@"image" forState:(UIControlStateNormal)];
    [image setTitleColor:UIColor.blueColor forState:(UIControlStateNormal)];
    [image addTarget:self action:@selector(didImage) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:image];

    UIButton *progress = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(image.frame), 150, 100, 30)];
    [progress setTitle:@"progress" forState:(UIControlStateNormal)];
    [progress setTitleColor:UIColor.blueColor forState:(UIControlStateNormal)];
    [progress addTarget:self action:@selector(didProgress) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:progress];
    
    UIButton *dismissall = [[UIButton alloc] initWithFrame:CGRectMake(20, 200, 100, 30)];
    [dismissall setTitle:@"dismissall" forState:(UIControlStateNormal)];
    [dismissall setTitleColor:UIColor.blueColor forState:(UIControlStateNormal)];
    [dismissall addTarget:self action:@selector(didAll) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:dismissall];
    

    LCToastManager.sharedManager.sharedStyle.activitySize = CGSizeMake(0, 0);
//    LCToastManager.sharedManager.toastQueueEnabled = YES;
    // Do any additional setup after loading the view.
}

- (void)didTop {
    [self.view lc_showToast:@"床前明月光，疑是地上霜。举头望明月，低头思故乡。" position:(LCToastPositionTop)];
}

- (void)didCenter {
    [self.view lc_showToast:@"泉眼无声惜细流，树阴照水爱晴柔。小荷才露尖尖角，早有蜻蜓立上头。" position:(LCToastPositionCenter)];
}

- (void)didBottom {
    [self.view lc_showToast:@"日照香炉生紫烟，遥看瀑布挂前川。飞流直下三千尺，疑是银河落九天。" position:(LCToastPositionBottom)];
}

- (void)didLoading {
    [self.view lc_showActivityToast:@"加载中..."];
}

- (void)didImage {
    [self.view lc_showToast:@"春种一粒粟，秋收万颗子。四海无闲田，农夫犹饿死。锄禾日当午，汗滴禾下土。谁知盘中餐，粒粒皆辛苦。" image:[UIImage imageNamed:@"warning"] position:(LCToastPositionCenter)];
}

- (void)didProgress {
    [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(startProgress:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];

    self.count = 0;
    [self startProgress:self.timer];
}

- (void)didAll {
    [self.view lc_dismissAllToasts];
}
- (void)startProgress:(NSTimer *)timer {
    self.count+=1;
    if (self.count == 10) {
        [self.timer invalidate];
        [self.view lc_dismissProgressToast];
    }
    [self.view lc_showProgressToast:self.count/10.0 message:@"下载中..."];
}

@end
