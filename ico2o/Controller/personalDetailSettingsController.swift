//
//  personalDetailSettingsController.swift
//  ico2o
//
//  Created by 覃红 on 2016/9/23.
//  Copyright © 2016年 chingyam. All rights reserved.
//

import UIKit

class personalDetailSettingsController: UITableViewController {
    @IBAction func logoutBtn(sender: AnyObject) {
        
        let alertController = UIAlertController(title: "提示",
                                                message: "您确定要退出登录吗？", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
        let okAction = UIAlertAction(title: "确定", style: .Default,
                                     handler: {
                                        action in
                                        
                                        NSUserDefaults.standardUserDefaults().setObject(0, forKey: "UserID")
                                        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "ModelCode")
                                        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "avatar")
                                        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "DefaultCar")
                                        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "pwd")
                                        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "userName")
                                        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "Gender")
                                        self.navigationController?.popToRootViewControllerAnimated(true)
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
      
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.title  = "设置"
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
