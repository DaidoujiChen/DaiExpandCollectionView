DaiExpandCollectionView
======

Expand current selected item and catch users' eyes.

Demo
======

![image](https://s3-ap-northeast-1.amazonaws.com/daidoujiminecraft/Daidouji/DaiExpandCollectionViewPad6.gif)

Overview
======
Unlike default `UICollectionView` can only display items with same fixed size,
`DaiExpandCollectionView` can not only display items in two different sizes simultaneously but also change selected items with smooth animation.

Installation
======

### CocoaPods
DaiExpandCollectionView is available through [CocoaPods](http://cocoapods.org).

* Add ```pod 'DaiExpandCollectionView'``` to your Podfile
* Run ```pod install```
* Run ```open App.xcworkspace```
* Then ```#import <DaiExpandCollectionView/DaiExpandCollectionView.h>```

### Manually
Drag 4 source files under folder `DaiExpandCollectionView\DaiExpandCollectionView\` to your project.

`````
DaiExpandCollectionView.h
DaiExpandCollectionView.m
DaiExpandCollectionViewFlowLayout.h
DaiExpandCollectionViewFlowLayout.m
`````

and then import the main header file：`#import "DaiExpandCollectionView.h"`

How to use
======

### Step 1 : Init

`````
DaiExpandCollectionView *daiExpandCollectionView = [DaiExpandCollectionView initWithFrame:self.view.bounds];
[daiExpandCollectionView registerClass:[ImageCollectionViewCell class] forCellWithReuseIdentifier:@"ImageCollectionViewCell"];
daiExpandCollectionView.expandDelegate = self;
[self.view addSubview:daiExpandCollectionView];
`````

**Note:** Init `DaiExpandCollectionView` using `[DaiExpandCollectionView initWithFrame:]` instead of `[[UICollectionView alloc] initWithFrame:collectionViewLayout:]` which used by default `UICollectionView`.

Next, register `UICollectionViewCell` and then set up `expandDelegate`.

### Step 2 : Required delegate methods

There are two required methods in `DaiExpandCollectionViewDelegate`

`````
- (NSInteger)numberOfItemsInCollectionView:(UICollectionView *)collectionView;
`````

Return the number of items (views) in the collection view.

For example:

`````
- (NSInteger)numberOfItemsInCollectionView:(UICollectionView *)collectionView {
	return 20;
}
`````

means there are 20 items (views) in the collection view.

`````
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
`````

Return a `UICollectionViewCell` to be displayed at the specified index in the collection view.

For example:

`````
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *identifier = @"ImageCollectionViewCell";
	ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
	cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg", indexPath.row + 1]];
	return cell;
}
`````

### Step 3 : Optional delegate methods

`````
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndex:(NSInteger)index;
`````

Return the index of current selected item.
For example:

`````
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndex:(NSInteger)index {
	NSLog(@"selected : %d", index);
}
`````

Custom
======
If you want use more than 3 items in row. Change your code from

`````
self.daiExpandCollectionView = [DaiExpandCollectionView initWithFrame:frame];
`````

to

`````
self.daiExpandCollectionView = [DaiExpandCollectionView initWithFrame:frame itemsInRow:4];
`````

or you can dynamic change the value `itemsInRow` in the run time

`````
self.daiExpandCollectionView.itemsInRow = 5;
`````

`DaiExpandCollectionView` will handle the animation automatic.

Who use it
======
[Noooo (on App Store)](https://itunes.apple.com/us/app/id1096501732)

Support
======
- iOS 7.0+
- iOS 8.0+ Tested
- iPhone / iPad
- Vertical only
  
