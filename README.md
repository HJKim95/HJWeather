# HJWeather

![HJWeather_main](https://user-images.githubusercontent.com/29699823/91936775-7cb78500-ed2b-11ea-8b16-48f88ffa6f01.png)
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
* [Getting started with AmPmWeather](#getting_started_ampm)
* [Getting started with FutureWeather](#getting_started_future)

### 1. Getting started with TodayWeather <a id='getting_started_today'></a>
* Getting started with code. Provides today, tomorrow, day after tomorrow weather data.
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

### 2. Getting started with AmPmWeather <a id='getting_started_ampm'></a>
* Getting started with code. Provides today, tomorrow, day after tomorrow Am, Pm weather data.
```swift
public func getTomorrowWeather(future: Bool, completed: @escaping (_ tomorrowInfo: [futureWeatherModel]) -> Void)
```
> Simply call function * future = false is for AmPm Weather, future = true is for Future Weather<br/> 
> Please check example for implementaion
```swift
var ampmWeatherInfo = [futureWeatherModel]()
WeatherApiHelper.shared.getTomorrowWeather(future: future) { [weak self] (weather) in
    self?.ampmWeatherInfo = weather
}
```
> FutureWeatherModel
```swift
@objcMembers
public class futureWeatherModel: NSObject {
    public var rain_text = "" // 강수확률
    public var sky_text = "" // 날씨 image text
    public var temp_Max = "" // 최고기온
    public var temp_Min =  "" // 최저기온
    public var sky = "" // 날씨 (한글)
}
```

### 3. Getting started with FutureWeather <a id='getting_started_future'></a>
* Getting started with code. Provides information for 8 days from 3 days from today
```swift
public func getForecastWeather(completed: @escaping (_ forecastInfo: [futureWeatherModel]) -> Void)
``` 

> First, get 3day datas(today, tomorrow, after tomorrow) from today using getTomorrowWeather( )
> Second, call getForecastWeather( ) for 8day datas
```swift
var futureWeatherInfo = [futureWeatherModel]()
WeatherApiHelper.shared.getTomorrowWeather(future: true) { [weak self] (nearWeather) in
    self?.futureWeatherInfo = nearWeather
    WeatherApiHelper.shared.getForecastWeather { [weak self] (futureWeather) in
        self?.futureWeatherInfo += futureWeather
        self?.weatherCollectionView.reloadData()
    }
}
```

## Author

HJKim95, 25ephipany@naver.com

## License

HJWeather is available under the MIT license. See the LICENSE file for more info.
