//
//  ViewController.m
//  DaiExpandCollectionView
//
//  Created by DaidoujiChen on 2015/5/11.
//  Copyright (c) 2015年 DaidoujiChen. All rights reserved.
//

#import "ViewController.h"
#import "ImageCollectionViewCell.h"

@interface ViewController ()

@property (nonatomic, strong) DaiExpandCollectionView *daiExpandCollectionView;

@end

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
    
    CGRect frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 40);
    self.daiExpandCollectionView = [DaiExpandCollectionView initWithFrame:frame itemsInRow:3];
    [self.daiExpandCollectionView registerClass:[ImageCollectionViewCell class] forCellWithReuseIdentifier:@"ImageCollectionViewCell"];
    self.daiExpandCollectionView.backgroundColor = [UIColor whiteColor];
    self.daiExpandCollectionView.expandDelegate = self;
    [self.view addSubview:self.daiExpandCollectionView];
    [self.daiExpandCollectionView expandAtIndex:0 animated:NO];
    
    frame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - 40, CGRectGetWidth(self.view.bounds), 40);
    UISlider *slider = [[UISlider alloc] initWithFrame:frame];
    slider.maximumValue = 7;
    slider.minimumValue = 3;
    slider.value = 3;
    [slider addTarget:self action:@selector(onSliderValueChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:slider];
}

- (void)onSliderValueChange:(UISlider *)slider {
    self.daiExpandCollectionView.itemsInRow = slider.value;
}

@end
