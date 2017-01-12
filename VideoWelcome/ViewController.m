//
//  ViewController.m
//  VideoWelcome
//
//  Created by 王晨晓 on 15/7/15.
//  Copyright (c) 2015年 Chinsyo. All rights reserved.
//

#import "ViewController.h"
#import "CardView.h"
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSUInteger, buttonDirection) {
    buttonLeft = 0,
    buttonRight,
};

typedef NS_ENUM(NSUInteger, currentStatus) {
    freeStatus = 0,
    loginStatus,
    signupStatus,
};

static const float PLAYER_VOLUME = 0.0;
static const float BUTTON_PADDING = 20.0f;
static const float BUTTON_CORNER_RADIUS = 8.0f;
static const float BUTTON_ANIM_DURATION = 3.0f;
static const float TITLE_ANIM_DURATION = 5.0f;
static const float TITLE_FONT_SIZE = 72.0f;

const NSString *leftButtonFreeTitle = @"Login";
const NSString *leftButtonLoginTitle = @"Confirm Login";
const NSString *leftButtonSignupTitle = @"Confirm Signup";

const NSString *rightButtonFreeTitle = @"Signup";
const NSString *rightButtonLoginTitle = @"Cancel Login";
const NSString *rightButtonSignupTitle = @"Cancel Signup";

const NSString *leftButtonFreeAction = @"loginClick";
const NSString *leftButtonLoginAction = @"confirmClick";
const NSString *leftButtonSignupAction = @"confirmClick";

const NSString *rightButtonFreeAction = @"signupClick";
const NSString *rightButtonLoginAction = @"cancelClick";
const NSString *rightButtonSignupAction = @"cancelClick";

@interface ViewController ()
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UIButton *leftButton;
@property (nonatomic) UIButton *rightButton;

@property (nonatomic) CardView *cardView;
@property (nonatomic) currentStatus status;

@property (nonatomic) AVPlayer *player;
@property (weak, nonatomic) IBOutlet UIView *playerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.status = freeStatus;
    
    [self createVideoPlayer];
    [self createTitleLabel];
    [self createTwoButton];
    [self createShowAnim];
    [self addCardView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChangeFrame:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil
     ];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)createShowAnim {
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    anim.fromValue = @0.0f;
    anim.toValue = @1.0f;
    anim.duration = BUTTON_ANIM_DURATION;
    for (UIView *subview in self.view.subviews) {
        if ([subview isEqual:self.playerView] || [subview isEqual:self.titleLabel]) {
            continue;
        }
        [subview.layer addAnimation:anim forKey:@"alpha"];
    }
    CAKeyframeAnimation *keyAnim = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    keyAnim.duration = TITLE_ANIM_DURATION;
    keyAnim.values = @[@0.0, @1.0, @0.0];
    keyAnim.keyTimes = @[@0.0, @0.35, @1.0];
    [self.titleLabel.layer addAnimation:keyAnim forKey:@"opacity"];
}

- (void)createVideoPlayer {
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"welcome_video" ofType:@"mp4"];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];

    self.player = [AVPlayer playerWithPlayerItem:playerItem];
    self.player.volume = PLAYER_VOLUME;
    
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    playerLayer.videoGravity = UIViewContentModeScaleToFill;
    playerLayer.frame = self.playerView.layer.bounds;
    [self.playerView.layer addSublayer:playerLayer];

    [self.player play];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}

- (void)createTitleLabel {
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 80, 80)];
    self.titleLabel.alpha = 0.0f;
    self.titleLabel.center = self.view.center;
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.text = @"UBER";
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.2];
    self.titleLabel.font = [UIFont systemFontOfSize:TITLE_FONT_SIZE];
    [self.view addSubview:self.titleLabel];
}

- (void)createTwoButton {
    self.leftButton = [self createButtonWithTitle:@"Log in" index:buttonLeft action:@selector(loginClick)];
    self.rightButton = [self createButtonWithTitle:@"Sign up" index:buttonRight action:@selector(signupClick)];
    [self.view addSubview:self.leftButton];
    [self.view addSubview:self.rightButton];
}

- (UIButton *)createButtonWithTitle:(NSString *)title index:(buttonDirection)index action:(SEL)action {
    float screenWidth = self.view.frame.size.width;
    float screenHeight = self.view.frame.size.height;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setFrame:CGRectMake(0, 0, (screenWidth - 3*BUTTON_PADDING) / 2, 30)];
    [button setCenter:CGPointMake((screenWidth / 4) + (index * screenWidth / 2), screenHeight - 30)];
    [button setTintColor:[UIColor whiteColor]];
    [button setBackgroundColor:[UIColor clearColor]];
    
    button.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    button.layer.borderWidth = 1.0f;
    button.layer.borderColor = [[UIColor whiteColor] CGColor];
    button.clipsToBounds = YES;
    
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

#pragma mark - observer of player

// 视频循环播放
- (void)moviePlayDidEnd:(NSNotification*)notification{
    
    AVPlayerItem *item = [notification object];
    [item seekToTime:kCMTimeZero];
    [self.player play];
}

#pragma mark - keyboard
// 解决键盘遮挡textfield和确认按钮,通过通知中心触发,改变相应视图frame
- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGRect beginKeyboardRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect endKeyboardRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat yOffset = endKeyboardRect.origin.y - beginKeyboardRect.origin.y;
    for (UIView *subview in self.view.subviews) {
        if ([subview isEqual:self.playerView] || [subview isEqual:self.titleLabel]) {
            continue;
        }
        CGRect frame = subview.frame;
        frame.origin.y += yOffset;
        subview.frame = frame;
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    
    if (!self.player) return;
    [self.player play];
}

#pragma mark - button click
- (void)loginClick {
    [self transitionToNewStatus:loginStatus];
}

- (void)signupClick {
    [self transitionToNewStatus:signupStatus];
}

- (void)confirmClick {
    for (UIView *subview in self.cardView.subviews) {
        [subview resignFirstResponder];
    }
    NSLog(@"%@成功 %@ %@",self.status == 1 ? @"登陆":@"注册", self.cardView.username.text, self.cardView.password.text);
    [self transitionToNewStatus:freeStatus];
}

- (void)cancelClick {
    for (UIView *subview in self.cardView.subviews) {
        [subview resignFirstResponder];
    }
    [self transitionToNewStatus:freeStatus];
}

// 当前按钮状态发生改变时改变按钮标题和事件
- (void)transitionToNewStatus:(currentStatus)newStatus {

    NSArray *leftButtonTitles = @[leftButtonFreeTitle, leftButtonLoginTitle, leftButtonSignupTitle];
    NSArray *rightButtonTitles = @[rightButtonFreeTitle, rightButtonLoginTitle, rightButtonSignupTitle];
    NSArray *leftButtonActions = @[leftButtonFreeAction, leftButtonLoginAction, leftButtonSignupAction];
    NSArray *rightButtonActions = @[rightButtonFreeAction, rightButtonLoginAction, rightButtonSignupAction];
    
    // 移除按钮事件
    [self.leftButton removeTarget:self action:NSSelectorFromString(leftButtonActions[self.status]) forControlEvents:UIControlEventTouchUpInside];
    [self.rightButton removeTarget:self action:NSSelectorFromString(rightButtonActions[self.status]) forControlEvents:UIControlEventTouchUpInside];
   
    // 刷新当前状态
    self.status = newStatus;
    
    // 刷新按钮事件
    [self.leftButton addTarget:self action:NSSelectorFromString(leftButtonActions[newStatus]) forControlEvents:UIControlEventTouchUpInside];
    [self.leftButton setTitle:leftButtonTitles[newStatus] forState:UIControlStateNormal];
    [self.rightButton addTarget:self action:NSSelectorFromString(rightButtonActions[newStatus]) forControlEvents:UIControlEventTouchUpInside];
    [self.rightButton setTitle:rightButtonTitles[newStatus] forState:UIControlStateNormal];
    
    switch (self.status) {
        case freeStatus:
            [self hideCardView];
            break;
            
        case loginStatus:
        case signupStatus:
            [self showCardView];
            break;
    }
}

#pragma mark - CardView Animation
- (void)addCardView {
    // TODO: 修改为弹性动画
    _cardView = [[CardView alloc] init];
    _cardView.center = CGPointMake(CGRectGetMidX(self.view.bounds), -CGRectGetMidY(_cardView.bounds));
    [self.view addSubview:_cardView];
}

- (void)showCardView {
    [UIView animateWithDuration:1.0 animations:^{
        CGPoint center = CGPointMake(self.cardView.center.x, self.cardView.center.y + 500);
        self.cardView.center = center;
    }];
}

- (void)hideCardView {
    self.cardView.username.text = self.cardView.password.text = @"";
    [UIView animateWithDuration:0.3 animations:^{
        CGPoint center = CGPointMake(self.cardView.center.x, self.cardView.center.y - 500);
        self.cardView.center = center;
    }];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
