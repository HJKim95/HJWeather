//
//  DustApiHelper.swift
//  SpotShare
//
//  Created by 김희중 on 2020/03/13.
//  Copyright © 2020 김희중. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

public class DustApiHelper {
    
    public static let shared = DustApiHelper()
    
    public func todayDustInfo(cityName:String, subLocalName: String , dustData: @escaping (_ data:todayDust) -> Void) {
        requestDust(cityName: cityName) { (response) in
            //여기서 데이터 구성
            var totalDustData = [todayDust]()
            for data in response.arrayValue {
                let responsecityName = data["stationName"].stringValue
                let pm10 = data["pm10Value"].stringValue
                let pm25 = data["pm25Value"].stringValue
                let time = data["dataTime"].stringValue
                let PM10comment = self.convertPM10Comment(dustScore: pm10)
                let PM25comment = self.convertPM25Comment(dustScore: pm25)
                let tempTodatDust = todayDust(time: time,
                                              location: responsecityName,
                                              dust10Value: pm10,
                                              dust25Value: pm25,
                                              dustPM10Comment: PM10comment,
                                              dustPM25Comment: PM25comment)
                totalDustData.append(tempTodatDust)
            }
            var pm10: String = ""
            for data in totalDustData {
                // 측정 자치구가 있는 경우.
                if data.location == subLocalName {
                    pm10 = data.dust10Value
                }
            }
            
            var pm25: String = ""
            for data in totalDustData {
                // 측정 자치구가 있는 경우.
                if data.location == subLocalName {
                    pm25 = data.dust25Value
                }
            }
            
            // 측정 자치구가 없는 경우 평균값을 이용해서 보여주기
            var pm10Average:String = ""
            var sumPM10:Int = 0
            var pm10Count:Int = 0
            for data in totalDustData {
                if let pm10 = Int(data.dust10Value) {
                    sumPM10 += pm10
                    pm10Count += 1
                }
            }
            
            if sumPM10 > 0 && pm10Count > 0 {
                pm10Average = "\(sumPM10 / pm10Count)"
            }
            
            // 측정 자치구가 없는 경우 평균값을 이용해서 보여주기
            var pm25Average:String = ""
            var sumPM25:Int = 0
            var pm25Count:Int = 0
            for data in totalDustData {
                if let pm25 = Int(data.dust25Value) {
                    sumPM25 += pm25
                    pm25Count += 1
                }
            }

            if sumPM25 > 0 && pm25Count > 0 {
                pm25Average = "\(sumPM25 / pm25Count)"
            }
            

            let now = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd-HH:00"
            let time = formatter.string(from: now)
            var curruntDustData:todayDust = todayDust(time: time,
                                                      location: "정보 없음",
                                                      dust10Value: "0",
                                                      dust25Value: "0",
                                                      dustPM10Comment: "정보 없음",
                                                      dustPM25Comment: "정보 없음")
            if pm10 != "" {
                print("특정 자치구의 측정값 이용")
                curruntDustData.location = cityName
                curruntDustData.dust10Value = pm10
                curruntDustData.dust25Value = pm25
                curruntDustData.dustPM10Comment = self.convertPM10Comment(dustScore: pm10)
                curruntDustData.dustPM25Comment = self.convertPM25Comment(dustScore: pm25)
                curruntDustData.time = time
                dustData(curruntDustData)
            }
            else {
                print("자치구의 측정값 평균값 이용")
                curruntDustData.location = cityName
                curruntDustData.dust10Value = pm10Average
                curruntDustData.dust25Value = pm25Average
                curruntDustData.dustPM10Comment = self.convertPM10Comment(dustScore: pm10Average)
                curruntDustData.dustPM25Comment = self.convertPM25Comment(dustScore: pm25Average)
                curruntDustData.time = time
                dustData(curruntDustData)
            }
            
            
            var dustCache:[String:String] = [:]
            dustCache["time"] = time
            dustCache["location"] = cityName
            dustCache["sublocation"] = subLocalName
            dustCache["dustPM10Value"] = pm10Average
            dustCache["dustPM25Value"] = pm25Average
            dustCache["dustPM10Comment"] = self.convertPM10Comment(dustScore: pm10Average)
            dustCache["dustPM25Comment"] = self.convertPM25Comment(dustScore: pm25Average)
            UserDefaults.standard.set(dustCache, forKey: "dustCache")
            print("미세먼지 cache 완료")
        }
    }
    
    public func forecastDustInfo(pm:String, completed: @escaping (_ data: Array<Dictionary<String, String>>) -> Void) {
        requestForecastDust(pm: pm) { [weak self] (response) in
//            print(response)
            var totalDict = [String:[String:String]]()
            for dust in response.arrayValue {
                let informTime = dust["informData"].stringValue
                let pmValues = dust["informGrade"].stringValue.components(separatedBy: ",")
                var pmDict = [String:String]()
                for pm in pmValues {
                    let data = pm.components(separatedBy: " : ")
                    pmDict[data[0]] = data[1]
                    totalDict[informTime] = pmDict
                }
            }
            guard let tomorrow = self?.getTomorrow(after: false) else {return}
            guard let after = self?.getTomorrow(after: true) else {return}
            var dustArray = [Dictionary<String, String>]()
            dustArray.append(totalDict[tomorrow] ?? [:])
            dustArray.append(totalDict[after] ?? [:])
            completed(dustArray)
        }
    }
    
    private func convertPM10Comment(dustScore:String) -> String {
        guard let score = Int(dustScore) else { return "정보 없음" }
        if 0 < score && score <= 30 {
            return "좋음"
        } else if 30 < score && score <= 80 {
            return "보통"
        } else if 80 < score && score <= 150 {
            return "나쁨"
        } else if score > 150 {
            return "매우 나쁨"
        }
        return "정보 없음"
    }
    
    private func convertPM25Comment(dustScore:String) -> String {
        guard let score = Int(dustScore) else { return "정보 없음" }
        if 0 < score && score <= 15 {
            return "좋음"
        } else if 15 < score && score <= 35 {
            return "보통"
        } else if 35 < score && score <= 75 {
            return "나쁨"
        } else if score > 75 {
            return "매우 나쁨"
        }
        return "정보 없음"
    }
    
    private func convertName(eng: String) -> String {
        switch eng {
        case "Seoul","서울특별시": return "서울"
        case "Busan","부산광역시": return "부산"
        case "Daegu","대구광역시": return "대구"
        case "Incheon","인천광역시": return "인천"
        case "Gwangju", "광주광역시": return "광주"
        case "Daejeon", "대전광역시": return "대전"
        case "Gyeonggi-do", "경기도": return "경기"
        case "Gangwon","강원도": return "강원"
        case "North Chungcheong","충청북도": return "충북"
        case "South Chungcheong","충청남도": return "충남"
        case "North Jeolla","전라북도": return "전북"
        case "South Jeolla","전라남도": return "전남"
        case "North Gyeongsang","경상북도": return "경북"
        case "South Gyeongsang","경상남도": return "경남"
        case "Jeju","제주도","제주시": return "제주"
        default: return "위치 확인 불가"
        }
    }
    
   private func requestDust(cityName:String, completion: @escaping (_ dustValue:JSON) -> Void) {
        let sidoName:String = convertName(eng: cityName)
        let appkey = WeatherData.appKey
        let url = WeatherData.dustApi
        
        let parameter = ["ServiceKey":appkey.removingPercentEncoding!,
                         "ver":"1.3",
                         "sidoName":sidoName,
                         "_returnType":"json"]
        

        AF.request(url, method: .get,
                  parameters: parameter,
                  encoding: URLEncoding.default,
                  headers: nil).responseJSON { (response) in
                    
                guard let responseData = response.data else { return }
                let tempData = JSON(responseData)
                let today = tempData["list"]
                print("미세먼지데이터 받아오기 시작")
                completion(today)
        }
    }
    
    func requestForecastDust(pm:String, completion: @escaping (_ dustValue:JSON) -> Void) {
        let appkey = WeatherData.appKey
        let url = WeatherData.forecastDustApi
        let parameter = ["serviceKey":appkey.removingPercentEncoding!,
                         "numOfRows":"10",
                         "pageNo":"1",
                         "searchDate":getDate(),
                         "InformCode":pm,
                         "_returnType":"json"]
        
        AF.request(url, method: .get,
                  parameters: parameter,
                  encoding: URLEncoding.default,
                  headers: nil).responseJSON { (response) in
                    
                guard let responseData = response.data else { return }
                let tempData = JSON(responseData)
                let dust = tempData["list"]
                completion(dust)
        }
    }
    
    private func getDate() -> String {
        let now = Date()
        let dateFommater = DateFormatter()
        dateFommater.dateFormat = "yyyy-MM-dd"
        dateFommater.timeZone = TimeZone(secondsFromGMT: 9 * 60 * 60)
        
        let date:String = dateFommater.string(from: now)
        
        return date
    }
    
    private func getTomorrow(after: Bool) -> String {
        let now = Date()
        let tomorrow = now.addingTimeInterval(24 * 60 * 60)
        let afterTomorrow = now.addingTimeInterval(48 * 60 * 60)
        let dateFommater = DateFormatter()
        dateFommater.dateFormat = "yyyy-MM-dd"
        dateFommater.timeZone = TimeZone(secondsFromGMT: 9 * 60 * 60)
        
        var date = ""
        if !after {
            date = dateFommater.string(from: tomorrow)
        }
        else {
            date = dateFommater.string(from: afterTomorrow)
        }
        
        return date
    }
    
}

public struct todayDust {
    
    public var time:String
    public var location:String
    public var dust10Value:String
    public var dust25Value:String
    public var dustPM10Comment:String
    public var dustPM25Comment:String
  
}
