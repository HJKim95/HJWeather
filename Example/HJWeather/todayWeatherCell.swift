//
//  todayWeatherCell.swift
//  HJWeather-Korea
//
//  Created by 김희중 on 2020/07/20.
//  Copyright © 2020 HJ. All rights reserved.
//

import UIKit
import HJWeather

class todayWeatherCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var nowWeather = nowWeatherModel() {
        didSet {
            weatherLabel.attributedText = nowWeather.attributedString
            weatherLabel.sizeToFit()
            compareLabel.text = nowWeather.sky_text
        }
    }
    
    var dustAttributedString =  NSMutableAttributedString(string: "") {
        didSet {
            dustLabel.attributedText = dustAttributedString
            dustLabel.sizeToFit()
        }
    }
    
    var didCall: Bool = false
    var todayWeatherDateTime = [String]()
    var todayWeatherInfo = [String:[String:String]]() {
        didSet {
            if !didCall {
                getWeatherDataTime()
                didCall = true
            }
        }
    }
    
    fileprivate let cellid = "cellid"
    
    let weatherLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.backgroundColor = .white
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 40)
        return label
    }()
    
    let compareLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.backgroundColor = .white
        label.font = UIFont.systemFont(ofSize: 24)
        label.textColor = .black
        return label
    }()
    
    let dustLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.backgroundColor = .white
        label.textColor = .black
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    lazy var todayWeatherCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.delegate = self
        cv.dataSource = self
        cv.alwaysBounceHorizontal = true
        cv.isPagingEnabled = true
        return cv
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayouts()
        
        todayWeatherCollectionView.register(WeatherInnerCell.self, forCellWithReuseIdentifier: cellid)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
    var weatherLabelConstraint: NSLayoutConstraint?
    var compareLabelConstraint: NSLayoutConstraint?
    var dustLabelConstraint: NSLayoutConstraint?
    var todayWeatherCollectionViewConstraint: NSLayoutConstraint?
    
    fileprivate func setupLayouts() {
        self.backgroundColor = .white

        addSubview(weatherLabel)
        addSubview(compareLabel)
        addSubview(dustLabel)
        addSubview(todayWeatherCollectionView)
        
        weatherLabelConstraint = weatherLabel.anchor(self.topAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 80).first
        compareLabelConstraint = compareLabel.anchor(weatherLabel.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 20).first
        dustLabelConstraint = dustLabel.anchor(compareLabel.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 40).first
        todayWeatherCollectionViewConstraint = todayWeatherCollectionView.anchor(dustLabel.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: (self.frame.width / 8 * 3) + 142).first
        
        
    }
    
    
    let timeGap = ["0000","0300","0600","0900","1200","1500","1800","2100"]
    
    fileprivate func getWeatherDataTime() {
    
        let date = getDate(index: 0)
        let time = getTime()
        let tomorrow = getDate(index: 1)
        for i in timeGap {
            if time == "23" {
                todayWeatherDateTime.append("\(tomorrow)\(i)")
            }
            else {
                todayWeatherDateTime.append("\(date)\(i)")
            }
            self.todayWeatherCollectionView.reloadData()
        }
    }
    
    fileprivate func getDate(index: Int) -> String {
        // index: 0 now, 1 tomorrow, 2 day after tomorrow
        var date = Date()
        if index == 1 {
            date = date.addingTimeInterval(24 * 60 * 60)
        }
        else if index == 2 {
            date = date.addingTimeInterval(48 * 60 * 60)
        }
        let dateFommater = DateFormatter()
        dateFommater.dateFormat = "yyyyMMdd"
        dateFommater.timeZone = TimeZone(secondsFromGMT: 9 * 60 * 60)
        let dateString:String = dateFommater.string(from: date)
        
        return dateString
    }
    
    private func getTime() -> String {
        let now = Date()
        let timeFommater = DateFormatter()
        timeFommater.dateFormat = "HH"
        // time은 hour단위
        let time:String = timeFommater.string(from: now)
        
        return time
    }
    
    //MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return todayWeatherDateTime.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellid, for: indexPath) as! WeatherInnerCell
        let realTime = getTime()
        let dateTime = todayWeatherDateTime[indexPath.item]
        let timeinfo = timeInfoModel()
        var timeStartIndex = dateTime.index(dateTime.startIndex, offsetBy: 8)
        if dateTime[timeStartIndex] == "0" {
            timeStartIndex = dateTime.index(dateTime.startIndex, offsetBy: 9)
        }
        let timeEndIndex = dateTime.index(dateTime.startIndex, offsetBy: 10)
        if abs(Double(String(dateTime[timeStartIndex..<timeEndIndex]))! - Double(realTime)!) < 1.5 {
            timeinfo.timeNow = "지금"
            timeinfo.rainText = "비올확률"
        }
        else if Double(realTime)! > 21.0 && Double(String(dateTime[timeStartIndex..<timeEndIndex]))! == 21.0 {
            // 당일 21시 이후인 경우 21시를 지금으로 표시
            timeinfo.timeNow = "지금"
            timeinfo.rainText = "비올확률"
        }
        else {
            // 아닌 것은 다시 초기화를 시켜주어야 중복으로 생기지 않는다.
            timeinfo.timeNow = "\(String(dateTime[timeStartIndex..<timeEndIndex]))시"
            timeinfo.rainText = ""
        }
        let weatherInfo = todayWeatherInfo[dateTime]
        cell.timeInfo = timeinfo
        cell.weatherInfo = weatherInfo
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / CGFloat(todayWeatherDateTime.count), height: collectionView.frame.height)
    }
}
