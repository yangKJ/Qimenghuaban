//
//  AppDelegate.h
//  YunFengSi
//
//  Created by 杨科军 on 2018/9/17.
//  Copyright © 2018年 杨科军. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "KJBaseTabBarController.h"

API_AVAILABLE(ios(10.0))
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic)UIWindow *window;

@property (readonly, strong)NSPersistentContainer *persistentContainer;

@end

#import "AppDelegate+KJCustom.h"
