//
//  AddAddressViewController.swift
//  ico2o
//
//  Created by Katherine on 15/12/5.
//  Copyright © 2015年 chingyam. All rights reserved.
//

import UIKit
import Alamofire
import JSONNeverDie

class AddAddressViewController: UIViewController, ChineseSubdivisionsPickerDelegate, UITextFieldDelegate {
    /*personTF:收货人
    telTF:电话
    postageTF:邮编
    districtTF:地区（省、市、区）
    addressTF:详细地址
    dataFromOther:从其它页面传过来的数据
    districtPicker:地区选择器
    listData,filePath：URL相关
    headerURL:ip地址
    addAddressURL：添加新地址的URL
    changeAddressURL:修改地址的URL
    districtText：地区信息（省、市、区）
    lastVC:上一个页面
    */
    @IBOutlet weak var personTF: UITextField!
    @IBOutlet weak var telTF: UITextField!
    @IBOutlet weak var postageTF: UITextField!
    @IBOutlet weak var districtTF: UITextField!
    @IBOutlet weak var addressTF: UITextField!
    var dataFromOther:AddressModel?
    var districtPicker = ChineseSubdivisionsPicker()
    var listData: NSDictionary = NSDictionary()
    var filePath = NSBundle.mainBundle().pathForResource("config.plist", ofType:nil )
    var headerURL:String = ""
    let addAddressURL:String = "/ASHX/MobileAPI/Receiving/AddReceiving.ashx"
    let changeAddressURL:String = "/ASHX/MobileAPI/Receiving/UpdateReceiving.ashx"
    var districtText:[String] = ["","",""]
    weak var lastVC:MyAddressTableViewController?
    var checkNetWork:CheckNetWorking = CheckNetWorking()
    @IBOutlet weak var confirmO: UIButton!
    //确定按钮
    @IBAction func confirm(sender: AnyObject) {
        if(!self.checkNetWork.checkNetwork()){
            return
        }
        //检查信息是否完整
        if (personTF.text != "") && (telTF.text != "") && (postageTF.text != "") && (districtTF.text != "") && (addressTF.text != "") && (telTF.text != "") {
            //所需参数
            var parameters:[String:AnyObject] = ["UserID":NSUserDefaults.standardUserDefaults().integerForKey("UserID"), "Name":personTF.text!, "PostCode":postageTF.text!, "Province":(districtPicker.province ?? ""), "City":(districtPicker.city ?? ""), "District":(districtPicker.district ?? ""), "Address":addressTF.text!, "Mobile":telTF.text!]
            
            var URL = headerURL + addAddressURL
            if dataFromOther != nil {
                URL = headerURL + changeAddressURL
                parameters = ["RecevingID":dataFromOther!.ID, "Name":personTF.text!, "PostCode":postageTF.text!, "Province":(districtPicker.province ?? ""), "City":(districtPicker.city ?? ""), "District":(districtPicker.district ?? ""), "Address":addressTF.text!, "Mobile":telTF.text!]
            }
            Alamofire.request(.POST, URL , parameters:parameters)
                .response { request ,response ,data , eror in
                    let result = JSONND.initWithData(data!)
                    let isSuccess:Bool = result["result"].boolValue
                    if (isSuccess){
                        let alterWin = UIAlertView(title: nil, message: "提交成功", delegate: nil, cancelButtonTitle: "确定")
                        alterWin.show()
                        //返回上一页时刷新
                        self.lastVC!.viewDidLoad()
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    else{
                        let alterWin = UIAlertView(title: nil, message: "提交失败，请重试", delegate: nil, cancelButtonTitle: "确定")
                        alterWin.show()
                    }
            }
            
        }
        else {
            let alterV = UIAlertView(title: nil, message: "请输入完整信息", delegate: nil, cancelButtonTitle: "确定")
            alterV.show()
        }
    }
    //返回到上一页面
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //设置提交数据的url
        listData = NSDictionary(contentsOfFile: filePath!)!
        headerURL = listData.valueForKey("url") as! String

        //地区选择器的处理
        districtTF.delegate = self
        districtPicker.pickerDelegate = self
        districtPicker.pickerType = .District
        districtTF.inputView = districtPicker
        districtTF.text = ""
        confirmO.layer.cornerRadius = 0
        //若dataFromOther不为空，则当前为修改收货地址信息页面，需将原信息显示出来
        if dataFromOther != nil {
            reviseMsg()
        }
}

    //districtPicker当前选中的内容变化后更改输入框显示的内容
    func subdivisionsPickerDidUpdate(sender: ChineseSubdivisionsPicker) {
        districtText[0] = (districtPicker.province ?? "")
        districtText[1] = (districtPicker.city ?? "")
        districtText[2] = (districtPicker.district ?? "")
        //先将textfield中原内容清空再赋值
        districtTF.text = ""
        for string in districtText {
            districtTF.text! += (string + " ")
        }
    }
    
    //显示修改前的信息
    func reviseMsg() {
        personTF.text = dataFromOther!.Name
        telTF.text = dataFromOther!.Mobile
        postageTF.text = dataFromOther!.PostCode
        districtTF.text = dataFromOther!.Province + dataFromOther!.City + dataFromOther!.District
        addressTF.text = dataFromOther!.Address
        //更改地区选择器中的信息以免影响后续
        districtPicker.province = dataFromOther?.Province
        districtPicker.city = dataFromOther?.City
        districtPicker.district = dataFromOther?.District
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

}
