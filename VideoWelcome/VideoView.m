//
//  VideoView.m
//  VideoWelcome
//
//  Created by 王晨晓 on 15/7/15.
//  Copyright (c) 2015年 Chinsyo. All rights reserved.
//

#import "VideoView.h"

@implementation VideoView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (void)setPlayer:(AVPlayer *)player {
    AVPlayerLayer *layer = (AVPlayerLayer *)self.layer;
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [layer setPlayer:player];
}

@end
