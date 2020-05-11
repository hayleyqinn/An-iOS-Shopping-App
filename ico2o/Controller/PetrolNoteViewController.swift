//
//  PetrolNoteViewController.swift
//  ico2o
//
//  Created by CatKatherine on 15/10/19.
//  Copyright (c) 2015年 chingyam. All rights reserved.
//

import UIKit
import Alamofire
import JSONNeverDie

class PetrolNoteViewController: UIViewController , UIPickerViewDelegate , UIPickerViewDataSource ,UIAlertViewDelegate {
    var temp = 0
    var fuelType = []
    var chooseCar = []
    var pickerArray = []
    var myCarDao:MyCarDao?
    
    var listData:NSDictionary = NSDictionary()
    var filePath = NSBundle.mainBundle().pathForResource("config.plist", ofType: nil)
    var saveActionURL:String = ""
    var totalTemp = 0.00
    
    @IBOutlet weak var hitLabel: UILabel!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!

    @IBOutlet weak var totalButton: UIButton!
    @IBOutlet weak var chooseCarTextField: UITextField!
    @IBOutlet weak var oilTextField: UITextField!
    @IBOutlet weak var moneyTF: UITextField!
    @IBOutlet weak var timeTF: UITextField!
    @IBOutlet weak var milesTF: UITextField!
    @IBOutlet weak var avgMoneyTF: UITextField!
    let carspicker = UIPickerView()
    let oilpicker = UIPickerView()
    var checkNetwork = CheckNetWorking()
    // 没有登陆时跳转到登陆界面，从登陆界面返回后会调用这个函数
    func closureFuc()->Void{
        print("success!")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        fuelType = ["0","90","92","93","95","97","98"]
        //chooseCar = ["2014版凯美瑞","BMW X6"]
        myCarDao = MyCarDao()
        chooseCar = (myCarDao?.queryMyCar())!
        totalButton.setTitle("点击获取总油量", forState: UIControlState.Normal)
        pickerArray = fuelType
        let datePick = UIDatePicker()
        datePick.datePickerMode = UIDatePickerMode.Date
        datePick.addTarget(self, action: #selector(PetrolNoteViewController.dateChange(_:)), forControlEvents: UIControlEvents.ValueChanged)
        timeTF.inputView = datePick
        // picker.datePickerMode = UIDatePickerMode.Date
        carspicker.delegate = self
        carspicker.dataSource = self
        oilpicker.delegate = self
        oilpicker.dataSource = self
        chooseCarTextField.inputView = carspicker
        oilTextField.inputView = oilpicker
        
        listData = NSDictionary(contentsOfFile: filePath!)!
        saveActionURL = listData.valueForKey("url") as! String
        saveActionURL += "/ASHX/MobileAPI/Oilhistory/Add.ashx"
    }

    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
        判断输入是否为空还需加入机油类型（待完善
     **/
    @IBAction func save(sender: AnyObject) {
        
        var alertwin:UIAlertView!
        
        if moneyTF.text != "" && timeTF.text != "" && milesTF.text != "" && avgMoneyTF.text != "" {
            
            // 保存加油记录到服务器
            
            let userID = NSUserDefaults.standardUserDefaults().integerForKey("UserID")
//            let carID = "364"//NSUserDefaults.standardUserDefaults().integerForKey("CarID")
            let carID = NSUserDefaults.standardUserDefaults().integerForKey("CarID")
            let addTime     = timeTF.text!
            let price       = avgMoneyTF.text!
            let amount      = moneyTF.text!
            let total       = totalTemp
            let driver_KM   = milesTF.text!
            
            var petrolType  = oilTextField.text!
            let n = (petrolType as NSString).substringWithRange(NSMakeRange(0, 1)) as String
            if n == "0" {
                petrolType = n
            }else{
                petrolType = (petrolType as NSString).substringWithRange(NSMakeRange(0, 2)) as String
            }
            
            let parameters = [
                "UserID"    :userID,
                "AddTime"   :addTime,
                "Price"     :price,
                "Amount"    :amount,
                "PetrolType":petrolType,
                "Total"     :total,
                "Driver_KM" :driver_KM,
                "CarID"     :carID
            ]
            
            
            if(!checkNetwork.checkNetwork()){
            return
            }
            Alamofire.request(.POST, saveActionURL,parameters:parameters as! [String : AnyObject])
                .response { request, response, data, eror in
                
                    let json = JSONND.initWithData(data!)!
                    let res = json["result"].boolValue
                
                    alertwin = UIAlertView(title: nil, message: "", delegate: nil, cancelButtonTitle: "确定")
                    if res == true { alertwin!.message = "保存成功" }
                    else { alertwin!.message = "保存失败，请稍后重试" }
                    alertwin!.tag = 1
                    alertwin!.show()
            }
            
        }
        else{
            alertwin = UIAlertView(title: nil, message: "请填写完整", delegate: nil, cancelButtonTitle: "确定")
            alertwin!.tag = 2
            alertwin!.show()
        }
        
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertView.tag == 1{
            if buttonIndex == 0{
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func back_btn(sender: AnyObject) {
        //返回上一页面
        self.dismissViewControllerAnimated(true, completion: nil)
    }


    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView == oilpicker){
            return pickerArray.count
        }
        else{
            return chooseCar.count
        }
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == oilpicker{
            if( row == 0 ){
                var temp:String = (pickerArray.objectAtIndex(row) as? String)!
                temp += "号柴油"
                return temp
            }
            else{
                var temp:String = (pickerArray.objectAtIndex(row) as? String)!
                temp += "号汽油"
                return temp
            }
        }
        else{
            return chooseCar.objectAtIndex(row) as? String
        }

    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == oilpicker{
            if( row == 0 ){
                let temp = pickerArray[row] as? String
                oilTextField.text = temp! + "号柴油"
            }
            else{
                let temp = pickerArray[row] as? String
                oilTextField.text = temp! + "号汽油"
            }
        }
        else{
            chooseCarTextField.text = chooseCar[row] as? String
        }
    }
    
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        chooseCarTextField.resignFirstResponder()
        oilTextField.resignFirstResponder()
        return true
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        chooseCarTextField.resignFirstResponder()
        oilTextField.resignFirstResponder()
        
       
    }
    
    func dateChange(sender : UIDatePicker){
        let df = NSDateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let zone : NSTimeZone = NSTimeZone.systemTimeZone()
        let interval : Int = zone.secondsFromGMTForDate(NSDate())
        let local : NSDate = sender.date.dateByAddingTimeInterval(Double(interval))
        timeTF.text = df.stringFromDate(local)
    }
    @IBAction func getTotal(sender: AnyObject) {
        if (moneyTF.text != "" && avgMoneyTF.text != ""){
            let money:Double = (moneyTF.text! as NSString).doubleValue
            let avgMoney:Double = (avgMoneyTF.text! as NSString).doubleValue
            totalTemp = money/avgMoney
            let result = String(format: "%.2f", totalTemp)
            totalButton.setTitle("\(result)升", forState:UIControlState.Normal)
        }
    }
 }
