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
    
    var futureWeatherInfo: [futureWeatherModel]?
    
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
            let time = WeatherApiHelper.shared.getTime()
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
                
                let index = indexPath.item - startIndex
                cell.futureWeatherInfo = futureWeatherInfo?[index]
                
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

