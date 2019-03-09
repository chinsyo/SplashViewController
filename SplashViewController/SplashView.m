//
//  SplashView.m
//  SplashViewController
//
//  Created by 王晨晓 on 15/7/16.
//  Copyright (c) 2015年 Chinsyo. All rights reserved.
//

#import "SplashView.h"

@implementation SplashView

- (instancetype)init {
    self = [super init]
    if (self) {
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        CGRect frame = CGRectMake(0, 0, screenSize.width, screenSize.height * 2.0/3);
        self = [[SplashView alloc] initWithFrame:frame];
        self.backgroundColor = [UIColor clearColor];
        self.layer.cornerRadius = 10.0f;
        self.layer.maskToBounds = YES;
        
        for (NSUInteger idx = 0; idx < 2; idx++) {
            UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 220, 30)];
            field.borderStyle = UITextBorderStyleRoundedRect;
            field.center = CGPointMake(self.frame.size.width/2.0, 200 + idx * 50);
            field.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.6f];
            field.placeholder = idx ? @"password" : @"username";
            field.secureTextEntry = idx != 0;
            field.keyboardAppearance = UIKeyboardAppearanceDark;
            if (idx == 0) {
                self.username = field;
            } else {
                self.password = field;
            }
            [self addSubview:field];
        }
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self.subviews makeObjectsPerformSelector:@selector(resignFirstResponder)];

}
@end
