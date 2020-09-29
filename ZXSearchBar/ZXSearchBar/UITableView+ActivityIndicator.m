//
//  UITableView+ActivityIndicator.m
//  SmartMeterMgr
//
//  Created by apple on 2019/1/3.
//  Copyright © 2019年 suntrontios. All rights reserved.
//

#import "UITableView+ActivityIndicator.h"
#import "Masonry.h"

@implementation UITableView (ActivityIndicator)

- (UIActivityIndicatorView *)activityIndicatorView {
    
    UIActivityIndicatorView *activity = [self viewWithTag:20180103];
    if (!activity) {
        activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activity.tag = 20180103;
        [self addSubview:activity];
        [activity mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.top.equalTo(@(15));
            make.size.mas_equalTo(CGSizeMake(20, 20));
        }];
    }
    
    return activity;
}

- (void)setTopSpaceForActivity:(CGFloat)topSpace {
    
    UIActivityIndicatorView *activity = [self viewWithTag:20180103];
    
    [activity mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(@(topSpace));
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
}

- (void)startActivityAnimation {
    [[self activityIndicatorView] setHidden:NO];
    [[self activityIndicatorView] startAnimating];
}
- (void)stopActivityAnimation {
    [[self activityIndicatorView] setHidden:YES];
    [[self activityIndicatorView] stopAnimating];
}

@end
