//
//  ViewController.m
//  VideoWelcome
//
//  Created by 王晨晓 on 15/7/15.
//  Copyright (c) 2015年 Chinsyo. All rights reserved.
//

const float PLAYER_VOLUME = 0.0;
const float BUTTON_PADDING = 20.0f;
const float BUTTON_CORNER_RADIUS = 8.0f;

#import "ViewController.h"
#import "VideoView.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UIButton *logInButton;
@property (nonatomic) UIButton *signUpButton;
@property (nonatomic) AVPlayer *player;
@property (weak, nonatomic) IBOutlet VideoView *playerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createVideoPlayer];
    [self createTitleLabel];
    [self createTwoButton];
    [self createShowAnim];
}

- (void)createShowAnim {
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    anim.fromValue = @0.0f;
    anim.toValue = @1.0f;
    anim.duration = 3.0f;
    for (UIView *subview in self.view.subviews) {
        if ([subview isEqual:self.playerView]) {
            continue;
        }
        [subview.layer addAnimation:anim forKey:@"alpha"];
    }
    
}

- (void)createVideoPlayer {
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"welcome_video" ofType:@"mp4"];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    self.player = [AVPlayer playerWithPlayerItem:playerItem];
    self.player.volume = PLAYER_VOLUME;
    
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    playerLayer.videoGravity = UIViewContentModeScaleToFill;
    [self.playerView.layer addSublayer:playerLayer];

    [self.playerView setPlayer:self.player];
    [self.player play];
    
    [self.player.currentItem addObserver:self forKeyPath:AVPlayerItemDidPlayToEndTimeNotification options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}

- (void)createTitleLabel {
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 80, 80)];
    self.titleLabel.center = self.view.center;
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.text = @"UBER";
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.2];
    self.titleLabel.font = [UIFont systemFontOfSize:72.0f];
    [self.view addSubview:self.titleLabel];
}

- (void)createTwoButton {
    self.logInButton = [self createButtonWithTitle:@"Log in" index:0 action:@selector(loginClick)];
    self.signUpButton = [self createButtonWithTitle:@"Sign up" index:1 action:@selector(signupClick)];
    [self.view addSubview:self.logInButton];
    [self.view addSubview:self.signUpButton];
}

- (UIButton *)createButtonWithTitle:(NSString *)title index:(NSUInteger)index action:(SEL)action {
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
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

}


- (void)moviePlayDidEnd:(NSNotification*)notification{
    
    AVPlayerItem *item = [notification object];
    [item seekToTime:kCMTimeZero];
    [self.player play];
}

#pragma mark - button click
- (void)loginClick {

}

- (void)signupClick {

}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
