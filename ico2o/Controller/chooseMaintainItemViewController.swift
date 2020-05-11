//
//  chooseMaintainItemViewController.swift
//  ico2o
//
//  Created by 覃红 on 2017/3/3.
//  Copyright © 2017年 chingyam. All rights reserved.
//

import UIKit

class chooseMaintainItemViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func m2(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("NotificationIdentifier2", object: "保养项目2")
        self.navigationController?.popViewControllerAnimated(true)

        
    }

    @IBAction func m1(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("NotificationIdentifier2", object:"保养项目1")
        self.navigationController?.popViewControllerAnimated(true)

    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
