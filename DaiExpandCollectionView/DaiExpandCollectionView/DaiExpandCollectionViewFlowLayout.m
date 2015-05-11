//
//  DaiExpandCollectionViewFlowLayout.m
//  DaiExpandCollectionView
//
//  Created by DaidoujiChen on 2015/5/11.
//  Copyright (c) 2015年 DaidoujiChen. All rights reserved.
//

#import "DaiExpandCollectionViewFlowLayout.h"

#define defaultGap 5.0f
#define numbersInRow 3

#define GridForX(arg) \
(arg % numbersInRow)

#define GridForY(arg) \
(arg / numbersInRow)

#define GridPosition(arg) \
(defaultGap + ((arg) * self.squareWithGap))

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
@property (nonatomic, assign) DaiExpandCollectionViewFlowLayoutCenterExpandType centerExpandType;

@end

@implementation DaiExpandCollectionViewFlowLayout

#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super init];
    if (self) {
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.minimumLineSpacing = defaultGap;
        self.minimumInteritemSpacing = 0;
        self.sectionInset = UIEdgeInsetsMake(defaultGap, defaultGap, 0, 0);
        
        // gap - square - gap - square - gap - square - gap => 4 gaps
        CGFloat square = (CGRectGetWidth(frame) - (4 * defaultGap)) / numbersInRow;
        self.squareWithGap = square + defaultGap;
        
        //一般大小
        self.originalSize = CGSizeMake(square, square);
        
        //長大後的大小
        self.expandSize = CGSizeMake(square * 2 + defaultGap, square * 2 + defaultGap);
    }
    return self;
}

#pragma mark - method to override

- (void)prepareLayout {
    [super prepareLayout];
    
    //如果在同一列上
    if (GridForY([self.delegate previousSelectedIndexPath].row) == GridForY([self.delegate selectedIndexPath].row)) {
        DaiExpandCollectionViewFlowLayoutType previousSelectedType = [self.delegate previousSelectedIndexPath].row % numbersInRow;
        DaiExpandCollectionViewFlowLayoutType selectedType = [self.delegate selectedIndexPath].row % numbersInRow;
        
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
        self.maxHeight = defaultGap + ceil(((float)[self.collectionView numberOfItemsInSection:0] + numbersInRow) / numbersInRow) * self.squareWithGap;
    }
    else {
        self.maxHeight = defaultGap + ceil(((float)[self.collectionView numberOfItemsInSection:0]) / numbersInRow) * self.squareWithGap;
    }
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    //加大上下的範圍, 多運算幾個 items 的位置
    CGRect shiftFrame = rect;
    shiftFrame.origin.y -= self.squareWithGap * 2;
    shiftFrame.size.height += self.squareWithGap * 8;
    NSArray *attributes = [super layoutAttributesForElementsInRect:shiftFrame];
    
    //運算可視範圍內的 item frame 該是多少
    NSIndexPath *selectedIndexPath = [self.delegate selectedIndexPath];
    for (int i = 0; i < attributes.count; i++) {
        UICollectionViewLayoutAttributes *layoutAttributes = attributes[i];
        CGRect frame = layoutAttributes.frame;
        NSInteger row = layoutAttributes.indexPath.row;
        BOOL isDefaultItem = NO;
        if (selectedIndexPath) {
            DaiExpandCollectionViewFlowLayoutType selectedType = selectedIndexPath.row % numbersInRow;
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
                    shiftIndex = row + numbersInRow;
                }
                frame.origin.x = GridPosition(GridForX(shiftIndex));
                frame.origin.y = GridPosition(GridForY(shiftIndex));
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
            frame.origin.x = GridPosition(GridForX(row));
            frame.origin.y = GridPosition(GridForY(row));
        }
        layoutAttributes.frame = frame;
    }
    return attributes;
}

- (CGSize)collectionViewContentSize {
    return CGSizeMake(self.maxWidth, self.maxHeight);
}

#pragma mark - private

#pragma mark * left expand method

- (void)selectedLeftItemRuleAtRow:(NSInteger)row andSelectedIndex:(NSIndexPath *)selectedIndex isDefaultItem:(BOOL *)isDefaultItem frame:(CGRect *)frame {
    switch (row - selectedIndex.row) {
        case 0:
            frame->origin.x = GridPosition(GridForX(row));
            frame->origin.y = GridPosition(GridForY(row));
            break;
            
        case 1:
            frame->origin.x = GridPosition(GridForX(row) + 1);
            frame->origin.y = GridPosition(GridForY(row));
            break;
            
        case 2:
            frame->origin.x = GridPosition(GridForX(row));
            frame->origin.y = GridPosition(GridForY(row) + 1);
            break;
            
        default:
            *isDefaultItem = YES;
            break;
    }
}

#pragma mark * center expand method

- (void)selectedCenterItemRuleAtRow_rightDown:(NSInteger)row andSelectedIndex:(NSIndexPath *)selectedIndex isDefaultItem:(BOOL *)isDefaultItem frame:(CGRect *)frame {
    switch (row - selectedIndex.row) {
        case -1:
            frame->origin.x = GridPosition(GridForX(row));
            frame->origin.y = GridPosition(GridForY(row));
            break;
            
        case 0:
            frame->origin.x = GridPosition(GridForX(row));
            frame->origin.y = GridPosition(GridForY(row));
            break;
            
        case 1:
            frame->origin.x = GridPosition(GridForX(row) - 2);
            frame->origin.y = GridPosition(GridForY(row) + 1);
            break;
            
        default:
            *isDefaultItem = YES;
            break;
    }
}

- (void)selectedCenterItemRuleAtRow_leftDown:(NSInteger)row andSelectedIndex:(NSIndexPath *)selectedIndex isDefaultItem:(BOOL *)isDefaultItem frame:(CGRect *)frame {
    switch (row - selectedIndex.row) {
        case -1:
            frame->origin.x = GridPosition(GridForX(row) + 2);
            frame->origin.y = GridPosition(GridForY(row) + 1);
            break;
            
        case 0:
            frame->origin.x = GridPosition(GridForX(row) - 1);
            frame->origin.y = GridPosition(GridForY(row));
            break;
            
        case 1:
            frame->origin.x = GridPosition(GridForX(row));
            frame->origin.y = GridPosition(GridForY(row));
            break;
            
        default:
            *isDefaultItem = YES;
            break;
    }
}

#pragma mark * right expand method

- (void)selectedRightItemRuleAtRow:(NSInteger)row andSelectedIndex:(NSIndexPath *)selectedIndex isDefaultItem:(BOOL *)isDefaultItem frame:(CGRect *)frame {
    switch (row - selectedIndex.row) {
        case -2:
            frame->origin.x = GridPosition(GridForX(row));
            frame->origin.y = GridPosition(GridForY(row) + 1);
            break;
            
        case -1:
            frame->origin.x = GridPosition(GridForX(row) - 1);
            frame->origin.y = GridPosition(GridForY(row));
            break;
            
        case 0:
            frame->origin.x = GridPosition(GridForX(row) - 1);
            frame->origin.y = GridPosition(GridForY(row));
            break;
            
        default:
            *isDefaultItem = YES;
            break;
    }
}

@end
