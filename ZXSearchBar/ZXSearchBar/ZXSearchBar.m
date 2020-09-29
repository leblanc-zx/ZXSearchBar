//
//  ZXSearchBar.m
//  YiXunJian
//
//  Created by apple on 2019/10/24.
//  Copyright © 2019 新天科技股份有限公司. All rights reserved.
//

#import "ZXSearchBar.h"
#import "UITableView+ActivityIndicator.h"
#import "IQKeyboardManager.h"
#import "Masonry.h"
#import "CustomRefreshBackFooter.h"

@interface ZXSearchBar ()<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UILabel *noResultLabel;    //无结果

@end

@implementation ZXSearchBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self createUI];
    }
    return self;
}


- (void)createUI {
    
    self.maskingColor = [UIColor colorWithWhite:0 alpha:0.5];
    
    _searchBarContainerRect = ZXViewRectMake(12, 12, 0, 30);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    
    self.backgroundColor = [UIColor redColor];
    
    //灰色容器：装载 searchIcon,textField,cancelButton
    self.searchBarContainer = [[UIView alloc] init];
    [self addSubview:self.searchBarContainer];
    [self.searchBarContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.searchBarContainerRect.left);
        make.right.mas_equalTo(-self.searchBarContainerRect.right);
        make.bottom.mas_equalTo(-self.searchBarContainerRect.bottom);
        make.height.mas_equalTo(self.searchBarContainerRect.height);
    }];
    self.searchBarContainer.backgroundColor = [UIColor whiteColor];
    self.searchBarContainer.layer.cornerRadius = self.searchBarContainerRect.height/2.0;
    self.searchBarContainer.layer.masksToBounds = YES;
    
    
    //cancelButton
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor colorWithRed:255/255.0 green:130/255.0 blue:127/255.0 alpha:1] forState:UIControlStateNormal];
    self.cancelButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    [self.cancelButton addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.cancelButton.hidden = YES;
    [self addSubview:self.cancelButton];
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.searchBarContainer.mas_right);
        make.bottom.mas_equalTo(-_searchBarContainerRect.bottom);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(_searchBarContainerRect.height);
    }];
    
    //searchIcon
    self.searchIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_search.png"]];
    [self.searchBarContainer addSubview:self.searchIcon];
    [self.searchIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.centerY.mas_equalTo(0);
        make.width.mas_equalTo(12);
        make.height.mas_equalTo(12);
    }];
    
    //textField
    self.textField = [[UITextField alloc] init];
    self.textField.delegate = self;
    self.textField.clearButtonMode = UITextFieldViewModeAlways;
    self.textField.returnKeyType = UIReturnKeySearch;
    self.textField.font = [UIFont fontWithName:@"Helvetica" size:15];
    [self.searchBarContainer addSubview:self.textField];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    
    //line
    self.line = [[UIImageView alloc] init];
    self.line.backgroundColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1];
    [self addSubview:self.line];
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(0.5);
        make.bottom.mas_equalTo(0);
    }];
    self.line.hidden = YES;
    
    //searchResultView 蒙版,搜索到结果后，会被动态添加到界面上
    UIControl *control = [[UIControl alloc] init];
    [control addTarget:self action:@selector(searchResultViewTouch:) forControlEvents:UIControlEventTouchUpInside];
    [self.searchResultView addSubview:control];
    [control mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    
    //搜索结果tableView
    self.searchResultTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 10, 10) style:UITableViewStyleGrouped];
    self.searchResultTableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.searchResultTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.searchResultTableView setTopSpaceForActivity:22];
    [self.searchResultView addSubview:self.searchResultTableView];
    self.searchResultTableView.hidden = YES;
    self.searchResultTableView.dataSource = self;
    self.searchResultTableView.delegate = self;
    CustomRefreshBackFooter *footer = [CustomRefreshBackFooter footerWithRefreshingTarget:self refreshingAction:@selector(searchMore)];
    self.searchResultTableView.mj_footer = footer;
    [self.searchResultTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    
    //noResultLabel
    self.noResultLabel = [[UILabel alloc] init];
    self.noResultLabel.textColor = [UIColor colorWithRed:148/255.0 green:148/255.0 blue:148/255.0 alpha:1];
    [self.noResultLabel setTextAlignment:NSTextAlignmentCenter];
    self.noResultLabel.font = [UIFont  fontWithName:@"Helvetica-Bold" size:18.0];
    self.noResultLabel.text = @"无结果";
    [self.searchResultTableView addSubview:self.noResultLabel];
    [self.noResultLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.centerY.equalTo(self.searchResultTableView).multipliedBy(3.5/8.0);
    }];
    
    self.cancelButtonMode = ZXSearchBarCancelButtonModeWhileEditing;
    
}

- (void)setCancelButtonMode:(ZXSearchBarCancelButtonMode)cancelButtonMode {
    
    _cancelButtonMode = cancelButtonMode;
    if (cancelButtonMode == ZXSearchBarCancelButtonModeWhileEditing) {
        //用时展示
        [self.searchBarContainer mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-self.searchBarContainerRect.right);
        }];
        [self layoutIfNeeded];
        self.cancelButton.hidden = YES;
    } else if (cancelButtonMode == ZXSearchBarCancelButtonModeAlways) {
        //总是展示
        [self.searchBarContainer mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-self.searchBarContainerRect.right-40);
        }];
        [self layoutIfNeeded];
        self.cancelButton.hidden = NO;
    } else  {
        //永远隐藏
        [self.searchBarContainer mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-self.searchBarContainerRect.right);
        }];
        [self layoutIfNeeded];
        self.cancelButton.hidden = YES;
    }
    
}

- (void)setSearchBarContainerRect:(ZXViewRect)searchBarContainerRect {
    
    _searchBarContainerRect = searchBarContainerRect;
    
    [self.searchBarContainer mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.searchBarContainerRect.left);
        make.right.mas_equalTo(self.isActive ? (-self.searchBarContainerRect.right-40) : (-self.searchBarContainerRect.right));
        make.bottom.mas_equalTo(-self.searchBarContainerRect.bottom);
        make.height.mas_equalTo(self.searchBarContainerRect.height);
    }];
    
    
    [self.cancelButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.searchBarContainer.mas_right);
        make.bottom.mas_equalTo(-_searchBarContainerRect.bottom);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(_searchBarContainerRect.height);
    }];
    
}

- (void)setSearchResultTableViewEdgeInsets:(UIEdgeInsets)searchResultTableViewEdgeInsets {
    
    _searchResultTableViewEdgeInsets = searchResultTableViewEdgeInsets;
    
    [self.searchResultTableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.searchResultTableViewEdgeInsets.left);
        make.right.mas_equalTo(-self.searchResultTableViewEdgeInsets.right);
        make.top.mas_equalTo(self.searchResultTableViewEdgeInsets.top);
        make.bottom.mas_equalTo(-self.searchResultTableViewEdgeInsets.bottom);
    }];
    if (self.searchResultView.superview != nil) {
        [self.searchResultView layoutIfNeeded];
    }
    
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    if (self.superview) {
        [self.superview addSubview:self.searchResultView];
        self.searchResultView.hidden = YES;
        
        [self.searchResultView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.searchResultViewEdgeInsets.left);
            make.right.mas_equalTo(-self.searchResultViewEdgeInsets.right);
            make.top.mas_equalTo(self.mas_bottom).offset(self.searchResultViewEdgeInsets.top);
            make.bottom.mas_equalTo(-self.searchResultViewEdgeInsets.bottom);
        }];
        
    }
    
}

#pragma mark - methods
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"searchBar_dealloc");
}

- (void)setDelegate:(id<ZXSearchBarDelegate>)delegate {
    _delegate = delegate;
}

- (void)searchComplete:(BOOL)hasMoreData {
    
    [self.searchResultTableView reloadData];
    
    [self.searchResultTableView stopActivityAnimation];

    
    if (!hasMoreData) {
        self.searchResultTableView.mj_footer.hidden = YES;
    } else {
        self.searchResultTableView.mj_footer.hidden = NO;
        [self.searchResultTableView.mj_footer resetNoMoreData];
    }
    
    self.noResultLabel.hidden = NO;
    NSInteger count = [self numberOfSectionsInTableView:self.searchResultTableView];
    for (int i = 0; i < count; i ++) {
        NSInteger rows = [self tableView:self.searchResultTableView numberOfRowsInSection:i];
        if (rows > 0) {
            self.noResultLabel.hidden = YES;
        }
    }
    
}

- (void)searchMore {
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBar:searchTextForSearchMore:complete:)]) {
        
        [self.searchResultTableView.mj_footer beginRefreshing];
        
        __weak typeof(self) weakSelf = self;
        [self.delegate searchBar:self searchTextForSearchMore:self.textField.text complete:^(BOOL hasMoreData) {
            if (hasMoreData) {
                [weakSelf.searchResultTableView.mj_footer endRefreshing];
            } else {
                [weakSelf.searchResultTableView.mj_footer endRefreshingWithNoMoreData];
            }
            [weakSelf.searchResultTableView reloadData];
        }];
    }
    
}

/// 直接搜索
- (void)searchWithText:(NSString *)text {
    self.textField.text = text;
    [self textFieldShouldBeginEditing:self.textField];
    NSNotification *noti = [[NSNotification alloc] initWithName:@"ZXSearchBarTextFieldChange" object:self.textField userInfo:nil];
    [self textFieldDidChange:noti];
}

#pragma mark - clicks
- (void)closeSearchResult {
    [self cancelButtonClick:self.cancelButton];
}

- (void)cancelButtonClick:(UIButton *)sender {
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(clearTextWhenClose:)]) {
        BOOL clear = [self.delegate clearTextWhenClose:self];
        if (clear) {
            self.textField.text = nil;
        }
    } else {
        self.textField.text = nil;
    }
    
    [self endEditing:YES];
    self.searchResultView.hidden = YES;
    
    if (self.cancelButtonMode == ZXSearchBarCancelButtonModeWhileEditing) {
        //用完隐藏
        [UIView animateWithDuration:0.15 animations:^{
            [self.searchBarContainer mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(-self.searchBarContainerRect.right);
            }];
            [self layoutIfNeeded];
            self.cancelButton.hidden = YES;
        }];
    } else if (self.cancelButtonMode == ZXSearchBarCancelButtonModeAlways) {
        //总是展示
    } else  {
        //永远隐藏
    }
    
    _isActive = NO;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBar:isActive:)]) {
        [self.delegate searchBar:self isActive:NO];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBar:cancelButtonClick:)]) {
        if (sender == self.cancelButton) {
            [self.delegate searchBar:self cancelButtonClick:self.cancelButton];
        }
    }
    
}

- (void)searchResultViewTouch:(UIControl *)control {
    [self cancelButtonClick:nil];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self endEditing:YES];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBarShouldBecomeActive:)]) {
        BOOL shouldBecomeActive = [self.delegate searchBarShouldBecomeActive:self];
        if (shouldBecomeActive == NO) {
            return NO;
        }
    }
    
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    
    self.searchResultView.backgroundColor = self.maskingColor;
    self.searchResultView.hidden = NO;
    self.searchResultTableView.hidden = textField.text.length == 0;
    
    if (self.cancelButtonMode == ZXSearchBarCancelButtonModeWhileEditing) {
        //用时展示
        [UIView animateWithDuration:0.15 animations:^{
            [self.searchBarContainer mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(-self.searchBarContainerRect.right-40);
            }];
            [self layoutIfNeeded];
            self.cancelButton.hidden = NO;
        }];
    } else if (self.cancelButtonMode == ZXSearchBarCancelButtonModeAlways) {
        //总是展示
    } else  {
        //永远隐藏
    }
    
    
    if (_isActive == YES) {
        return YES;
    }
    _isActive = YES;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBar:isActive:)]) {
        [self.delegate searchBar:self isActive:YES];
    }
    
    return YES;
}

- (void)textFieldDidChange:(NSNotification *)noti {
    UITextField *textField = noti.object;
    
    if (textField != self.textField) {
        return;
    }
    
    if (textField.markedTextRange) {
        return;
    }
    
    self.searchResultTableView.hidden = YES;
    
    self.searchResultTableView.hidden = textField.text.length == 0;

    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBar:textDidChange:complete:)]) {
        [self.searchResultTableView startActivityAnimation];
        self.noResultLabel.hidden = YES;
        self.searchResultTableView.mj_footer.hidden = YES;
        __weak typeof(self) weakSelf = self;
        [self.delegate searchBar:self textDidChange:textField.text complete:^(BOOL hasMoreData) {
            [weakSelf searchComplete:hasMoreData];
        }];
    }
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"\n"]) {
        
        [self endEditing:YES];
        self.searchResultTableView.hidden = NO;
        if (self.delegate && [self.delegate respondsToSelector:@selector(searchBar:textDidChange:complete:)]) {
            [self.searchResultTableView startActivityAnimation];
            self.noResultLabel.hidden = YES;
            self.searchResultTableView.mj_footer.hidden = YES;
            __weak typeof(self) weakSelf = self;
            [self.delegate searchBar:self textDidChange:textField.text complete:^(BOOL hasMoreData) {
                
                [weakSelf searchComplete:hasMoreData];
            }];
        }
        
        return NO;
    } else {
        
        return YES;
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.delegate respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
        return [self.delegate numberOfSectionsInTableView:tableView];
    } else {
        return 1;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.delegate tableView:tableView numberOfRowsInSection:section];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.delegate tableView:tableView cellForRowAtIndexPath:indexPath];
}
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
        return [self.delegate tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)]) {
        return [self.delegate tableView:tableView heightForHeaderInSection:section];
    }
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)]) {
        return [self.delegate tableView:tableView viewForHeaderInSection:section];
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:heightForFooterInSection:)]) {
        return [self.delegate tableView:tableView heightForFooterInSection:section];
    }
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:viewForFooterInSection:)]) {
        return [self.delegate tableView:tableView viewForFooterInSection:section];
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        [self.delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

#pragma mark - Lazy loading
- (UIView *)searchResultView {
    if (!_searchResultView) {
        _searchResultView = [[UIView alloc] init];
    }
    return _searchResultView;
}

@end
