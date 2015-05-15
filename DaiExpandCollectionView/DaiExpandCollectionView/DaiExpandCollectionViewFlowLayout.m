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
    DaiExpandCollectionViewFlowLayoutTypeLeft,
    DaiExpandCollectionViewFlowLayoutTypeCenter,
    DaiExpandCollectionViewFlowLayoutTypeRight
} DaiExpandCollectionViewFlowLayoutType;

typedef enum {
    DaiExpandCollectionViewFlowLayoutCenterExpandTypeLeft,
    DaiExpandCollectionViewFlowLayoutCenterExpandTypeRight
} DaiExpandCollectionViewFlowLayoutCenterExpandType;

@interface DaiExpandCollectionViewFlowLayout ()

@property (nonatomic, assign) CGSize originalSize;
@property (nonatomic, assign) CGSize expandSize;
@property (nonatomic, assign) CGFloat squareWithGap;
@property (nonatomic, assign) CGFloat maxWidth;
@property (nonatomic, assign) CGFloat maxHeight;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign) DaiExpandCollectionViewFlowLayoutCenterExpandType centerExpandType;

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
        
        [self reloadGrid];
    }
    return self;
}

#pragma mark - method to override

- (void)prepareLayout {
    [super prepareLayout];
    
    NSInteger previousSelectedIndex = [self.delegate previousSelectedIndexPath].row;
    NSInteger selectedIndex = [self.delegate selectedIndexPath].row;
    //如果在同一列上
    if ([self gridYFromIndex:previousSelectedIndex] == [self gridYFromIndex:selectedIndex]) {
        DaiExpandCollectionViewFlowLayoutType previousSelectedType = [self typeAtIndex:previousSelectedIndex];
        DaiExpandCollectionViewFlowLayoutType selectedType = [self typeAtIndex:selectedIndex];
        
        if (previousSelectedType == DaiExpandCollectionViewFlowLayoutTypeLeft && selectedType == DaiExpandCollectionViewFlowLayoutTypeCenter) {
            self.centerExpandType = DaiExpandCollectionViewFlowLayoutCenterExpandTypeRight;
        }
        else if (previousSelectedType == DaiExpandCollectionViewFlowLayoutTypeRight && selectedType == DaiExpandCollectionViewFlowLayoutTypeCenter) {
            self.centerExpandType = DaiExpandCollectionViewFlowLayoutCenterExpandTypeLeft;
        }
        else {
            self.centerExpandType = arc4random() % 2;
        }
    }
    else {
        self.centerExpandType = arc4random() % 2;
    }
    
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
    NSArray *attributes = [super layoutAttributesForElementsInRect:shiftFrame];
    
    //運算可視範圍內的 item frame 該是多少
    NSIndexPath *selectedIndexPath = [self.delegate selectedIndexPath];
    for (int i = 0; i < attributes.count; i++) {
        UICollectionViewLayoutAttributes *layoutAttributes = attributes[i];
        CGRect frame = layoutAttributes.frame;
        NSInteger row = layoutAttributes.indexPath.row;
        BOOL isDefaultItem = NO;
        if (selectedIndexPath) {
            DaiExpandCollectionViewFlowLayoutType selectedType = [self typeAtIndex:selectedIndexPath.row];
            switch (selectedType) {
                case DaiExpandCollectionViewFlowLayoutTypeLeft:
                    [self selectedLeftItemRuleAtRow:row andSelectedIndex:selectedIndexPath isDefaultItem:&isDefaultItem frame:&frame];
                    break;
                    
                case DaiExpandCollectionViewFlowLayoutTypeCenter:
                    switch (self.centerExpandType) {
                        case DaiExpandCollectionViewFlowLayoutCenterExpandTypeLeft:
                            [self selectedCenterItemRuleAtRow_leftDown:row andSelectedIndex:selectedIndexPath isDefaultItem:&isDefaultItem frame:&frame];
                            break;
                            
                        case DaiExpandCollectionViewFlowLayoutCenterExpandTypeRight:
                            [self selectedCenterItemRuleAtRow_rightDown:row andSelectedIndex:selectedIndexPath isDefaultItem:&isDefaultItem frame:&frame];
                            break;
                    }
                    break;
                    
                case DaiExpandCollectionViewFlowLayoutTypeRight:
                    [self selectedRightItemRuleAtRow:row andSelectedIndex:selectedIndexPath isDefaultItem:&isDefaultItem frame:&frame];
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

#pragma mark * DaiExpandCollectionViewFlowLayoutType

- (DaiExpandCollectionViewFlowLayoutType)typeAtIndex:(NSInteger)index {
    DaiExpandCollectionViewFlowLayoutType returnType = index % self.itemsInRow;
    if (returnType == 0) {
        returnType = DaiExpandCollectionViewFlowLayoutTypeLeft;
    }
    else if (returnType == self.itemsInRow - 1) {
        returnType = DaiExpandCollectionViewFlowLayoutTypeRight;
    }
    else {
        returnType = DaiExpandCollectionViewFlowLayoutTypeCenter;
    }
    return returnType;
}

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

#pragma mark * left expand method

- (void)selectedLeftItemRuleAtRow:(NSInteger)row andSelectedIndex:(NSIndexPath *)selectedIndex isDefaultItem:(BOOL *)isDefaultItem frame:(CGRect *)frame {
    NSInteger delta = row - selectedIndex.row;
    if (delta == 0) {
        frame->origin = [self gridPositionAtIndex:row];
    }
    else if (delta < self.itemsInRow && delta > 0) {
        frame->origin = [self gridPositionAtIndex:row offsetX:(self.itemsInRow - delta - 1) offsetY:(delta - 1)];
    }
    else {
        *isDefaultItem = YES;
    }
}

#pragma mark * center expand method

- (void)selectedCenterItemRuleAtRow_rightDown:(NSInteger)row andSelectedIndex:(NSIndexPath *)selectedIndex isDefaultItem:(BOOL *)isDefaultItem frame:(CGRect *)frame {
    if ([self gridYFromIndex:row] == [self gridYFromIndex:selectedIndex.row]) {
        NSInteger delta = row - selectedIndex.row;
        if (delta >= -1 * self.itemsInRow && delta < 0) {
            frame->origin = [self gridPositionAtIndex:row offsetX:(-1 * (row % self.itemsInRow)) offsetY:(row % self.itemsInRow)];
        }
        else if (delta == 0) {
            frame->origin = [self gridPositionAtIndex:row offsetX:(1 - (row % self.itemsInRow)) offsetY:0];
        }
        else if (delta <= self.itemsInRow && delta > 0) {
            frame->origin = [self gridPositionAtIndex:row offsetX:(-1 * (row % self.itemsInRow)) offsetY:abs((-1 * (row % self.itemsInRow))) - 1];
        }
    }
    else {
        *isDefaultItem = YES;
    }
}

- (void)selectedCenterItemRuleAtRow_leftDown:(NSInteger)row andSelectedIndex:(NSIndexPath *)selectedIndex isDefaultItem:(BOOL *)isDefaultItem frame:(CGRect *)frame {
    if ([self gridYFromIndex:row] == [self gridYFromIndex:selectedIndex.row]) {
        NSInteger delta = row - selectedIndex.row;
        if (delta >= -1 * self.itemsInRow && delta < 0) {
            frame->origin = [self gridPositionAtIndex:row offsetX:((self.itemsInRow - 1) - (row % self.itemsInRow)) offsetY:(row % self.itemsInRow)];
        }
        else if (delta == 0) {
            frame->origin = [self gridPositionAtIndex:row offsetX:(-1 * (row % self.itemsInRow)) offsetY:0];
        }
        else if (delta <= self.itemsInRow && delta > 0) {
            frame->origin = [self gridPositionAtIndex:row offsetX:((self.itemsInRow - 1) - (row % self.itemsInRow)) offsetY:(row % self.itemsInRow) - 1];
        }
    }
    else {
        *isDefaultItem = YES;
    }
}

#pragma mark * right expand method

- (void)selectedRightItemRuleAtRow:(NSInteger)row andSelectedIndex:(NSIndexPath *)selectedIndex isDefaultItem:(BOOL *)isDefaultItem frame:(CGRect *)frame {
    NSInteger delta = row - selectedIndex.row;
    if (delta == 0) {
        frame->origin = [self gridPositionAtIndex:row offsetX:(2 - self.itemsInRow) offsetY:0];
    }
    else if (delta >= -(self.itemsInRow - 1) && delta < 0) {
        frame->origin = [self gridPositionAtIndex:row offsetX:-(self.itemsInRow + delta - 1) offsetY:(labs(delta) - 1)];
    }
    else {
        *isDefaultItem = YES;
    }
}

@end
