//
//  LoginViewController.swift
//  ico2o
//
//  Created by CatKatherine on 15/10/19.
//  Copyright (c) 2015年 chingyam. All rights reserved.
//
//登陆控制器
import UIKit
import Alamofire
import JSONNeverDie
import NVActivityIndicatorView
// 算是声明一种闭包类型吧
typealias callClosure=()->Void




class LoginViewController: UIViewController, UITextFieldDelegate,WXApiDelegate {
    //视图与控制器绑定
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var pwdTextField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!

    
    //构造URL
    var listData: NSDictionary = NSDictionary()
    var filePath = NSBundle.mainBundle().pathForResource("config.plist", ofType:nil )
    var loginURL:String = ""
        var checkNetwork = CheckNetWorking()
   
    override func viewDidLoad() {
        super.viewDidLoad()
  
       
    
        listData = NSDictionary(contentsOfFile: filePath!)!
        loginURL = listData.valueForKey("url") as! String
        loginURL += "/ASHX/MobileAPI/Login.ashx"
        //设置输入框委托对象为当前视图控制器
        pwdTextField.delegate = self
        userNameTextField.delegate = self
        
        userNameTextField.placeholder = "请输入手机号"
        pwdTextField.placeholder = "请输入密码"
        loginBtn.layer.cornerRadius = 0
        loginBtn.enabled = false
        loginBtn.alpha = 0.3
    }
    
    var myClosure:callClosure?
    func initWithClosure(closure:callClosure?){
        myClosure = closure
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        //避免用户不合法输入
        if userNameTextField.text != "" && pwdTextField.text != "" {
            loginBtn.alpha = 1
            loginBtn.enabled = true
        }
        if range.location == 0 && string == "" {
            loginBtn.enabled = false
            loginBtn.alpha = 0.3
        }
        return true
    }

    
    @IBAction func back(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setObject("nil", forKey: "goToView")
        self.dismissAction()
    }
    //点击登录按钮的事件方法
    @IBAction func loginAction(sender: AnyObject) {
        //收起键盘
        UIApplication.sharedApplication().keyWindow?.endEditing(true)
        

        if self.userNameTextField.text == "" || self.pwdTextField.text == ""{
            let alterWin = UIAlertView(title: nil, message: "用户名和密码不能为空！", delegate: nil, cancelButtonTitle: "确定")
            alterWin.show()

       
        }
        else if self.userNameTextField.text != "" && self.pwdTextField.text != ""{
            var userName:String = userNameTextField.text!
            let userPwd:String = pwdTextField.text!
            userName = userName.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            let parameters = ["UserName":userName,"Pwd":userPwd]
            if(!checkNetwork.checkNetwork()){
                return
            }
            
            //提供加载动画并示意用户不再点击该按钮
            let loadAnimation = NVActivityIndicatorView(frame: CGRect(x: loginBtn.center.x - 30, y: loginBtn.center.y - 30, width: 60, height: 60), type: .BallScaleMultiple, color: UIColor.whiteColor(), padding: CGFloat(0))
            self.view.addSubview(loadAnimation)
            loadAnimation.startAnimating()
            loginBtn.enabled = false
            loginBtn.alpha = 0.3
            
            //存储账号密码以供下次打开App自动获取cookie
            NSUserDefaults.standardUserDefaults().setObject(userPwd, forKey: "pwd")
            NSUserDefaults.standardUserDefaults().setObject(userName, forKey: "userName")
            
            Alamofire.request(.POST, loginURL , parameters:parameters)
                .response { request ,response ,data , eror in
                    //为了体验的连续性而加
                    NSThread.sleepForTimeInterval(1)
                    let json = JSONND.initWithData(data!)
                    let userID = json["UserID"].intValue
                    print("userID = \(userID)")
                    //停止加载
                    loadAnimation.stopAnimating()
                    if(userID == -1){
                        let alterwin = UIAlertView(title: nil, message: "登录失败 请输入正确的账号或密码", delegate: nil, cancelButtonTitle: "确定")
                        alterwin.show()
                    }
                    else{
                        NSUserDefaults.standardUserDefaults().setObject(userID, forKey: "UserID")
                        //通知给上个界面登录成功
                        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "Gender")
                    NSNotificationCenter.defaultCenter().postNotificationName("NotificationIdentifier", object: nil)
                        self.dismissAction()
                    }
            }
            
         }
    }
    
    // 从注册/登陆界面的返回动作，进行判断
    // 如果以正常入口进入注册/登陆界面，原路返回
    // 如果从其他界面调出来的注册/登陆界面，则返回触发按钮本该去向的页面
    func dismissAction() {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        let vcName = NSUserDefaults.standardUserDefaults().stringForKey("goToView")
        if vcName == "nil" {
            return }
        
        let vc = (self.storyboard?.instantiateViewControllerWithIdentifier(vcName!))!
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    
    
    //微信登录按钮处理方法
    @IBAction func wechatLogin(sender: UIButton) {
        
        let wc_access_token = NSUserDefaults.standardUserDefaults().stringForKey("wc_access_token")
        var wc_refresh_token = NSUserDefaults.standardUserDefaults().stringForKey("wc_refresh_token")
        var wc_openid = NSUserDefaults.standardUserDefaults().stringForKey("wc_openid")
        
//        if wc_access_token != nil {
//            
//        } else {
            let req = SendAuthReq()
            req.scope = "snsapi_userinfo"
            req.state = "ico2o_ios"
            WXApi.sendReq(req)
//        }
        self.dismissAction()
    }

    @IBAction func QQLogin(sender: AnyObject) {
         self.navigationController?.view.makeToast("正在接入中...")
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
