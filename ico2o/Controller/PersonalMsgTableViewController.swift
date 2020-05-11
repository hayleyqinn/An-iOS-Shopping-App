//
//  PersonalMsgTableViewController.swift
//  ico2o
//
//  Created by CatKatherine on 15/10/23.
//  Copyright (c) 2015年 chingyam. All rights reserved.
//

import UIKit
import Alamofire
import JSONNeverDie

class PersonalMsgTableViewController: UITableViewController{
    /*
    btnName为项目名称,btnEngName为英文版
    middleBtnTag为项目图标数目及标记
    cellTag为底部单元格数目及标记
    isEnglish:系统语言为英文
    */
    let btnName = ["我的订单","我的收藏","预约维修店","收货地址","我的代购车","退换货","预约记录","预定商品"/*,"我的消息"*/]
    var btnEngName = ["MyOrders","Collection","RepairShop","Address","MyBooking","Return","BookingNote","Commodity"/*,"MyMsg"*/]
    var middleBtnTag = 0
    var cellTag = 0
    var isEnglish = false
    var carL = UILabel()
    var timer: NSTimer?
//    var isDisplayTip: Bool?
    
   
    
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if NSUserDefaults.standardUserDefaults().stringForKey("SysLanguage") == "en-US" {
            isEnglish = true
            btnName
        }
        //注册通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PersonalMsgTableViewController.disPlayMsg(_:)), name:"NotificationIdentifier", object: nil)

        
        
        //取消单元格间的分割线
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }
    
    func disPlayMsg(notification:NSNotification){
        self.navigationController?.view.makeToast("登录成功！", duration: 1, position: .Center)

    }
    
    override func viewDidAppear(animated: Bool) {
        let userId = NSUserDefaults.standardUserDefaults().integerForKey("UserID")
        if userId == 0 {
            carL.text = isEnglish ? "Please choose your car type" : "请选择车型"
        } else {
            getData()
        }
//        if(NSUserDefaults.standardUserDefaults().integerForKey("UserID") != 0){
//
//        }else{
//            let alertController = UIAlertController(title: "", message: "请登录后操作", preferredStyle: UIAlertControllerStyle.Alert)
//            let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
//            let goToAction = UIAlertAction(title: "前往", style: .Default, handler: {(alterWin: UIAlertAction!) in self.performSegueWithIdentifier("loginNav", sender: self)})
//            alertController.addAction(cancelAction)
//            alertController.addAction(goToAction)
//            self.presentViewController(alertController, animated: true, completion: nil)
//        }
        
//        tableView.reloadData()

    }

    
    func setDefaultLabel() -> Bool {
        let defaultCarInfo = NSUserDefaults.standardUserDefaults().objectForKey("DefaultCar") as! String
        if defaultCarInfo != "" {
            carL.text = defaultCarInfo
            return true
        }
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //0:个人头像及名称栏，1:项目图标栏
        switch section {
        case 0:
            return 1
        case 1:
            return Int(ceil(Float(btnName.count) / 4))
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            if NSUserDefaults.standardUserDefaults().integerForKey("UserID") == 0 {
         
                self.performSegueWithIdentifier("loginNav", sender: self)
                // 正常的注册页面入口，给一个nil标志
                NSUserDefaults.standardUserDefaults().setObject("nil", forKey: "goToView")
            } else {
                self.performSegueWithIdentifier("myMsg", sender: self)

            }
        default: break
        }
    }

    //按钮点击事件
    func btnClick(obj : UIButton){
        let tag = obj.tag
        var segue = ""
        //若无登录则先登录
        if NSUserDefaults.standardUserDefaults().integerForKey("UserID") == 0 {
            segue = "loginNav"
    
            // 正常的注册页面入口，给一个nil标志
            NSUserDefaults.standardUserDefaults().setObject("nil", forKey: "goToView")
        }
        else {
            switch tag {
                /*111:会员头像，转至登录页面，222:更换车型，0：退出登录，
                1-10:中间项目(我的订单,我的收藏,预约维修店,收货地址,我的代购车,   退换货,预约纪录,预定商品,我的消息
                */
            case 111:
                segue = "myMsg"
            case 1:
                segue = "PersonalToOrder"
            case 2:
                segue = "PersonalToMyCollection"
            case 3:
                segue = "PersonalToStoreList"
            case 4:
                segue = "PersonalToAddress"
            case 5:
                segue = "PersonalToProcurement"
            case 6:
                segue = "PersonalToReturnManage"
            case 7:
                segue = "PersonalToOrderNote"
            case 8:
                segue = "PersonalToReserveProduct"
            case 9:
                segue = "PersonalToMsgToMe"
            case 222:
                segue = "PersonalToMyCar"
            default:
                break
            }
        }
        self.performSegueWithIdentifier(segue, sender: self)
    }
    
    //转跳时传递数据
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PersonalToMyCar" {
            let receive = (segue.destinationViewController as! UINavigationController)
            let a = receive.viewControllers[0] as! ViewController
            a.isFromOtherPage = true
        }
        if segue.identifier == "PersonalToOrder" {
            let receive = (segue.destinationViewController as! UINavigationController)
            let isPop = receive.viewControllers[0] as! MyOrderViewController
            isPop.isPop = false
        }
        
    }
    
    //每一行的具体内容设置
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let screenW = self.view.frame.width
        let margin3 = Int((screenW - 60 * 4) / 5)
        //设置单元格重用，重用标记为“cell”
        let cellIdentifier = "cell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier)
        }
        
        //清除单元格内容，以免上下滑动后内容重叠
        cell!.textLabel!.text = ""
        cell?.backgroundView = nil
        for view in cell!.contentView.subviews {
            if view.isKindOfClass(UIButton.self) {
                view.removeFromSuperview()
            } else if view.isKindOfClass(UILabel.self) {
                view.removeFromSuperview()
            }
        }
        
        //根据不同的section和行进行相应的操作来设置单元格内容
        switch indexPath.section {
        //0:会员信息，1:项目图标栏
        case 0:
                let icon = UIButton(frame: CGRect(x: 10, y: 10, width: 50, height: 50))
                if(NSUserDefaults.standardUserDefaults().valueForKey("brown") == nil){
                    icon.setImage(UIImage(named: "brown"), forState: UIControlState.Normal)
                }else{
                        //let imgData = NSUserDefaults.standardUserDefaults().valueForKey("brown")!
                    //let avatar:UIImage = UIImage(data: imgData as! NSData)!
                    let avatar:UIImage = UIImage(named: "brown")!
                  
                    icon.setImage(avatar, forState: UIControlState.Normal)
                }
                
                icon.tag = 111
                icon.addTarget(self, action: #selector(PersonalMsgTableViewController.btnClick(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                cell!.contentView.addSubview(icon)
                cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                let name = UILabel(frame: CGRect(x: 10, y: 60, width: 100, height: 20))
                name.text = isEnglish ? "Name" : "未设置昵称"
                name.textColor = UIColor.whiteColor()
                name.font = UIFont.systemFontOfSize(14)
                name.textAlignment = NSTextAlignment.Left
                name.tag = 112
                cell!.contentView.addSubview(name)
                
                //会员余额等信息栏
                let view = UIView(frame: CGRect(x: 0, y: 80, width: screenW, height: 30))
                
              
                var perMsg = ["余额：0","积分：0","优惠券：0"]
                if isEnglish {
                    perMsg = ["Balance:0","Credit:0","Coupon:0"]
                }
                let labelW = Int(self.view.frame.size.width / 3)
                for i in 0 ..< perMsg.count {
                    let label = UILabel(frame: CGRect (x: (labelW - 45) * i + 10, y: 5, width: labelW-40, height: 20))
                    label.text = perMsg[i]
                    label.textAlignment = NSTextAlignment.Left
                    label.textColor = UIColor.whiteColor()
                    label.font = UIFont.systemFontOfSize(14)
                    view.addSubview(label)
                }
                cell?.contentView.addSubview(view)
                cell?.backgroundColor = UIColor(red: 25/255, green: 133/255, blue: 217/255, alpha: 1)
        
        case 1:
            var count = 4
            if indexPath.row == Int(ceil(Float(btnName.count) / 4) - 1){
                if (btnName.count % 4) != 0 {
                    count = btnName.count % 4
                }
            }
            for i in 0 ..< count {
                let button = UIButton(frame: CGRect(x: (margin3 + 72) * i + 15, y: 8, width: 60, height: 70))
                button.setImage(UIImage(named: btnName[indexPath.row * 4 + i]), forState: UIControlState.Normal)
                button.imageEdgeInsets = UIEdgeInsetsMake(5, 10, 20, 5)
                button.setTitle(isEnglish ? btnEngName[indexPath.row * 4 + i] : btnName[indexPath.row * 4 + i], forState: UIControlState.Normal)
                button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
                button.titleEdgeInsets = UIEdgeInsetsMake(50, -190, 0, -10)
                button.titleLabel!.textAlignment = NSTextAlignment.Center
                button.titleLabel!.font = UIFont.systemFontOfSize(13)
                button.tag = indexPath.row * 4 + i + 1
                button.addTarget(self, action: #selector(PersonalMsgTableViewController.btnClick(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                cell!.contentView.addSubview(button)
            }
            
        default:
            break
        }
        //取消点击选中
        cell!.selectionStyle = UITableViewCellSelectionStyle.None
        return cell!

    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height:CGFloat = 0
        //0:会员信息，00:会员头像，01:会员名称，1:项目栏，2:表格及退出按钮
        switch indexPath.section {
        case 0:
            height = 110
        case 1:
            if indexPath.row == Int(ceil(Float(btnName.count) / 4)) - 1 {
                height = 90
            }
            else {
                height = 78
            }
        default:
            height = 30
            
        }
        return height
    }
    
    //主要设置“当前车型”栏
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let screenW = self.view.frame.size.width
            let currentB = UIButton(frame: CGRect(x: 13, y: 8, width: 90, height: 30))
            currentB.setTitle( isEnglish ? "CarType" : "当前车型：", forState: UIControlState.Normal)
            currentB.titleLabel?.font = UIFont.systemFontOfSize(15)
            currentB.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            currentB.titleEdgeInsets = UIEdgeInsetsMake(3, -20, 3, 0)
            currentB.titleLabel!.textAlignment = NSTextAlignment.Right
            self.carL = UILabel(frame: CGRect (x: 85, y: 10, width: screenW - 165, height: 25))
            carL.text = isEnglish ? "Please choose your car type" : "请选择车型"
            carL.textColor = UIColor.grayColor()
            carL.font = UIFont.systemFontOfSize(15)
            let changeB = UIButton(frame: CGRect(x: 0, y: 8, width: screenW, height: 25))
            changeB.backgroundColor = UIColor.clearColor()
            changeB.tag = 222
            changeB.layer.cornerRadius = 7.0
            changeB.addTarget(self, action: #selector(PersonalMsgTableViewController.btnClick(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            let cell = UITableViewCell()
            cell.addSubview(currentB)
            cell.addSubview(carL)
            cell.addSubview(changeB)
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            cell.backgroundColor = UIColor.whiteColor()
            return cell
        } else{
            return nil
        }
    }
   
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 40
        }
        else {
            return 0
        }
    }
    
    //获取车型信息，并设置默认车型
    func getData() {
        var listData: NSDictionary = NSDictionary()
        let filePath = NSBundle.mainBundle().pathForResource("config.plist", ofType:nil )
        var getMyCarURL:String = ""
        //userID赋值为NSUserDefaluts里面的UserID
        let userID = NSUserDefaults.standardUserDefaults().stringForKey("UserID")!
        //构造参数
        let parameters = ["UserID":userID]
        //构造URL
        listData = NSDictionary(contentsOfFile: filePath!)!
        getMyCarURL = listData.valueForKey("url") as! String
        getMyCarURL += "/ASHX/MobileAPI/MyCars/GetMyCars.ashx"
    
        
        let defaultCarInfo = NSUserDefaults.standardUserDefaults().objectForKey("DefaultCar")
        if defaultCarInfo != nil {
            self.carL.text = "\(defaultCarInfo!)"
        } else {
            Alamofire.request(.POST, getMyCarURL, parameters: parameters).response {    request ,response ,data , eror in
                //数据转为Json
                let json = JSONND.initWithData(data!)
                //Json转为数组
                let mycars = json.arrayValue
                //数组转为模型
                //设置个人中心页面的当前车型

                for i in 0..<mycars.count{
                    let models = mycars[i]["Models"].stringValue
                    let proDate = mycars[i]["ProDate"].stringValue
                    let isDefalut = mycars[i]["IsDefault"].boolValue
                    let brand = mycars[i]["Brand"].stringValue
                    if(isDefalut) {
                        NSUserDefaults.standardUserDefaults().setObject(mycars[i]["ModelCode"].stringValue, forKey: "ModelCode")
                        NSUserDefaults.standardUserDefaults().setObject("\(proDate)年版 \(brand) \(models)", forKey: "DefaultCar")
                        self.carL.text = "\(proDate)年版 \(brand) \(models)"
                    }
                }
            }
        }
    }
    
}
