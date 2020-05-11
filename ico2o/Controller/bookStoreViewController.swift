//
//  bookStoreViewController.swift
//  ico2o
//
//  Created by 覃红 on 2016/12/21.
//  Copyright © 2016年 chingyam. All rights reserved.
//

import UIKit

class bookStoreViewController: UIViewController,  UITextFieldDelegate {
    var tempStore = "null"

    @IBOutlet weak var storeName: UITextField!
    @IBOutlet weak var bookDate: UITextField!
    @IBOutlet weak var carID: UITextField!
    @IBOutlet weak var phoneNum: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var chooseOrder: UITextField!
    @IBOutlet weak var bookItems: UITextField!
    @IBOutlet weak var memo: UITextField!
    @IBOutlet weak var myCar: UITextField!
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print(tempStore)
        storeName.text = tempStore
       
        bookDate.delegate = self
//        carID.delegate = self
//        phoneNum.delegate = self
//        name.delegate = self
        chooseOrder.delegate = self
        bookItems.delegate = self
//        memo.delegate = self
        let defaultCarInfo = NSUserDefaults.standardUserDefaults().objectForKey("DefaultCar")
        if defaultCarInfo != nil {
            myCar.text = "\(defaultCarInfo as! String)(默认)"
        }
        
        //注册通知 for order
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(bookStoreViewController.disPlayMsg(_:)), name:"NotificationIdentifier", object: nil)
        //注册通知 for item
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(bookStoreViewController.disPlayMsg2(_:)), name:"NotificationIdentifier2", object: nil)
        
        
    }
    
    @IBAction func chooseTime(sender: AnyObject) {
        
        //创建datePicker对象
        let bookingstoredatePick = UIDatePicker(frame: CGRect(x: 5, y: 0, width: UIScreen.mainScreen().bounds.width - 30, height: 260))
        //let bookingstoredatePick = UIDatePicker()
        //设置DatePicker的模式为日期
        bookingstoredatePick.datePickerMode = UIDatePickerMode.Date
        //当Picker的值改变时，添加事件
        bookingstoredatePick.addTarget(self, action: #selector(bookStoreViewController.bookingStoreDateChange(_:)), forControlEvents: UIControlEvents.ValueChanged)
        //用\n给日期腾出位置
        let optionMenu = UIAlertController(title: "请选择预约日期", message: "\n\n\n\n\n\n\n\n\n\n", preferredStyle: .ActionSheet)
        optionMenu.view.addSubview(bookingstoredatePick)
        let cancelAction = UIAlertAction(title: "确定", style: .Cancel, handler: nil)
        optionMenu.addAction(cancelAction)
        self.presentViewController(optionMenu, animated: true, completion: nil)
        self.view.endEditing(true)

    }
   
    @IBAction func chooseOrd(sender: AnyObject) {
        self.performSegueWithIdentifier("bookToOrderList", sender: self)
    }
    
    
    @IBAction func bookItem(sender: AnyObject) {
        self.performSegueWithIdentifier("bookToItemList", sender: self)
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        //可以提前返回以继续键入值
        //print(textField.placeholder)
        if textField == self.bookDate || textField == self.chooseOrder || textField == self.bookItems {
           textField.resignFirstResponder()
        }
        
        return true
    }
    
    //预约维修店时间的事件方法
    func bookingStoreDateChange(sender : UIDatePicker){
        let df = NSDateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        bookDate.text = df.stringFromDate(sender.date)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
 
    
    @IBAction func summit(sender: AnyObject) {
        self.navigationController?.view.makeToast("提交成功！")
    }
    
    func disPlayMsg(notification:NSNotification){
        chooseOrder.text = "订单号 \(notification.object as! String)"
        
    }
    
    func disPlayMsg2(notification:NSNotification){
        bookItems.text = notification.object as? String
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
