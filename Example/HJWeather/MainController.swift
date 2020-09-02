//
//  MainController.swift
//  HJWeather_Example
//
//  Created by 김희중 on 2020/09/01.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import CoreLocation
import HJWeather

class MainController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    
    fileprivate let todayid = "todayid"
    fileprivate let tomorrowid = "tomorrowid"
    fileprivate let forecastid = "forecastid"
    
    let locationLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.backgroundColor = .clear
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .black
        return label
    }()
    
    lazy var updateImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "refresh")
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(updateLocation)))
        return iv
    }()
    
    lazy var weatherbar: weatherBar = {
        let wb = weatherBar()
        wb.weathers = self
        wb.translatesAutoresizingMaskIntoConstraints = false
        return wb
    }()
    
    lazy var weatherCollectionView: UICollectionView = {
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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.navigationController?.navigationBar.isHidden = true
        
        setupLayouts()
        weatherCollectionView.register(todayWeatherCell.self, forCellWithReuseIdentifier: todayid)
        weatherCollectionView.register(tomorrowWeatherCell.self, forCellWithReuseIdentifier: tomorrowid)
        weatherCollectionView.register(forecastWeatherCell.self, forCellWithReuseIdentifier: forecastid)
        
        getLocationPermission()
        
    }
    
    var locationLabelConstraint: NSLayoutConstraint?
    var updateImageViewConstraint: NSLayoutConstraint?
    var weatherbarConstraint: NSLayoutConstraint?
    var weatherCollectionViewConstraint: NSLayoutConstraint?
    
    fileprivate func setupLayouts() {
        view.addSubview(locationLabel)
        view.addSubview(updateImageView)
        view.addSubview(weatherbar)
        view.addSubview(weatherCollectionView)
        
        if #available(iOS 11.0, *) {
            updateImageViewConstraint = updateImageView.anchor(view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 30, widthConstant: 20, heightConstant: 20).first
            locationLabelConstraint = locationLabel.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: updateImageView.leftAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 40).first
            weatherbarConstraint = weatherbar.anchor(locationLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 40).first
            weatherCollectionViewConstraint = weatherCollectionView.anchor(weatherbar.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0).first
        }
            
        else {
            updateImageViewConstraint = updateImageView.anchor(view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 30, widthConstant: 20, heightConstant: 20).first
            locationLabelConstraint = locationLabel.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: updateImageView.leftAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 40).first
            weatherbarConstraint = weatherbar.anchor(locationLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 40).first
            weatherCollectionViewConstraint = weatherCollectionView.anchor(weatherbar.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0).first
        }
    }
    
    fileprivate func getLocationPermission() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()

        if CLLocationManager.locationServicesEnabled(){
            locationManager.startUpdatingLocation()
        }
    }
    
    @objc fileprivate func updateLocation() {
        rotate()
        weatherInfo.removeAll()
        ampmWeatherInfo.removeAll()
        dustAttributedString =  NSMutableAttributedString(string: "")
        dustAttributedStrings_tomorrow = [NSMutableAttributedString]()
        futureWeatherInfo.removeAll()
        
        updateImageView.isUserInteractionEnabled = false
        didUpdated = false
        locationManager.startUpdatingLocation()
    }
    
    fileprivate func rotate() {
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 0.8
        rotation.isCumulative = true
        rotation.repeatCount = 2
        updateImageView.layer.add(rotation, forKey: "rotationAnimation")
    }
    
    var nowWeather = nowWeatherModel()
    
    fileprivate func getNowWeather(lat: String, long: String) {
        let date = getDate(index: 0)
        let time = Int(getTime())!
        var timeString = ""
        if time < 9 {
            timeString = "\(date)0\(time + 1)00"
        }
        else {
            if time == 23 {
                let tomorrow = getDate(index: 1)
                timeString = "\(tomorrow)0000"
            }
            else {
                timeString = "\(date)\(time + 1)00"
            }
            
        }
        WeatherApiHelper.shared.getNowWeather(lat: lat, long: long) { [weak self] (weather) in
            if let weatherInfo = weather.totalWeatherDataStringDict {
                let attributedString = NSMutableAttributedString(string: "")
                let imageAttachment = NSTextAttachment()
                
                if let rainImageString = weatherInfo[timeString]?["api_rain_image"] {
                    // 비가 올경우 비오는걸 무조건 표현하고 아닌경우 하늘 상태를 표현한다.
                    imageAttachment.image = UIImage(named: rainImageString)
                }
                else {
                    if let skyImageString = weatherInfo[timeString]?["api_sky_image"] {
                        imageAttachment.image = UIImage(named: skyImageString)
                    }
                }
                imageAttachment.bounds = CGRect(x: 0, y: -30, width: 80, height: 80)
                attributedString.append(NSAttributedString(attachment: imageAttachment))
                
                guard let temp = weatherInfo[timeString]?["T1H"] else {return}
                attributedString.append(NSAttributedString(string: "\(temp)°C"))
                
                guard let sky = weatherInfo[timeString]?["SKY"] else {return}

                let nowWeather = nowWeatherModel()
                nowWeather.attributedString = attributedString
                nowWeather.sky_text = sky
                self?.nowWeather = nowWeather
                self?.weatherCollectionView.reloadData()
                
            }
        }
    }

    
    var weatherInfo = [String:[String:String]]()
    fileprivate func getWeatherData(lat: String, long: String) {
        WeatherApiHelper.shared.getTotalCurrentWeather(lat: lat, long: long) { [weak self] (weatherinfo) in
            self?.weatherInfo = weatherinfo
            self?.weatherCollectionView.reloadData()
        }
    }

    var ampmWeatherInfo = [futureWeatherModel]()
    
    fileprivate func getAmPmWeather(future: Bool) {
        WeatherApiHelper.shared.getTomorrowWeather(future: future) { [weak self] (weather) in
            self?.ampmWeatherInfo = weather
        }
    }
    
    fileprivate func getCurrentDustData(cityName: String, subLocalName: String) {
        DustApiHelper.shared.todayDustInfo(cityName: cityName, subLocalName: subLocalName) { [weak self] (data) in
            guard let attributedString = self?.getDustData(pm10: data.dust10Value, pm10Comment: data.dustPM10Comment, pm25: data.dust25Value, pm25Comment: data.dustPM25Comment) else {return}
            self?.dustAttributedString = attributedString
            self?.weatherCollectionView.reloadData()
        }
    }
    
    fileprivate func getTomorrowDustData() {
        var pm10Comment_tomorrow = ""
        var pm25Comment_tomorrow = ""
        var pm10Comment_after = ""
        var pm25Comment_after = ""
        DustApiHelper.shared.forecastDustInfo(pm: "PM10") { [weak self] (dust) in
            pm10Comment_tomorrow = dust[0]["서울"] ?? "정보없음"
            pm10Comment_after = dust[1]["서울"] ?? "정보없음"
            
            DustApiHelper.shared.forecastDustInfo(pm: "PM25") { [weak self] (dust) in
                pm25Comment_tomorrow = dust[0]["서울"] ?? "정보없음"
                pm25Comment_after = dust[1]["서울"] ?? "정보없음"
                guard let tomorrow = self?.getDustData(pm10: "", pm10Comment: pm10Comment_tomorrow, pm25: "", pm25Comment: pm25Comment_tomorrow) else {return}
                guard let after = self?.getDustData(pm10: "", pm10Comment: pm10Comment_after, pm25: "", pm25Comment: pm25Comment_after) else {return}
                self?.dustAttributedStrings_tomorrow.append(tomorrow)
                self?.dustAttributedStrings_tomorrow.append(after)
                self?.weatherCollectionView.reloadData()
            }
        }
    }
    
    var dustAttributedString =  NSMutableAttributedString(string: "")
    var dustAttributedStrings_tomorrow = [NSMutableAttributedString]()
    
    fileprivate func getDustData(pm10: String, pm10Comment: String, pm25: String, pm25Comment: String) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: "")
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(named: "fineDust")
        imageAttachment.bounds = CGRect(x: 0, y: -2, width: 20, height: 20)
        attributedString.append(NSAttributedString(attachment: imageAttachment))
        let dust10 = " 미세먼지  " + pm10
        attributedString.append(NSAttributedString(string: dust10))
        let dust10Comment = " " + pm10Comment + "     "
        attributedString.append(NSAttributedString(string: dust10Comment))
        let imageAttachment2 = NSTextAttachment()
        imageAttachment2.image = UIImage(named: "ultrafineDust")
        imageAttachment2.bounds = CGRect(x: 0, y: -2, width: 20, height: 20)
        attributedString.append(NSAttributedString(attachment: imageAttachment2))
        let dust25 = " 초미세먼지  " + pm25
        attributedString.append(NSAttributedString(string: dust25))
        let dust25Comment = " " + pm25Comment
        attributedString.append(NSAttributedString(string: dust25Comment))
        return attributedString
    }
    
    
    
    fileprivate func getFutureTemp() {
        WeatherApiHelper.shared.getForecastTemp { [weak self] (temp) in
//            guard let tempMin = temp["tempMin"] else {return}
//            guard let tempMax = temp["tempMax"] else {return}
//            self?.futureWeatherInfo["tempMin"] = tempMin
//            self?.futureWeatherInfo["tempMax"] = tempMax
//            self?.weatherCollectionView.reloadData()
        }
    }
    
    var futureWeatherInfo = [futureWeatherModel]()
    
    fileprivate func getFutureWeather() {
        WeatherApiHelper.shared.getTomorrowWeather(future: true) { [weak self] (nearWeather) in
            self?.futureWeatherInfo = nearWeather
            WeatherApiHelper.shared.getForecastWeather { [weak self] (futureWeather) in
                self?.futureWeatherInfo += futureWeather
                self?.weatherCollectionView.reloadData()
            }
        }
        
    }
    
    var didUpdated: Bool = false

    //MARK: - location delegate methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation :CLLocation = locations[0] as CLLocation

        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
        
        let lat = "\(userLocation.coordinate.latitude)"
        let long = "\(userLocation.coordinate.longitude)"
        
        if !didUpdated {
            getNowWeather(lat: lat, long: long)
            getWeatherData(lat: lat, long: long)
            getAmPmWeather(future: false)

            getFutureTemp()
            getFutureWeather()

            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(userLocation) { [weak self] (placemarks, error) in
                if (error != nil){
                    print("error in reverseGeocode")
                }
                let placemark = placemarks! as [CLPlacemark]
                if placemark.count > 0 {
                    let placemark = placemarks![0]
//                print(placemark.locality!)
//                print(placemark.administrativeArea!)
//                print(placemark.country!)
//                print(placemark.name!)
                    guard let city = placemark.administrativeArea else {return}
                    guard let locality = placemark.locality else {return}
                    guard let locName = placemark.name else {return}
                    self?.locationLabel.text = "  \(city) \(locality) \(locName)"
                    self?.getCurrentDustData(cityName: city, subLocalName: locality)
                    self?.getTomorrowDustData()

                }
            }
            locationManager.stopUpdatingLocation()
            updateImageView.isUserInteractionEnabled = true
            didUpdated = true
        }
        
        
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }

    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: todayid, for: indexPath) as! todayWeatherCell
            cell.nowWeather = nowWeather
            cell.todayWeatherInfo = weatherInfo
            cell.dustAttributedString = dustAttributedString
            cell.todayWeatherCollectionView.reloadData()
            return cell
        }
        else if indexPath.item == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: tomorrowid, for: indexPath) as! tomorrowWeatherCell
            cell.tomorrowWeatherInfo = weatherInfo
            cell.tomorrowAfterCheck = "tomorrow"
            if ampmWeatherInfo.count == 5 {
                cell.ampmWeatherInfo = Array(ampmWeatherInfo[1...2])
            }
            else if ampmWeatherInfo.count == 6 {
                cell.ampmWeatherInfo = Array(ampmWeatherInfo[2...3])
            }
            if dustAttributedStrings_tomorrow.count > 0 {
                cell.dustAttributedString = dustAttributedStrings_tomorrow[0]
            }
            cell.tomorrowWeatherCollectionView.reloadData()
            return cell
        }
        else if indexPath.item == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: tomorrowid, for: indexPath) as! tomorrowWeatherCell
            cell.tomorrowWeatherInfo = weatherInfo
            cell.tomorrowAfterCheck = "after"
            if ampmWeatherInfo.count == 5 {
                cell.ampmWeatherInfo = Array(ampmWeatherInfo[3...4])
            }
            else if ampmWeatherInfo.count == 6 {
                cell.ampmWeatherInfo = Array(ampmWeatherInfo[4...5])
            }
            if dustAttributedStrings_tomorrow.count > 0 {
                cell.dustAttributedString = dustAttributedStrings_tomorrow[1]
            }
            cell.tomorrowWeatherCollectionView.reloadData()
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: forecastid, for: indexPath) as! forecastWeatherCell
            cell.futureWeatherInfo = futureWeatherInfo
            cell.forecastWeatherCollectionView.reloadData()
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func scrollToMenuIndex(menuIndex: Int) {
        let indexPath = NSIndexPath(item: menuIndex, section: 0)
        weatherCollectionView.scrollToItem(at: indexPath as IndexPath, at: [], animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        weatherbar.horizontalBarleftAnchor?.constant = scrollView.contentOffset.x / 4
    }
    
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let index = targetContentOffset.pointee.x / view.frame.width
        
        let indexPath = IndexPath(item: Int(index), section: 0)
        
        let date = getBarDate(index: indexPath.item)
        if indexPath.item == 0 {
            weatherbar.weatherGroups = ["오늘 \(date)","내일","모레","이후 10일"]
        }
        else if indexPath.item == 1 {
            weatherbar.weatherGroups = ["오늘","내일 \(date)","모레","이후 10일"]
        }
        else if indexPath.item == 2 {
            weatherbar.weatherGroups = ["오늘","내일","모레 \(date)","이후 10일"]
        }
        else {
            weatherbar.weatherGroups = ["오늘","내일","모레","이후 10일"]
        }
        
        weatherbar.barCollectionView.reloadData()
        weatherbar.barCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
        
    }
    
    // MARK:- Private
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
    
    fileprivate func getTime() -> String {
        let now = Date()
        let timeFommater = DateFormatter()
        timeFommater.dateFormat = "HH"
        // time은 hour단위
        let time:String = timeFommater.string(from: now)
        
        return time
    }
    
    fileprivate func getBarDate(index: Int) -> String {
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

}
