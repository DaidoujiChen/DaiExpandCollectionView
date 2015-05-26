//
//  UIView+Swizzling.m
//  DaiExpandCollectionView
//
//  Created by DaidoujiChen on 2015/5/26.
//  Copyright (c) 2015年 DaidoujiChen. All rights reserved.
//

#import "UIView+DaiExpandCollectionView.h"
#import <objc/runtime.h>
#import "DaiExpandCollectionView.h"

@implementation UIView (DaiExpandCollectionView)

#pragma mark - life cycle

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzling:@selector(snapshotViewAfterScreenUpdates:) to:@selector(daiExpandCollectionView_snapshotViewAfterScreenUpdates:)];
    });
}

#pragma mark - swizzling method

- (UIView *)daiExpandCollectionView_snapshotViewAfterScreenUpdates:(BOOL)afterUpdates {
    if ([self.superview isKindOfClass:[DaiExpandCollectionView class]]) {
        DaiExpandCollectionView *collectionView = (DaiExpandCollectionView *)self.superview;
        CGRect visibleFrame = CGRectMake(collectionView.contentOffset.x, collectionView.contentOffset.y, collectionView.contentOffset.x + collectionView.bounds.size.width, collectionView.contentOffset.y + collectionView.bounds.size.height);
        if (!CGRectContainsRect(visibleFrame, self.frame)) {
            return nil;
        }
    }
    return [self daiExpandCollectionView_snapshotViewAfterScreenUpdates:afterUpdates];
}

#pragma mark - private instance method

+ (void)swizzling:(SEL)before to:(SEL)after {
    Class class = [self class];
    
    SEL originalSelector = before;
    SEL swizzledSelector = after;
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }
    else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@end
