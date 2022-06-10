

# LCToast

Add toast to UIView.

## Requirements

- **iOS 8.0+**

## Features

The LCToast is a comparison of features with [Toast](https://github.com/scalessec/Toast) and [SVProgressHUD](https://github.com/SVProgressHUD/SVProgressHUD).

|                                             |  LCToast   |    Toast    | SVProgressHUD |
| :-----------------------------------------: | :--------: | :---------: | :-----------: |
|               image position                | top center | left center |  top center   |
|                  superview                  | any views  |  any views  |   UIWindow    |
|  automatic calculation text time interval   |     ✅      |      ❌      |       ✅       |
|      dismiss loading when toast shown       |     ✅      |      ❌      |       ✅       |
|      click the loading  to dismiss it       |     ✅      |      ❌      |       ❌       |
|                modify center                |     ❌      |      ✅      |       ✅       |
|                  progress                   |     ✅      |      ❌      |       ✅       |
|                  subtitle                   |     ❌      |      ✅      |       ❌       |
|                    queue                    |     ✅      |      ✅      |       ❌       |
| support for disabling superview interaction |     ✅      |      ❌      |       ✅       |

## Usage

### show toast

```objective-c
[self.view lc_showToast:@"床前明月光，疑是地上霜。举头望明月，低头思故乡。"];
```

|                      LCToastPositionTop                      |                    LCToastPositionCenter                     |                    LCToastPositionBottom                     |
| :----------------------------------------------------------: | :----------------------------------------------------------: | :----------------------------------------------------------: |
| ![top](https://github.com/iLiuChang/LCToast/raw/main/Images/top.png) | ![center](https://github.com/iLiuChang/LCToast/raw/main/Images/center.png) | ![bottom](https://github.com/iLiuChang/LCToast/raw/main/Images/bottom.png) |

### show image toast

```objective-c
[self.view lc_showToast:@"春种一粒粟，秋收万颗子。四海无闲田，农夫犹饿死。锄禾日当午，汗滴禾下土。谁知盘中餐，粒粒皆辛苦。" image:[UIImage imageNamed:@"warning"] position:(LCToastPositionCenter)];
```

<img src="https://github.com/iLiuChang/LCToast/raw/main/Images/toast_image.png" width="300" />

### show loading

```objective-c
[self.view lc_showLoading];
```

<img src="https://github.com/iLiuChang/LCToast/raw/main/Images/loading.png" width="300" />

### show progress

```objective-c
[self.view lc_showProgress:0.3];
```

<img src="https://github.com/iLiuChang/LCToast/raw/main/Images/progress.png" width="300" />

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