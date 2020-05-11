//
//  ChooseCarViewController.swift
//  ico2o
//
//  Created by Katherine on 15/11/4.
//  Copyright © 2015年 chingyam. All rights reserved.
//

import UIKit
import Alamofire
import JSONNeverDie


class ChooseCarViewController: UIViewController ,UIPickerViewDataSource,UIPickerViewDelegate{
    
    var temp:Bool = false

    @IBOutlet weak var versionTextField: UITextField!
 
    @IBOutlet weak var gearBoxTextField: UITextField!
    @IBOutlet weak var horseTextField: UITextField!
    @IBOutlet weak var engineTextField: UITextField!
    @IBOutlet weak var brandTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var carxiTextField: UITextField!
    //声明pickerView的数据源数组
    var brandNames = []
    var years = []
    var engines = []
    var carVersions = []
    var carxis = []
    var gearBoxs = []
    //dao层的类
    var brandDao:BrandDao!
   //读取plist方法 获取URL地址
    var listData: NSDictionary = NSDictionary()
    var filePath = NSBundle.mainBundle().pathForResource("config.plist", ofType:nil )
    var updateURL:String = ""
    var dataVersionURL:String = ""
    
    
    //登录后通过车架号添加我的爱车
    var saveByHorseURL:String = ""
    //登陆后通过查询条件添加我的爱车
    var saveByCarXiURL:String = ""
    //未登录 通过车架号选择车型获得ModelCode
    var getModelCodeByHorseURL:String = ""
    //未登录 通过选择车型获得ModelCode
    var getModelCodeURL:String = ""
    //初始化UIPickerView
    let brandPick = UIPickerView()
    let yearsPick = UIPickerView()
    let enginePick = UIPickerView()
    let carVersionPick = UIPickerView()
    let carxiPick = UIPickerView()
    let gearBoxPick = UIPickerView()
    var checkNetwork = CheckNetWorking()

    //返回上一级菜单的方法
//    @IBAction func back(sender: AnyObject) {
//        self.dismissViewControllerAnimated(true, completion: nil)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //在该ViewController加载的时候将第一个以外的TextField enable设置为false
        versionTextField.enabled = false
        engineTextField.enabled = false
        yearTextField.enabled = false
        gearBoxTextField.enabled = false
        carxiTextField.enabled = false
        //构造URL地址
        listData = NSDictionary(contentsOfFile: filePath!)!
        updateURL = listData.valueForKey("url") as! String
        updateURL += "/ASHX/MobileAPI/CarType/Update.ashx"
        dataVersionURL = listData.valueForKey("url") as! String
        dataVersionURL += "/ASHX/MobileAPI/CarType/Version.ashx"
        saveByHorseURL = listData.valueForKey("url") as! String
        saveByHorseURL += "/ASHX/MobileAPI/MyCars/SaveByHorse.ashx"
        getModelCodeByHorseURL = listData.valueForKey("url") as! String
        getModelCodeByHorseURL += "/ASHX/MobileAPI/CarType/GetModelCodeByHorse.ashx"
        saveByCarXiURL = listData.valueForKey("url") as! String
        saveByCarXiURL += "/ASHX/MobileAPI/MyCars/SaveByCarXi.ashx"
        getModelCodeURL = listData.valueForKey("url") as! String
        getModelCodeURL += "/ASHX/MobileAPI/CarType/GetModelCode.ashx"
//        years = ["2002"]
//        engines = ["1.4T"]
//        carVersions = ["MT"]
//        brandNames = ["奥迪","现代"]
        //判断版本 如果版本不符合就从后台获取数据
        brandDao = BrandDao()
        //getData()
        brandNames = (brandDao?.queryBrand())!
        initTextField()
        //为TextField结束编辑的时候增加事件方法
        brandTextField.addTarget(self, action: #selector(ChooseCarViewController.brandsSelect), forControlEvents: UIControlEvents.EditingDidEnd)
        carxiTextField.addTarget(self, action: #selector(ChooseCarViewController.carxiSelect), forControlEvents: UIControlEvents.EditingDidEnd)
        yearTextField.addTarget(self, action: #selector(ChooseCarViewController.yearSelect), forControlEvents: UIControlEvents.EditingDidEnd)
        engineTextField.addTarget(self, action: #selector(ChooseCarViewController.engineSelect), forControlEvents: UIControlEvents.EditingDidEnd)
        versionTextField.addTarget(self, action: #selector(ChooseCarViewController.versionSelect), forControlEvents: UIControlEvents.EditingDidEnd)
        gearBoxTextField.addTarget(self, action: Selector("gearboxOnChange"), forControlEvents: UIControlEvents.EditingChanged)
        // Do any additional setup after loading the view.
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //pickerView 的轮子 设置为1个
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    //pickerView的数据的个数，不同的PickerView对应不同的数据个数
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView == brandPick){
            return brandNames.count
        }
        else if(pickerView == carxiPick){
            return carxis.count
        }
        else if(pickerView == yearsPick){
            return years.count
        }
        else if(pickerView == enginePick){
            return engines.count
        }
        else if(pickerView == carVersionPick){
            return carVersions.count
        }
        else if(pickerView == gearBoxPick){
            return gearBoxs.count
        }
        return 1
    }
    //根据不同的PickerView,返回不同的PickerView中的数据
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView == brandPick){
            return brandNames.objectAtIndex(row) as? String
        }
        else if(pickerView == carxiPick){
            return carxis.objectAtIndex(row) as? String
        }
        else if(pickerView == yearsPick){
            return years.objectAtIndex(row) as? String
        }
        else if(pickerView == enginePick){
            return engines.objectAtIndex(row) as? String
        }
        else if(pickerView == carVersionPick){
            return carVersions.objectAtIndex(row) as? String
        }
        else if(pickerView == gearBoxPick){
            return gearBoxs.objectAtIndex(row) as? String
        }
        return nil
    }
    //选择的PickerView的选项设置为TextField的值
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView == brandPick){
            brandTextField.text = brandNames[row] as? String
        }
        else if(pickerView == carxiPick){
            carxiTextField.text = carxis[row] as? String
        }
        else if(pickerView == yearsPick){
            yearTextField.text = years[row] as? String
        }
        else if(pickerView == enginePick){
            engineTextField.text = engines[row] as? String
        }
        else if(pickerView == carVersionPick){
            versionTextField.text = carVersions[row] as? String
        }else if(pickerView == gearBoxPick){
            gearBoxTextField.text = gearBoxs[row] as? String
        }

    }

    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    //将TextField的输入源设置为PickerView
    func initTextField(){
        brandPick.delegate = self
        brandPick.dataSource = self
        yearsPick.delegate = self
        yearsPick.dataSource = self
        enginePick.delegate = self
        enginePick.dataSource = self
        carVersionPick.delegate = self
        carVersionPick.dataSource = self
        carxiPick.delegate = self
        carxiPick.dataSource = self
        gearBoxPick.delegate = self
        gearBoxPick.dataSource = self
        brandTextField.inputView = brandPick
        yearTextField.inputView = yearsPick
        engineTextField.inputView = enginePick
        versionTextField.inputView = carVersionPick
        carxiTextField.inputView = carxiPick
        gearBoxTextField.inputView = gearBoxPick
    }
    
    //当TextField的值改变时，从数据库中查询并且更改下一个TextField对应的PickerView的dataSource
    func brandsSelect(){
        carxis = (brandDao?.queryCarXi(brandTextField.text!))!
        carxiPick.reloadAllComponents()
        if brandTextField.text != ""{
            carxiTextField.enabled = true
        }
    }
    func carxiSelect(){
        years = (brandDao?.queryYear(brandTextField.text!,carxi: carxiTextField.text!))!
        yearsPick.reloadAllComponents()
        if carxiTextField.text != ""{
            yearTextField.enabled = true
        }
    }
    func yearSelect(){
        engines = (brandDao?.queryEngine(yearTextField.text!,brandname: brandTextField.text!,carxi: carxiTextField.text!))!
        enginePick.reloadAllComponents()
        if yearTextField.text != ""{
            engineTextField.enabled = true
        }
    }
    func engineSelect(){
        carVersions = (brandDao?.queryVersion(yearTextField.text!, brandname: brandTextField.text!, engine: engineTextField.text!, carxi: carxiTextField.text!))!
        carVersionPick.reloadAllComponents()
        if engineTextField.text != ""{
            versionTextField.enabled = true
        }
    }
    func versionSelect(){
        gearBoxs = (brandDao?.queryGearBox(brandTextField.text!, carXi: carxiTextField.text!, year: yearTextField.text!, engine: engineTextField.text!, carversion: versionTextField.text!))!
        gearBoxPick.reloadAllComponents()
        if versionTextField.text != ""{
            gearBoxTextField.enabled = true
        }
    }

    //点击确定触发的事件 未完善
    @IBAction func comfirmAction(sender: AnyObject) {
        if(!checkNetwork.checkNetwork()){
            return
        }
        if(horseTextField.text != ""){
            var horse = horseTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            horse = horse.uppercaseString
            if(horse.characters.count != 17){
                let alterwin = UIAlertView(title: nil, message: "请正确填写车架号", delegate: nil, cancelButtonTitle: "确定")
                alterwin.show()
            }
            else{
                print(NSUserDefaults.standardUserDefaults().integerForKey("UserID"))
                if(NSUserDefaults.standardUserDefaults().integerForKey("UserID") != 0){
                    let userID = NSUserDefaults.standardUserDefaults().integerForKey("UserID")
                    let parameters = ["UserID":userID , "Horse":horse]
                    Alamofire.request(.POST, saveByHorseURL , parameters:parameters as? [String : AnyObject])
                        .response { request ,response ,data , eror in
                            let json = JSONND.initWithData(data!)
                            print(json)
                            let modelCode = json["ModelCode"].string
                            NSUserDefaults.standardUserDefaults().setObject(modelCode, forKey: "ModelCode")
                            let alterwin = UIAlertView(title: nil, message: "绑定成功", delegate: nil, cancelButtonTitle: "确定")
                            alterwin.show()
                    }
                }
                else{
                    let parameters = ["Horse":horse]
                    
                    Alamofire.request(.POST, getModelCodeByHorseURL , parameters:parameters)
                        .response { request ,response ,data , eror in
                            let json = JSONND.initWithData(data!)
                            print(json)
                            let modelCode = json["ModelCode"].string
                            NSUserDefaults.standardUserDefaults().setObject(modelCode, forKey: "ModelCode")
                            let alterwin = UIAlertView(title: nil, message: "绑定成功", delegate: nil, cancelButtonTitle: "确定")
                            alterwin.show()
                    }
                }
            }
                
        }
        else if gearBoxTextField.text != ""{
            if(NSUserDefaults.standardUserDefaults().integerForKey("UserID") != 0){
                let userID = NSUserDefaults.standardUserDefaults().integerForKey("UserID")
                let carXi = carxiTextField.text
                let year = yearTextField.text
                let engine = engineTextField.text
                let gearbox = gearBoxTextField.text
                let brand = brandTextField.text
                let configuration = versionTextField.text
               // print()
                let parameters = ["CarXi":carXi!,"Year":year!,"Engine":engine!,"GearBox":gearbox!]
                Alamofire.request(.POST, getModelCodeURL, parameters: parameters ).response{
                    request ,response ,data , eror in
                    var json = JSONND.initWithData(data!)
                    let result = json.arrayValue
                    let modelCode = result[0].string!
                    NSUserDefaults.standardUserDefaults().setObject(modelCode, forKey: "ModelCode")
                    print(modelCode)
                    let parameters2 = ["CarXi":carXi!,"Year":year!,"Engine":engine!,"GearBox":gearbox! ,"UserID":userID , "ModelCode":modelCode,"Configuration":configuration!,"Brand":brand!]
                    print("\(carXi!)    \(configuration!)     \(brand!)     \(engine!)    ")
                    print(parameters2)
                     Alamofire.request(.POST, self.saveByCarXiURL, parameters: parameters2 as! [String : AnyObject]).response{
                        request ,response ,data , eror in
                        json = JSONND.initWithData(data!)
                        print(json)
                    }
                }
                let alterwin = UIAlertView(title: nil, message: "绑定成功", delegate: nil, cancelButtonTitle: "确定")
                alterwin.show()
            }
            else{
                let carXi = carxiTextField.text
                let year = yearTextField.text
                let engine = engineTextField.text
                let gearbox = gearBoxTextField.text
                // print()
                let parameters = ["CarXi":carXi!,"Year":year!,"Engine":engine!,"GearBox":gearbox!]
                Alamofire.request(.POST, getModelCodeURL, parameters: parameters ).response{
                    request ,response ,data , eror in
                    let json = JSONND.initWithData(data!)
                    let result = json.arrayValue
                    let modelCode = result[0].string!
                    NSUserDefaults.standardUserDefaults().setObject(modelCode, forKey: "ModelCode")
                }
                let alterwin = UIAlertView(title: nil, message: "绑定成功", delegate: nil, cancelButtonTitle: "确定")
                alterwin.show()
            }
            
        }
        else{
            let alterwin = UIAlertView(title: nil, message: "选择正确的车型或输入正确的车架号", delegate: nil, cancelButtonTitle: "确定")
            alterwin.show()
        }
    }
    
    
}

