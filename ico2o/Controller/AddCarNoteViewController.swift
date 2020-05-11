//
//  AddCarNoteViewController.swift
//  ico2o
//
//  Created by CatKatherine on 15/10/19.
//  Copyright (c) 2015年 chingyam. All rights reserved.
//



// 添加我的爱车

import UIKit
import Alamofire
import JSONNeverDie



class AddCarNoteViewController: UIViewController ,UITextFieldDelegate{
    //视图控件与控制器绑定
    @IBOutlet weak var lastMaintenanceDateTextField: UITextField!
    @IBOutlet weak var registerDateTextField: UITextField!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var carNumsTF: UITextField!
    @IBOutlet weak var milesTF: UITextField!
    @IBOutlet weak var maintenMilesTF: UITextField!
    @IBOutlet weak var sixNums: UITextField!
    var checkNetwork:CheckNetWorking = CheckNetWorking()
    //声明Dao变量以及构造读取config.plist的对象
    var myCarDao:MyCarDao?
    var listData: NSDictionary = NSDictionary()
    var filePath = NSBundle.mainBundle().pathForResource("config.plist", ofType:nil )
    var addCarNoteURL:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //读取plist构造URL
        listData = NSDictionary(contentsOfFile: filePath!)!
        addCarNoteURL = listData.valueForKey("url") as! String
        addCarNoteURL += "/ASHX/MobileAPI/MyCars/SaveByHorse.ashx"
        
        myCarDao = MyCarDao()
        //创建datePicker对象
        let registerdatePick = UIDatePicker()
        let maintenanceDatePick = UIDatePicker()
        //设置DatePicker的模式为日期
        registerdatePick.datePickerMode = UIDatePickerMode.Date
        maintenanceDatePick.datePickerMode = UIDatePickerMode.Date
        //当Picker的值改变时，添加事件
        registerdatePick.addTarget(self, action: #selector(AddCarNoteViewController.registerDateChange(_:)), forControlEvents: UIControlEvents.ValueChanged)
        maintenanceDatePick.addTarget(self, action: #selector(AddCarNoteViewController.maintenanceDateChange(_:)), forControlEvents: UIControlEvents.ValueChanged)
        //将两个TextField的输入源改为对应的PickerView
        lastMaintenanceDateTextField.inputView = maintenanceDatePick
        registerDateTextField.inputView = registerdatePick
        
        
        //为提交按钮增加事件
        submitBtn.addTarget(self, action: #selector(AddCarNoteViewController.submit), forControlEvents: UIControlEvents.TouchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(sender: AnyObject) {
        //返回上一页面
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    //点击提交按钮后触发事件的方法
    func submit(){
        if(!checkNetwork.checkNetwork()){
            print("1")
            return
        }
        //先判断里面的关键值是否为空
        if ((carNumsTF.text != "") && (milesTF.text != "") && (maintenMilesTF.text != "")) {
            //去掉车架号的空格 再将车架号全部变成大写
            var carNums = carNumsTF.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            carNums = carNums.uppercaseString
            //判断车架号的位数是否为17 是则将数据传到后台 并且关闭当前页面
            if(carNums.characters.count == 17){
                let userID = NSUserDefaults.standardUserDefaults().stringForKey("UserID")!
                let drive_KM:String = milesTF.text!
                let lastMaintenance:String = lastMaintenanceDateTextField.text!
                let registerDate:String = registerDateTextField.text!
                let lastMaintenanceKM:String = maintenMilesTF.text!
                let engineNum = sixNums.text!
                let parameters = ["UserID":userID,"Horse":carNums,"Drive_KM": drive_KM,"LastMaintenanceKM":lastMaintenanceKM,"LastMaintenanceDate":lastMaintenance,"LicenseDate":registerDate,"MotorLastSixNumber":engineNum]
                Alamofire.request(.POST, addCarNoteURL , parameters:parameters)
                    .response { request ,response ,data , eror in
                }
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            else{
                let alterwin = UIAlertView(title: nil, message: "请正确填写车架号", delegate: nil, cancelButtonTitle: "确定")
                alterwin.show()
            }
        }
        else {
            let alterwin = UIAlertView(title: nil, message: "请填写完整", delegate: nil, cancelButtonTitle: "确定")
            alterwin.show()
        }
    }
    //上牌时间的事件方法
    func registerDateChange(sender : UIDatePicker){
        let df = NSDateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        registerDateTextField.text = df.stringFromDate(sender.date)
    }
    //上次保养时间的事件方法
    func maintenanceDateChange(sender : UIDatePicker){
        let df = NSDateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        lastMaintenanceDateTextField.text = df.stringFromDate(sender.date)
    }
}
