//
//  forecastCell.swift
//  HJWeather-Korea
//
//  Created by 김희중 on 2020/07/29.
//  Copyright © 2020 HJ. All rights reserved.
//

import UIKit
import HJWeather

class forecastCell: UICollectionViewCell {
    
    var futureWeatherInfo: futureWeatherModel? {
        didSet {
            guard let rain = futureWeatherInfo?.rain_text else {return}
            rainLabel.text = "강수확률\n\(rain)%"
            
            guard let sky = futureWeatherInfo?.sky_text else {return}
            if sky == "맑음" {
                weatherImageView.image = UIImage(named: "SKY_D01")
            }
            else if sky == "구름많음" {
                weatherImageView.image = UIImage(named: "SKY_D03")
            }
            else if sky == "흐림" {
                weatherImageView.image = UIImage(named: "SKY_D04")
            }
            else if sky.contains("비") {
                weatherImageView.image = UIImage(named: "RAIN_D01")
            }
            else if sky.contains("눈") {
                weatherImageView.image = UIImage(named: "RAIN_D02")
            }
            else {
                weatherImageView.image = UIImage(named: "SKY_D03")
            }
            guard let tempMax = futureWeatherInfo?.temp_Max else {return}
            highTempLabel.text = "\(tempMax)°"
            
            guard let tempMin = futureWeatherInfo?.temp_Min else {return}
            lowTempLabel.text = "\(tempMin)°"
            
            
        }
    }

    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .black
        label.adjustsFontSizeToFitWidth = true
        label.backgroundColor = .clear
        label.layer.cornerRadius = 12.5
        label.layer.masksToBounds = true
        return label
    }()
    
    let weatherImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.masksToBounds = true
        return iv
    }()
    
    let highTempLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .black
        return label
    }()
    
    let lowTempLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .black
        return label
    }()
    
    let rainLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .black
        return label
    }()
    
    let coverView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1, alpha: 0.8)
        view.alpha = 0
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayouts()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var checkTodayConstraint: NSLayoutConstraint?
    var dateLabelConstraint: NSLayoutConstraint?
    var weatherImageViewConstraint: NSLayoutConstraint?
    var highTempLabelConstraint: NSLayoutConstraint?
    var lowTempLabelConstraint: NSLayoutConstraint?
    var rainLabelConstraint: NSLayoutConstraint?
    var coverViewConstraint: NSLayoutConstraint?
    
    fileprivate func setupLayouts() {
        addSubview(dateLabel)
        addSubview(weatherImageView)
        addSubview(highTempLabel)
        addSubview(lowTempLabel)
        addSubview(rainLabel)
        addSubview(coverView)
        
        dateLabelConstraint = dateLabel.anchor(self.topAnchor, left: self.leftAnchor, bottom: nil, right: nil, topConstant: 2, leftConstant: (self.frame.width - 25) / 2, bottomConstant: 0, rightConstant: 0, widthConstant: 25, heightConstant: 25).first
        weatherImageViewConstraint = weatherImageView.anchor(dateLabel.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: frame.width, heightConstant: frame.width).first
        highTempLabelConstraint = highTempLabel.anchor(weatherImageView.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 15).first
        lowTempLabelConstraint = lowTempLabel.anchor(highTempLabel.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 15).first
        rainLabelConstraint = rainLabel.anchor(lowTempLabel.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 30).first
        coverViewConstraint = coverView.anchor(self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0).first
    }
}

class datesCell: UICollectionViewCell {
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .black
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayouts()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var dateLabelConstraint: NSLayoutConstraint?
    fileprivate func setupLayouts() {
        addSubview(dateLabel)
        dateLabelConstraint = dateLabel.anchor(self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0).first
        
    }
}
