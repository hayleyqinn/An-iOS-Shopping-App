//
//  StoreListViewController.swift
//  ico2o
//
//  Created by Katherine on 15/12/12.
//  Copyright © 2015年 chingyam. All rights reserved.
//  维修店列表界面

import UIKit
import Alamofire
import JSONNeverDie
/*
* locationService 获取定位信息
* areaBtn 地区按钮 sequenceBtn 排序按钮
* models  维修店模型的数组
*/

class StoreListViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,BMKLocationServiceDelegate{
    
    var locationService: BMKLocationService!
    @IBOutlet weak var areaBtn: UIButton!
    @IBOutlet weak var sequenceBtn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    var models:[CarShopModel] = []
    var listData: NSDictionary = NSDictionary()
    var filePath = NSBundle.mainBundle().pathForResource("config.plist", ofType:nil )
    var NearMaintenanceURL:String = ""
    var index:NSIndexPath?
        var checkNetwork = CheckNetWorking()
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func locationIcon(sender: AnyObject) {
    }
    //构造URL 做一些初始化的操作
    override func viewDidLoad() {
        super.viewDidLoad()
        listData = NSDictionary(contentsOfFile: filePath!)!
        NearMaintenanceURL = listData.valueForKey("url") as! String
        NearMaintenanceURL += "/ASHX/MobileAPI/Maintenance/NearMaintenance.ashx"
        tableView.dataSource = self
        tableView.delegate = self
        areaBtn.addTarget(self, action: #selector(StoreListViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        sequenceBtn.addTarget(self, action: #selector(StoreListViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
       // data = dataInit()
    //开始/显示定位
        locationService = BMKLocationService()
               locationService.allowsBackgroundLocationUpdates = true
    
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        locationService.delegate = self
       
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        locationService.delegate = nil
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    //当地理信息更新的时候 获取经纬度 传到后台获取维修店信息 并且暂停地理信息更新
    func didUpdateBMKUserLocation(userLocation: BMKUserLocation!) {
        print("didUpdateUserLocation lat:\(userLocation.location.coordinate.latitude) lon:\(userLocation.location.coordinate.longitude)")
        let longitude:Double = Double(userLocation.location.coordinate.longitude)
        let latitude:Double = Double(userLocation.location.coordinate.latitude)
        //mapView?.centerCoordinate =
        
        getCarShopInfo(latitude,longitude: longitude)
        locationService.stopUserLocationService()
    }
    //获取维修店信息 保存在models内
    func getCarShopInfo(latitude:Double , longitude:Double){
        if(!checkNetwork.checkNetwork()){
            return
        }
        let parameters = ["longitude":longitude , "latitude":latitude]
        Alamofire.request(.POST, NearMaintenanceURL , parameters:parameters)
            .response { request ,response ,data , eror in
                let json = JSONND.initWithData(data!)
                
                let result = json.arrayValue
                for i in 0  ..< result.count  {
                    let id:Int = result[i]["ID"].int!
                    let garage:String = result[i]["Garage"].stringValue
                    let address:String = result[i]["Address"].stringValue
                    let longitude:Double = Double(result[i]["Longitude"].floatValue)
                    let latitude:Double = Double(result[i]["Latitude"].floatValue)
                    var tel:String = result[i]["Tel"].stringValue
                    var imgpath = result[i]["ImgPath"].stringValue
                    var star:Double = Double(result[i]["Star"].floatValue)
                    var distance:Double = Double(result[i]["Distance"].floatValue)
                    let code:String = result[i]["Code"].stringValue
                    if imgpath == ""{
                        imgpath = "default"
                    }
                    if tel == "" {
                        tel = "null"
                    }
                    if star == 0{
                        star = 1.0
                    }
                    distance = Double(distance.format(".1"))!
                    let model = CarShopModel(id: id, garage: garage, address: address, tel: tel, longitude: longitude, latitude: latitude, imgPath: imgpath, star: star, distance: distance, code: code)
                    self.models.append(model)
                }
                     self.tableView.reloadData()

                
            }
        
    }
    func btnClicked(btn:UIButton) {
        //1:选择区域，2:排序，3:预约
        switch btn.tag {
        case 1:
            let alterV = UIAlertView(title: "", message: "请选择区域", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "广东", "北京")
            alterV.tag = 1
            alterV.show()
        case 2:
            let alterV = UIAlertView(title: "", message: "请选择排序方式", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "全部","按评分排序","按距离排序","按价格排序" )
            alterV.tag = 2
            alterV.show()
        case 3:
            let cell = btn.superview?.superview as! UITableViewCell
            index = tableView.indexPathForCell(cell)
            self.performSegueWithIdentifier("StoreListToBookingStore", sender: self)
        default:
            break
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        tableView.reloadData()
        if alertView.tag == 1 {
            areaBtn.setTitle(alertView.buttonTitleAtIndex(buttonIndex), forState: UIControlState.Normal)
            if alertView.buttonTitleAtIndex(buttonIndex) == "取消" {
                areaBtn.setTitle("请选择区域", forState: UIControlState.Normal)
            }
        }
        else if alertView.tag == 2 {
            sequenceBtn.setTitle(alertView.buttonTitleAtIndex(buttonIndex), forState: UIControlState.Normal)
            if alertView.buttonTitleAtIndex(buttonIndex) == "取消" {
                sequenceBtn.setTitle("请选择排序方式", forState: UIControlState.Normal)
            }
        }
    }
    
    //转跳时传递相应数据
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "StoreListToStoreDetail" {
            let receive = (segue.destinationViewController as! UINavigationController)
            let a = receive.viewControllers[0] as! StoreDetailTableViewController
            a.dataFromOther = String(1)
        }
        else if segue.identifier == "StoreListToBookingStore" {
            let receive = (segue.destinationViewController as! UINavigationController)
            let a = receive.viewControllers[0] as! BookingStoreViewController
            a.storeSelected = models[(index?.row)!]
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.models.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //设置单元格重用，重用标记为“cell”
        let cellIdentifier = "cell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier)
        }
        //根据tag获取storyboard中相应的控件
        let storeName = cell!.viewWithTag(111) as! UILabel
        let storePhoto = cell!.viewWithTag(222) as! UIImageView
        let storeAddress = cell!.viewWithTag(333) as! UILabel
        let distance = cell!.viewWithTag(444) as! UIButton
        let item = cell!.viewWithTag(555) as! UILabel
        let starLevel = cell!.viewWithTag(666) as! UIImageView
        let levelLabel = cell!.viewWithTag(777) as! UILabel
        let bookBtn = cell!.viewWithTag(3) as! UIButton
        
        storeName.text = models[indexPath.row].garage
        storePhoto.image = UIImage(named: "logo_icon")
        storeAddress.text = models[indexPath.row].address
        distance.setTitle("\(models[indexPath.row].distance)km", forState: UIControlState.Normal)
        item.text = "项目："
        levelLabel.text = String(models[indexPath.row].star)
        bookBtn.addTarget(self, action: #selector(StoreListViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        let grade = Float(levelLabel.text!)
        let starY = (ceil(Float(grade! * 10) / 5) - 2) * (Float(330 / 9))
        //获取想要显示的部分的大小及位置
        let starPic = UIImage(named: "stars")
        let rect = CGRectMake(0, CGFloat(starY), 170, 36)
        //将此部分从图片中剪切出来
        let ref = CGImageCreateWithImageInRect(starPic!.CGImage!, rect)
        //将剪切下来图片放入UIImageView中
        starLevel.image = UIImage(CGImage: ref!)
        cell?.selectionStyle = UITableViewCellSelectionStyle.None
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("StoreListToStoreDetail", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
//截取价格小数点后两位
extension Double {
    func format(f: String) -> String {
        return NSString(format: "%\(f)f", self) as String
    }
}
//截图
extension UIImage {
    func cutPicture(rect:CGRect)->UIImage {
        //将此部分从图片中剪切出来
        let ref = CGImageCreateWithImageInRect(self.CGImage!, rect)
        //将剪切下来图片放入UIImageView中
        return UIImage(CGImage: ref!)
        
    }
}
