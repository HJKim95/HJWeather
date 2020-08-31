//
//  weatherInnerCell.swift
//  HJWeather-Korea
//
//  Created by 김희중 on 2020/07/29.
//  Copyright © 2020 HJ. All rights reserved.
//

import UIKit
import HJWeather

class WeatherInnerCell: UICollectionViewCell {
    
    var timeInfo: timeInfoModel? {
        didSet {
            guard let timeText = timeInfo?.timeNow else {return}
            timeLabel.text = timeText
            
            guard let rainText = timeInfo?.rainText else {return}
            rainPercentCommentLabel.text = rainText
        }
    }
    
    var weatherInfo: [String:String]? {
        didSet {
            if let rainImageString = weatherInfo?["api_rain_image"] {
                weatherImageView.image = UIImage(named: rainImageString)
            }
            else {
                guard let skyImageString = weatherInfo?["api_sky_image"] else {return}
                    weatherImageView.image = UIImage(named: skyImageString)
            }
            
            guard let percent = weatherInfo?["POP"] else {return}
            rainPercentLabel.text = "\(percent)%"
            
            guard let temp = weatherInfo?["T3H"] else {return}
            tempLabel.text = "\(temp)°"

            directionImageView.image = UIImage(named: "direction")
            guard let angle = weatherInfo?["VEC"] else {return}
            let transfer = (Double(angle)! + (22.5 * 0.5)) / 22.5
            if Int(transfer) % 4 == 0 {
                var rotate: CGFloat = 0
                if Int(transfer) == 0 {
                    rotate = 1
                }
                else {
                    rotate = CGFloat(16 / Int(transfer))
                }
                directionImageView.transform = directionImageView.transform.rotated(by: .pi * 2 / rotate)
            }
            else {
                let rotate = 16.0 / transfer
                directionImageView.transform = directionImageView.transform.rotated(by: CGFloat(.pi * 2 / rotate))
            }
            
            guard let wind = weatherInfo?["WSD"] else {return}
            let intWind = Int(Double(wind)!)
            windLabel.text = "\(String(describing: intWind))m/s"
            
            guard let humi = weatherInfo?["REH"] else {return}
            guard let humi_double = Double(humi) else {return}
            guard let dropImage = UIImage(named: "drop") else {return}
            let color = UIColor.init(red: 77/255, green: 131/255, blue: 206/255, alpha: 1)
            humiImageView.image = withBottomHalfOverlayColor(myImage: dropImage, color: color, humi: humi_double)
            
            
            humiLabel.text = "\(humi)%"
        }
    }
    
    // https://stackoverflow.com/questions/22960945/ios-changing-half-of-the-images-color
    func withBottomHalfOverlayColor(myImage: UIImage, color: UIColor, humi: Double) -> UIImage {
        
        let rect = CGRect(x: 0, y: 0, width: myImage.size.width, height: myImage.size.height)

        UIGraphicsBeginImageContextWithOptions(myImage.size, false, myImage.scale)
        myImage.draw(in: rect)

        let context = UIGraphicsGetCurrentContext()!
        context.setBlendMode(CGBlendMode.sourceIn)

        context.setFillColor(color.cgColor)
        
        let humiPercent = CGFloat(humi) * 0.01
        // y값은 위에가 0 밑으로 갈수록 1 --> 반대로 계산하여야함.(물이 채워지는것처럼 보이게)
        let rectToFill = CGRect(x: 0, y: myImage.size.height * CGFloat(1-humiPercent), width: myImage.size.width, height: myImage.size.height * CGFloat(humiPercent))
        context.fill(rectToFill)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.backgroundColor = .clear
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .black
        return label
    }()
    
    let weatherImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.masksToBounds = true
        iv.backgroundColor = .clear
        return iv
    }()
    
    let rainPercentCommentLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.backgroundColor = .clear
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .black
        return label
    }()
    
    let rainPercentLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.backgroundColor = .clear
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .black
        return label
    }()
    
    let tempLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.backgroundColor = .clear
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .black
        return label
    }()
    
    let dividerLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.4, alpha: 0.4)
        return view
    }()
    
    let directionImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.masksToBounds = true
        iv.backgroundColor = .clear
        return iv
    }()
    
    let windLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.backgroundColor = .clear
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .black
        return label
    }()
    
    let humiImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.masksToBounds = true
        iv.backgroundColor = .clear
        return iv
    }()
    
    let humiLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.backgroundColor = .clear
        label.adjustsFontSizeToFitWidth = true
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
    
    var timeLabelConstraint: NSLayoutConstraint?
    var weatherImageViewConstraint: NSLayoutConstraint?
    var rainPercentCommentLabelConstraint: NSLayoutConstraint?
    var rainPercentLabelConstraint: NSLayoutConstraint?
    var tempLabelConstraint: NSLayoutConstraint?
    var dividerLineConstraint: NSLayoutConstraint?
    var directionImageViewConstraint: NSLayoutConstraint?
    var windLabelConstraint: NSLayoutConstraint?
    var humiImageViewConstraint: NSLayoutConstraint?
    var humiLabelConstraint: NSLayoutConstraint?
    
    fileprivate func setupLayouts() {
        self.backgroundColor = .white
        
        addSubview(timeLabel)
        addSubview(weatherImageView)
        addSubview(rainPercentCommentLabel)
        addSubview(rainPercentLabel)
        addSubview(tempLabel)
        addSubview(dividerLine)
        addSubview(directionImageView)
        addSubview(windLabel)
        addSubview(humiImageView)
        addSubview(humiLabel)
        
        timeLabelConstraint = timeLabel.anchor(self.topAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topConstant: 0, leftConstant: 2, bottomConstant: 0, rightConstant: 2, widthConstant: 0, heightConstant: 16).first
        weatherImageViewConstraint = weatherImageView.anchor(timeLabel.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: frame.width).first
        rainPercentCommentLabelConstraint = rainPercentCommentLabel.anchor(weatherImageView.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topConstant: 0, leftConstant: 2, bottomConstant: 0, rightConstant: 2, widthConstant: 0, heightConstant: 20).first
        rainPercentLabelConstraint = rainPercentLabel.anchor(rainPercentCommentLabel.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topConstant: 0, leftConstant: 4, bottomConstant: 0, rightConstant: 4, widthConstant: 0, heightConstant: 16).first
        tempLabelConstraint = tempLabel.anchor(rainPercentLabel.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topConstant: 15, leftConstant: 4, bottomConstant: 0, rightConstant: 4, widthConstant: 0, heightConstant: 16).first
        dividerLineConstraint = dividerLine.anchor(tempLabel.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topConstant: 15, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0.5).first
        directionImageViewConstraint = directionImageView.anchor(dividerLine.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topConstant: 1, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: frame.width).first
        windLabelConstraint = windLabel.anchor(directionImageView.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topConstant: 5, leftConstant: 2, bottomConstant: 0, rightConstant: 2, widthConstant: 0, heightConstant: 16).first
        humiImageViewConstraint = humiImageView.anchor(windLabel.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topConstant: 20, leftConstant: 10, bottomConstant: 0, rightConstant: 10, widthConstant: 0, heightConstant: frame.width - 20).first
        humiLabelConstraint = humiLabel.anchor(humiImageView.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topConstant: 5, leftConstant: 2, bottomConstant: 0, rightConstant: 2, widthConstant: 0, heightConstant: 16).first
    }
}

