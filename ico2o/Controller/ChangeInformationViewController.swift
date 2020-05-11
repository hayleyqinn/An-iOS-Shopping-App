//
//  ChangeInformationViewController.swift
//  ico2o
//
//  Created by 覃红 on 2016/10/11.
//  Copyright © 2016年 chingyam. All rights reserved.
//

import UIKit

class ChangeInformationViewController: UIViewController {

    var viewTitle: String?
    var content: String?
    @IBOutlet weak var data: UILabel!
    
    override func viewWillAppear(animated: Bool) {
      
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = viewTitle
        
        self.data.text = content
       
        
        
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
