//
//  AppDelegate.swift
//  ico2o
//
//  Created by chingyam on 15/10/14.
//  Copyright (c) 2015年 chingyam. All rights reserved.ØØ
//

import UIKit
import Alamofire
import JSONNeverDie


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UIAlertViewDelegate,BMKGeneralDelegate,WXApiDelegate {

    var listData: NSDictionary = NSDictionary()
    var filePath = NSBundle.mainBundle().pathForResource("config.plist", ofType:nil )
    var updateURL:String = ""
    var dataVersionURL:String = ""
    var carPartsURL:String = ""
    var carPartsVersionURL:String = ""
    var window: UIWindow?
    var brandDao:BrandDao?
    var carPartDao:CarPartsDao?
    var alertView:UIAlertView?
    var _mapManager: BMKMapManager?
    var wc_auth_root = "https://api.weixin.qq.com/sns"
    
    
    //重写微信登录SDK方法
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        return WXApi.handleOpenURL(url, delegate: self)
    }
    
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        return WXApi.handleOpenURL(url, delegate: self)
    }
    
    
    func onResp(resp: BaseResp!) {
        if resp.isKindOfClass(SendAuthResp) {
            let sendAuthResp = resp as! SendAuthResp
            
            //获取微信授权Code
            let code = sendAuthResp.code
            
            let parameters = ["appid": "wxd3a6c5c8b8981d55","secret": "5f01738b65236744d8f1b8b8f68ac5fe","code": code,"grant_type":"authorization_code"]
            
            Alamofire.request(.POST, "\(wc_auth_root)/oauth2/access_token", parameters: parameters)
                .response { request, response, data, error in
                    let json = JSONND.initWithData(data!)
                    let wc_access_token = json["access_token"].stringValue
                    let wc_refresh_token = json["refresh_token"].stringValue
                    let wc_openid = json["openid"].stringValue
                    
                    if wc_access_token != "" && wc_refresh_token != "" && wc_openid != "" {
                        
                        NSUserDefaults.standardUserDefaults().setValue(wc_refresh_token, forKey: "wc_refresh_token")
                        NSUserDefaults.standardUserDefaults().setValue(wc_access_token, forKey: "wc_access_token")
                        NSUserDefaults.standardUserDefaults().setValue(wc_openid, forKey: "openid")
                        print("token获取成功！")
                        
//                        parameters = ["access_token": wc_access_token,"oppenid":wc_openid]
//                        Alamofire.request(.POST, "\(self.wc_auth_root)/userinfo", parameters: parameters)
//                            .response{ request, response, data, error in
//                                var json = JSONND.initWithData(data!)
//                                
//                                
//                        }
                        let wc_login_url = self.listData.valueForKey("url") as! String + "/ASHX/MobileAPI/WeChat/Login.ashx"
                        Alamofire.request(.POST, wc_login_url, parameters: ["openid":wc_openid])
                            .response{request, response, data, error in
                                let json = JSONND.initWithData(data!)
                                let success = json["success"].boolValue
                                if success {
                                    let userInfo = json["data"]
                                    NSUserDefaults.standardUserDefaults().setObject(userInfo.arrayValue[0]["UserID"].intValue, forKey: "UserID")
                                    print("\(NSUserDefaults.standardUserDefaults().integerForKey("UserID"))授权成功！！！")
                                }
                        }
                    }
            }
            
            
            
        }
    }

    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        //应用启动时向微信注册APPID
        WXApi.registerApp("wxd3a6c5c8b8981d55")

        //启动应用时检查微信相关Token
        var wc_access_token = NSUserDefaults.standardUserDefaults().stringForKey("wc_access_token")
        let wc_refresh_token = NSUserDefaults.standardUserDefaults().stringForKey("wc_refresh_token")
        let wc_openid = NSUserDefaults.standardUserDefaults().stringForKey("wc_openid")
        
        
        if (wc_access_token != nil && wc_refresh_token != nil && wc_openid != nil) {
            Alamofire.request(.POST, "\(wc_auth_root)/auth", parameters: ["access_token": wc_access_token!,"openid": wc_openid!])
                .response { request, response, data, error in
                    let json = JSONND.initWithData(data!)
                    let errcode = json["errcode"].intValue
                    if errcode != 0 {
                        let parameters = ["appid":"wxd3a6c5c8b8981d55","grant_type":"refresh_token","refresh_token":wc_refresh_token!]
                        Alamofire.request(.POST, "\(self.wc_auth_root)/oauth2/refresh_token", parameters: parameters)
                            .response { request, response, data, error in
                                let json = JSONND.initWithData(data!)
                                wc_access_token = json["access_token"].stringValue
                                if wc_access_token != nil {
                                    NSUserDefaults.standardUserDefaults().setValue(wc_access_token, forKey: "wc_access_token")
                                } else {
                                    NSUserDefaults.standardUserDefaults().setValue(nil, forKey: "wc_access_token")
                                    NSUserDefaults.standardUserDefaults().setValue(nil, forKey: "wc_refresh_token")
                                }
                        }
                    }
            }
        } else {
            print("none!!!")
        }
        
        //去掉半透明
        UINavigationBar.appearance().translucent = false
        //去掉下面的黑线，设置导航栏颜色，第一方法需要第二个方法的使用，否则无效
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIColor(red: 25/255, green: 133/255, blue: 217/255, alpha: 1).toImage(), forBarMetrics: UIBarMetrics.Default)
        
        //UINavigationBar.appearance().barTintColor = UIColor(red: 47/255, green: 137/255, blue: 227/255, alpha: 1)
        //设置文字颜色
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        //设置item颜色
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
     
        
        
        
        //判断当前的系统语言并保存
        let languages = NSLocale.preferredLanguages()
        NSUserDefaults.standardUserDefaults().setValue(languages[0], forKey: "SysLanguage")
        //初始化百度地图
        _mapManager = BMKMapManager()
        // 如果要关注网络及授权验证事件，请设定generalDelegate参数
        let ret = _mapManager?.start("6xiwZxHWva3mG83YqGjG00Fs", generalDelegate: self)
        if ret == false {
            NSLog("manager start failed!")
        }
        //启用IQKeyboardManager
    
        IQKeyboardManager.sharedManager().enable = true
//        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
//        IQKeyboardManager.sharedManager().enableAutoToolbar = true
        
        //检测网络
        let reachability = Reachability.reachabilityForInternetConnection()
        if !reachability!.isReachable(){
            alertView = UIAlertView(title: "", message: "您没有联网哦！", delegate: self, cancelButtonTitle: "好的")
            alertView?.show()
        }else{
            getData()
        }
        
        if(!(NSUserDefaults.standardUserDefaults().boolForKey("everLaunched"))){
            NSUserDefaults.standardUserDefaults().setBool(true, forKey:"everLaunched")
            //第一次加载的时候
            //加载界面
            //var  guideViewController = GuideViewController()
            //self.window!.rootViewController=guideViewController;
            //构造URL地址
            
            NSThread.sleepForTimeInterval(2)
        }
        
        
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func getData(){
        listData = NSDictionary(contentsOfFile: filePath!)!
        updateURL = listData.valueForKey("url") as! String
        updateURL += "/ASHX/MobileAPI/CarType/Update.ashx"
        dataVersionURL = listData.valueForKey("url") as! String
        dataVersionURL += "/ASHX/MobileAPI/CarType/Version.ashx"
        carPartsURL = listData.valueForKey("url") as! String
        carPartsURL += "/ASHX/MobileAPI/Product/Update.ashx"
        carPartsVersionURL = listData.valueForKey("url") as! String
        carPartsVersionURL += "/ASHX/MobileAPI/Product/Version.ashx"
        //初始化brandDao
        brandDao  = BrandDao()
        carPartDao = CarPartsDao()
        //先检查版本号 如果版本号等于0 就从update的api获取汽车信息的数据
        //转成model对象再传到dao中进行插入数据库操作
        //调用Alamofire的request方法向后台请求数据 获取版本号
        Alamofire.request(.POST, dataVersionURL).response{request ,response ,data , eror in
            //将获取到得数据转化为JSONND格式
            let json = JSONND.initWithData(data!)
            //从JSONND里面获取version号 再写入到NSUserDefaults里面
            let version = json["CarXiVersion"].int
            if(version != NSUserDefaults.standardUserDefaults().integerForKey("CarVersion")){
                self.brandDao?.deleteBrand()
                NSUserDefaults.standardUserDefaults().setObject(version, forKey: "CarVersion")
                //调用Alamofire的request方法向后台请求数据 获取选择车型的数据
                Alamofire.request(.POST, self.updateURL).response{request ,response ,data , eror in
                    //将获取到得数据转化为JSONND格式
                    let updatedata = JSONND.initWithData(data!)
                    //将JSONND转化为数组格式
                    let brands = updatedata.arrayValue
                    //遍历数组 将数组里面的值保存到BrandModel 再将BrandModel传入BrandDao插入到数据库中
                    for i in 0  ..< brands.count  {
                        let brandname = brands[i]["Brand"].string
                        let carXi = brands[i]["CarXi"].string
                        let year = brands[i]["Year"].string
                        let engine = brands[i]["Engine"].string
                        let gearBox = brands[i]["Gearbox"].string
                        let configuration = brands[i]["Configuration"].string
                        let modelCode = brands[i]["ModelCode"].string
                        let brand:BrandModel = BrandModel(brand: brandname!, carXi: carXi!, year: year!, engine: engine!, gearBox: gearBox!, configuration: configuration!, modelCode:modelCode!)
                        self.brandDao?.addBrand(brand)
                    }
                }
            }
            
        }
        Alamofire.request(.POST, carPartsVersionURL).response{ request,response , data ,error in
            let json = JSONND.initWithData(data!)
            if let version = json["ProVersion"].int {
                print(json)
                if(version != NSUserDefaults.standardUserDefaults().integerForKey("CarPartsVersion")){
                    NSUserDefaults.standardUserDefaults().setObject(version, forKey: "CarPartsVersion")
                    Alamofire.request(.POST, self.carPartsURL).response{ request,response , data ,error in
                        let updatedata = JSONND.initWithData(data!)
                        let carparts = updatedata.arrayValue
                        //print(carparts[0]["ParentID"].intValue)
                        for i in 0  ..< carparts.count  {
                            let id = carparts[i]["ID"].intValue
                            let name = carparts[i]["Name"].string!
                            let parentID = carparts[i]["ParentID"].intValue
                            let depth = carparts[i]["Depth"].intValue
                            let carpart:CarPartsModel = CarPartsModel(id: id, name: name, parentID: parentID, depth: depth)
                            self.carPartDao?.insertData(carpart)
                        }
                    }
                    
                }
            }
            //let version = json["ProVersion"].int!
         
        }
        
    }
    func alertView(var alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        switch(buttonIndex){
        case 0: break
        case 1:
            let reachability = Reachability.reachabilityForInternetConnection()
            if !reachability!.isReachable(){
                alertView = UIAlertView(title: "", message: "您没有联网哦！", delegate: self, cancelButtonTitle: "好的")
                alertView.show()
            }
            else{
                getData()
            }
        default:
            break
            
        }
    }
    func onGetNetworkState(iError: Int32) {
        if (0 == iError) {
            NSLog("联网成功");
        }
        else{
            NSLog("联网失败，错误代码：Error\(iError)");
        }
    }
    
    func onGetPermissionState(iError: Int32) {
        if (0 == iError) {
            NSLog("授权成功");
        }
        else{
            NSLog("授权失败，错误代码：Error\(iError)");
        }
    }
}

