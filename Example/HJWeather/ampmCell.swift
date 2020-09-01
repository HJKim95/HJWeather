//
//  ampmCell.swift
//  HJWeather-Korea
//
//  Created by 김희중 on 2020/07/29.
//  Copyright © 2020 HJ. All rights reserved.
//

import UIKit
import HJWeather

class ampmCell: UICollectionViewCell {
    
    var amText: String? {
        didSet {
            amLabel.text = amText
            if amText == "오후" {
                dividerline.alpha = 0
            }
        }
    }
    
    var ampmInfo: futureWeatherModel? {
        didSet {
            guard let weather = ampmInfo?.sky else {return}
            weatherLabel.text = "\(weather)"
            
            guard let rain = ampmInfo?.rain_text else {return}
            rainLabel.text = "강수확률 \(rain)%"
            
            let attributedString = NSMutableAttributedString(string: "")
            let imageAttachment = NSTextAttachment()
            
            if let sky = ampmInfo?.sky_text {
                switch sky {
                case "맑음":
                    imageAttachment.image = UIImage(named: "SKY_D01")
                case "구름많음":
                    imageAttachment.image = UIImage(named: "SKY_D03")
                case "흐림":
                    imageAttachment.image = UIImage(named: "SKY_D04")
                case "비":
                    imageAttachment.image = UIImage(named: "RAIN_D01")
                case "비/눈":
                    imageAttachment.image = UIImage(named: "RAIN_D02")
                case "눈":
                    imageAttachment.image = UIImage(named: "RAIN_D03")
                case "소나기":
                    imageAttachment.image = UIImage(named: "RAIN_D04")
                default:
                    imageAttachment.image = UIImage(named: "")
                }
                

                imageAttachment.bounds = CGRect(x: 0, y: -15, width: 50, height: 50)
                attributedString.append(NSAttributedString(attachment: imageAttachment))
                
                var temp = ""
                if self.tag == 0 {
                    temp = ampmInfo?.temp_Min as! String
                }
                else {
                    temp = ampmInfo?.temp_Max as! String
                }
                attributedString.append((NSAttributedString(string: "\(temp)°C")))
                weatherTempLabel.attributedText = attributedString
                weatherTempLabel.sizeToFit()
            }
        }
    }
    
    let amLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.backgroundColor = .white
        label.textColor = .black
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let weatherTempLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.backgroundColor = .white
        label.font = UIFont.systemFont(ofSize: 28)
        label.textColor = .black
        return label
    }()
    
    let weatherLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .black
        return label
    }()
    
    let rainLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 14, weight: .light)
        return label
    }()
    
    let dividerline: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.4, alpha: 0.4)
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayouts()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var amLabelConstraint:NSLayoutConstraint?
    var weatherTempLabelConstraint: NSLayoutConstraint?
    var weatherLabelConstraint: NSLayoutConstraint?
    var rainLabelConstraint: NSLayoutConstraint?
    var dividerlineConstraint: NSLayoutConstraint?
    
    fileprivate func setupLayouts() {
        addSubview(amLabel)
        addSubview(weatherTempLabel)
        addSubview(weatherLabel)
        addSubview(rainLabel)
        addSubview(dividerline)
        
        amLabelConstraint = amLabel.anchor(self.topAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 20).first
        weatherTempLabelConstraint = weatherTempLabel.anchor(amLabel.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topConstant: 8, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 50).first
        weatherLabelConstraint = weatherLabel.anchor(weatherTempLabel.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topConstant: 8, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 35).first
        rainLabelConstraint = rainLabel.anchor(weatherLabel.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 20).first
        dividerlineConstraint = dividerline.anchor(self.topAnchor, left: nil, bottom: self.bottomAnchor, right: self.rightAnchor, topConstant: 20, leftConstant: 0, bottomConstant: 20, rightConstant: 0, widthConstant: 0.5, heightConstant: 0).first
        
    }
}
