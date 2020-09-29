//
//  UITableView+ActivityIndicator.h
//  SmartMeterMgr
//
//  Created by apple on 2019/1/3.
//  Copyright © 2019年 suntrontios. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITableView (ActivityIndicator)

- (void)setTopSpaceForActivity:(CGFloat)topSpace;
- (void)startActivityAnimation;
- (void)stopActivityAnimation;

@end

NS_ASSUME_NONNULL_END
