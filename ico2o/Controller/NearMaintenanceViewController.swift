//
//  NearMaintenanceViewController.swift
//  ico2o
//
//  Created by chingyam on 15/12/11.
//  Copyright © 2015年 chingyam. All rights reserved.
//

import UIKit
import Alamofire
import JSONNeverDie


class NearMaintenanceViewController: UIViewController ,BMKMapViewDelegate , BMKLocationServiceDelegate{
    
    var addressTemp = ""
    var models:[CarShopModel] = []
    var locationService: BMKLocationService!
    @IBOutlet weak var _mapView: BMKMapView!
    var listData: NSDictionary = NSDictionary()
    var filePath = NSBundle.mainBundle().pathForResource("config.plist", ofType:nil )
    var NearMaintenanceURL:String = ""
    var customView:MyAnnotationView!
    var checkNetwork = CheckNetWorking()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listData = NSDictionary(contentsOfFile: filePath!)!
        NearMaintenanceURL = listData.valueForKey("url") as! String
        NearMaintenanceURL += "/ASHX/MobileAPI/Maintenance/NearMaintenance.ashx"
        
        locationService = BMKLocationService()
        locationService.allowsBackgroundLocationUpdates = true
    
//        //注册通知
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NearMaintenanceViewController.disPlayMsg(_:)), name:"NotificationIdentifierForBook", object: nil)

    }
    
    //跳转前传递数据
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "mapToBooking" {
            let page = segue.destinationViewController as! bookStoreViewController
            page.tempStore = addressTemp
            //print(addressTemp)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        _mapView.viewWillAppear()
        locationService.delegate = self
        _mapView.delegate = self
        
       
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        _mapView.viewWillDisappear()
        locationService.delegate = nil
         _mapView.delegate = nil
        
       
    }
    
    override func viewDidAppear(animated: Bool) {
        locationService.startUserLocationService()
        _mapView.showsUserLocation = false
        _mapView.userTrackingMode = BMKUserTrackingModeFollow
        _mapView.showsUserLocation = true//显示定位图层
           }
    
    func willStartLocatingUser() {
        print("willStartLocatingUser");
    }
    
    func didUpdateUserHeading(userLocation: BMKUserLocation!) {
        //  print("heading is \(userLocation.heading)")
        // print("didUpdateUserLocation lat:\(userLocation.location.coordinate.latitude) lon:\(userLocation.location.coordinate.longitude)")
        print("heading is \(userLocation.heading)")
        _mapView.updateLocationData(userLocation)
        
    }
    
    func didUpdateBMKUserLocation(userLocation: BMKUserLocation!) {
        _mapView.updateLocationData(userLocation)
        let longitude:Double = Double(userLocation.location.coordinate.longitude)
        let latitude:Double = Double(userLocation.location.coordinate.latitude)
        getData(longitude,latitude: latitude)
        locationService.stopUserLocationService()
    }
    
    
    /**
     *在地图View停止定位后，会调用此函数
     *@param mapView 地图View
     */
    func didStopLocatingUser() {
        print("didStopLocatingUser")
    }
    
    func getData(longitude:Double,latitude:Double){
        
        print("经纬度 \(longitude)   \(latitude)")
        if(!checkNetwork.checkNetwork()){
            return
        }
        let parameters = ["longitude":longitude , "latitude":latitude]
        Alamofire.request(.POST, NearMaintenanceURL , parameters:parameters)
            .response { request ,response ,data , eror in
                let json = JSONND.initWithData(data!)
              
                let result = json.arrayValue
                for i in 0  ..< result.count {
                    let id:Int = result[i]["ID"].int!
                    let garage:String = result[i]["Garage"].stringValue
                    let address:String = result[i]["Address"].stringValue
                    let longitude:Double = Double(result[i]["Longitude"].floatValue)
                    let latitude:Double = Double(result[i]["Latitude"].floatValue)
                    let tel:String = result[i]["Tel"].stringValue
                    var imgpath = result[i]["ImgPath"].stringValue
                    let star:Double = Double(result[i]["Star"].floatValue)
                    let distance:Double = Double(result[i]["Distance"].floatValue)
                    let code:String = result[i]["Code"].stringValue
                    if imgpath == ""{
                        imgpath = "default"
                    }
                    let model = CarShopModel(id: id, garage: garage, address: address, tel: tel, longitude: longitude, latitude: latitude, imgPath: imgpath, star: star, distance: distance, code: code)
                    self.models.append(model)
                      //print(address)
                    
                }
                self.addPointAnnotation(self.models)
        }
        
        
        
    }
    func addPointAnnotation(models:[CarShopModel]) {
        for i in 0  ..< models.count {
            let point1:BMKPointAnnotation = BMKPointAnnotation()
            point1.coordinate = CLLocationCoordinate2DMake(models[i].latitude, models[i].longitude)
            point1.title = models[i].garage
            point1.subtitle = models[i].address
            _mapView.addAnnotation(point1)
        }
    }
    
    func mapView(mapView: BMKMapView!, viewForAnnotation annotation: BMKAnnotation!) -> BMKAnnotationView! {
        
        if annotation.isKindOfClass(BMKPointAnnotation){
            let newAnnotation:BMKPinAnnotationView = BMKPinAnnotationView(annotation: annotation, reuseIdentifier: "myAnnotation")
            //            自定义弹出视图（核心）
            let nib = UINib(nibName: "callOutView", bundle: nil)
            //            初始化自定义弹出视图
            customView = nib.instantiateWithOwner(self, options: nil).last as! MyAnnotationView
            //            设置自定义视图显示内容
            customView!.setShowLabel("camry", title: annotation.title!(), context: annotation.subtitle!())
            //            设置标注点显示为我们自定义的视图
            
            newAnnotation.paopaoView = BMKActionPaopaoView(customView: customView)
            
            return newAnnotation
        }
        return nil
    }
    
    //点击图钉时
    func mapView(mapView: BMKMapView!, didSelectAnnotationView view: BMKAnnotationView!) {
        addressTemp = ""
        addressTemp = view.annotation.title!()
        print(view.annotation.title!())
    }
}



