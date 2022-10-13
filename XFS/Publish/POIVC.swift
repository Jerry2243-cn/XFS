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
//    var poiName = ""
    lazy var selectedPOI = POI()
    lazy var myPOI = POI()
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
        request.offset = 20
        request.types = kPOITypes
        request.location = AMapGeoPoint.location(withLatitude: CGFloat(myPOI.latitude), longitude: CGFloat(myPOI.longtitude))
        return request
    }()
    lazy var keywordSearchRequest: AMapPOIKeywordsSearchRequest = {
        let request = AMapPOIKeywordsSearchRequest()
        request.offset = 20
        request.types = kPOITypes
        return request
    }()
    
    //上拉加载分页
    lazy var footer = MJRefreshAutoNormalFooter()
    
    //坐标及POI
    var pois = [POI(name: "不显示位置")]
    var currentAroundPage = 1
    var isAllAroundPOILoad = false
    var currentKeywordPage = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        
        config()
        locationAction()
        
        mapSearch?.delegate = self
  
    }
    
    //高德SDK请求回调处理
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        print("搜索了一次，页数\(request.page)，poi数量\(response.count)")
        hideHUD()
        if response.count == 0 {
            self.isAllAroundPOILoad = true
            self.tableView.reloadData()
            return
        }
        
        
        for poi in response.pois {
            
            let province = poi.province.description == poi.city.description ? "" : poi.province
            let address = poi.address.description == poi.district ? "" : poi.address
            let fixedAddress = "\(province!)\(poi.city!)\(poi.district!)\(address!)"
            
            pois.append(POI(name: poi.name, address: fixedAddress, latitude: poi.location.latitude, longtitude: poi.location.longitude))
        }
        self.tableView.reloadData()
        //解析response获取POI信息，具体解析见 Demo
    }
    
    //高德地图相关配置
    func locationAction(){
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
                self.myPOI.latitude = location.coordinate.latitude
                self.myPOI.longtitude = location.coordinate.longitude
                
                //搜索周边POI
                self.footer.setRefreshingTarget(self, refreshingAction: #selector(self.footerRefreshAround))
                self.aroundLocationsSearch()
            }
        })
    }

}

extension POIVC{
    
    func config(){
        
        //定位信息配置
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.locationTimeout = 5
        locationManager.reGeocodeTimeout = 5
        
        //上拉加载
        tableView.mj_footer = footer
    }
    
    @objc func footerRefreshAround(){
        if !isAllAroundPOILoad {
            currentAroundPage += 1
            print("发起周边查询请求，请求页数\(currentAroundPage)")
            aroundLocationsSearch(currentAroundPage)
            footer.endRefreshing()
        }else{
            print("没有数据了")
            footer.endRefreshingWithNoMoreData()
        }
    }
    
    @objc func footerRefreshKeyword(){
        if !isAllAroundPOILoad {
            currentKeywordPage += 1
            print("发起关键字查询请求，请求页数\(currentKeywordPage)")
            keywordLocationsSearch(currentKeywordPage)
            footer.endRefreshing()
        }else{
            print("没有数据了")
            footer.endRefreshingWithNoMoreData()
        }
    }
    
    private func keywordLocationsSearch(_ page:Int = 1){
        keywordSearchRequest.page = page
        mapSearch!.aMapPOIKeywordsSearch(keywordSearchRequest)
    }
    
    private func aroundLocationsSearch(_ page:Int = 1){
        aroundSearchRequest.page = page
        mapSearch?.aMapPOIAroundSearch(aroundSearchRequest)
    }
}

extension POIVC: UITableViewDelegate{
    //反向传值给NoteEdititingVC
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.accessoryType = .checkmark
        POIDelegate?.updateLocation(poi: pois[indexPath.item])
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
        let poi = pois[indexPath.row]
        cell.poi = poi
        cell.titleLabel.text = poi.name
        cell.addressLabel.text = poi.address
        cell.accessoryType = selectedPOI == poi ? .checkmark : .none
        return cell
    }
    
}

extension POIVC: UISearchBarDelegate{
    
   
    //搜索结果处理
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        showLoadHUD()
        pois.removeAll()
        isAllAroundPOILoad = false
        tableView.mj_footer?.resetNoMoreData()
        if searchText != ""{
            currentKeywordPage = 1
            keywordSearchRequest.keywords = searchText
            self.footer.setRefreshingTarget(self, refreshingAction: #selector(self.footerRefreshKeyword))
            keywordLocationsSearch(currentKeywordPage)
        }else{
            pois.append(POI(name: "不显示位置"))
            currentAroundPage = 1
            aroundLocationsSearch(currentAroundPage)
        }
        hideHUD()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
