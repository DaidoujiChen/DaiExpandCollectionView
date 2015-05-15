//
//  DaiExpandCollectionView.h
//  DaiExpandCollectionView
//
//  Created by DaidoujiChen on 2015/5/11.
//  Copyright (c) 2015年 DaidoujiChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DaiExpandCollectionViewFlowLayout.h"

@protocol DaiExpandCollectionViewDelegate;

@interface DaiExpandCollectionView : UICollectionView <UICollectionViewDelegate, UICollectionViewDataSource, DaiExpandCollectionViewFlowLayoutDelegate>

@property (nonatomic, weak) id <DaiExpandCollectionViewDelegate> expandDelegate;

@property (nonatomic, assign) NSInteger itemsInRow;

// the default itemsInRow is 3
+ (instancetype)initWithFrame:(CGRect)frame;
+ (instancetype)initWithFrame:(CGRect)frame itemsInRow:(NSInteger)itemsInRow;

- (void)expandAtIndex:(NSInteger)index animated:(BOOL)animated;

@end

@protocol DaiExpandCollectionViewDelegate <NSObject>

@required
- (NSInteger)numberOfItemsInCollectionView:(UICollectionView *)collectionView;
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;

@optional
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndex:(NSInteger)index;

@end
