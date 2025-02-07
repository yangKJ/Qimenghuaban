//
//  KJBaseViewController.h
//  YunFengSi
//
//  Created by 杨科军 on 2018/9/17.
//  Copyright © 2018年 杨科军. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KJBaseViewController : UIViewController

/// ------------ Method ------------
/// Initialization method. This is the preferred way to create a new Controller.
///
/// params   - The parameters to be passed to Controller.
///
/// Returns a new Controller.
- (instancetype)initWithParams:(NSDictionary *)params;

/// 基础配置 （PS：子类可以重写，但不需要在ViewDidLoad中手动调用，但是子类重写必须调用 [super configure]）
//- (void)configure;

/// 请求远程数据
/// sub class can override ， 但不需要在ViewDidLoad中手动调用 ，依赖`shouldRequestRemoteDataOnViewDidLoad = YES` 且不用调用 super， 直接重写覆盖
- (void)requestRemoteData;

/// fetch the local data
/// sub class can override ，且不用调用 super， 直接重写覆盖
/// Returns a local data.
- (id)fetchLocalData;

/// ------------ Property ------------
/// The `params` parameter in `-initWithParams:` method.
/// The `params` Key's `KJViewControllerIDKey`
@property (nonatomic, readonly, copy)NSDictionary *params;

/// The callback block. 当Push/Present时，通过block反向传值
@property (nonatomic, readwrite, copy)void (^callback)(id);

/** should request data when viewController videwDidLoad . default is YES*/
/** 是否需要在控制器viewDidLoad后调用`requestRemoteData` default is YES*/
@property (nonatomic, readwrite, assign)BOOL shouldRequestRemoteDataOnViewDidLoad;

/// FDFullscreenPopGesture
/// Whether the interactive pop gesture is disabled when contained in a navigation
/// stack. (是否取消掉左滑pop到上一层的功能（栈底控制器无效），默认为NO，不取消)
@property (nonatomic, readwrite, assign)BOOL interactivePopDisabled;
/// Indicate this view controller prefers its navigation bar hidden or not,
/// checked when view controller based navigation bar's appearance is enabled.
/// Default to NO, bars are more likely to show.
/// 是否隐藏该控制器的导航栏 默认是不隐藏 (NO)
@property (nonatomic, readwrite, assign)BOOL prefersNavigationBarHidden;
/// 是否隐藏该控制器的导航栏底部的分割线 默认不隐藏 （NO）
@property (nonatomic, readwrite, assign)BOOL prefersNavigationBarBottomLineHidden;


/// IQKeyboardManager
/// 是否让IQKeyboardManager的管理键盘的事件 默认是YES（键盘管理）
@property (nonatomic, readwrite, assign)BOOL keyboardEnable;
/// 是否键盘弹起的时候，点击其他区域键盘掉下 默认是 YES
@property (nonatomic, readwrite, assign)BOOL shouldResignOnTouchOutside;
/// To set keyboard distance from textField. can't be less than zero. Default is 10.0.
/// keyboardDistanceFromTextField
@property (nonatomic, readwrite, assign)CGFloat keyboardDistanceFromTextField;

/// 截图（Push/Pop Present/Dismiss 过度过程中的缩略图）主要用在过渡动画里面
@property (nonatomic, readwrite, strong)UIView *snapshot;

#pragma mark - 转场动画相关
// Bubble样式的转场动画效果 sourceRect:从什么位置产生气泡  StrokeColor:填充颜色
- (void)presentationBubbleAnimationFromVC:(UIViewController*)fromVC ToVC:(UIViewController*)toVC Frame:(CGRect)sourceRect StrokeColor:(UIColor*)strokeColor;

// Explode样式的转场动画效果 Time:持续时间(默认为1.0秒)
- (void)presentationExplodeAnimationFromVC:(UIViewController*)fromVC ToVC:(UIViewController*)toVC Time:(NSTimeInterval)continueTime;

@end
