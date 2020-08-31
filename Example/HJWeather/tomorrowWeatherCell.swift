//
//  tomorrowWeatherCell.swift
//  HJWeather-Korea
//
//  Created by 김희중 on 2020/07/21.
//  Copyright © 2020 HJ. All rights reserved.
//

import UIKit
import HJWeather

class tomorrowWeatherCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var dustAttributedString =  NSMutableAttributedString(string: "") {
        didSet {
            dustLabel.attributedText = dustAttributedString
            dustLabel.sizeToFit()
        }
    }
    
    fileprivate let ampmid = "ampmid"
    fileprivate let cellid = "cellid"
    
    lazy var ampmWeatherCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.delegate = self
        cv.dataSource = self
        return cv
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
    
    lazy var tomorrowWeatherCollectionView: UICollectionView = {
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
        
        ampmWeatherCollectionView.register(ampmCell.self, forCellWithReuseIdentifier: ampmid)
        tomorrowWeatherCollectionView.register(WeatherInnerCell.self, forCellWithReuseIdentifier: cellid)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var ampmWeatherCollectionViewConstraint: NSLayoutConstraint?
    var dustLabelConstraint: NSLayoutConstraint?
    var tomorrowWeatherCollectionViewConstraint: NSLayoutConstraint?
    
    fileprivate func setupLayouts() {
        self.backgroundColor = .white
        
        addSubview(ampmWeatherCollectionView)
        addSubview(dustLabel)
        addSubview(tomorrowWeatherCollectionView)
        
        ampmWeatherCollectionViewConstraint = ampmWeatherCollectionView.anchor(self.topAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 155).first
        dustLabelConstraint = dustLabel.anchor(ampmWeatherCollectionView.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 40).first
        tomorrowWeatherCollectionViewConstraint = tomorrowWeatherCollectionView.anchor(dustLabel.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: (self.frame.width / 8 * 3) + 142).first
        
    }
    
    var ampmWeatherInfo = [Dictionary<String, String>]()
    
    var tomorrowWeatherDateTime = [String]()
    var tomorrowWeatherInfo = [String:[String:String]]()
    
    var didCall: Bool = false
    
    let timeGap = ["0000","0300","0600","0900","1200","1500","1800","2100"]
    
    var tomorrowAfterCheck = "" {
        didSet {
            if !didCall {
                let date = getTomorrowDate(check: tomorrowAfterCheck)
                for i in timeGap {
                    tomorrowWeatherDateTime.append("\(date)\(i)")
                    self.tomorrowWeatherCollectionView.reloadData()
                }
                didCall = true
            }
        }
    }
    
    
    private func getTomorrowDate(check: String) -> String {
        let now = Date()
        var tomorrow = now.addingTimeInterval(24 * 60 * 60)
        if check == "after" {
            tomorrow = now.addingTimeInterval(48 * 60 * 60)
        }
        let dateFommater = DateFormatter()
        dateFommater.dateFormat = "yyyyMMdd"
        dateFommater.timeZone = TimeZone(secondsFromGMT: 9 * 60 * 60)
        let date:String = dateFommater.string(from: tomorrow)
        
        return date
    }
    
    private func getTime() -> String {
        let now = Date()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH"
        // time은 hour단위
        let time:String = timeFormatter.string(from: now)
        
        return time
    }
    
    //MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == ampmWeatherCollectionView {
            return ampmWeatherInfo.count
        }
        else {
            return tomorrowWeatherDateTime.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == ampmWeatherCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ampmid, for: indexPath) as! ampmCell
            if indexPath.item == 0 {
                cell.amText = "오전"
            }
            else {
                cell.amText = "오후"
            }
            
            let info = ampmWeatherInfo[indexPath.item]
            cell.ampmInfo = info
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellid, for: indexPath) as! WeatherInnerCell
            let dateTime = tomorrowWeatherDateTime[indexPath.item]
            let timeinfo = timeInfoModel()
            var timeStartIndex = dateTime.index(dateTime.startIndex, offsetBy: 8)
            if dateTime[timeStartIndex] == "0" {
                timeStartIndex = dateTime.index(dateTime.startIndex, offsetBy: 9)
            }
            let timeEndIndex = dateTime.index(dateTime.startIndex, offsetBy: 10)
            timeinfo.timeNow = "\(String(dateTime[timeStartIndex..<timeEndIndex]))시"

            let weatherInfo = tomorrowWeatherInfo[dateTime]
            cell.timeInfo = timeinfo
            cell.weatherInfo = weatherInfo
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == ampmWeatherCollectionView {
            return CGSize(width: collectionView.frame.width / 2, height: 155)
        }
        else {
            return CGSize(width: collectionView.frame.width / CGFloat(tomorrowWeatherDateTime.count), height: collectionView.frame.height)
        }
    }
}
