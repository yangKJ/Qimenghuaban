//
//  KJCompassView.h
//  MoLiao
//
//  Created by 杨科军 on 2018/7/20.
//  Copyright © 2018年 杨科军. All rights reserved.
//

#import "KJCompassView.h"
#import "KJLoctionManager.h"

#define toRad(X) (X*M_PI/180.0)
#define toDeg(X) (X*180.0/M_PI)
#define defaultRadius 100

@interface KJCompassView () 

@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, assign) CGPoint point;
@property (nonatomic, assign) CGFloat scale;

@property (nonatomic, weak) UIImageView *pointerImageView;
@property (nonatomic, weak) UIView *dialView;
@property (nonatomic, weak) UIView *horizontalView;

@property (nonatomic, strong) KJLoctionManager *manager;

@end

@implementation KJCompassView

+ (instancetype)sharedWithRect:(CGRect)rect radius:(CGFloat)radius{
    return [[self alloc]initWithFrame:rect radius:radius];
}

- (instancetype)initWithFrame:(CGRect)frame radius:(CGFloat)radius{
    if (self = [super initWithFrame:frame]) {
        _point = CGPointMake(frame.size.width/2, frame.size.height/2);
        _radius = radius;
        _scale = radius/100;
        _textColor = [UIColor blackColor];
        _calibrationColor = [UIColor blackColor];
        _northColor = [UIColor redColor];
        [self setUI];
        [self startSensor];
    }
    return self;
}

- (void)setUI{
    [self createPointer];
    [self createDial];
    [self createCalibration];
    [self createHorizontalView];
    [self resetSize];
}


/**
 *  重置尺寸
 */
- (void)resetSize{
    _dialView.transform = CGAffineTransformScale(_dialView.transform, _scale, _scale);
}


/**
 *  创建表盘
 */
- (void)createDial{
    UIView *dialView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, defaultRadius*2, defaultRadius*2)];
    dialView.center = _point;
    _dialView = dialView;
    [self addSubview:_dialView];
    
    UIBezierPath *bezPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(_dialView.frame.size.width/2, _dialView.frame.size.height/2) radius:defaultRadius startAngle:-M_PI_2 endAngle:M_PI_2*3 clockwise:YES];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.lineWidth = 1;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.strokeColor = _calibrationColor.CGColor;
    shapeLayer.path = bezPath.CGPath;
    [_dialView.layer addSublayer:shapeLayer];
}

/**
 *  创建刻度
 */
- (void)createCalibration{
    CGFloat perAngle = M_PI/90;
    NSArray *array = @[@"N",@"E",@"S",@"W"];
    for (int i = 0; i < 180; i++) {
        CGFloat startAngle = (-M_PI_2+perAngle*i);
        CGFloat endAngle = startAngle+perAngle/2;
        
        UIBezierPath *bezPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(_dialView.frame.size.width/2, _dialView.frame.size.height/2) radius:defaultRadius*0.9 startAngle:startAngle endAngle:endAngle clockwise:YES];
        
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        
        if (i == 0) {
            shapeLayer.strokeColor = _northColor.CGColor;
            shapeLayer.lineWidth = 10;
        }else if (i%15 == 0) {
            shapeLayer.strokeColor = _calibrationColor.CGColor;
            shapeLayer.lineWidth = 10;
        }else{
            shapeLayer.strokeColor = CGColorCreateCopyWithAlpha(_calibrationColor.CGColor, 0.6);
            shapeLayer.lineWidth = 5;
        }
        
        shapeLayer.path = bezPath.CGPath;
        shapeLayer.fillColor = [UIColor clearColor].CGColor;
        [_dialView.layer addSublayer:shapeLayer];
        
        if (i%15 == 0){
            NSString *tickText = [NSString stringWithFormat:@"%d",i * 2];
            if (i%45 == 0){
                tickText = array[i/45];
            }
            
            if (i < 180) {
                CGFloat textAngel = startAngle+(endAngle-startAngle)/2;
                CGPoint point = [self calculateTextPositonWithArcCenter:CGPointMake(_dialView.frame.size.width/2, _dialView.frame.size.height/2) Angle:textAngel];
                
                UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(point.x, point.y, 18, 12)];
                label.center = point;
                label.text = tickText;
                label.textColor = _textColor;
                label.font = [UIFont systemFontOfSize:8];
                label.textAlignment = NSTextAlignmentCenter;
                label.transform = CGAffineTransformRotate(CGAffineTransformIdentity, (CGFloat)toRad(i * 2));
                
                [_dialView addSubview:label];
            }
        }
    }
}

- (void)setPointerImage:(UIImage *)pointerImage{
    self.pointerImageView.image = pointerImage;
}

/**
 *  创建指针
 */
- (void)createPointer{
    UIImageView *pointerImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _radius*2, _radius*2)];
    pointerImageView.center = _point;
    [pointerImageView setImage:[UIImage imageNamed:@"compass"]];
    _pointerImageView = pointerImageView;
    [self addSubview:_pointerImageView];
}

/**
 *  创建水平仪
 */
- (void)createHorizontalView{
    UIView *horizontalView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, (_radius*2/1500)*70, (_radius*2/1500)*70)];
    horizontalView.center = _point;
    horizontalView.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.3];
    horizontalView.layer.cornerRadius = horizontalView.frame.size.height/2;
    horizontalView.layer.masksToBounds = YES;
    _horizontalView = horizontalView;
    [self addSubview:_horizontalView];
}

/**
 *  启动传感器
 */
- (void)startSensor{
    __weak typeof(self)mySelf = self;
    _manager = [KJLoctionManager shared];
    
    _manager.didUpdateHeadingBlock = ^(CLLocationDirection theHeading){
        [mySelf updateHeading:theHeading];
    };
    _manager.updateDeviceMotionBlock = ^(CMDeviceMotion *data){
        mySelf.horizontalView.center = CGPointMake(mySelf.point.x + data.gravity.x*100, mySelf.point.y + data.gravity.y*100);
    };
    [_manager startSensor];
    [_manager startGyroscope];
}

- (void)updateHeading:(CLLocationDirection)theHeading{
    __weak typeof(self)mySelf = self;
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction animations:^{
         CGAffineTransform headingRotation = CGAffineTransformRotate(CGAffineTransformIdentity, (CGFloat)-toRad(theHeading));
         headingRotation = CGAffineTransformScale(headingRotation, mySelf.scale, mySelf.scale);
         mySelf.dialView.transform = headingRotation;
    }completion:nil];
    // Animate Pointer
    [UIView animateWithDuration:0.6 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction animations:^{
         CGAffineTransform headingRotation = CGAffineTransformRotate(CGAffineTransformIdentity, (CGFloat)toRad(0)-toRad(theHeading));
         headingRotation = CGAffineTransformScale(headingRotation, mySelf.scale, mySelf.scale);
         mySelf.dialView.transform = headingRotation;
    }completion:nil];
}

//计算中心坐标
- (CGPoint)calculateTextPositonWithArcCenter:(CGPoint)center Angle:(CGFloat)angel{
    CGFloat x = defaultRadius*0.75 * cosf(angel);
    CGFloat y = defaultRadius*0.75 * sinf(angel);
    return CGPointMake(center.x + x, center.y + y);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - 设置属性
- (void)setTextColor:(UIColor *)textColor{
    _textColor = textColor;
    [self removeAll];
    [self setUI];
}

- (void)setCalibrationColor:(UIColor *)calibrationColor{
    _calibrationColor = calibrationColor;
    [self removeAll];
    [self setUI];
}

- (void)setNorthColor:(UIColor *)northColor{
    _northColor = northColor;
    [self removeAll];
    [self setUI];
}

- (void)setHorizontalColor:(UIColor *)horizontalColor{
    _horizontalColor = horizontalColor;
    UIColor *color = [UIColor colorWithCGColor:CGColorCreateCopyWithAlpha(_horizontalColor.CGColor, 0.7)];
    _horizontalView.backgroundColor = color;
}

- (void)removeAll{
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
}

@end
