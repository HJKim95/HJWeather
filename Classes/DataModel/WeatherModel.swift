//
//  WeatherModel.swift
//  SpotShare
//
//  Created by 김희중 on 2020/03/12.
//  Copyright © 2020 김희중. All rights reserved.
//

import Foundation

public struct Constants {
    
    //- for API
    // 동네예보
    static let api_sky:String = "SKY" // 하늘상태  맑음(1),구름많음(3),흐림(4)
    static let api_rainform:String = "PTY" // 강수형태  없음(0),비(1),비.눈(2),눈(3),소나기(4)
    static let api_rainPercent:String = "POP" // 강수확률
    static let api_3HourTemp:String = "T3H" // 3시간 기온
    static let api_6hourRain:String = "R06" // 6시간 강수량
    static let api_EWwind:String = "UUU" // 동서바람성분  동(+),서(-)
    static let api_SNwind:String = "VVV" // 남북바람성분  북(+),남(-)
    static let api_humi:String = "REH" // 습도
    static let api_windDirect:String = "VEC" // 풍향
    static let api_wind:String = "WSD" // 풍속
    static let api_minTemp: String = "TMN" // 아침최저기온
    static let api_maxTemp: String = "TMX" // 낮최고기온
    
    static let api_sky_image:String = "api_sky_image" // 하늘 image string
    static let api_rain_image:String = "api_rain_image" // rain image string
    
    
    static let api_1HourTemp:String = "T1H" // 1시간 기온
    
}

@objcMembers
public class WeatherModel: NSObject {
    public var fcstDateTime: Array<String>?
    public var totalWeatherDataStringDict: [String:[String:String]]?
    public var totalWeatherRawCodeDict: [String:[String:String]]?
    
    public static let empty = WeatherModel()
}

@objcMembers
public class nowWeatherModel: NSObject {
    public var attributedString: NSMutableAttributedString?
    public var sky_text: String?
}

@objcMembers
public class futureWeatherModel: NSObject {
    public var rain_text = "" // 강수확률
    public var sky_text = "" // 날씨 image text
    public var temp_Max = "" // 최고기온
    public var temp_Min =  "" // 최저기온
    public var sky = "" // 날씨 (한글)
}

@objcMembers
public class timeInfoModel: NSObject {
    public var timeNow: String?
    public var rainText: String?
}

public enum Weather {
    case Sunny
    case LittleCloudy
    case MoreCloudy
    case Cloudy
    case ClearNight
    case LittleCloudyNight
    case Rainy
    case Sleet
    case Snow
    case Shower
    
    func convertName() -> (code:String, subs:String){
        switch self {
        case .Sunny:
            return ("SKY_D01","맑음")
        case .LittleCloudy:
            return ("SKY_D02","구름 조금")
        case .MoreCloudy:
            return ("SKY_D03","구름 많음")
        case .Cloudy:
            return ("SKY_D04","흐림")
        case .ClearNight:
            return ("SKY_D08","맑음")
        case .LittleCloudyNight:
            return ("SKY_D09","구름 조금")
        case .Rainy:
            return ("RAIN_D01","비")
        case .Sleet:
            return ("RAIN_D02","진눈깨비")
        case .Snow:
            return ("RAIN_D03","눈")
        case .Shower:
            return ("RAIN_D04","소나기")
        }
    }
}

