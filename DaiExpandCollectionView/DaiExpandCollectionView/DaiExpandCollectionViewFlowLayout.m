//
//  DaiExpandCollectionViewFlowLayout.m
//  DaiExpandCollectionView
//
//  Created by DaidoujiChen on 2015/5/11.
//  Copyright (c) 2015年 DaidoujiChen. All rights reserved.
//

#import "DaiExpandCollectionViewFlowLayout.h"

#define defaultGap 5.0f

typedef enum {
    DaiExpandCollectionViewFlowLayoutExpandDirectionLeft,
    DaiExpandCollectionViewFlowLayoutExpandDirectionRight
} DaiExpandCollectionViewFlowLayoutExpandDirection;

@interface DaiExpandCollectionViewFlowLayout ()

@property (nonatomic, assign) CGSize originalSize;
@property (nonatomic, assign) CGSize expandSize;
@property (nonatomic, assign) CGFloat squareWithGap;
@property (nonatomic, assign) CGFloat maxWidth;
@property (nonatomic, assign) CGFloat maxHeight;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign) DaiExpandCollectionViewFlowLayoutExpandDirection expandDirection;

@end

@implementation DaiExpandCollectionViewFlowLayout

#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame itemsInRow:(NSInteger)items {
    self = [super init];
    if (self) {
        self.itemsInRow = items;
        self.frame = frame;
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.minimumLineSpacing = defaultGap;
        self.minimumInteritemSpacing = 0;
        self.sectionInset = UIEdgeInsetsMake(defaultGap, defaultGap, 0, 0);
        self.expandDirection = DaiExpandCollectionViewFlowLayoutExpandDirectionRight;
        
        [self reloadGrid];
    }
    return self;
}

#pragma mark - method to override

- (void)prepareLayout {
    [super prepareLayout];
    
    self.expandDirection = !self.expandDirection;
    
    //計算 data 長度
    NSIndexPath *selectedIndexPath = [self.delegate selectedIndexPath];
    self.maxWidth = CGRectGetWidth(self.collectionView.frame);
    if (selectedIndexPath) {
        NSInteger increaseItems = pow((self.itemsInRow - 1), 2) - 1;
        self.maxHeight = defaultGap + ceil(((float)[self.collectionView numberOfItemsInSection:0] + increaseItems) / self.itemsInRow) * self.squareWithGap;
    }
    else {
        self.maxHeight = defaultGap + ceil(((float)[self.collectionView numberOfItemsInSection:0]) / self.itemsInRow) * self.squareWithGap;
    }
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    //加大上下的範圍, 多運算幾個 items 的位置
    CGRect shiftFrame = rect;
    shiftFrame.origin.y -= CGRectGetHeight(self.collectionView.bounds);
    shiftFrame.size.height += CGRectGetHeight(self.collectionView.bounds) * 2;
    NSMutableArray *attributes = [NSMutableArray array];
    NSArray *originAttributes = [super layoutAttributesForElementsInRect:shiftFrame];
    
    //運算可視範圍內的 item frame 該是多少
    NSIndexPath *selectedIndexPath = [self.delegate selectedIndexPath];
    for (int i = 0; i < originAttributes.count; i++) {
        UICollectionViewLayoutAttributes *layoutAttributes = [originAttributes[i] copy];
        CGRect frame = layoutAttributes.frame;
        NSInteger row = layoutAttributes.indexPath.row;
        BOOL isDefaultItem = NO;
        if (selectedIndexPath) {
            switch (self.expandDirection) {
                case DaiExpandCollectionViewFlowLayoutExpandDirectionLeft:
                    [self expandToLeftAtRow:row selectIndexPath:selectedIndexPath isDefaultItem:&isDefaultItem frame:&frame];
                    break;
                    
                case DaiExpandCollectionViewFlowLayoutExpandDirectionRight:
                    [self expandToRightAtRow:row selectIndexPath:selectedIndexPath isDefaultItem:&isDefaultItem frame:&frame];
                    break;
            }
            
            if (isDefaultItem) {
                NSInteger shiftIndex = row;
                if (row > selectedIndexPath.row) {
                    shiftIndex = row + pow((self.itemsInRow - 1), 2) - 1;
                }
                frame.origin = [self gridPositionAtIndex:shiftIndex];
            }
            
            if ([self.delegate previousSelectedIndexPath] && row == [self.delegate previousSelectedIndexPath].row) {
                CGFloat shift = (self.originalSize.width - self.expandSize.width) / 2;
                CGFloat scale = self.originalSize.width / self.expandSize.width;
                CGAffineTransform newTransform = CGAffineTransformMakeTranslation(shift, shift);
                newTransform = CGAffineTransformScale(newTransform, scale, scale);
                layoutAttributes.transform = newTransform;
            }
        }
        else {
            frame.origin = [self gridPositionAtIndex:row];
        }
        layoutAttributes.frame = frame;
        [attributes addObject:layoutAttributes];
    }
    return attributes;
}

- (CGSize)collectionViewContentSize {
    return CGSizeMake(self.maxWidth, self.maxHeight);
}

#pragma mark - instance method

- (void)reloadGrid {
    // gap - square - gap - square - gap - square - gap => (self.itemsInRow + 1) gaps
    CGFloat square = (CGRectGetWidth(self.frame) - ((self.itemsInRow + 1) * defaultGap)) / self.itemsInRow;
    self.squareWithGap = square + defaultGap;
    
    //一般大小
    self.originalSize = CGSizeMake(square, square);
    
    //長大後的大小
    self.expandSize = CGSizeMake(square * (self.itemsInRow - 1) + defaultGap * (self.itemsInRow - 2), square * (self.itemsInRow - 1) + defaultGap * (self.itemsInRow - 2));
}

#pragma mark - private

#pragma mark * grid position

- (CGPoint)gridPositionAtIndex:(NSInteger)index offsetX:(NSInteger)offsetX offsetY:(NSInteger)offsetY {
    NSInteger gridX = [self gridXFromIndex:index];
    NSInteger gridY = [self gridYFromIndex:index];
    CGFloat positionX = defaultGap + ((gridX + offsetX) * self.squareWithGap);
    CGFloat positionY = defaultGap + ((gridY + offsetY) * self.squareWithGap);
    return CGPointMake(positionX, positionY);
}

- (CGPoint)gridPositionAtIndex:(NSInteger)index {
    return [self gridPositionAtIndex:index offsetX:0 offsetY:0];
}

- (NSInteger)gridXFromIndex:(NSInteger)index {
    return index % self.itemsInRow;
}

- (NSInteger)gridYFromIndex:(NSInteger)index {
    return index / self.itemsInRow;
}

#pragma mark * expand method

- (void)expandToRightAtRow:(NSInteger)row selectIndexPath:(NSIndexPath *)selectedIndexPath isDefaultItem:(BOOL *)isDefaultItem frame:(CGRect *)frame {
    //需要位移的只有在同一個 row 上的項目
    if ([self gridYFromIndex:row] == [self gridYFromIndex:selectedIndexPath.row]) {
        NSInteger delta = row - selectedIndexPath.row;
        NSInteger indexInRow = row % self.itemsInRow;
        NSInteger offsetX = 0;
        NSInteger offsetY = 0;
        if (delta < 0) {
            NSInteger balance = 0;
            offsetX = -1 * indexInRow;
            offsetY = balance - offsetX;
        }
        else if (delta == 0) {
            offsetX = 1 - indexInRow;
        }
        else if (delta > 0) {
            NSInteger balance = -1;
            offsetX = -1 * indexInRow;
            offsetY = balance - offsetX;
        }
        frame->origin = [self gridPositionAtIndex:row offsetX:offsetX offsetY:offsetY];
    }
    else {
        *isDefaultItem = YES;
    }
}

- (void)expandToLeftAtRow:(NSInteger)row selectIndexPath:(NSIndexPath *)selectedIndexPath isDefaultItem:(BOOL *)isDefaultItem frame:(CGRect *)frame {
    //需要位移的只有在同一個 row 上的項目
    if ([self gridYFromIndex:row] == [self gridYFromIndex:selectedIndexPath.row]) {
        NSInteger delta = row - selectedIndexPath.row;
        NSInteger indexInRow = row % self.itemsInRow;
        NSInteger offsetX = 0;
        NSInteger offsetY = 0;
        if (delta < 0) {
            NSInteger balance = self.itemsInRow - 1;
            offsetX = balance - indexInRow;
            offsetY = balance - offsetX;
        }
        else if (delta == 0) {
            offsetX = -1 * indexInRow;
        }
        else if (delta > 0) {
            NSInteger balance = self.itemsInRow - 2;
            offsetX = balance - indexInRow + 1;
            offsetY = balance - offsetX;
        }
        frame->origin = [self gridPositionAtIndex:row offsetX:offsetX offsetY:offsetY];
    }
    else {
        *isDefaultItem = YES;
    }
}

@end
