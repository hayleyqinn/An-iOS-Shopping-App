//
//  PetrolNote2ViewController.swift
//  ico2o
//
//  Created by 曾裕璇 on 2015/12/28.
//  Copyright © 2015年 chingyam. All rights reserved.
//

import UIKit
import Alamofire
import JSONNeverDie

class PetrolNote2ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func save(sender: AnyObject) {
        Alamofire.request(.POST, "https://httpbin.org/get")
            .response { request, response, data, eror in
                print("in")
                //let json = JSONND.initWithData(data!)
                //let res = json["result"].bool!
        }
        print("out")
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
