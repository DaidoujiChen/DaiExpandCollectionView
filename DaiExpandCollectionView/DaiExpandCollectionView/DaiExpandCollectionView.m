//
//  DaiExpandCollectionView.m
//  DaiExpandCollectionView
//
//  Created by DaidoujiChen on 2015/5/11.
//  Copyright (c) 2015年 DaidoujiChen. All rights reserved.
//

#import "DaiExpandCollectionView.h"

@interface DaiExpandCollectionView ()

@property (nonatomic, strong) NSLock *animationLock;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) NSInteger previousSelectedIndex;
@property (nonatomic, strong) DaiExpandCollectionViewFlowLayout *daiExpandCollectionViewFlowLayout;

@end

@implementation DaiExpandCollectionView

@synthesize itemsInRow = _itemsInRow;

#pragma mark - custom getter / setter

- (void)setItemsInRow:(NSInteger)itemsInRow {
    if (_itemsInRow != itemsInRow) {
        if ([self.animationLock tryLock]) {
            _itemsInRow = itemsInRow;
            __weak DaiExpandCollectionView *weakSelf = self;
            [self performBatchUpdates:^{
                weakSelf.daiExpandCollectionViewFlowLayout.itemsInRow = itemsInRow;
                [weakSelf.daiExpandCollectionViewFlowLayout reloadGrid];
            } completion:^(BOOL finished) {
                [weakSelf.animationLock unlock];
            }];
        }
    }
}

- (NSInteger)itemsInRow {
    return _itemsInRow;
}

#pragma mark - DaiExpandCollectionViewFlowLayoutDelegate

- (NSIndexPath *)selectedIndexPath {
    if (self.selectedIndex != -1) {
        return [NSIndexPath indexPathForRow:self.selectedIndex inSection:0];
    }
    else {
        return nil;
    }
}

- (NSIndexPath *)previousSelectedIndexPath {
    if (self.previousSelectedIndex != -1) {
        return [NSIndexPath indexPathForRow:self.previousSelectedIndex inSection:0];
    }
    else {
        return nil;
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.selectedIndex || indexPath.row == self.previousSelectedIndex) {
        return self.daiExpandCollectionViewFlowLayout.expandSize;
    }
    else {
        return self.daiExpandCollectionViewFlowLayout.originalSize;
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.expandDelegate numberOfItemsInCollectionView:self];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.expandDelegate collectionView:self cellForItemAtIndexPath:indexPath];
}

#pragma mark - UICollectionViewDelegate

//由使用者點擊畫面上的某個 item 時
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // index 相同的話則回傳, 不同的話則做動畫
    if (self.selectedIndex == indexPath.row) {
        if ([self.expandDelegate respondsToSelector:@selector(collectionView:didSelectItemAtIndex:)]) {
            [self.expandDelegate collectionView:self didSelectItemAtIndex:self.selectedIndex];
        }
    }
    else {
        [self updateCollectionView:self atSelectedIndexPath:indexPath animated:YES];
    }
}

#pragma mark - class method

+ (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame itemsInRow:3];
}

+ (instancetype)initWithFrame:(CGRect)frame itemsInRow:(NSInteger)itemsInRow {
    // init flowlayout
    DaiExpandCollectionViewFlowLayout *newDaiExpandCollectionViewFlowLayout = [[DaiExpandCollectionViewFlowLayout alloc] initWithFrame:frame itemsInRow:itemsInRow];
    
    // init collectionview
    DaiExpandCollectionView *newDaiExpandCollectionView = [[DaiExpandCollectionView alloc] initWithFrame:frame collectionViewLayout:newDaiExpandCollectionViewFlowLayout];
    newDaiExpandCollectionView.daiExpandCollectionViewFlowLayout = newDaiExpandCollectionViewFlowLayout;
    newDaiExpandCollectionView.daiExpandCollectionViewFlowLayout.delegate = newDaiExpandCollectionView;
    newDaiExpandCollectionView.delegate = newDaiExpandCollectionView;
    newDaiExpandCollectionView.dataSource = newDaiExpandCollectionView;
    newDaiExpandCollectionView.selectedIndex = -1;
    newDaiExpandCollectionView.previousSelectedIndex = -1;
    newDaiExpandCollectionView.animationLock = [NSLock new];
    return newDaiExpandCollectionView;
}

#pragma mark - instance method

//外部手動用 code 選擇某一個 index, 只有在 index 不同時才需要做
- (void)expandAtIndex:(NSInteger)index animated:(BOOL)animated {
    if (self.selectedIndex != index) {
        [self updateCollectionView:self atSelectedIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:animated];
    }
}

#pragma mark - private instance method

//動畫效果
- (void)updateCollectionView:(UICollectionView *)collectionView atSelectedIndexPath:(NSIndexPath *)selectedIndexPath animated:(BOOL)animated {
    if ([self.animationLock tryLock]) {
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:selectedIndexPath];
        [collectionView bringSubviewToFront:cell];
        if (animated) {
            __weak DaiExpandCollectionView *weakSelf = self;
            [collectionView performBatchUpdates: ^{
                weakSelf.previousSelectedIndex = weakSelf.selectedIndex;
                weakSelf.selectedIndex = selectedIndexPath.row;
            } completion: ^(BOOL finished) {
                if (weakSelf.previousSelectedIndex != -1) {
                    [weakSelf restoreItemInCollectionView:collectionView atIndexPath:[NSIndexPath indexPathForRow:weakSelf.previousSelectedIndex inSection:0]];
                }
                [weakSelf.animationLock unlock];
            }];
        }
        else {
            self.previousSelectedIndex = self.selectedIndex;
            self.selectedIndex = selectedIndexPath.row;
            [self reloadData];
            if (self.previousSelectedIndex != -1) {
                [self restoreItemInCollectionView:collectionView atIndexPath:[NSIndexPath indexPathForRow:self.previousSelectedIndex inSection:0]];
            }
            [self.animationLock unlock];
        }
    }
}

//還原經過 transform 變化的 item
- (void)restoreItemInCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.transform = CGAffineTransformIdentity;
    CGRect newFrame = cell.frame;
    newFrame.size = self.daiExpandCollectionViewFlowLayout.originalSize;
    cell.frame = newFrame;
}

@end
