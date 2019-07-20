//
//  KJMeForUSVC.m
//  袋鼠记
//
//  Created by 杨科军 on 2018/10/19.
//  Copyright © 2018年 杨科军. All rights reserved.
//

#import "KJMeForUSVC.h"

@interface KJMeForUSVC ()

@property (weak, nonatomic) IBOutlet UILabel *appName;
@property (weak, nonatomic) IBOutlet UILabel *appVersion;

@end

@implementation KJMeForUSVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"关于我们";
    self.view.theme_backgroundColor = @"block_bg";
    
    self.appName.text = kAppName;
    self.appVersion.text = [NSString stringWithFormat:@"版本: %@",[KJTools appVersion]];
    
    self.appName.theme_textColor = @"text_h1";
    self.appVersion.theme_textColor = @"text_h1";
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
