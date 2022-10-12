//
//  HomeVC.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/10/2.
//

import UIKit
import XLPagerTabStrip

class HomeVC: ButtonBarPagerTabStripViewController, AMapLocationManagerDelegate{
    
    let locationM = CLLocationManager()
    let locationManager = AMapLocationManager()
    var location = "附近"

    @IBOutlet weak var searchBUtton: UIButton!
    override func viewDidLoad() {
        
        // MARK: 顶部导航栏
        
        //顶部tab item下的横条颜色和高度
        self.settings.style.selectedBarBackgroundColor = UIColor(named: "main_color")!
        self.settings.style.selectedBarHeight = 3
        
        //顶部item
        self.settings.style.buttonBarItemBackgroundColor = .clear
        self.settings.style.buttonBarItemTitleColor = .label
        self.settings.style.buttonBarItemFont = .systemFont(ofSize: 18)
        self.settings.style.buttonBarItemLeftRightMargin = 0
        
        super.viewDidLoad()
        
        locationM.requestWhenInUseAuthorization()
        loactionConfig()
        
        searchBUtton.text("")
        
        containerView.bounces = false
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }

            oldCell?.label.textColor = UIColor.secondaryLabel
            newCell?.label.textColor = UIColor.label
            newCell?.label.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight(rawValue: 20))
            
            //选中文字大小动画
            if animated {
                UIView.animate(withDuration: 0.1, animations: { () -> Void in
                    newCell?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    oldCell?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                })
            }
            else {
                newCell?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                oldCell?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }
        }
        
//        DispatchQueue.main.async {
//            self.moveToViewController(at: 1, animated: false)
//        }

        // Do any additional setup after loading the view.
    }
    
    func loactionConfig(){
        
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters

        locationManager.locationTimeout = 5

        locationManager.reGeocodeTimeout = 5
        
        locationManager.requestLocation(withReGeocode: true, completionBlock: { (location: CLLocation?, reGeocode: AMapLocationReGeocode?, error: Error?) in
                    
            if let error = error {
                let error = error as NSError
                
                if error.code == AMapLocationErrorCode.locateFailed.rawValue {
                    //定位错误：此时location和regeocode没有返回值，不进行annotation的添加
                    print("定位错误:{\(error.code) - \(error.localizedDescription)};")
                    return
                }
                else if error.code == AMapLocationErrorCode.reGeocodeFailed.rawValue
                    || error.code == AMapLocationErrorCode.timeOut.rawValue
                    || error.code == AMapLocationErrorCode.cannotFindHost.rawValue
                    || error.code == AMapLocationErrorCode.badURL.rawValue
                    || error.code == AMapLocationErrorCode.notConnectedToInternet.rawValue
                    || error.code == AMapLocationErrorCode.cannotConnectToHost.rawValue {
                    
                    //逆地理错误：在带逆地理的单次定位中，逆地理过程可能发生错误，此时location有返回值，regeocode无返回值，进行annotation的添加
                    print("逆地理错误:{\(error.code) - \(error.localizedDescription)};")
                }
                else {
                    //没有错误：location有返回值，regeocode是否有返回值取决于是否进行逆地理操作，进行annotation的添加
                }
            }
            
            if let location = location {
                print("location:" + location.description)
            }
            
            if let reGeocode = reGeocode {
                print("reGeocode:" + reGeocode.description)
                let indexStart = reGeocode.city.startIndex
                let index = reGeocode.city.index(indexStart, offsetBy: 2)
                let fixed = String(reGeocode.city[indexStart..<index])
                self.location = fixed
                
                DispatchQueue.main.async {
                    self.reloadPagerTabStripView()
                }
            }
        })
    }
    
    
    //加载三个子视图
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let DiscoverVC = storyboard!.instantiateViewController(identifier: kDiscoverVCID)
        let FellowVC = storyboard!.instantiateViewController(identifier: kFellowVCID)
        let NearbyVC = storyboard!.instantiateViewController(identifier: kNearbyVCID) as! NearbyVC
        NearbyVC.location = location
        return [DiscoverVC, FellowVC, NearbyVC]
    }
    
    

}
