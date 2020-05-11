//
//  ReserveProductsTableViewController.swift
//  ico2o
//
//  Created by Katherine on 15/12/3.
//  Copyright © 2015年 chingyam. All rights reserved.
//

import UIKit

class ReserveProductsTableViewController: UITableViewController {
    
    var data:[[[[String]]]] = []
    //返回上一页
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        data = dataInit()
    }

    func dataInit()->[[[[String]]]] {
        let orderDetail = ["good1","专用于海马M3鲨鱼鳍天线 m3改装配件天线 ramble收音机汽车天线收音机汽车天线","20.00","38.00","1","2016年2月12日"]
        let orderNum = [["15524783510001"]]
        let orderState1 = [["已到货"]]
        let orderState2 = [["途中"]]
        let dataList = [
            [orderNum,orderState1,[orderDetail]],
                        [orderNum,orderState2,[orderDetail,orderDetail]]]
        return dataList
    }
    
    //btn的点击事件
    func btnClicked(btn:UIButton) {
        //若大于999则为“支付余额”按钮
        if btn.tag > 999 {
            //得到当前btn所在的cell及indexPath
            let cell = btn.superview?.superview as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        //若无订单数据则显示无订单
        if data.count == 0 {
            return 1
        }
        else {
            return data.count
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if data.count == 0 {
            return 1
        }
        else {
            return data[section][2].count
        }
        
    }

    //订单号及订单状态栏
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //若无信息则不显示
        if data.count != 0 {
            let screenW = self.view.frame.size.width
            var orderState = ""
            orderState = data[section][1][0][0]
            if data[section][1][0][0] == "已到货" {
                orderState = data[section][1][0][0] + "(请支付余额)"
            }
            let headerView = OrdersHeaderView(title1: "订单号", content1: data[section][0][0][0], title2: "状态", content2: orderState, indexPath: NSIndexPath(index: section))
            headerView.frame = CGRect(x: 0, y: 0, width: screenW, height: 40)
            headerView.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
            return headerView
        }
        else {
            return nil
        }
    }
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
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
        for view in cell!.contentView.subviews {
            if view.isKindOfClass(UIImageView.self) {
                view.removeFromSuperview()
            }
            else if view.isKindOfClass(UILabel.self) {
                view.removeFromSuperview()
            }
        }
        let screenW = self.view.frame.size.width
        
        //若无订单数据则显示无订单，否则显示订单信息
        if data.count == 0 {
            let tips = UILabel(frame: CGRect(x: 0, y: 0, width: screenW, height: 60))
            tips.text = "暂无订单"
            tips.font = UIFont.systemFontOfSize(14)
            tips.textAlignment = NSTextAlignment.Center
            cell?.contentView.addSubview(tips)
        }
        else {
            //pic:商品图片,name:商品名称,dateL：日期标签，date：具体日期,paied:已付货款，moneylast：未付货款，countL：商品数量,pay:支付余款
            let pic = UIImageView(frame: CGRect(x: 5, y: 10, width: 70, height: 70))
            pic.image = UIImage(named: data[indexPath.section][2][indexPath.row][0])
            cell?.contentView.addSubview(pic)
            
            let name = UILabel(frame: CGRect(x: 80, y: 10, width: screenW - 90, height: 20))
            name.text = data[indexPath.section][2][indexPath.row][1]
            name.font = UIFont.systemFontOfSize(14)
            cell?.contentView.addSubview(name)
            
//            let dateL = UILabel(frame: CGRect(x: 80, y: 30, width: 90, height: 20))
//            dateL.text = "预计到货日期:"
//            dateL.font = UIFont.systemFontOfSize(14)
//            cell?.contentView.addSubview(dateL)
//            
//            let date = UILabel(frame: CGRect(x: 170, y: 30, width: 100, height: 20))
//            date.text = data[indexPath.section][2][indexPath.row][5]
//            date.font = UIFont.systemFontOfSize(13)
//            date.textColor = UIColor.redColor()
//            cell?.contentView.addSubview(date)
            
            let paied = UILabel(frame: CGRect(x: 80, y: 50, width: 80, height: 20))
            paied.text = "已付款:" + String(format: "%.2f", Float(data[indexPath.section][2][indexPath.row][2])!)
            paied.font = UIFont.systemFontOfSize(13)
            paied.textColor = UIColor.redColor()
            cell?.contentView.addSubview(paied)
            
            let moneyLast = UILabel(frame: CGRect(x: 80, y: 70, width: 80, height: 20))
            moneyLast.text = "未付款:" + String(format: "%.2f", Float(data[indexPath.section][2][indexPath.row][3])!)
            moneyLast.font = UIFont.systemFontOfSize(13)
            moneyLast.textColor = UIColor.redColor()
            cell?.contentView.addSubview(moneyLast)
            
            let countL = UILabel(frame: CGRect(x: screenW - 90, y: 45, width: 80, height: 20))
            countL.text = "数量:" + data[indexPath.section][2][indexPath.row][4]
            countL.font = UIFont.systemFontOfSize(13)
            countL.textAlignment = NSTextAlignment.Right
            cell?.contentView.addSubview(countL)
            
            let pay = UIButton(frame: CGRect(x: (screenW - 65), y: 70, width: 60, height: 20))
            pay.backgroundColor = UIColor.grayColor()
            pay.enabled = false
            //若状态为已到货，则将“支付余额”按钮设置为可点击
            if data[indexPath.section][1][0][0] == "已到货" {
                pay.backgroundColor = UIColor(red: 39/255, green: 124/255, blue: 252/255, alpha: 1.0)
                pay.enabled = true
            }
            pay.setTitle("支付余款", forState: UIControlState.Normal)
            pay.titleLabel!.font = UIFont.systemFontOfSize(13)
            pay.titleLabel?.textAlignment = NSTextAlignment.Center
            pay.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            pay.layer.cornerRadius = 3.0
            pay.addTarget(self, action: #selector(ReserveProductsTableViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            pay.tag = indexPath.row * 1000
            cell?.contentView.addSubview(pay)
            
            let line = UILabel(frame: CGRect(x: 0, y: 95, width: screenW, height: 2))
            line.backgroundColor = UIColor.whiteColor()
            cell?.contentView.addSubview(line)
        }
        cell?.selectionStyle = UITableViewCellSelectionStyle.None
        cell?.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 97
    }
        
}
