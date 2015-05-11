//
//  ImageCollectionViewCell.m
//  DaiExpandCollectionView
//
//  Created by DaidoujiChen on 2015/5/12.
//  Copyright (c) 2015年 DaidoujiChen. All rights reserved.
//

#import "ImageCollectionViewCell.h"

@implementation ImageCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
        self = arrayOfViews[0];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}

@end
