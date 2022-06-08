

# LCToast

Add toast to UIView.

## Requirements

- **iOS 8.0+**

## Usage

### show toast

```objective-c
[self.view lc_showToast:@"床前明月光，疑是地上霜。举头望明月，低头思故乡。"];
```

|                             Top                              |                            Center                            |                            Bottom                            |
| :----------------------------------------------------------: | :----------------------------------------------------------: | :----------------------------------------------------------: |
| ![top](https://github.com/iLiuChang/LCToast/raw/main/Images/top.png) | ![center](https://github.com/iLiuChang/LCToast/raw/main/Images/center.png) | ![bottom](https://github.com/iLiuChang/LCToast/raw/main/Images/bottom.png) |

### show image toast

```objective-c
[self.view lc_showToast:@"春种一粒粟，秋收万颗子。四海无闲田，农夫犹饿死。锄禾日当午，汗滴禾下土。谁知盘中餐，粒粒皆辛苦。" image:[UIImage imageNamed:@"warning"] position:(LCToastPositionCenter)];
```

<center><img src="https://github.com/iLiuChang/LCToast/raw/main/Images/toast_image.png" alt="image toast" style="zoom:50%;"></center> 

### show loading

```objective-c
[self.view lc_showLoading];
```


<center><img src="https://github.com/iLiuChang/LCToast/raw/main/Images/loading.png" alt="image toast" style="zoom:50%;"></center>


## Installation

### CocoaPods

To integrate LCToast into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'LCToast'
```

### Manual

1. Download everything in the LCToast folder;
2. Add (drag and drop) the source files in LCToast to your project;
3. Import `UIView+LCToast.h`.

## License

LCToast is provided under the MIT license. See LICENSE file for details.