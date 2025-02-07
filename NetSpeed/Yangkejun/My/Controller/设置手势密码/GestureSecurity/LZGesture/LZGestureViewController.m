//
//  LZGestureViewController.m
//  LZGestureSecurity
//
//  Created by 杨科军 on 2016/10/17.
//  Copyright © 2018年 杨科军. All rights reserved.
//

#define LZNaigationBarHeight 64

#import "LZGestureViewController.h"
#import "PCCircleView.h"
#import "LZWarnLabel.h"
#import "PCCircleViewConst.h"
#import "LZGestureTool.h"
#import "TouchIdUnlock.h"

//#import "LZPasswordViewController.h"
//#import "LZNumberTool.h"
#import "LZGestureScreen.h"

static NSString *firstGesturePsw;

#define characterColor [UIColor blackColor]

@interface LZGestureViewController ()<CircleViewDelegate>
{
    BOOL _isHiddenNavigationBarWhenDisappear;//记录当页面消失时是否需要隐藏系统导航
    BOOL _isHasTabBarController;//是否含有tabbar
    BOOL _isHasNavitationController;//是否含有导航
    
    // 用于区分是设置密码,还是更新密码
    BOOL isShowDefaultImage;
}

@property (nonatomic, strong) PCCircleView *lockView;
@property (nonatomic, strong) LZWarnLabel *msgLabel;
@property (nonatomic, strong) UIButton *resetButton;
@property (nonatomic, strong) UIImageView *showImage;
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UIButton *forgetButton;
@property (nonatomic, strong) UIButton *otherButton;
@end

@implementation LZGestureViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_isHasNavitationController == YES) {
        if (self.navigationController.navigationBarHidden == YES) {
            _isHiddenNavigationBarWhenDisappear = NO;
        } else {
            self.navigationController.navigationBarHidden = YES;
            _isHiddenNavigationBarWhenDisappear = YES;
        }
    }
    
    // 进来先清空存的第一个密码
    [PCCircleViewConst saveGesture:nil Key:gestureOneSaveKey];
    
    [self.titleLab sizeToFit];
    self.titleLab.center = CGPointMake(self.view.center.x, (LZNaigationBarHeight - 20)/2.0 + 20);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (_isHiddenNavigationBarWhenDisappear == YES) {
        self.navigationController.navigationBarHidden = NO;
    }
    
    [self resetButtonClock:self.resetButton];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImageView *bgImage = [[UIImageView alloc]initWithFrame:self.view.bounds];
    bgImage.image = [UIImage imageNamed:@"LanuchImage"];
    [self.view addSubview:bgImage];
    
//    self.view.backgroundColor = [UIColor whiteColor];
    
    if (self.type == LZGestureTypeScreen) {
        
    } else {
        [self setupCustomNavi];
    }
}

#pragma mark -- 自定义导航
- (void)setupCustomNavi {
    
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.font = [UIFont systemFontOfSize:16];
    titleLabel.textColor = characterColor;
    
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
    self.titleLab = titleLabel;
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(10, 20, 40, 44);
    backButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [backButton setTitle:@"╳" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
}

- (void)backButtonClick:(UIButton *)button {
    
    [self back];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(gestureViewCanceled:)]) {
        
        [self.delegate gestureViewCanceled:self];
    }
}

- (void)dismiss {
    
    [self back];
}
- (void)back {
    
    if (self.navigationController) {
        
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)delayBack {
    
    dispatch_time_t dalayTime = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC*0.4);
    dispatch_queue_t queueDelay = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_after(dalayTime, queueDelay, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self back];
        });
    });
}
- (void)resetButtonClock:(UIButton *)button {
    
    button.hidden = YES;
    
    // msgLabel提示文字复位
    [self.msgLabel showNormalMsg:gestureTextBeforeSet];
    
    // 清除之前存储的密码
    [PCCircleViewConst saveGesture:nil Key:gestureOneSaveKey];
    
    self.showImage.image = kAppIcon;
}

- (UIButton *)resetButton {
    if (_resetButton == nil) {
        
        UIButton *resetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        resetBtn.frame = CGRectMake(SCREEN_WIDTH - 50, 20, 40, 44);
        resetBtn.hidden = YES;
        resetBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [resetBtn setTitle:@"Reset" forState:UIControlStateNormal];
        [resetBtn addTarget:self action:@selector(resetButtonClock:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:resetBtn];
        _resetButton = resetBtn;
    }
    
    return _resetButton;
}

- (PCCircleView *)lockView {
    
    if (_lockView == nil) {
        
        _lockView = [[PCCircleView alloc]init];
        _lockView.delegate = self;
        [self.view addSubview:_lockView];
    }
    
    return _lockView;
}

- (LZWarnLabel *)msgLabel {
    if (_msgLabel == nil) {
        
        _msgLabel = [[LZWarnLabel alloc]init];
        _msgLabel.bounds = CGRectMake(0, 0, SCREEN_WIDTH, 14);
        _msgLabel.center = CGPointMake(SCREEN_WIDTH/2.0, CGRectGetMinY(self.lockView.frame) - 30);
        
        [self.view addSubview:_msgLabel];
    }
    
    return _msgLabel;
}

- (UIImageView *)showImage {
    if (_showImage == nil) {
        
        _showImage = [[UIImageView alloc]init];
        _showImage.bounds = CGRectMake(0, 0, CircleRadius * 4 * 0.6, CircleRadius * 4 * 0.6);
        _showImage.center = CGPointMake(kScreenW/2, CGRectGetMinY(self.msgLabel.frame) - CGRectGetHeight(_showImage.frame)/2 - 20);
        
        [self.view addSubview:_showImage];
    }
    
    return _showImage;
}

- (UIButton *)forgetButton {
    if (_forgetButton == nil) {
        
        _forgetButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _forgetButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_forgetButton setTitle:@"Forgot?" forState:UIControlStateNormal];
        [_forgetButton setTitleColor:characterColor forState:UIControlStateNormal];
        _forgetButton.frame = CGRectMake(20, CGRectGetMaxY(self.lockView.frame) + 20, 100, 14);
        
        [_forgetButton addTarget:self action:@selector(forgetButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_forgetButton];
    }
    
    return _forgetButton;
}
#warning 如果所有的验证方式均无效,可在此方法弹出警告框,或希望用户执行的操作
- (void)forgetButtonClick {
    NSLog(@"忘记密码相关操作!!");
}

- (UIButton *)otherButton {
    
    if (_otherButton == nil) {
        
        _otherButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _otherButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_otherButton setImage:[UIImage imageNamed:@"gesture_unlock"] forState:UIControlStateNormal];
        [_otherButton setTitle:@" Unlock" forState:UIControlStateNormal];
        [_otherButton setTitleColor:characterColor forState:UIControlStateNormal];
        _otherButton.frame = CGRectMake(kScreenW - 120, CGRectGetMaxY(self.lockView.frame) + 20, 100, 14);
        
        [_otherButton addTarget:self action:@selector(otherButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_otherButton];
    }
    
    return _otherButton;
}
#warning 如果有多种验证方式,可在此进行切换
- (void)otherButtonClick {
    [[TouchIdUnlock sharedInstance] startVerifyTouchID:^{
            [[LZGestureScreen shared] dismiss];
    }];
}
- (void)showInViewController:(UIViewController *)vc type:(LZGestureType)type  {
    self.type = type;
    [vc presentViewController:self animated:YES completion:nil];
    switch (type) {
        case LZGestureTypeSetting:
            [self gestureSetting];
            break;
        case LZGestureTypeVerifying:
            [self gestureVerity];
            break;
        case LZGestureTypeUpdate:
            [self gertureUpdate];
            break;
        case LZGestureTypeScreen:
            [self gestureScreen];
            break;
            
        default:
            break;
    }
}
- (void)gestureSetting {
    self.titleLab.text = @"Set the gesture password";
    
    [self.lockView setType:CircleViewTypeSetting];
    [self.msgLabel showNormalMsg:gestureTextBeforeSet];
    self.showImage.image = kAppIcon;
}

- (void)gestureVerity {
    
    self.titleLab.text = @"Verify gesture password";
    [self.lockView setType:(CircleViewTypeLogin)];
    [self.msgLabel showNormalMsg:gestureTextBeforeSet];
    
    self.showImage.image = kAppIcon;
}

- (void)gertureUpdate {
    
    self.titleLab.text = @"Change password";
    
    [self.lockView setType:CircleViewTypeVerify];
    [self.msgLabel showNormalMsg:gestureTextOldGesture];
    self.showImage.image = kAppIcon;
}

- (void)gestureScreen {
    
    [self forgetButton];
    if ([[TouchIdUnlock sharedInstance] canVerifyTouchID]) {
        
        [self otherButton];
    }
    
    
    [self.lockView setType:CircleViewTypeLogin];
    [self.msgLabel showNormalMsg:gestureTextBeforeSet];
    
    self.showImage.image = kAppIcon;
}

#pragma mark - 设置手势密码代理方法
/**
 *  连线个数少于4个时，通知代理
 *
 *  @param view    circleView
 *  @param type    type
 *  @param gesture 手势结果
 */
- (void)circleView:(PCCircleView *)view type:(CircleViewType)type connectCirclesLessThanNeedWithGesture:(NSString *)gesture {
    
    NSString *gestureOne = [PCCircleViewConst getGestureWithKey:gestureOneSaveKey];
    
    // 看是否存在第一个密码
    if (gestureOne.length > 0) {
        
        [self.msgLabel showWarnMsgAndShake:gestureTextDrawAgainError];
        self.resetButton.hidden = NO;
    } else {
        
        [self.msgLabel showWarnMsgAndShake:gestureTextConnectLess];
    }
}

/**
 *  连线个数多于或等于4个，获取到第一个手势密码时通知代理
 *
 *  @param view    circleView
 *  @param type    type
 *  @param gesture 第一个次保存的密码
 */
- (void)circleView:(PCCircleView *)view type:(CircleViewType)type didCompleteSetFirstGesture:(NSString *)gesture {
    
    [self.msgLabel showWarnMsg:gestureTextDrawAgain];
}

/**
 *  获取到第二个手势密码时通知代理
 *
 *  @param view    circleView
 *  @param type    type
 *  @param gesture 第二次手势密码
 *  @param equal   第二次和第一次获得的手势密码匹配结果
 */
- (void)circleView:(PCCircleView *)view type:(CircleViewType)type didCompleteSetSecondGesture:(NSString *)gesture result:(BOOL)equal {
    
    if (equal) {
        
        [self.msgLabel showSuccessMsg];
        [PCCircleViewConst saveGesture:gesture Key:gestureFinalSaveKey];
        
        
        [self delayBack];
        
        if (self.type == LZGestureTypeUpdate) {
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(gestureView:didUpdate:)]) {
                
                [self.delegate gestureView:self didUpdate:gesture];
            }
        } else {
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(gestureView:didSetted:)]) {
                
                [self.delegate gestureView:self didSetted:gesture];
            }
        }
        
    } else {
        
        [self.msgLabel showWarnMsgAndShake:gestureTextDrawAgainError];
        
        self.resetButton.hidden = NO;
    }
}

#pragma mark - 登录手势密码代理方法
/**
 *  登陆或者验证手势密码输入完成时的代理方法
 *
 *  @param view    circleView
 *  @param type    type
 *  @param gesture 登陆时的手势密码
 */
- (void)circleView:(PCCircleView *)view type:(CircleViewType)type didCompleteLoginGesture:(NSString *)gesture result:(BOOL)equal {
    
    // 此时的type有两种情况 Login or verify
    if (type == CircleViewTypeLogin) {
        
        if (equal) {
            
            [self back];
            if (self.delegate && [self.delegate respondsToSelector:@selector(gestureViewVerifiedSuccess:)]) {
                
                [self.delegate gestureViewVerifiedSuccess:self];
            }
            
            
        } else {
            
            [self.msgLabel showWarnMsgAndShake:gestureTextGestureVerifyError];
        }
    } else if (type == CircleViewTypeVerify) {
        
        if (equal) {
            
            [self.lockView setType:CircleViewTypeSetting];
            [self.msgLabel showNormalMsg:gestureTextBeforeSet];
            self.showImage.image = kAppIcon;
            isShowDefaultImage = YES;
        } else {
            
            [self.msgLabel showWarnMsgAndShake:gestureTextGestureVerifyError];
        }
    }
}

- (void)cicleView:(PCCircleView *)view type:(CircleViewType)type didEndGesture:(UIImage *)image {
    
    if (type == CircleViewTypeSetting) {
        
        if (self.type == LZGestureTypeScreen) {
            
            return;
        }
        
        if (isShowDefaultImage) {
            
            isShowDefaultImage = NO;
            self.showImage.image = kAppIcon;
        } else {
            
            self.showImage.image = image;
        }
        
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

@end
