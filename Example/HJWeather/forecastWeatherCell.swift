//
//  moreWeatherCell.swift
//  HJWeather-Korea
//
//  Created by 김희중 on 2020/07/24.
//  Copyright © 2020 HJ. All rights reserved.
//

import UIKit
import HJWeather

class forecastWeatherCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    fileprivate let cellid = "cellid"
    fileprivate let dateid = "dateid"
    
    lazy var forecastWeatherCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.delegate = self
        cv.dataSource = self
        cv.isScrollEnabled = false
        return cv
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayouts()
    
        forecastWeatherCollectionView.register(datesCell.self, forCellWithReuseIdentifier: dateid)
        forecastWeatherCollectionView.register(forecastCell.self, forCellWithReuseIdentifier: cellid)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var forecastWeatherCollectionViewConstraint: NSLayoutConstraint?
    
    fileprivate func setupLayouts() {
        self.backgroundColor = .white

        addSubview(forecastWeatherCollectionView)
        forecastWeatherCollectionViewConstraint = forecastWeatherCollectionView.anchor(self.topAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topConstant: 40, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 40 + ((frame.width / 7) + 87) * 3).first
    }
    var futureWeatherInfo: [String:Array<Any>]? {
        didSet {
            guard let temp_max = futureWeatherInfo?["tempMax"] else {return}
            tempMax = temp_max
            
            guard let temp_min = futureWeatherInfo?["tempMin"] else {return}
            tempMin = temp_min
            
            guard let rain_Info = futureWeatherInfo?["rain"] else {return}
            rainInfo = rain_Info
            
            guard let sky_Info = futureWeatherInfo?["sky"] else {return}
            skyInfo = sky_Info
            forecastWeatherCollectionView.reloadData()
        }
    }
    
    var tempMax = [Any]()
    var tempMin = [Any]()
    var rainInfo = [Any]()
    var skyInfo = [Any]()
    
    
    fileprivate func getTime() -> String {
        let now = Date()
        let timeFommater = DateFormatter()
        timeFommater.dateFormat = "HH"
        // time은 hour단위
        let time:String = timeFommater.string(from: now)
        
        return time
    }
    
    var ampmWeatherInfo = [Dictionary<String, String>]()
    
    //MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 7
        }
        else {
            return 17
        }
    }
    
    let dates = ["일","월","화","수","목","금","토"]
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: dateid, for: indexPath) as! datesCell
            cell.dateLabel.text = dates[indexPath.item]
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellid, for: indexPath) as! forecastCell
            
            let cal = Calendar(identifier: .gregorian)
            let now = Date()
            let yesterday = now.addingTimeInterval(TimeInterval(-24 * 60 * 60))
            // 일:1 ~ 토:7
            let comps = cal.dateComponents([.weekday], from: now)
            let comps_yesterday = cal.dateComponents([.weekday], from: yesterday)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "d"
            
            var startIndex = (comps.weekday ?? 1) - 1
            let time = getTime()
            if Int(time)! < 5 {
                // 밤 12시 ~ 오전 5시
                startIndex = (comps_yesterday.weekday ?? 1) - 1
            }
            let distance = indexPath.item - startIndex
            
            if indexPath.item >= startIndex && indexPath.item < startIndex + 11 {
                var future = now.addingTimeInterval(TimeInterval(24 * 60 * 60 * distance))
                if Int(time)! < 5 {
                    // 밤 12시 ~ 오전 5시
                    future = yesterday.addingTimeInterval(TimeInterval(24 * 60 * 60 * distance))
                }
                let futureDate = formatter.string(from: future)
                cell.dateLabel.text = futureDate
                if indexPath.item == 6 || indexPath.item == 13 {
                    cell.dateLabel.textColor = .blue
                }
                else if indexPath.item % 7 == 0 {
                    cell.dateLabel.textColor = .red
                }
                else {
                    cell.dateLabel.textColor = .black
                }
                
                if Int(time)! < 5 {
                    // 밤 12시 ~ 오전 5시
                    if (indexPath.item - 1) == startIndex {
                        // 당일 현재
                        cell.dateLabel.textColor = .white
                        cell.dateLabel.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
                    }
                    else {
                        cell.dateLabel.backgroundColor = .clear
                        if indexPath.item == startIndex {
                            // 전날
                            cell.coverView.alpha = 1
                        }
                        else {
                            cell.coverView.alpha = 0
                        }
                    }
                }
                else {
                    cell.dateLabel.backgroundColor = .clear
                    if indexPath.item == startIndex {
                        cell.dateLabel.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
                        cell.dateLabel.textColor = .white
                    }
                }
                

                if indexPath.item > startIndex + 2 {
                    // 3일 이후 부터
                    let futureWeather = futureWeatherModel()
                    let index = indexPath.item - startIndex - 3
                    
                    if tempMax.count > 0 {
                        let tempmax = tempMax[index]
                        futureWeather.temp_Max = tempmax
                    }
                    if tempMin.count > 0 {
                        let tempmin = tempMin[index]
                        futureWeather.temp_Min = tempmin
                    }
                    if rainInfo.count > 0 {
                        let rain = rainInfo[index] as! Int
                        if rain > 30 {
                            futureWeather.rain_text = rain
                        }
                    }
                    if skyInfo.count > 0 {
                        let sky = skyInfo[index] as! String
                        print(sky, "forecast Weather Cell ", indexPath.item)
                        futureWeather.sky_text = sky
                    }
                    cell.futureWeatherInfo = futureWeather
                }
                else {
                    // 오늘,내일,모레
                    let nearfutureWeather = futureWeatherModel()
                    let maxIndex = (indexPath.item - startIndex) * 2
                    if ampmWeatherInfo.count > 0 {
                        let maxTemp = ampmWeatherInfo[maxIndex]["ta"]
                        nearfutureWeather.temp_Max = maxTemp
                        if let isRain = ampmWeatherInfo[maxIndex]["rnYn"] {
                            if Int(isRain)! == 0 {
                                if let sky = ampmWeatherInfo[maxIndex]["wfCd"] {
                                    if sky == "DB01" {
                                        nearfutureWeather.sky_text = "SKY_D01"
                                    }
                                    else if sky == "DB03" {
                                        nearfutureWeather.sky_text = "SKY_D03"
                                    }
                                    else {
                                        // DB04
                                        nearfutureWeather.sky_text = "SKY_D04"
                                    }
                                }
                            }
                            else if Int(isRain)! == 1 {
                                nearfutureWeather.sky_text = "RAIN_D01"
                            }
                            else if Int(isRain)! == 2 {
                                nearfutureWeather.sky_text = "RAIN_D02"
                            }
                            else if Int(isRain)! == 3 {
                                nearfutureWeather.sky_text = "RAIN_D03"
                            }
                            else {
                                nearfutureWeather.sky_text = "RAIN_D04"
                            }
                        }
                    }
                    if ampmWeatherInfo.count == 5 {
                        // 오전 11시 이후 요청시
                        let minIndex = maxIndex - 1
                        if indexPath.item - startIndex > 0 {
                            let minTemp = ampmWeatherInfo[minIndex]["ta"]
                            nearfutureWeather.temp_Min = minTemp
                            
                        }
                        else {
                            nearfutureWeather.temp_Min = ""
                        }
                        let rain = ampmWeatherInfo[maxIndex]["rnSt"]
                        nearfutureWeather.rain_text = rain
                    }
                    else if ampmWeatherInfo.count == 6 {
                        // 오전 11시 이전 요청시
                        let minIndex = maxIndex + 1
                        let minTemp = ampmWeatherInfo[minIndex]["ta"]
                        nearfutureWeather.temp_Min = minTemp
                    }
                    
                    cell.nearfutureWeatherInfo = nearfutureWeather
                }
            }
            else {
                // cell reuse에 대한 오류 해결.
                cell.dateLabel.backgroundColor = .clear
                cell.dateLabel.text = ""
                cell.weatherImageView.image = nil
                cell.highTempLabel.text = ""
                cell.lowTempLabel.text = ""
                cell.rainLabel.text = ""
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSize(width: collectionView.frame.width / 7, height: 40)
        }
        else {
            return CGSize(width: collectionView.frame.width / 7, height: (collectionView.frame.height - 40) / 3)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
}
