//
//  ViewController.m
//  DaiExpandCollectionView
//
//  Created by DaidoujiChen on 2015/5/11.
//  Copyright (c) 2015年 DaidoujiChen. All rights reserved.
//

#import "ViewController.h"
#import "ImageCollectionViewCell.h"

@implementation ViewController

#pragma mark - DaiExpandCollectionViewDelegate

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"ImageCollectionViewCell";
    ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    NSInteger imageIndex = (indexPath.row + 1);
    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%td.jpg", imageIndex]];
    return cell;
}

- (NSInteger)numberOfItemsInCollectionView:(UICollectionView *)collectionView {
    return 20;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndex:(NSInteger)index {
    NSLog(@"selected : %td", index);
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    DaiExpandCollectionView *daiExpandCollectionView = [DaiExpandCollectionView initWithFrame:self.view.bounds];
    [daiExpandCollectionView registerClass:[ImageCollectionViewCell class] forCellWithReuseIdentifier:@"ImageCollectionViewCell"];
    daiExpandCollectionView.backgroundColor = [UIColor whiteColor];
    daiExpandCollectionView.expandDelegate = self;
    [self.view addSubview:daiExpandCollectionView];
    
    [daiExpandCollectionView expandAtIndex:0 animated:NO];
}

@end
