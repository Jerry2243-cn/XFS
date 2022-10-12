//
//  POIVC.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/10/10.
//

import UIKit
import AMapLocationKit

class POIVC: UIViewController, AMapLocationManagerDelegate, AMapSearchDelegate {
    
    var POIDelegate: POIViewControllerDelegate?
    
    //布局组件outle
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    //取消按钮操作
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    //定位相关变量
    let locationManager = AMapLocationManager()
    lazy var mapSearch = AMapSearchAPI()
    lazy var aroundSearchRequest: AMapPOIAroundSearchRequest = {
        let request = AMapPOIAroundSearchRequest()
        request.types = kPOITypes
        request.location = AMapGeoPoint.location(withLatitude: CGFloat(latitude), longitude: CGFloat(longtitude))
        return request
    }()
    
    //坐标及POI
    
    var pois = [["不显示位置" , ""]]
    var latitude = 0.0
    var longtitude = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        
        locationConfig()
        
        mapSearch?.delegate = self
  
    }
    
    //高德SDK请求回调处理
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        print("搜索了一次")
        self.pois.removeAll()
        hideHUD()
        if response.count == 0 {
            self.pois.removeAll()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            return
        }
        
        if request is AMapPOIAroundSearchRequest {
            pois.append(["不显示位置" , ""])
        }
        
        for poi in response.pois {
            
            let province = poi.province.description == poi .city.description ? "" : poi.province
            let address = poi.address.description == poi.district ? "" : poi.address
            let fixedAddress = "\(province!)\(poi.city!)\(poi.district!)\(address!)"
            
            pois.append([poi.name!,fixedAddress])
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        //解析response获取POI信息，具体解析见 Demo
    }
    
    //高德地图相关配置
    func locationConfig(){
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters

        locationManager.locationTimeout = 5

        locationManager.reGeocodeTimeout = 5
        
        showLoadHUD()
        
        locationManager.requestLocation(withReGeocode: true, completionBlock: { [weak self] (location: CLLocation?, reGeocode: AMapLocationReGeocode?, error: Error?) in
                    
            self?.hideHUD()
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
            
            guard let self = self else {return}
            
            if let location = location {
//                print("location:" + location.description)
                self.latitude = location.coordinate.latitude
                self.longtitude = location.coordinate.longitude
                
                //搜索周边POI
                self.mapSearch?.aMapPOIAroundSearch(self.aroundSearchRequest)
            }
            
//            if let reGeocode = reGeocode {
//                print("reGeocode:" + reGeocode.description)
                
//                let province = reGeocode.province == reGeocode.city ? "" : reGeocode.province!
//
//                let currentPOI = [reGeocode.poiName!, "\(province)\(reGeocode.city!)\(reGeocode.district!)\(reGeocode.street ?? "")\(reGeocode.number ?? "")"]
//                self.pois.append(currentPOI)
//
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                }
//            }
        })
    }

}

extension POIVC: UITableViewDelegate{
    //反向传值给NoteEdititingVC
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        POIDelegate?.updateLocation(title: pois[indexPath.item][0], address: pois[indexPath.item][1])
        dismiss(animated: true)
    }
    
}

//tableviews数据初始化
extension POIVC:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        pois.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kPOICell, for: indexPath) as! POICell
        let poi = pois[indexPath.item]
        cell.poi = poi
        return cell
    }
    
}

extension POIVC: UISearchBarDelegate{
    
    //搜索结果处理
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        showLoadHUD()
        if searchText != ""{
            let request = AMapPOIKeywordsSearchRequest()
            request.keywords = searchText
            request.types = kPOITypes
            mapSearch!.aMapPOIKeywordsSearch(request)
        }else{
            mapSearch!.aMapPOIAroundSearch(aroundSearchRequest)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
