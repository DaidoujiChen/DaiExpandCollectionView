//
//  DaiExpandCollectionViewFlowLayout.h
//  DaiExpandCollectionView
//
//  Created by DaidoujiChen on 2015/5/11.
//  Copyright (c) 2015年 DaidoujiChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DaiExpandCollectionViewFlowLayoutDelegate;

@interface DaiExpandCollectionViewFlowLayout : UICollectionViewFlowLayout

@property (nonatomic, weak) id <DaiExpandCollectionViewFlowLayoutDelegate> delegate;
@property (nonatomic, readonly) CGSize originalSize;
@property (nonatomic, readonly) CGSize expandSize;
@property (nonatomic, assign) NSInteger itemsInRow;

- (instancetype)initWithFrame:(CGRect)frame itemsInRow:(NSInteger)items;
- (void)reloadGrid;

@end

@protocol DaiExpandCollectionViewFlowLayoutDelegate <NSObject>

@required
- (NSIndexPath *)selectedIndexPath;
- (NSIndexPath *)previousSelectedIndexPath;

@end
