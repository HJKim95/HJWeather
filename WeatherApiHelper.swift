//
//  WeatherApiHelper.swift
//  SpotShare
//
//  Created by 김희중 on 2020/03/12.
//  Copyright © 2020 김희중. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

public class WeatherApiHelper {
    public static let shared = WeatherApiHelper()
    
    private func getCurrent(base parameter:[String:String], completed: @escaping (_ currentData:[JSON]) -> Void) {
        print("get Current Weather")
        let url = WeatherData.weatherApi
        Alamofire.request(url, method: .get, parameters: parameter, encoding: URLEncoding.default, headers: nil)
            .responseJSON { (response) in
                switch response.result {
                case .success :
                    guard let weatherData = response.data else { return }
                    let data = JSON(weatherData)
                    let dataArray = data["response"]["body"]["items"]["item"].arrayValue
                    completed(dataArray)
                case .failure( _) : break
                }
        }
    }
    
    private func getNow(base parameter:[String:String], completed: @escaping (_ currentData:[JSON]) -> Void) {
        print("get Now Weather")
        let url = WeatherData.nowWeatherApi
        Alamofire.request(url, method: .get, parameters: parameter, encoding: URLEncoding.default, headers: nil)
            .responseJSON { (response) in
                switch response.result {
                case .success :
                    guard let weatherData = response.data else { return }
                    let data = JSON(weatherData)
                    let dataArray = data["response"]["body"]["items"]["item"].arrayValue
                    completed(dataArray)
                case .failure( _) : break
                }
        }
    }
    
    private func getTomorrow(base parameter:[String:String], completed: @escaping (_ curruntData:[JSON]) -> Void) {
        print("get Tomorrows Weather")
        let url = WeatherData.tomorrowWeatherApi
        Alamofire.request(url, method: .get, parameters: parameter, encoding: URLEncoding.default, headers: nil)
            .responseJSON { (response) in
                switch response.result {
                case .success :
                    guard let weatherData = response.data else { return }
                    let data = JSON(weatherData)
                    let dataArray = data["response"]["body"]["items"]["item"].arrayValue
                    completed(dataArray)
                case .failure( _) : break
                }
        }
    }
    
    private func getForecast(base parameter:[String:String], object: String, completed: @escaping (_ curruntData:[JSON]) -> Void) {
        print("get Forecast Weather")
        var url = ""
        if object == "weather" {
            url = WeatherData.forecastApi
        }
        else if object == "temp" {
            url = WeatherData.tempApi
        }
        
        Alamofire.request(url, method: .get, parameters: parameter, encoding: URLEncoding.default, headers: nil)
            .responseJSON { (response) in
                switch response.result {
                case .success :
                    guard let weatherData = response.data else { return }
                    let data = JSON(weatherData)
                    let dataArray = data["response"]["body"]["items"]["item"].arrayValue
                    completed(dataArray)
                case .failure( _) : break
                }
        }
    }
    
    var weatherInfo = [String:[String:String]]()
    let timeGap = ["0000","0300","0600","0900","1200","1500","1800","2100"]
    var savedInfo = [String:[String:String]]()
    
    public func getTotalCurrentWeather(lat: String, long: String, completed: @escaping (_ weatherinfo: Dictionary<String,Dictionary<String,String>>) -> Void) {
        getCurrentWeather(lat: lat, long: long, reload: false) { [weak self] (weather) in
            if let weatherInfo = weather.totalWeatherDataStringDict {
                self?.weatherInfo = weatherInfo
                let date = Date()
                let dateFommater = DateFormatter()
                dateFommater.dateFormat = "yyyyMMdd"
                dateFommater.timeZone = TimeZone(secondsFromGMT: 9 * 60 * 60)
                let dateString:String = dateFommater.string(from: date)
                let dates = dateString
                guard let time = self?.getTime() else {return}
                let timeString = "\(time)00"

                // 최신화하기 전, 이전 정보 저장
                for time in self!.timeGap {
                    if Int(time)! < Int(timeString)! {
                        let dateTimeString = "\(dates)\(time)"
                        self?.savedInfo[dateTimeString] = weatherInfo[dateTimeString]
                        
                    }
                }
                
                guard let saved = self?.savedInfo else {return}
                if saved.count > 0 {
                    // 최신화
                    self?.getCurrentWeather(lat: lat, long: long, reload: true) { [weak self] (weatherData) in
                        if let reloadWeatherInfo = weatherData.totalWeatherDataStringDict {
                            self?.weatherInfo = reloadWeatherInfo
                            for time in self!.timeGap {
                                if Int(time)! < Int(timeString)! {
                                    let dateTimeString = "\(dates)\(time)"
                                    self?.weatherInfo[dateTimeString] = saved[dateTimeString]
                                    print(self?.weatherInfo.count)
                                    completed(self!.weatherInfo)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func getCurrentWeather(lat: String, long: String ,reload: Bool, completed: @escaping (_ weatherinfo: WeatherModel) -> Void) {
        getCurrent(base: makeCurrentAPIParameter(lat: lat, lon: long, reload: reload)) { [weak self] (dataArray) in

            // 날씨정보 raw code
            var weatheRawCode: [String:String] = [:]
            var totalWeatherRawCode: [String:[String:String]] = [:]
            
            // 날씨정보 이름
            var weatherDataString: [String:String] = [:]
            var totalWeatherDataString: [String:[String:String]] = [:]
            
            var totalFcstDateTime = [String]()
            
            if dataArray.count == 0 {
                completed(WeatherModel.empty)
                print("DATA COUNT ZERO")
            } else {
                for i in 0...dataArray.count - 1 {
                    let fcstTime = dataArray[i]["fcstTime"].stringValue
                    let fcstDate = dataArray[i]["fcstDate"].stringValue
                    let fcstDateTime = "\(fcstDate)\(fcstTime)"
                    if !totalFcstDateTime.contains(fcstDateTime) {
                        totalFcstDateTime.append(fcstDateTime)
                    }
                    
                    switch dataArray[i]["category"].stringValue {
                    case Constants.api_sky : /// SKY - 하늘상태
                        guard let dayNightTime = Int(fcstTime) else { return }
                        let value = dataArray[i]["fcstValue"].stringValue
                        weatheRawCode[Constants.api_sky] = value
                        totalWeatherRawCode[fcstDateTime] = weatherDataString
                        switch value {
                        case "1":
                            // 맑음
                            if dayNightTime > 700 && dayNightTime < 2000 {
                                // 낮
                                weatherDataString[Constants.api_sky] = Weather.Sunny.convertName().subs
                                weatherDataString[Constants.api_sky_image] = Weather.Sunny.convertName().code
                                totalWeatherDataString[fcstDateTime] = weatherDataString
                                
                            } else {
                                // 밤
                                weatherDataString[Constants.api_sky] = Weather.ClearNight.convertName().subs
                                weatherDataString[Constants.api_sky_image] = Weather.ClearNight.convertName().code
                                totalWeatherDataString[fcstDateTime] = weatherDataString
                            }
                        case "2":
                            // 구름조금 (2019.06.04 이후 삭제됨)
                            if dayNightTime > 700 && dayNightTime < 2000 {
                                // 낮
                                weatherDataString[Constants.api_sky] = Weather.LittleCloudy.convertName().subs
                                weatherDataString[Constants.api_sky_image] = Weather.LittleCloudy.convertName().code
                                totalWeatherDataString[fcstDateTime] = weatherDataString
                            } else {
                                // 밤
                                weatherDataString[Constants.api_sky] = Weather.LittleCloudyNight.convertName().subs
                                weatherDataString[Constants.api_sky_image] = Weather.LittleCloudyNight.convertName().code
                                totalWeatherDataString[fcstDateTime] = weatherDataString
                            }
                        case "3":
                            // 구름많음
                            weatherDataString[Constants.api_sky] = Weather.MoreCloudy.convertName().subs
                            weatherDataString[Constants.api_sky_image] = Weather.MoreCloudy.convertName().code
                            totalWeatherDataString[fcstDateTime] = weatherDataString
                        case "4":
                            // 흐림
                            weatherDataString[Constants.api_sky] = Weather.Cloudy.convertName().subs
                            weatherDataString[Constants.api_sky_image] = Weather.Cloudy.convertName().code
                            totalWeatherDataString[fcstDateTime] = weatherDataString
                        default:
                            weatherDataString[Constants.api_sky] = "정보 없음"
                            totalWeatherDataString[fcstDateTime] = weatherDataString
                        }
                    case Constants.api_rainform : /// PTY - 강수형태
                        let value = dataArray[i]["fcstValue"].stringValue
                        weatheRawCode[Constants.api_rainform] = value
                        totalWeatherRawCode[fcstDateTime] = weatheRawCode
                        switch value {
                        case "0":
                            // 없음
                            weatherDataString[Constants.api_rainform] = ""
                            totalWeatherRawCode[fcstDateTime] = weatherDataString
                        case "1":
                            // 비
                            weatherDataString[Constants.api_rainform] = Weather.Rainy.convertName().subs
                            weatherDataString[Constants.api_rain_image] = Weather.Rainy.convertName().code
                            totalWeatherDataString[fcstDateTime] = weatherDataString
                        case "2":
                            // 비/눈 (진눈깨비)
                            weatherDataString[Constants.api_rainform] = Weather.Sleet.convertName().subs
                            weatherDataString[Constants.api_rain_image] = Weather.Sleet.convertName().code
                            totalWeatherDataString[fcstDateTime] = weatherDataString
                        case "3":
                            // 눈
                            weatherDataString[Constants.api_rainform] = Weather.Snow.convertName().subs
                            weatherDataString[Constants.api_rain_image] = Weather.Snow.convertName().code
                            totalWeatherDataString[fcstDateTime] = weatherDataString
                        case "4":
                            // 소나기
                            weatherDataString[Constants.api_rainform] = Weather.Shower.convertName().subs
                            weatherDataString[Constants.api_rain_image] = Weather.Snow.convertName().code
                            totalWeatherDataString[fcstDateTime] = weatherDataString
                        default:
                            weatherDataString[Constants.api_rainform] = "정보 없음"
                            totalWeatherDataString[fcstDateTime] = weatherDataString
                        }
                    
                    case Constants.api_3HourTemp : /// T3H - 3시간기온
                        let value = dataArray[i]["fcstValue"].stringValue
                        weatheRawCode[Constants.api_3HourTemp] = self?.roundedTemperature(from: value)
                        totalWeatherRawCode[fcstDateTime] = weatheRawCode
                        weatherDataString[Constants.api_3HourTemp] = self?.roundedTemperature(from: value)
                        totalWeatherDataString[fcstDateTime] = weatherDataString
                        
                    case Constants.api_rainPercent : /// POP - 강수확률
                        let value = dataArray[i]["fcstValue"].stringValue
                        weatherDataString[Constants.api_rainPercent] = value
                        totalWeatherDataString[fcstDateTime] = weatherDataString
                        weatheRawCode[Constants.api_rainPercent] = value
                        totalWeatherRawCode[fcstDateTime] = weatheRawCode
                        
                    case Constants.api_6hourRain : /// R06 - 6시간 강수량
                        let value = dataArray[i]["fcstValue"].stringValue
                        weatheRawCode[Constants.api_6hourRain] = value
                        totalWeatherRawCode[fcstDateTime] = weatheRawCode
                        weatherDataString[Constants.api_6hourRain] = value
                        totalWeatherDataString[fcstDateTime] = weatherDataString
                        
                    case Constants.api_EWwind : /// UUU - 동서바람성분
                        let value = dataArray[i]["fcstValue"].stringValue
                        weatheRawCode[Constants.api_EWwind] = value
                        totalWeatherRawCode[fcstDateTime] = weatheRawCode
                        weatherDataString[Constants.api_EWwind] = value
                        totalWeatherDataString[fcstDateTime] = weatherDataString
                        
                    case Constants.api_SNwind : /// VVV - 남북바람성분
                        let value = dataArray[i]["fcstValue"].stringValue
                        weatheRawCode[Constants.api_SNwind] = value
                        totalWeatherRawCode[fcstDateTime] = weatheRawCode
                        weatherDataString[Constants.api_SNwind] = value
                        totalWeatherDataString[fcstDateTime] = weatherDataString
                        
                    case Constants.api_humi : /// REH - 습도
                        let value = dataArray[i]["fcstValue"].stringValue
                        weatheRawCode[Constants.api_humi] = value
                        totalWeatherRawCode[fcstDateTime] = weatheRawCode
                        weatherDataString[Constants.api_humi] = value
                        totalWeatherDataString[fcstDateTime] = weatherDataString
                        
                    case Constants.api_windDirect : /// VEC - 풍향
                        let value = dataArray[i]["fcstValue"].stringValue
                        weatheRawCode[Constants.api_windDirect] = value
                        totalWeatherRawCode[fcstDateTime] = weatheRawCode
                        weatherDataString[Constants.api_windDirect] = value
                        totalWeatherDataString[fcstDateTime] = weatherDataString
                        
                    case Constants.api_wind : /// WSD - 풍속
                        let value = dataArray[i]["fcstValue"].stringValue
                        weatheRawCode[Constants.api_wind] = value
                        totalWeatherRawCode[fcstDateTime] = weatheRawCode
                        weatherDataString[Constants.api_wind] = value
                        totalWeatherDataString[fcstDateTime] = weatherDataString
                        
                    case Constants.api_minTemp : /// TMN - 오전최저기온
                        let value = dataArray[i]["fcstValue"].stringValue
                        weatheRawCode[Constants.api_minTemp] = value
                        totalWeatherRawCode[fcstDateTime] = weatheRawCode
                        weatherDataString[Constants.api_minTemp] = value
                        totalWeatherDataString[fcstDateTime] = weatherDataString
                        
                    case Constants.api_maxTemp : /// TMX - 오후최고기온
                        let value = dataArray[i]["fcstValue"].stringValue
                        weatheRawCode[Constants.api_maxTemp] = value
                        totalWeatherRawCode[fcstDateTime] = weatheRawCode
                        weatherDataString[Constants.api_maxTemp] = value
                        totalWeatherDataString[fcstDateTime] = weatherDataString
                        
                    default:
                        continue
                    }
                }
                
                let weather = WeatherModel()
                weather.fcstDateTime = totalFcstDateTime
                weather.totalWeatherDataStringDict = totalWeatherDataString
                weather.totalWeatherRawCodeDict = totalWeatherRawCode
                

                completed(weather)
                
                // Weather Cache화
//                if reload == false {
//                    UserDefaults.standard.set(weather.fcstDateTime, forKey: "fcstDateTime")
//                    UserDefaults.standard.set(weather.totalWeatherDataStringDict, forKey: "totalWeatherDataStringDict")
//                    UserDefaults.standard.set(weather.totalWeatherRawCodeDict, forKey: "totalWeatherRawCodeDict")
//                    print("날씨 cache 완료")
//                }
//                else {
//                    print("최신화 완료")
//                }
            }
        }
    }
    
    public func getNowWeather(lat: String, long: String, completed: @escaping (_ weatherinfo: WeatherModel) -> Void) {
        getNow(base: makeNowAPIParameter(lat: lat, lon: long)) { [weak self] (dataArray) in

            // 날씨정보 raw code
            var weatheRawCode: [String:String] = [:]
            var totalWeatherRawCode: [String:[String:String]] = [:]
            
            // 날씨정보 이름
            var weatherDataString: [String:String] = [:]
            var totalWeatherDataString: [String:[String:String]] = [:]
            
            var totalFcstDateTime = [String]()
            
            if dataArray.count == 0 {
                completed(WeatherModel.empty)
                print("DATA COUNT ZERO")
            } else {
                for i in 0...dataArray.count - 1 {
                    let fcstTime = dataArray[i]["fcstTime"].stringValue
                    let fcstDate = dataArray[i]["fcstDate"].stringValue
                    let fcstDateTime = "\(fcstDate)\(fcstTime)"
                    if !totalFcstDateTime.contains(fcstDateTime) {
                        totalFcstDateTime.append(fcstDateTime)
                    }
                    
                    switch dataArray[i]["category"].stringValue {
                    case Constants.api_sky : /// SKY - 하늘상태
                        guard let dayNightTime = Int(fcstTime) else { return }
                        let value = dataArray[i]["fcstValue"].stringValue
                        weatheRawCode[Constants.api_sky] = value
                        totalWeatherRawCode[fcstDateTime] = weatherDataString
                        switch value {
                        case "1":
                            // 맑음
                            if dayNightTime > 700 && dayNightTime < 2000 {
                                // 낮
                                weatherDataString[Constants.api_sky] = Weather.Sunny.convertName().subs
                                weatherDataString[Constants.api_sky_image] = Weather.Sunny.convertName().code
                                totalWeatherDataString[fcstDateTime] = weatherDataString
                                
                            } else {
                                // 밤
                                weatherDataString[Constants.api_sky] = Weather.ClearNight.convertName().subs
                                weatherDataString[Constants.api_sky_image] = Weather.ClearNight.convertName().code
                                totalWeatherDataString[fcstDateTime] = weatherDataString
                            }
                        case "2":
                            // 구름조금 (2019.06.04 이후 삭제됨)
                            if dayNightTime > 700 && dayNightTime < 2000 {
                                // 낮
                                weatherDataString[Constants.api_sky] = Weather.LittleCloudy.convertName().subs
                                weatherDataString[Constants.api_sky_image] = Weather.LittleCloudy.convertName().code
                                totalWeatherDataString[fcstDateTime] = weatherDataString
                            } else {
                                // 밤
                                weatherDataString[Constants.api_sky] = Weather.LittleCloudyNight.convertName().subs
                                weatherDataString[Constants.api_sky_image] = Weather.LittleCloudyNight.convertName().code
                                totalWeatherDataString[fcstDateTime] = weatherDataString
                            }
                        case "3":
                            // 구름많음
                            weatherDataString[Constants.api_sky] = Weather.MoreCloudy.convertName().subs
                            weatherDataString[Constants.api_sky_image] = Weather.MoreCloudy.convertName().code
                            totalWeatherDataString[fcstDateTime] = weatherDataString
                        case "4":
                            // 흐림
                            weatherDataString[Constants.api_sky] = Weather.Cloudy.convertName().subs
                            weatherDataString[Constants.api_sky_image] = Weather.Cloudy.convertName().code
                            totalWeatherDataString[fcstDateTime] = weatherDataString
                        default:
                            weatherDataString[Constants.api_sky] = "정보 없음"
                            totalWeatherDataString[fcstDateTime] = weatherDataString
                        }
                    case Constants.api_rainform : /// PTY - 강수형태
                        let value = dataArray[i]["fcstValue"].stringValue
                        weatheRawCode[Constants.api_rainform] = value
                        totalWeatherRawCode[fcstDateTime] = weatheRawCode
                        switch value {
                        case "0":
                            // 없음
                            weatherDataString[Constants.api_rainform] = ""
                            totalWeatherRawCode[fcstDateTime] = weatherDataString
                        case "1":
                            // 비
                            weatherDataString[Constants.api_rainform] = Weather.Rainy.convertName().subs
                            weatherDataString[Constants.api_rain_image] = Weather.Rainy.convertName().code
                            totalWeatherDataString[fcstDateTime] = weatherDataString
                        case "2":
                            // 비/눈 (진눈깨비)
                            weatherDataString[Constants.api_rainform] = Weather.Sleet.convertName().subs
                            weatherDataString[Constants.api_rain_image] = Weather.Sleet.convertName().code
                            totalWeatherDataString[fcstDateTime] = weatherDataString
                        case "3":
                            // 눈
                            weatherDataString[Constants.api_rainform] = Weather.Snow.convertName().subs
                            weatherDataString[Constants.api_rain_image] = Weather.Snow.convertName().code
                            totalWeatherDataString[fcstDateTime] = weatherDataString
                        case "4":
                            // 소나기
                            weatherDataString[Constants.api_rainform] = Weather.Shower.convertName().subs
                            weatherDataString[Constants.api_rain_image] = Weather.Snow.convertName().code
                            totalWeatherDataString[fcstDateTime] = weatherDataString
                        default:
                            weatherDataString[Constants.api_rainform] = "정보 없음"
                            totalWeatherDataString[fcstDateTime] = weatherDataString
                        }
                    
                    case Constants.api_1HourTemp : /// T1H - 1시간기온
                        let value = dataArray[i]["fcstValue"].stringValue
                        weatheRawCode[Constants.api_1HourTemp] = self?.roundedTemperature(from: value)
                        totalWeatherRawCode[fcstDateTime] = weatheRawCode
                        weatherDataString[Constants.api_1HourTemp] = self?.roundedTemperature(from: value)
                        totalWeatherDataString[fcstDateTime] = weatherDataString
                        
                    
                    default:
                        continue
                    }
                }
                
                let weather = WeatherModel()
                weather.fcstDateTime = totalFcstDateTime
                weather.totalWeatherDataStringDict = totalWeatherDataString
                weather.totalWeatherRawCodeDict = totalWeatherRawCode
                completed(weather)
                
            }
        }
    }
    
    public func getTomorrowWeather(completed: @escaping (_ tomorrowInfo: Array<Dictionary<String, String>>) -> Void) {
        getTomorrow(base: makeTomorrowAPIParameter()) { (dataArray) in
            var info = [Dictionary<String, String>]()
            for i in 0..<dataArray.count {
                var weather = [String:String]()
                weather["numEf"] = dataArray[i]["numEf"].stringValue
                weather["ta"] = dataArray[i]["ta"].stringValue
                weather["rnSt"] = dataArray[i]["rnSt"].stringValue
                weather["wf"] = dataArray[i]["wf"].stringValue
                weather["wfCd"] = dataArray[i]["wfCd"].stringValue
                weather["rnYn"] = dataArray[i]["rnYn"].stringValue
                info.append(weather)
            }
            completed(info)
        }
    }
    
    public func getForecastWeather(completed: @escaping (_ forecastInfo: [String:Array<Any>]) -> Void) {
        getForecast(base: makeForecastAPIParameter(object: "weather"), object: "weather") { (dataArray) in
            if dataArray.count > 0 {
                let info: Dictionary = dataArray[0].dictionaryObject ?? ["":""]
                let pmRainCode = ["rnSt3Pm","rnSt4Pm","rnSt5Pm","rnSt6Pm","rnSt7Pm"]
                let future_RainCode = ["rnSt8","rnSt9","rnSt10"]
                let pmWeatherCode = ["wf3Pm","wf4Pm","wf5Pm","wf6Pm","wf7Pm"]
                let future_WeatherCode = ["wf8","wf9","wf10"]
                var rainDict: [String:Array<Any>] = [:]
                var rainArray = [Any]()
                var skyArray = [Any]()
                for pmRain in pmRainCode {
                    rainArray.append(info[pmRain] ?? "")
                }
                for futRain in future_RainCode {
                    rainArray.append(info[futRain] ?? "")
                }
                
                for pmWeather in pmWeatherCode {
                    skyArray.append(info[pmWeather] ?? "")
                }
                for futWeather in future_WeatherCode {
                    skyArray.append(info[futWeather] ?? "")
                }
                rainDict["rain"] = rainArray
                rainDict["sky"] = skyArray
                
                completed(rainDict)
            }
        }
    }
    
    public func getForecastTemp(completed: @escaping (_ forecastInfo: [String:Array<Any>]) -> Void) {
        getForecast(base: makeForecastAPIParameter(object: "temp"), object: "temp") { (dataArray) in
            if dataArray.count > 0 {
                let info: Dictionary = dataArray[0].dictionaryObject ?? ["":""]
                let tempMinCode = ["taMin3","taMin4","taMin5","taMin6","taMin7","taMin8","taMin9","taMin10"]
                let tempMaxCode = ["taMax3","taMax4","taMax5","taMax6","taMax7","taMax8","taMax9","taMax10"]
                var tempMinArray = [Any]()
                var tempMaxArray = [Any]()
                var tempDict: [String:Array<Any>] = [:]
                for min in tempMinCode {
                    tempMinArray.append(info[min] ?? "")
                }
                for max in tempMaxCode {
                    tempMaxArray.append(info[max] ?? "")
                }
                tempDict["tempMin"] = tempMinArray
                tempDict["tempMax"] = tempMaxArray
                
                completed(tempDict)
            }
        }
    }
    

    //MARK: - Make Api Parameter
    // 오늘, 내일, 모레 날씨 받아오기 위함
    public func makeCurrentAPIParameter(lat:String, lon:String, reload: Bool) -> [String:String] {
        let now = Date()
        let dateFommater = DateFormatter()
        let yesterday = now.addingTimeInterval(-24 * 60 * 60)
        var nx = ""
        var ny = ""

        dateFommater.dateFormat = "yyyyMMdd"

        dateFommater.timeZone = TimeZone(secondsFromGMT: 9 * 60 * 60)

        var date:String = dateFommater.string(from: now)
        let setYesterday = dateFommater.string(from: yesterday)
        var timeString = "\(getTime())\(getMin())"

        if let lat = Double(lat), let lon = Double(lon) {
            nx = "\(Int(convertGrid(code: "toXY", v1: lat, v2: lon)["nx"]!))"
            ny = "\(Int(convertGrid(code: "toXY", v1: lat, v2: lon)["ny"]!))"
        }

        // 데이터 불러오는 특성때문(공공데이터 특성)
        let setTime = Int(timeString)!
        if reload == true {
            if setTime < 200 {
                date = setYesterday
                timeString = "2000"
            } else if setTime < 510 {
                date = setYesterday
                timeString = "2000"
            } else if setTime < 810 {
                timeString = "0200"
            } else if setTime < 1110 {
                timeString = "0500"
            } else if setTime < 1410 {
                timeString = "0800"
            } else if setTime < 1710 {
                timeString = "1100"
            } else if setTime < 2010 {
                timeString = "1400"
            } else if setTime < 2310 {
                timeString = "1700"
            } else if setTime >= 2310 {
                timeString = "2000"
            }
        }
        else {
            if setTime < 2000 {
                date = setYesterday
                timeString = "2000"
            }
            else if setTime < 2310 {
                date = setYesterday
                timeString = "2300"
            }
            else {
                timeString = "2000"
            }
        }
    
        let appid = WeatherData.appKey
        let parameter = ["ServiceKey":appid.removingPercentEncoding!,
                         "base_date":date,
                         "base_time":timeString,
                         "pageNo": "1",
                         "numOfRows": "999",
                         "nx":nx,
                         "ny":ny,
                         "dataType":"JSON"]
        return parameter
    }
    
    // 지금 현재 날씨 받아오기 위함
    public func makeNowAPIParameter(lat:String, lon:String) -> [String:String] {
        let now = Date()
        let dateFommater = DateFormatter()
        let yesterday = now.addingTimeInterval(-24 * 60 * 60)
        var nx = ""
        var ny = ""

        dateFommater.dateFormat = "yyyyMMdd"

        dateFommater.timeZone = TimeZone(secondsFromGMT: 9 * 60 * 60)

        var date:String = dateFommater.string(from: now)
        let setYesterday = dateFommater.string(from: yesterday)
        var timeString = "\(getTime())\(getMin())"

        if let lat = Double(lat), let lon = Double(lon) {
            nx = "\(Int(convertGrid(code: "toXY", v1: lat, v2: lon)["nx"]!))"
            ny = "\(Int(convertGrid(code: "toXY", v1: lat, v2: lon)["ny"]!))"
        }

        // 데이터 불러오는 특성때문(공공데이터 특성)
        let setTime = Int(timeString)!
        if setTime < 645 {
            date = setYesterday
            if setTime < 45 {
                timeString = "2330"
            }
            else {
                timeString = "2430"
            }
        }
        else {
            let time = Int(getTime())!
            if time < 11 {
                timeString = "0630"
            }
            else {
                timeString = "\(time - 1)30"
            }
        }
        let appid = WeatherData.appKey
        let parameter = ["ServiceKey":appid.removingPercentEncoding!,
                         "base_date":date,
                         "base_time":timeString,
                         "pageNo": "1",
                         "numOfRows": "999",
                         "nx":nx,
                         "ny":ny,
                         "dataType":"JSON"]
        return parameter
    }
    
    
    
    // 내일, 모레 오전 오후 날씨 받아오기 위함.
    public func makeTomorrowAPIParameter() -> [String:String] {
        // 추후 위치에 따라 regID를 바꿔야함.
        let regId = "11B10101"
        let appid = WeatherData.appKey
        let parameter = ["ServiceKey":appid.removingPercentEncoding!,
                         "pageNo": "1",
                         "numOfRows": "6",
                         "regId":regId,
                         "dataType":"JSON"]
        return parameter
    }
    
    public func makeForecastAPIParameter(object: String) -> [String:String] {
        var regId = ""
        if object == "weather" {
            regId = "11B00000"
        }
        else if object == "temp" {
            regId = "11B10101"
        }
        let timePar = getTimePar()
        let appid = WeatherData.appKey
        let parameter = ["ServiceKey":appid.removingPercentEncoding!,
                         "pageNo": "1",
                         "numOfRows": "1",
                         "regId":regId,
                         "tmFc":timePar,
                         "dataType":"JSON"]
        return parameter
    }
    
    //MARK: - Private
    private func roundedTemperature(from temperature:String) -> String {
        var result:String = ""
        if let doubleTemperature:Double = Double(temperature) {
            let intTemperature:Int = Int(doubleTemperature.rounded())
            result = "\(intTemperature)"
        }
        return result
    }
    
    private func getTime() -> String {
        let now = Date()
        let timeFommater = DateFormatter()
        timeFommater.dateFormat = "HH"
        // time은 hour단위
        let time:String = timeFommater.string(from: now)
        
        return time
    }
    
    private func getMin() -> String {
        let now = Date()
        let minFommater = DateFormatter()
        minFommater.dateFormat = "mm"
        let min:String = minFommater.string(from: now)
        
        return min
    }
    
    private func getTimeString() -> String {
        // 현재 시각에 따라 불러지는 데이터 형식이 달라지는것에 대비.
        var time = getTime()
        let min = getMin()
        
        if Int(min)! < 30 {
            let setTime = Int(time)!
            if setTime < 10 {
                time = "0"+"\(setTime)"
            }
        }
        else {
            let setTime = Int(time)! + 1
            if setTime > 24 {
                time = "0000"
            } else if setTime < 10 {
                time = "0"+"\(setTime)"
            } else {
                time = "\(setTime)"
            }
        }
        
        let timeString = time + "00"
        return timeString
    }
    
    private func getTimePar() -> String {
        let now = Date()
        let yesterday = now.addingTimeInterval(-24 * 60 * 60)
        let dateFommater = DateFormatter()
        dateFommater.dateFormat = "yyyyMMdd"
        dateFommater.timeZone = TimeZone(secondsFromGMT: 9 * 60 * 60)
        
        var date:String = dateFommater.string(from: now)
        var time = getTime()
        
        if let intTime = Int(time) {
            if intTime < 6 {
                date = dateFommater.string(from: yesterday)
                time = "18"
            }
            else if intTime < 18 {
                time = "06"
            }
            else {
                time = "18"
            }
        }


        let timePar = date + time + "00"
        return timePar
    }

    
    
    //MARK: - 위도경도 좌표변환뻘짓 함수. 기상청이 제공한 소스를 swift 버전으로 수정해본것.
    private func convertGrid(code:String, v1:Double, v2:Double) -> [String:Double] {
        // LCC DFS 좌표변환을 위한 기초 자료
        let RE = 6371.00877 // 지구 반경(km)
        let GRID = 5.0 // 격자 간격(km)
        let SLAT1 = 30.0 // 투영 위도1(degree)
        let SLAT2 = 60.0 // 투영 위도2(degree)
        let OLON = 126.0 // 기준점 경도(degree)
        let OLAT = 38.0 // 기준점 위도(degree)
        let XO = 43 // 기준점 X좌표(GRID)
        let YO = 136 // 기1준점 Y좌표(GRID)
        
        // LCC DFS 좌표변환 ( code : "toXY"(위경도->좌표, v1:위도, v2:경도), "toLL"(좌표->위경도,v1:x, v2:y) )
        
        let DEGRAD = Double.pi / 180.0
        let RADDEG = 180.0 / Double.pi

        let re = RE / GRID
        let slat1 = SLAT1 * DEGRAD
        let slat2 = SLAT2 * DEGRAD
        let olon = OLON * DEGRAD
        let olat = OLAT * DEGRAD

        var sn = tan(Double.pi * 0.25 + slat2 * 0.5) / tan(Double.pi * 0.25 + slat1 * 0.5)
        sn = log(cos(slat1) / cos(slat2)) / log(sn)
        var sf = tan(Double.pi * 0.25 + slat1 * 0.5)
        sf = pow(sf, sn) * cos(slat1) / sn
        var ro = tan(Double.pi * 0.25 + olat * 0.5)
        ro = re * sf / pow(ro, sn)
        var rs:[String:Double] = [:]
        var theta = v2 * DEGRAD - olon
        if (code == "toXY") {

            rs["lat"] = v1
            rs["lng"] = v2
            var ra = tan(Double.pi * 0.25 + (v1) * DEGRAD * 0.5)
            ra = re * sf / pow(ra, sn)
            if (theta > Double.pi) {
                theta -= 2.0 * Double.pi
            }
            if (theta < -Double.pi) {
                theta += 2.0 * Double.pi
            }
            theta *= sn
            rs["nx"] = floor(ra * sin(theta) + Double(XO) + 0.5)
            rs["ny"] = floor(ro - ra * cos(theta) + Double(YO) + 0.5)
        }
        else {
            rs["nx"] = v1
            rs["ny"] = v2
            let xn = v1 - Double(XO)
            let yn = ro - v2 + Double(YO)
            let ra = sqrt(xn * xn + yn * yn)
            if (sn < 0.0) {
                sn - ra
            }
            var alat = pow((re * sf / ra), (1.0 / sn))
            alat = 2.0 * atan(alat) - Double.pi * 0.5

            if (abs(xn) <= 0.0) {
                theta = 0.0
            }
            else {
                if (abs(yn) <= 0.0) {
                    let theta = Double.pi * 0.5
                    if (xn < 0.0){
                        xn - theta
                    }
                }
                else{
                    theta = atan2(xn, yn)
                }
            }
            let alon = theta / sn + olon
            rs["lat"] = alat * RADDEG
            rs["lng"] = alon * RADDEG
        }
        return rs
    }
}










