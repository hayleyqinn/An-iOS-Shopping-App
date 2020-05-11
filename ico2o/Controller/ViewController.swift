//
//  ViewController.swift
//  ico2o
//
//  Created by chingyam on 15/10/14.
//  Copyright (c) 2015年 chingyam. All rights reserved.
//

import UIKit
import Alamofire
import JSONNeverDie


class ViewController: UIViewController ,UITableViewDataSource {
    var cars:[CarsModel] = []
    var defaultbtn:UIButton!
    var findPartsBtn:UIButton!
    var maintainBtn:UIButton!
    //声明tableView
    @IBOutlet weak var addCarBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    //声明myCarDao 访问sqlite
    var myCarDao:MyCarDao?
    //读取plist文件构造的地址
    var listData: NSDictionary = NSDictionary()
    var filePath = NSBundle.mainBundle().pathForResource("config.plist", ofType:nil )
    var getMyCarURL:String = ""
    var deleteCarURL:String = ""
    var setDefaultCarURL:String = ""
    var isExistHorseURL:String = ""
    var getSecondSortsURL:String = ""
    var isFromOtherPage = false
    var secondSorts:[SecondSortsModel] = []
    var horse:String = ""
    var modelCode:String = ""
    var checkNetwork = CheckNetWorking()
    override func viewDidLoad() {
        super.viewDidLoad()
        listData = NSDictionary(contentsOfFile: filePath!)!
        deleteCarURL = listData.valueForKey("url") as! String
        deleteCarURL += "/ASHX/MobileAPI/MyCars/Delete.ashx"
        setDefaultCarURL = listData.valueForKey("url") as! String
        setDefaultCarURL += "/ASHX/MobileAPI/MyCars/UpdateDefault.ashx"
        isExistHorseURL = listData.valueForKey("url") as! String
        isExistHorseURL += "/ASHX/MobileAPI/LoveCarDocument/ExistHorse.ashx"
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        addCarBtn.layer.cornerRadius = 0
        
        
        navigationItem.rightBarButtonItem = editButtonItem()
        //若当前页面是从其它页面传过来，则提供返回键
        if isFromOtherPage {
            let leftBarItem = UIBarButtonItem(image: UIImage(named: "back"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ViewController.back))
            navigationItem.leftBarButtonItem = leftBarItem
        }
    }

    //返回上一页
    func back(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //tableview cell的个数 根据cars的数组的长度来确定
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return cars.count;
    }
    //tableView的Cell ，根据Tag获取到cell中的控件 再根据下标将cars里面的数据取出
    //将数据转化为视图 返回Cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("carsCell")! as UITableViewCell
        let car = cars[indexPath.row] as CarsModel
        var title = car.brand
        //print("titile  \(title)")
        
        title += " \(car.models) \(car.proDate)年"
        let drive = "\(car.drive_KM)km"
        let cartitle = cell.viewWithTag(101) as! UILabel
        let drivekm = cell.viewWithTag(103) as! UILabel
        defaultbtn = cell.viewWithTag(104) as! UIButton
        findPartsBtn = cell.viewWithTag(105) as! UIButton
        maintainBtn = cell.viewWithTag(106) as! UIButton
        if(car.isDefault == "true"){
            defaultbtn.selected = true
            NSUserDefaults.standardUserDefaults().setObject(car.modelCode, forKey: "ModelCode")
        }
        //添加btn的事件
        defaultbtn.addTarget(self, action: #selector(ViewController.setSelected(_:)), forControlEvents: UIControlEvents.TouchDown)
        findPartsBtn.addTarget(self, action: #selector(ViewController.goToFindParts(_:)), forControlEvents: UIControlEvents.TouchDown)
        maintainBtn.addTarget(self, action: #selector(ViewController.goToMainTain(_:)), forControlEvents: UIControlEvents.TouchDown)
        cartitle.text = title
        drivekm.text = drive
        //隐藏cell中的分割线
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
    }
    //在View完成加载的时候去获取数据
    override func viewWillAppear(animated: Bool) {
        
        if(NSUserDefaults.standardUserDefaults().integerForKey("UserID") != 0){
            addCarBtn.alpha = 1
            addCarBtn.enabled = true
            addCarBtn.setTitle("添加爱车", forState: .Normal)
            resetButton()
            cars = []
            tableView.reloadData()
            if(NSUserDefaults.standardUserDefaults().integerForKey("UserID") != 0){
                getData()
            }
            else{
                NSThread.sleepForTimeInterval(2)
            }
        }else{
            cars.removeAll()
            self.tableView.reloadData()
            addCarBtn.setTitle("登录后才能添加爱车哦！", forState: .Normal)
            addCarBtn.alpha = 0.3
            addCarBtn.enabled = false
            let alertController = UIAlertController(title: "", message: "请登录后操作", preferredStyle: UIAlertControllerStyle.Alert)
            let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
            let goToAction = UIAlertAction(title: "前往", style: .Default, handler: {(alterWin: UIAlertAction!) in let vc = (self.storyboard?.instantiateViewControllerWithIdentifier("login"))!
                self.presentViewController(vc, animated: true, completion: nil)
            })
            alertController.addAction(cancelAction)
            alertController.addAction(goToAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
    }
    
    
    func getData(){
        //设置加载动图
        let imgView = UIImageView(image: UIImage.gifWithName("loading2"))
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: tableView.frame.height))
        imgView.frame = CGRect(x: (view.frame.width) / 2 - 150, y: (view.frame.height) / 2 - 150, width: 300, height: 300)
        view.addSubview(imgView)
        tableView.backgroundView = view
        
        if(!checkNetwork.checkNetwork()){
            return
        }
        //创建Dao对象
        myCarDao = MyCarDao()
            //userID赋值为NSUserDefaluts里面的UserID
            let userID = NSUserDefaults.standardUserDefaults().stringForKey("UserID")!
            //构造参数
            let parameters = ["UserID":userID]
            //构造URL
            listData = NSDictionary(contentsOfFile: filePath!)!
            getMyCarURL = listData.valueForKey("url") as! String
            getMyCarURL += "/ASHX/MobileAPI/MyCars/GetMyCars.ashx"

        
            //往后台获取数据
            Alamofire.request(.POST, getMyCarURL, parameters: parameters).response {    request ,response ,data , eror in
                //数据转为Json
                let json = JSONND.initWithData(data!)
                //Json转为数组
                let mycars = json.arrayValue
                //数组转为模型
                //print(json)
                if mycars.count == 0{
                    print("没车没车没车！！")
                    imgView.removeFromSuperview()
                    view.sendSubviewToBack(imgView)
                    let alert = UIAlertView(title: "暂无爱车", message: "请添加爱车", delegate: self, cancelButtonTitle: "确定")
                    alert.alertViewStyle = UIAlertViewStyle.Default
                    alert.show()
                }else{
    
                    for i in 0 ..< mycars.count {
                        let id = mycars[i]["ID"].intValue
                        let userID = mycars[i]["UserID"].intValue
                        let imagepath = mycars[i]["ImagePath"].stringValue
                        let carNumber = mycars[i]["CarNumber"].stringValue
                        let models = mycars[i]["Models"].stringValue
                        let link = mycars[i]["Link"].stringValue
                        let proDate = mycars[i]["ProDate"].stringValue
                        let config = mycars[i]["Config"].stringValue
                        var createDate = mycars[i]["CreatedDate"].stringValue
                        let isDefalut = mycars[i]["IsDefault"].boolValue
                        let userName = mycars[i]["UserName"].stringValue
                        let engine = mycars[i]["Engine"].stringValue
                        let modelCode = mycars[i]["ModelCode"].stringValue
                        let brand = mycars[i]["Brand"].stringValue
                        let drive_KM = mycars[i]["Drive_KM"].intValue
                        let wave = mycars[i]["Wave"].stringValue
                        var licenseDate = mycars[i]["LicenseDate"].stringValue
                        var lastMaintenanceDate = mycars[i]["LastMaintenanceDate"].stringValue
                        let lastMaintenanceKM = mycars[i]["LastMaintenanceKM"].intValue
                        let motor_LastSixNumber = mycars[i]["Motor_LastSixNumber"].stringValue
                        //将返回的时间格式从YYYY-MM-DDTHH-mm-SS截掉后面的部分 保留年月日
                        licenseDate = licenseDate.subString(licenseDate)
                        lastMaintenanceDate = lastMaintenanceDate.subString(lastMaintenanceDate)
                        createDate = createDate.subString(createDate)
                        //将获取到的Int数据转为String
                        let lastMaintenanceKMStr = String(lastMaintenanceKM)
                        let isDefaultStr = String(isDefalut)
                        let driver_kmStr = String(drive_KM)
                        let idStr = String(id)
                        let useridStr = String(userID)
                        let carsModel:CarsModel = CarsModel(id: idStr, userID: useridStr, ImagePath: imagepath, carNumber: carNumber, models: models, link: link, proDate: proDate, config: config, createDate: createDate, isDefault: isDefaultStr, userName: userName, engine: engine, modelCode: modelCode, brand: brand, drive_KM: driver_kmStr, wave: wave, licenseDate: licenseDate, lastMaintenanceDate: lastMaintenanceDate, lastMaintenanceKM: lastMaintenanceKMStr, motor_LastSixNumber: motor_LastSixNumber)
                        
                        
                        //检查数据中的ID在数据库中是否存在 如果存在则不添加到数据库中
                        if self.myCarDao?.check(id) == false{
                            self.myCarDao?.addMyCar(carsModel)
                        }
                        //检查数据中得ID是否与cars数组中的ID相同 如果相同则不增加 如果不同则增加
                        var temp = 0
                        
                        for j in 0 ..< self.cars.count {

                            if self.cars[j].id == idStr{
                                temp = 1
                            }
                        }
                        if(temp == 0){
                            self.cars.append(carsModel)
                        }
                        
                        //TableView重新加载数据
                        self.tableView.backgroundView = nil
                        self.tableView.reloadData()                    
                    }
                }
            }
    }
    //cell中默认车型按钮的事件
    func setSelected(button:UIButton){
        //defaultbtn.selected = true
        //将所以的默认车型的按钮设为未选择
        resetButton()
        //获取当前点击的row
        let cell = button.superview?.superview as! UITableViewCell
        let row = tableView.indexPathForCell(cell)?.row
        //根据当前的row获取到对应的车型的modelCode 存到NSuserDefaults，将按钮设为selected状态
        button.selected = true
        let checkid:String =  "\(cars[row!].id)"
        let modelCode = myCarDao?.queryModelCode(Int(checkid)!)
        NSUserDefaults.standardUserDefaults().setObject(modelCode![0], forKey: "ModelCode")
        NSUserDefaults.standardUserDefaults().setObject(checkid, forKey: "CarID")
        let carInfo:String = (myCarDao?.queryMyCar(Int(checkid)!))!
        NSUserDefaults.standardUserDefaults().setObject(carInfo, forKey: "DefaultCar")
        let userID = NSUserDefaults.standardUserDefaults().integerForKey("UserID")
        let parameters = ["UserID":userID,"CarIncludedID":checkid]
        Alamofire.request(.POST, setDefaultCarURL,parameters:parameters as? [String : AnyObject]).response{
            request , response , data , error in
//            let json = JSONND.initWithData(data!)
//            print(json)
            
        }
    }
    
    func goToFindParts(button:UIButton){
        let cell = button.superview?.superview as! UITableViewCell
        let row = tableView.indexPathForCell(cell)?.row
        horse = "\(cars[row!].carNumber)"
        let parameters = ["Horse":horse]
        Alamofire.request(.POST, isExistHorseURL , parameters:parameters).response{
            request , response , data , error in
            let json = JSONND.initWithData(data!)
            let result = json["result"].bool
            if result == true {
                self.performSegueWithIdentifier("MyCarToSecondSort", sender: self)
            }
            else {
                self.navigationController?.view.makeToast("不存在该车架号哦！", duration: 1, position: .Center)
            }
        }
    }
    //将所有的按钮selected状态改为false
    func resetButton(){
        
        let table = tableView.subviews
        let cell = table[0].subviews
        for i in 0  ..< cars.count {

            let contentView = cell[i].subviews
            let btn = contentView[0].viewWithTag(104) as! UIButton
//            let tempbtn = btn[6] as! UIButton
//            print(tempbtn)
//            print("成功执行reset方法！")
            btn.selected = false
        }
        
    }
    //删除项 先在数据库中删除记录 再将后台的记录删除 最后reload tableView
    internal func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath){
        if editingStyle == UITableViewCellEditingStyle.Delete{
            
            myCarDao?.deleteMyCar(Int(cars[indexPath.row].id)!)
            let carIncludeID = cars[indexPath.row].id
            let parameters = ["CarIncludedID": carIncludeID]
            Alamofire.request(.POST, deleteCarURL , parameters:parameters)
                .response { request ,response ,data , eror in
                    //print(data)
                }
            }
            cars.removeAtIndex(indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            tableView.reloadData()
        }
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.setEditing(editing, animated: animated)
    }
    func goToMainTain(button:UIButton){
        let cell = button.superview?.superview as! UITableViewCell
        let row = tableView.indexPathForCell(cell)?.row
        self.modelCode = cars[row!].modelCode
        NSUserDefaults.standardUserDefaults().setObject(self.modelCode, forKey: "ModelCode")
        self.performSegueWithIdentifier("MyCarToMaint", sender: self)

    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "MyCarToSecondSort" {
            let receive = (segue.destinationViewController as! UINavigationController)
            let a = receive.viewControllers[0] as! SecondSortsViewController
            a.secondSort = self.secondSorts
            a.horse = self.horse
        }
    }
}


//扩展String的方法，截取String的长度，从下标为0开始 往后10个字符
extension String{
    func subString(str:String)->String{
        let ns = (str as NSString).substringWithRange(NSMakeRange(0, 10))
        return ns as String
    }
}
