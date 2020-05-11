//
//  RegisterViewController.swift
//  LoginRegister
//
//  Created by chingyam on 15/11/2.
//  Copyright © 2015年 chingyam. All rights reserved.
//  注册界面

import UIKit
import Alamofire
import JSONNeverDie

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var regBtn: UIButton!
    @IBOutlet weak var pwdBtn: UILabel!
    @IBOutlet weak var getIDCode: UIButton!
    @IBOutlet weak var IdentifyingCodeTF: UITextField!
    @IBOutlet weak var pwdTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    var timer:NSTimer!
    var isOnClick:Bool = false
    var checkNetWork:CheckNetWorking = CheckNetWorking()
    var remainingSec = 60
    //从config.plist里面构造URL
    var listData: NSDictionary = NSDictionary()
    var filePath = NSBundle.mainBundle().pathForResource("config.plist", ofType:nil )
    var registerURL:String = ""
    var getIDCodeURL:String = ""
    
    //获取验证码
    @IBAction func getIdentfCode(sender: AnyObject) {
        updateTime()
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(RegisterViewController.updateTime), userInfo: nil, repeats: true)
        
        isOnClick = true
        getIDCode.enabled = false
        getIDCode.alpha = 0.3
        
        let parameter = ["PhoneNumber":userNameTextField.text!]
        print(parameter, userNameTextField.text!)
        Alamofire.request(.POST, getIDCodeURL, parameters:parameter).response{
            request , response , data , error in
            //let json = JSONND.initWithData(data!)
        }
        
    }
    func updateTime() {
        // 计时开始时，逐秒减少remainingSeconds的值
        remainingSec -= 1 
        getIDCode.setTitle("\(remainingSec)s", forState: .Normal)
        if remainingSec <= 0 {
            tickDown()
        }
    }
    //注册按钮被点击60s后
    func tickDown(){
        isOnClick = false
        getIDCode.enabled = true
        getIDCode.alpha = 1
        getIDCode.setTitle("获取验证码", forState: .Normal)
        remainingSec = 60
        timer.invalidate()
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        listData = NSDictionary(contentsOfFile: filePath!)!
        registerURL = listData.valueForKey("url") as! String
        registerURL += "/ASHX/MobileAPI/PhoneVaildate/Validate.ashx"
        getIDCodeURL = listData.valueForKey("url") as! String
        getIDCodeURL += "/ASHX/MobileAPI/PhoneVaildate/GetValidate.ashx"
        pwdBtn.text = "   " + "密码"
        getIDCode.layer.cornerRadius = 0
        regBtn.layer.cornerRadius = 0
        getIDCode.alpha = 0.3
        getIDCode.enabled = false
        regBtn.enabled = false
        regBtn.alpha = 0.3
        userNameTextField.delegate = self
        pwdTextField.delegate = self
        IdentifyingCodeTF.delegate = self
        
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if !isOnClick {
            if userNameTextField.text != "" {
                getIDCode.enabled = true
                getIDCode.alpha = 1
            }
        }
        
        if pwdTextField.text != "" && IdentifyingCodeTF.text != "" && isOnClick == true {
            regBtn.enabled = true
            regBtn.alpha = 1
        }
        if range.location == 0 && string == "" {
            regBtn.enabled = false
            regBtn.alpha = 0.3
//            getIDCode.enabled = false
//            getIDCode.alpha = 0.3
        }
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func RegisterAction(sender: AnyObject) {
        if self.userNameTextField.text != nil && self.pwdTextField.text != nil{
            var userName = userNameTextField.text!
            let userPwd = pwdTextField.text!
            userName = userName.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            let IdentifyingCode = IdentifyingCodeTF.text!
            let parameters = ["Phone":userName,"Pwd":userPwd,"Vaildate":"\(IdentifyingCode)"]
            print(parameters)
            Alamofire.request(.POST, registerURL , parameters:parameters)
                .response { request, response, data, error in
                    let result = JSONND.initWithData(data!)
                    print(request, result, error, response)
                    let isRegister:Bool = result["result"].boolValue
                    if (isRegister){
                        let alterWin = UIAlertView(title: nil, message: "注册成功", delegate: nil, cancelButtonTitle: "确定")
                        alterWin.show()
                        self.performSegueWithIdentifier("registerToHomepage", sender: self)
                    }
                    else{
                        let alterWin = UIAlertView(title: nil, message: "注册失败，请重试", delegate: nil, cancelButtonTitle: "确定")
                        alterWin.show()
                        }
                    }
            }
            
        }
    }


