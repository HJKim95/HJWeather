# HJWeather

[![Languages](https://img.shields.io/badge/language-swift%205.0%20-FF69B4.svg?style=plastic)](#) <br/> 
[![CI Status](https://img.shields.io/travis/HJKim95/HJWeather.svg?style=flat)](https://travis-ci.org/HJKim95/HJWeather)
[![Version](https://img.shields.io/cocoapods/v/HJWeather.svg?style=flat)](https://cocoapods.org/pods/HJWeather)
[![License](https://img.shields.io/cocoapods/l/HJWeather.svg?style=flat)](https://cocoapods.org/pods/HJWeather)
[![Platform](https://img.shields.io/cocoapods/p/HJWeather.svg?style=flat)](https://cocoapods.org/pods/HJWeather)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
* iOS 10.0+ 
* Xcode 11+
* Swift 5.0+

## Installation
* Manually
* Cocoapods

### Manually
1. ***[Download](#)*** the source code.
2. Extract the zip file, simply drag folder ***[Classes](#)*** into your project.
3. Make sure ***Copy items if needed*** is checked.

### Cocoapods

HJLayout is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'HJWeather'
```

## Tutorial
* [Getting started with TodayWeather](#getting_started_today)
### 1. Getting started with TodayWeather <a id='getting_started_today'></a>

* Getting started with code<br/> 
```swift
public func getTotalCurrentWeather(lat: String, long: String, completed: @escaping (_ weatherinfo: Dictionary<String,Dictionary<String,String>>) -> Void)
```
> Simply call function with latitude and longitude.
```swift
var weatherInfo = [String:[String:String]]()
WeatherApiHelper.shared.getTotalCurrentWeather(lat: lat, long: long) { [weak self] (weatherinfo) in
    self?.weatherInfo = weatherinfo
    self?.weatherCollectionView.reloadData()
}
//data example
//"202009021500": ["UUU": "-0.5", "REH": "90", "R06": "5", "api_rain_image": "RAIN_D01", "api_sky_image": "SKY_D04", "T3H": "26", "SKY": "흐림", "POP": "80", "PTY": "비", "TMX": "28.0", "VEC": "18", "WSD": "2.1", "VVV": "-2"]
```

## Author

HJKim95, 25ephipany@naver.com

## License

HJWeather is available under the MIT license. See the LICENSE file for more info.
