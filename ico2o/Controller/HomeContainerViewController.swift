//
//  HomeContainerViewController.swift
//  ico2o
//
//  Created by 曾裕璇 on 2016/01/11.
//  Copyright © 2016年 chingyam. All rights reserved.
//

import UIKit

class HomeContainerViewController: UIViewController, UIAlertViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    
    // 分别对应主界面中部的六个图标按钮
    @IBAction func icon_1(sender: AnyObject) { loginFirst("maintenance") }
    @IBAction func icon_2(sender: AnyObject)
        { loginFirst("beauty") }
    @IBAction func icon_3(sender: AnyObject) { //loginFirst("nearMaintenance")
        let vc = (self.storyboard?.instantiateViewControllerWithIdentifier("nearMaintenance"))!
        self.presentViewController(vc, animated: true, completion: nil)
    }
    @IBAction func icon_4(sender: AnyObject) { loginFirst("searching") }
    @IBAction func icon_5(sender: AnyObject) { loginFirst("shareTable") }
    @IBAction func icon_6(sender: AnyObject) { loginFirst("petrolNote") }
    
    
    func loginFirst(vcName:String) {
        
        NSUserDefaults.standardUserDefaults().setObject(vcName, forKey: "goToView")
        
        // 如果没有登陆则跳转到登陆界面
        if NSUserDefaults.standardUserDefaults().stringForKey("UserID") == nil ||
            NSUserDefaults.standardUserDefaults().integerForKey("UserID")==0 {
            UIAlertView(
                title               : "",
                message             : "请先登陆账户",
                delegate            : self,
                cancelButtonTitle   : "取消",
                otherButtonTitles   : "前往"
            ).show()
                
        }else{
            let vc = (self.storyboard?.instantiateViewControllerWithIdentifier(vcName))!
            self.presentViewController(vc, animated: true, completion: nil)
        }
    }
    
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == alertView.cancelButtonIndex { return }
        // “前往”按钮
        let vc = (self.storyboard?.instantiateViewControllerWithIdentifier("login"))!
        self.presentViewController(vc, animated: true, completion: nil)
    }
}




