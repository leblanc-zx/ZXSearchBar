//
//  ZXSearchBar.h
//  YiXunJian
//
//  Created by apple on 2019/10/24.
//  Copyright © 2019 新天科技股份有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJRefresh.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ZXSearchBarCancelButtonMode) {
    ZXSearchBarCancelButtonModeNever,
    ZXSearchBarCancelButtonModeWhileEditing,
    ZXSearchBarCancelButtonModeAlways,
};

typedef struct ZXViewRect {
    CGFloat left;
    CGFloat right;
    CGFloat bottom;
    CGFloat height;
}ZXViewRect;

CG_INLINE ZXViewRect
ZXViewRectMake(CGFloat left, CGFloat right, CGFloat bottom, CGFloat height)
{
  ZXViewRect rect;
  rect.left = left; rect.right = right;
  rect.bottom = bottom; rect.height = height;
  return rect;
}

@class ZXSearchBar;
@protocol ZXSearchBarDelegate <NSObject, UITableViewDataSource, UITableViewDelegate>

@optional
/// Return YES 可以变成活跃，NO不能变成活跃
- (BOOL)searchBarShouldBecomeActive:(ZXSearchBar *)searchBar;
/// 搜索关键字发生变化
- (void)searchBar:(ZXSearchBar *)searchbar textDidChange:(NSString *)searchText complete:(void(^)(BOOL hasMoreData))complete;
/// 上拉加载更多
- (void)searchBar:(ZXSearchBar *)searchbar searchTextForSearchMore:(NSString *)searchText complete:(void(^)(BOOL hasMoreData))complete;
/// 变成活跃 或 变成非活跃 
- (void)searchBar:(ZXSearchBar *)searchbar isActive:(BOOL)active;
/// 关闭搜索时，是否清空搜索关键字，默认清空
- (BOOL)clearTextWhenClose:(ZXSearchBar *)searchBar;
/// 取消按钮点击
- (void)searchBar:(ZXSearchBar *)searchbar cancelButtonClick:(UIButton *)sender;

@end

@interface ZXSearchBar : UIView

///灰色容器：装载 searchIcon,textField,cancelButton
@property (nonatomic, strong) UIView *searchBarContainer;
///灰色容器的Rect，默认 left: 12, right: 12, bottom: 0, height: 30
@property (nonatomic, assign) ZXViewRect searchBarContainerRect;
@property (nonatomic, strong) UIImageView *searchIcon;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIImageView *line;
///右侧取消按钮
@property (nonatomic, strong) UIButton *cancelButton;
///右侧取消按钮取消方式 默认 WhileEditing
@property (nonatomic, assign) ZXSearchBarCancelButtonMode cancelButtonMode;

///搜索是否正在活动
@property (nonatomic, assign, readonly) BOOL isActive;

///搜索结果tableView
@property (nonatomic, strong) UITableView *searchResultTableView;
///搜索结果tableView偏移defult is UIEdgeInsetsMake(top: 0, left: 0, bottom: 0, right: 0)
@property (nonatomic, assign) UIEdgeInsets searchResultTableViewEdgeInsets;

///蒙版,搜索到结果后，会被动态添加到界面上
@property (strong, nonatomic) UIView *searchResultView;
///蒙版偏移defult is UIEdgeInsetsMake(top: 0, left: 0, bottom: 0, right: 0)
@property (nonatomic, assign) UIEdgeInsets searchResultViewEdgeInsets;
///蒙版颜色
@property (nonatomic, strong) UIColor *maskingColor;
/// 代理
@property (nonatomic, weak) id<ZXSearchBarDelegate> delegate;

/// 关闭搜索结果
- (void)closeSearchResult;
/// 搜索完成后请执行回调，用于关闭动画
- (void)searchComplete:(BOOL)hasMoreData;
/// 直接搜索
- (void)searchWithText:(NSString *)text ;

@end

NS_ASSUME_NONNULL_END
