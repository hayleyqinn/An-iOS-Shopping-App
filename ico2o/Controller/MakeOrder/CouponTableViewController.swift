//
//  CouponTableViewController.swift
//  ico2o
//
//  Created by Katherine on 15/12/15.
//  Copyright © 2015年 chingyam. All rights reserved.
//

import UIKit
//类似于OC中的typedef
typealias sendValueClosure=(string:String)->Void

class CouponTableViewController: UITableViewController {

    var data:[String] = []
    //声明一个闭包
    var myClosure:sendValueClosure?
    //下面这个方法需要传入上个界面的someFunctionThatTakesAClosure函数指针
    func initWithClosure(closure:sendValueClosure?){
        //将函数指针赋值给myClosure闭包，该闭包中涵盖了someFunctionThatTakesAClosure函数中的局部变量等的引用
        myClosure = closure
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        data = dataInit()
    }

    func dataInit()->[String] {
        let dataList = ["不使用优惠券"]
        return dataList
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //点击返回优惠券信息至确认订单页面
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //判空
        if (myClosure != nil){
            //闭包隐式调用someFunctionThatTakesAClosure函数：回调。
            myClosure!(string: (tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text)!)
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //设置单元格重用，重用标记为“cell”
        let cellIdentifier = "cell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier)
        }
        
        //清除单元格内容，以免上下滑动后内容重叠
        cell!.textLabel!.text = ""
        
        cell?.textLabel?.text = data[indexPath.row]
        return cell!
    }
}
