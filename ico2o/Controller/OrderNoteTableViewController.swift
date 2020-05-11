//
//  OrderNoteTableViewController.swift
//  ico2o
//
//  Created by Katherine on 15/12/16.
//  Copyright © 2015年 chingyam. All rights reserved.
//

import UIKit

class OrderNoteTableViewController: UITableViewController, UIAlertViewDelegate, OrdersHeaderViewDelegate {

    var data:[[String]] = []
    
    //返回上一页
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        data = dataInit()
    }

    func dataInit()->[[String]] {
        //预约单号，预约日期，店铺名称，店铺地址，电话，保养项目，工时费，订单状态
        let dataList = [["2015122515872","2015/12/25","爱车在线广州人和店","广州市白云区人和镇鹤亭村鹤亭西路28号裕隆商业大楼","020-123456789","小保养，换雨刷","230.00","等待确认"],["2015122515872","2015/12/25","爱车在线广州人和店","广州市白云区人和镇鹤亭村鹤亭西路28号裕隆商业大楼","020-123456789","小保养，换雨刷","230.00","已结案"]]
        return dataList
    }
    
    func btnClicked(btn:UIButton){
        let superview = btn.superview
        //5:订单状态,111:删除记录,222:我要投诉,333:评价
        switch btn.tag {
        case 5:
            break
        case 111:
            data.removeAtIndex((superview?.tag)! / 100)
            tableView.reloadData()
        case 222:
            let alertV = UIAlertView(title: "请输入投诉内容", message: "", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定")
            alertV.alertViewStyle = UIAlertViewStyle.PlainTextInput
            alertV.tag = 1
            alertV.show()
        case 333:
            self.performSegueWithIdentifier("OrderNoteToStoreEvaluate", sender: self)
        default:
            break
        }
    }
    
    //弹出框按钮的点击事件
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        //1:投诉
        switch alertView.tag {
        case 1:
            if buttonIndex == 1 {
                if alertView.textFieldAtIndex(0)?.text != "" {
                    let alertV = UIAlertView(title: nil, message: "提交成功", delegate: self, cancelButtonTitle: "确定")
                    alertV.show()
                }
                else {
                    let alertV = UIAlertView(title: nil, message: "投诉内容不能为空", delegate: self, cancelButtonTitle: "确定")
                    alertV.show()
                }
            }
        default:
            break
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return data.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //设置单元格重用，重用标记为“cell”
        let cellIdentifier = "cell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier)
        }
        //根据tag获取storyboard中的控件
        let storeNameLabel = cell!.viewWithTag(1) as! UILabel!
        let storeAddressLabel = cell!.viewWithTag(2) as! UILabel!
        let storeTelLabel = cell!.viewWithTag(3) as! UILabel!
        let serviceItenLabel = cell!.viewWithTag(4) as! UILabel!
        let orderStateBtn = cell!.viewWithTag(5) as! UIButton
        let storePriceLabel = cell!.viewWithTag(6) as! UILabel!
        
        //预约单号，预约日期，店铺名称，店铺地址，电话，服务项目，工时费
        storeNameLabel.text = data[indexPath.section][2]
        storeAddressLabel.text = "地址:" + data[indexPath.section][3]
        storeTelLabel.text = "电话：" + data[indexPath.section][4]
        serviceItenLabel.text = "服务项目：" + data[indexPath.section][5]
        storePriceLabel.text = data[indexPath.section][6]
        orderStateBtn.setTitle(data[indexPath.section][7], forState: UIControlState.Normal)
        orderStateBtn.addTarget(self, action: #selector(OrderNoteTableViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        cell?.selectionStyle = UITableViewCellSelectionStyle.None
        return cell!
    }
    
    //预约号及删除按钮
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //若无信息则不显示
        if data.count != 0 {
            let screenW = self.view.frame.size.width
            let headerView = OrdersHeaderView(title1: "预约单号", content1: data[section][0], style: OrdersHeaderViewStyle.defaultStyle, delegate: self,indexPath: NSIndexPath(index: section))
            headerView.frame = CGRect(x: 0, y: 0, width: screenW, height: 40)
            headerView.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
            return headerView
        }
        else {
            return nil
        }
    }
    
    //删除整个订单记录
    func OrdersHeaderViewDeleteBtnClicked(headerView: OrdersHeaderView) {
        //先移除数据，再对tableview作处理
        let section = (headerView.indexPath?.section)!
        data.removeAtIndex(section)
        var delayTime:Double = 0
        //订单数目大于1时删除section，并延迟0.25秒reload tableview以更新headerview中的indexpath，否则直接reload
        if data.count != 0 {
            tableView.deleteSections(NSIndexSet(index: section), withRowAnimation: UITableViewRowAnimation.Top)
            delayTime = 0.25
        }
        _ = NSTimer.scheduledTimerWithTimeInterval(delayTime, target: self, selector: #selector(OrderNoteTableViewController.delayReload), userInfo: nil, repeats: false)
    }
    
    func delayReload() {
        tableView.reloadData()
    }
    

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    //预约日期及按钮
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let screenW = self.view.frame.width
        let view = UIView(frame: CGRect(x: 0, y: 0, width: screenW, height: 50))
        view.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
        
        let complain = UIButton(frame: CGRect(x: screenW - 80, y: 10, width: 70, height: 20))
        complain.setTitle("我要投诉", forState: UIControlState.Normal)
        complain.titleLabel!.textAlignment = NSTextAlignment.Center
        complain.titleLabel!.font = UIFont.systemFontOfSize(13)
        complain.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        complain.layer.cornerRadius = 3.0
        complain.backgroundColor = UIColor.orangeColor()
        complain.addTarget(self, action: #selector(OrderNoteTableViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        complain.tag = 222
        view.addSubview(complain)
        //若预约单已结案，则显示“评价”和“晒单”按钮，并修改“我要投诉”的位置
        if data[section][7] == "已结案" {
            complain.frame = CGRect(x: screenW - 140, y: 10, width: 70, height: 20)
            
            let judge = UIButton(frame: CGRect(x: screenW - 60, y: 10, width: 50, height: 20))
            judge.setTitle("评价", forState: UIControlState.Normal)
            judge.titleLabel!.textAlignment = NSTextAlignment.Center
            judge.titleLabel!.font = UIFont.systemFontOfSize(13)
            judge.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            judge.layer.cornerRadius = 3.0
            judge.backgroundColor = UIColor(red: 92/255, green: 208/255, blue: 7/255, alpha: 1.0)
            judge.addTarget(self, action: #selector(OrderNoteTableViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            judge.tag = 333
            view.addSubview(judge)
        }
        
        let date = UILabel(frame: CGRect(x: 10, y: 10, width: screenW - complain.frame.width - 10, height: 20))
        date.text = "预约日期：" + data[section][1]
        date.font = UIFont.systemFontOfSize(14)
        view.addSubview(date)
        
        let line = UIView(frame: CGRect(x: 0, y: 40, width: screenW, height: 10))
        line.backgroundColor = UIColor.whiteColor()
        view.addSubview(line)
        
        view.tag = section * 1000
        return view
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
    }
}
