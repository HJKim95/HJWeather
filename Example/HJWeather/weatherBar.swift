//
//  weatherBar.swift
//  HJWeather-Korea
//
//  Created by 김희중 on 2020/07/25.
//  Copyright © 2020 HJ. All rights reserved.
//

import UIKit
import HJWeather

class weatherBar: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private let pageID = "pageID"
    
    var weatherGroups = ["오늘","내일","모레","이후 10일"]
    
    weak var weathers: MainController?
    
    lazy var barCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.dataSource = self
        cv.delegate = self
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .white
        return cv
    }()
    
    let horizontalBar: UIView = {
        let view = UIView()
        view.backgroundColor = .orange
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var barCollectionviewConstraint: NSLayoutConstraint?
    var horizontalBarConstraint: NSLayoutConstraint?
    var horizontalBarleftAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(barCollectionView)
        addSubview(horizontalBar)
        
        barCollectionView.register(weatherBarCell.self, forCellWithReuseIdentifier: pageID)
        barCollectionviewConstraint = barCollectionView.anchor(self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0).first
        
        horizontalBarleftAnchor = horizontalBar.leftAnchor.constraint(equalTo: self.leftAnchor)
        horizontalBarleftAnchor?.isActive = true
        horizontalBar.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        horizontalBar.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1/4).isActive = true
        horizontalBar.heightAnchor.constraint(equalToConstant: 2).isActive = true
        
        let date = getDate(index: 0)
        weatherGroups = ["오늘 \(date)","내일","모레","이후 10일"]
        barCollectionView.reloadData()
        
        let selectedIndexPath = NSIndexPath(item: 0, section: 0)
        barCollectionView.selectItem(at: selectedIndexPath as IndexPath, animated: false, scrollPosition: [])
    
    }
    
    fileprivate func getDate(index: Int) -> String {
        let now = Date()
        let tomorrow = now.addingTimeInterval(24 * 60 * 60)
        let after = now.addingTimeInterval(48 * 60 * 60)
        var date:String = ""
        
        let dateFommater = DateFormatter()
        dateFommater.dateFormat = "M.d"
        dateFommater.timeZone = TimeZone(secondsFromGMT: 9 * 60 * 60)
        
        if index == 0 {
            date = dateFommater.string(from: now)
        }
        else if index == 1 {
            date = dateFommater.string(from: tomorrow)
        }
        else if index == 2 {
            date = dateFommater.string(from: after)
        }
        else {
            date = ""
        }
        return date
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let date = getDate(index: indexPath.item)
        if indexPath.item == 0 {
            weatherGroups = ["오늘 \(date)","내일","모레","이후 10일"]
        }
        else if indexPath.item == 1 {
            weatherGroups = ["오늘","내일 \(date)","모레","이후 10일"]
        }
        else if indexPath.item == 2 {
            weatherGroups = ["오늘","내일","모레 \(date)","이후 10일"]
        }
        else {
            weatherGroups = ["오늘","내일","모레","이후 10일"]
        }
        
        barCollectionView.reloadData()
        barCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        weathers?.scrollToMenuIndex(menuIndex: indexPath.item)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: pageID, for: indexPath) as! weatherBarCell
        cell.barLabels.text = weatherGroups[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width / 4, height: frame.height)
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class weatherBarCell: UICollectionViewCell {
    
    let barLabels: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .gray
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    override var isHighlighted: Bool {
        didSet {
            barLabels.textColor = isHighlighted ? UIColor.black : UIColor.gray
            barLabels.font = isHighlighted ? UIFont.boldSystemFont(ofSize: 16) : UIFont.systemFont(ofSize: 14)
        }
    }

    override var isSelected: Bool {
        didSet {
            barLabels.textColor = isSelected ? UIColor.black : UIColor.gray
            barLabels.font = isSelected ? UIFont.boldSystemFont(ofSize: 16) : UIFont.systemFont(ofSize: 14)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    var barLabelsConstraint: NSLayoutConstraint?
    
    
    func setupViews() {
        backgroundColor = .clear
        addSubview(barLabels)

        barLabelsConstraint = barLabels.anchor(self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0).first
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
