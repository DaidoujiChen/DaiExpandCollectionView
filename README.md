DaiExpandCollectionView
======

Expand the current selected item. Focus the user's eyes.

DaidoujiChen

daidoujichen@gmail.com

Preview
======

![image](https://s3-ap-northeast-1.amazonaws.com/daidoujiminecraft/Daidouji/DaiExpandCollectionView2.gif)

Overview
======
最傳統的 `UICollectionView` 只可以單一的顯示某些固定大小, `DaiExpandCollectionView` 可以同時顯示兩種不同大小 size 的 item, 並且以動畫的效果呈現. 

Install
======

###Cocoapods

	pod 'DaiExpandCollectionView', '~> 0.0.3'

然後在要使用 `DaiExpandCollectionView` 的地方

	#import <DaiExpandCollectionView/DaiExpandCollectionView.h>

###Manual

複製 `DaiExpandCollectionView\DaiExpandCollectionView\` 的四個檔案

	DaiExpandCollectionView.h
	DaiExpandCollectionView.m
	DaiExpandCollectionViewFlowLayout.h
	DaiExpandCollectionViewFlowLayout.m
	
到你的專案中, 然後在要使用 `DaiExpandCollectionView` 的地方

	#import "DaiExpandCollectionView.h"


How to use
======

###Step 1 : init

	DaiExpandCollectionView *daiExpandCollectionView = [DaiExpandCollectionView initWithFrame:self.view.bounds];
    [daiExpandCollectionView registerClass:[ImageCollectionViewCell class] forCellWithReuseIdentifier:@"ImageCollectionViewCell"];
    daiExpandCollectionView.expandDelegate = self;
    [self.view addSubview:daiExpandCollectionView];

比較不一樣的地方是, 初始化 `DaiExpandCollectionView` 的方法是調用 `[DaiExpandCollectionView initWithFrame:]` 而不是一般的 `UICollectionView` 的 `[[UICollectionView alloc] initWithFrame:collectionViewLayout:]`, 之後, 如同一般的 `UICollectionView`, 我們需要先幫他註冊一個要用的 `UICollectionViewCell`, 並且把 `expandDelegate` 設定完成即可.

###Step 2 : implement required delegate

`DaiExpandCollectionViewDelegate` 中, 有兩個必要實現的 method

	- (NSInteger)numberOfItemsInCollectionView:(UICollectionView *)collectionView;
	- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;

`numberOfItemsInCollectionView:` 回傳 data 的總數, 像是

	- (NSInteger)numberOfItemsInCollectionView:(UICollectionView *)collectionView {
	     return 20;
	}
	
代表有 20 筆的資料.

`collectionView:cellForItemAtIndexPath:` 回傳當前 `indexPath` 需要顯示的 `UICollectionViewCell`, 像是

	- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    	static NSString *identifier = @"ImageCollectionViewCell";
    	ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    	cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg", indexPath.row + 1]];
    	return cell;
	}
	
就如同一般的 `UICollectionView` 的方式.

###Step 3 : implement optional delegate

`DaiExpandCollectionViewDelegate` 的最後一個 method, 可以選擇要不要實現

	- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndex:(NSInteger)index;

會在這個 method 回傳使用者點擊了哪一個 index 的物件, 像是

	- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndex:(NSInteger)index {
    	NSLog(@"selected : %d", index);
	}
	
如果頁面需要跳轉, 或是顯示其他資訊, 可以從這邊完成.

Support
======
- iOS 7.0+
- iOS 8.0+ Tested
- iPhone / iPad
- Vertical only
  
