//
//  PetrolHistoryViewController.swift
//  ico2o
//
//  Created by 曾裕璇 on 2015/12/02.
//  Copyright © 2015年 chingyam. All rights reserved.
//

import UIKit
import Alamofire
import JSONNeverDie

// 加油记录的结构体
struct petrolNoteObject {
    
    var addTime :String
    var driveKM :Int
    var total   :Float
    var price   :Float
    var oilWave :Float
    var amount  :Float
}

class PetrolHistoryViewController:UIViewController, UIPickerViewDelegate{
    
    @IBOutlet weak var timeFromTF   : UITextField!
    @IBOutlet weak var timeToTF     : UITextField!
    @IBOutlet weak var tableview    : PetrolHistoryTableView!
    
    var listData:NSDictionary = NSDictionary()
    var filePath = NSBundle.mainBundle().pathForResource("config.plist",ofType: nil)
    var requestURL:String = ""
    
    let userID = NSUserDefaults.standardUserDefaults().stringForKey("UserID")!
//    let carID = "364"//NSUserDefaults.standardUserDefaults().stringForKey("CarID")!
    let carID = NSUserDefaults.standardUserDefaults().stringForKey("CarID")!
    var checkNetwork = CheckNetWorking()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listData = NSDictionary(contentsOfFile: filePath!)!
        requestURL = listData.valueForKey("url") as! String
        requestURL += "/ASHX/MobileAPI/Oilhistory/Get.ashx"
        
        let timeFromDatePick = UIDatePicker()
        timeFromDatePick.datePickerMode = UIDatePickerMode.Date
        timeFromDatePick.addTarget(self,action:#selector(PetrolHistoryViewController.timeFromDateChange(_:)),forControlEvents:UIControlEvents.ValueChanged)
        timeFromTF.inputView = timeFromDatePick
        
        let timeToDatePick = UIDatePicker()
        timeToDatePick.datePickerMode = UIDatePickerMode.Date
        timeToDatePick.addTarget(self, action: #selector(PetrolHistoryViewController.timeToDateChange(_:)), forControlEvents: UIControlEvents.ValueChanged)
        timeToTF.inputView = timeToDatePick
        
        
        
        // 默认加载最近15条记录
        requestAndInsert(userID, carID: carID, startTime: "", endTime: "", pageNO: 1, pageSize: 15)
    }
    
    
    // "<"按钮 返回上一页
    @IBAction func back_btn(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // 显示选择后的内容到文本框
    func timeFromDateChange(sender:UIDatePicker){
        let df = NSDateFormatter()
        df.dateFormat = "yyy-MM-dd"
        let zone:NSTimeZone = NSTimeZone.systemTimeZone()
        let interval:Int = zone.secondsFromGMTForDate(NSDate())
        let local:NSDate = sender.date.dateByAddingTimeInterval(Double(interval))
        timeFromTF.text = df.stringFromDate(local)
    }
    func timeToDateChange(sender:UIDatePicker){
        let df = NSDateFormatter()
        df.dateFormat = "yyy-MM-dd"
        let zone:NSTimeZone = NSTimeZone.systemTimeZone()
        let interval:Int = zone.secondsFromGMTForDate(NSDate())
        let local:NSDate = sender.date.dateByAddingTimeInterval(Double(interval))
        timeToTF.text = df.stringFromDate(local)
    }
    
    
    @IBAction func searchBtn(sender: AnyObject) {
        
        // 先清除上一次查询留下的内容
        for i in 0..<petrolNoteObjects.count {
            let indexPath = NSIndexPath(forRow: i, inSection: 0)
            self.tableview.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
        petrolNoteObjects.removeAll()
        
        let timeFrom = self.timeFromTF.text!
        let timeTo   = self.timeToTF.text!
        
        if timeFrom == "" || timeTo  == "" || validDateInterval(timeFrom, to: timeTo) == false{
            
            let alertWin = UIAlertView(title: nil, message: "请选择完整且有效的日期区间", delegate: nil, cancelButtonTitle: "确定")
            alertWin.show()
                
        }else{
            requestAndInsert(userID, carID: carID, startTime: timeFrom, endTime: timeTo, pageNO: 1, pageSize: 15)
        }
    }
    
    
    // 判断日期区间是否有效（前一个时间是否早于后一个时间）
    func validDateInterval(fr:String, to:String) -> Bool {
        
        let yearFr = ((fr as NSString).substringWithRange(NSMakeRange(0, 4)) as NSString).intValue
        let yearTo = ((to as NSString).substringWithRange(NSMakeRange(0, 4)) as NSString).intValue
        if yearFr > yearTo { return false }
        if yearFr < yearTo { return true  }
        
        let monthFr = ((fr as NSString).substringWithRange(NSMakeRange(5, 2)) as NSString).intValue
        let monthTo = ((to as NSString).substringWithRange(NSMakeRange(5, 2)) as NSString).intValue
        if monthFr > monthTo { return false }
        if monthFr < monthTo { return true  }
        
        let dayFr = ((fr as NSString).substringWithRange(NSMakeRange(8, 2)) as NSString).intValue
        let dayTo = ((to as NSString).substringWithRange(NSMakeRange(8, 2)) as NSString).intValue
        if dayFr > dayTo { return false }
        
        return true
    }
    
    
    
    
    // 根据参数发出请求并添加到tableview
    func requestAndInsert(userID:String, carID:String, startTime:String, endTime:String, pageNO:Int, pageSize:Int){
        
        let parameters = [
            "UserID"    :userID,
            "CarID"     :carID,
            "StartTime" :startTime,
            "EndTime"   :endTime,
            "PageNO"    :pageNO,
            "PageSize"  :pageSize
        ]
        
    if(!checkNetwork.checkNetwork()){
            return
        }
        // 先清除上一次查询留下的内容
        for i in 0..<petrolNoteObjects.count {
            let indexPath = NSIndexPath(forRow: i, inSection: 0)
            self.tableview.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
        petrolNoteObjects.removeAll()
        
        Alamofire.request(.POST, requestURL, parameters:parameters as! [String : AnyObject])
            .response { request, response, data, eror in
                
                let json = JSONND.initWithData(data!)
                print(json)
                let notes = json.arrayValue
                // 统计数据的总值或平均值
                var allTotal    :Float = 0
                var allPrice    :Float = 0
                var allOilWave  :Float = 0
                var allAmount   :Float = 0
                
                for i in 0 ..< notes.count {
                    
                    let addTime = notes[i]["AddTime"].stringValue
                    let price   = notes[i]["Price"].floatValue
                    let amount  = notes[i]["Amount"].floatValue
                    let total   = notes[i]["Total"].floatValue
                    let driveKM = notes[i]["Driver_KM"].intValue
                    let oilWave = notes[i]["OilWear"].floatValue
                    
                    // 累加
                    allTotal    += total
                    allPrice    += price
                    allOilWave  += oilWave
                    allAmount   += amount
                    
                    let object = petrolNoteObject(
                        addTime : addTime,
                        driveKM : driveKM,
                        total   : total,
                        price   : price,
                        oilWave : oilWave,
                        amount  : amount
                    )
                    
                    // 先把这条记录添加到数组
                    petrolNoteObjects.insert(object, atIndex: i)
                    let indexPath = NSIndexPath(forRow: i, inSection: 0)
                    
                    // 再触发tableview中的tableview(cellForRowAtIndexPath)方法
                    self.tableview.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                }
                
                // "总计"行
                let finalObject = petrolNoteObject(
                    addTime : "总  计",
                    driveKM : 0,
                    total   : allTotal,
                    price   : allPrice / Float(notes.count),
                    oilWave : allOilWave / Float(notes.count),
                    amount  : allAmount
                )
                
                petrolNoteObjects.insert(finalObject, atIndex: notes.count)
                let indexPath = NSIndexPath(forRow: notes.count, inSection: 0)
                self.tableview.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }

    }
    
    
}