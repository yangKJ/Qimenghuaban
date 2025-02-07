//
//  KJErrorView.h
//  GuessWho
//
//  Created by 杨科军 on 2018/11/20.
//  Copyright © 2018 杨科军. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KJErrorView : UIView

+ (instancetype)createErrorView:(void(^)(KJErrorView *obj))block;

// 链接式设置属性
@property(nonatomic,strong,readonly) KJErrorView *(^Tag)(NSInteger);
@property(nonatomic,strong,readonly) KJErrorView *(^Frame)(CGRect);//frame
@property(nonatomic,strong,readonly) KJErrorView *(^BackgroundColor)(UIColor *);//backgroundColor
@property(nonatomic,strong,readonly) KJErrorView *(^AddView)(UIView *);

@end

NS_ASSUME_NONNULL_END
