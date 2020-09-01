//
//  WeatherData.swift
//  SpotShare
//
//  Created by 김희중 on 2020/03/12.
//  Copyright © 2020 김희중. All rights reserved.
//

import Foundation

public struct WeatherData {
    // 공공데이터 포털 ( data.go.kr )
    
    static let appKey = "SBjctzZ2m9%2Bi3Ofn4rYZxEphq1hoyVCjKXehzK30iLF18jXhK%2B0K6HE0qOV0x8kj2wLGTlcQxcxKmIVzeT0zaw%3D%3D"
    static let weatherApi = "http://apis.data.go.kr/1360000/VilageFcstInfoService/getVilageFcst" // 동네예보조회
    static let nowWeatherApi = "http://apis.data.go.kr/1360000/VilageFcstInfoService/getUltraSrtFcst" // 초단기조회
    static let tomorrowWeatherApi = "http://apis.data.go.kr/1360000/VilageFcstMsgService/getLandFcst" // 동네예보조회통보문
    static let forecastApi = "http://apis.data.go.kr/1360000/MidFcstInfoService/getMidLandFcst" // 중기예보조회
    static let tempApi = "http://apis.data.go.kr/1360000/MidFcstInfoService/getMidTa"
    
    static let dustApi = "http://openapi.airkorea.or.kr/openapi/services/rest/ArpltnInforInqireSvc/getCtprvnRltmMesureDnsty" // 시도별 실시간 측정정보 조회
    static let forecastDustApi = "http://openapi.airkorea.or.kr/openapi/services/rest/ArpltnInforInqireSvc/getMinuDustFrcstDspth" // 대기질 예보통보 조회

    
}

public enum WeatherObject {
    case now
    case current
    case tomorrow
    case forecastWeather
    case forecastTemp
    case none
}
