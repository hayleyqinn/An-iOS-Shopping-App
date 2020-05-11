//
//  MyOrderAllTableViewController.swift
//  ico2o
//
//  Created by Katherine on 15/12/1.
//  Copyright © 2015年 chingyam. All rights reserved.
//

import UIKit

class MyOrderAllTableViewController: UITableViewController, OrdersHeaderViewDelegate {
    /*data:页面中显示的订单信息
    radioState:每个订单的选中状态
    dataType:目标数据的类型，共5种："全部", "待付款", "待发货", "待收货", "已评价"
    */
    var data:[[[[String]]]] = []
    var radioState:[Bool] = []
    var dataType = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        data = dataInit()
        radioState = stateInit()
        tableView.tableHeaderView = headerView()
        tableView.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }
    
    //根据dataType加载目标数据
    func dataInit()->[[[[String]]]] {
//        switch dataType {
//        case "全部":
//            break
//        case "待付款":
//            break
//        case "待发货":
//            break
//        case "待收货":
//            break
//        case "已评价":
//            break
//        }
        let pic = ["good1"]
        let name = ["专用于海马M3鲨鱼鳍天线 m3改装配件天线 ramble收音机汽车天线收音机汽车天线"]
        let place = ["白色"]
        let price = ["58.00"]
        let count = ["1"]
        let orderNum = ["15524783510001"]
        let postage = ["10"]
        let good = [orderNum,pic,name,place,price,count,postage]
        let goods = [[good,good],[good,good]]
        return goods
        
    }

    //设置订单的多选按钮的选中的初始状态，默认为false为选中
    func stateInit()->[Bool] {
        var arr:[Bool] = []
        for i in 0..<data.count {
            arr.append(false)
        }
        return arr
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
            return data[section].count
        }
        
    }
    
    //btn的点击事件
    func btnClicked(btn:UIButton){
        //若所点击的为headerview或footerview里的按钮，判断其属于哪一个section
        var section = 0
        if btn.tag == 1 || btn.tag == 2 {
            section = (btn.superview!).tag / 100
        }
        else if btn.tag == 3 || btn.tag == 4 || btn.tag == 5 {
            section = (btn.superview!).tag / 1000
        }
        //111:预约维修店,1:radioBtn,2:删除订单,3:查看物流,4:退换货，5:订单状态修改（付款、评价等）
        switch btn.tag {
        case 111:
            self.performSegueWithIdentifier("MyOrderAllToStoreList", sender: self)
        case 1:
            var img = "radioBtn_2"
            if radioState[section] {
                img = "radioBtn_1"
            }
            btn.setImage(UIImage(named: img), forState: UIControlState.Normal)
            radioState[section] = !radioState[section]
        case 2:
            data.removeAtIndex(section)
            radioState.removeAtIndex(section)
            tableView.reloadData()
        case 3:
            let alertV = UIAlertView(title: "物流信息", message: "物流信息\n物流信息\n物流信息\n物流信息\n物流信息", delegate: nil, cancelButtonTitle: "确定")
            alertV.show()
        case 4:
            self.performSegueWithIdentifier("MyOrderToReturnedPurchase", sender: self)
        case 5:
            if btn.titleLabel!.text == "评价" {
                self.performSegueWithIdentifier("MyOrderToGoodEvaluate", sender: self)
            }
        default:
            break
        }
    }
    
//    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
//        countText = (alertView.textFieldAtIndex(0)?.text)!
//        count.setTitle(countText, forState: UIControlState.Normal)
//        
//    }
    
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
            //pic:商品图片,name:商品名称,kind:属性，price:价格,countL：商品数量
            let pic = UIImageView(frame: CGRect(x: 5, y: 10, width: 70, height: 70))
            pic.image = UIImage(named: data[indexPath.section][indexPath.row][1][0])
            cell?.contentView.addSubview(pic)
            
            let name = UILabel(frame: CGRect(x: 80, y: 10, width: screenW - 145, height: 50))
            name.text = data[indexPath.section][indexPath.row][2][0]
            name.font = UIFont.systemFontOfSize(13)
            name.numberOfLines = 0;
            name.lineBreakMode = NSLineBreakMode.ByWordWrapping
            cell?.contentView.addSubview(name)
            
            let kind = UILabel(frame: CGRect(x: 80, y: 60, width: 80, height: 20))
            kind.text = "属性:" + data[indexPath.section][indexPath.row][3][0]
            kind.font = UIFont.systemFontOfSize(13)
            cell?.contentView.addSubview(kind)
            
            let price = UILabel(frame: CGRect(x: screenW - 75, y: 10, width: 70, height: 20))
            let a = Float(data[indexPath.section][indexPath.row][4][0])!
            price.text = "¥" + String(format: "%.2f", a)
            price.font = UIFont.systemFontOfSize(13)
            price.textAlignment = NSTextAlignment.Right
            cell?.contentView.addSubview(price)
            
            let countL = UILabel(frame: CGRect(x: (screenW - 45), y: 42, width: 40, height: 20))
            countL.text = "x" + data[indexPath.section][indexPath.row][5][0]
            countL.font = UIFont.systemFontOfSize(14)
            countL.textAlignment = NSTextAlignment.Center
            cell?.contentView.addSubview(countL)
            
            let line = UILabel(frame: CGRect(x: 0, y: 90, width: screenW, height: 2))
            line.backgroundColor = UIColor.whiteColor()
            cell?.contentView.addSubview(line)
            
        }
        cell?.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
        return cell!
    }
    
    //点击商品转跳至商品详情
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("OrderDetailToGoodDetail", sender: self)
    }
    
    //订单标题栏
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //若无信息则不显示
        if data.count != 0 {
            let screenW = self.view.frame.size.width
            let headerView = OrdersHeaderView(title1: "订单号", content1: data[section][0][0][0], style: OrdersHeaderViewStyle.radioStyle, delegate: self,indexPath: NSIndexPath(index: section))
            headerView.frame = CGRect(x: 0, y: 0, width: screenW, height: 40)
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
        _ = NSTimer.scheduledTimerWithTimeInterval(delayTime, target: self, selector: Selector("delayReload"), userInfo: nil, repeats: false)
    }
    
    func delayReload() {
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    //订单底部信息及按钮栏
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if data.count != 0 {
        let screenW = self.view.frame.size.width
        let view = UIView(frame: CGRect(x: 0, y: 0, width: screenW, height: 40))
        view.backgroundColor = UIColor.whiteColor()
        var totalCount = 0
        var totalPrice:Float = 0
        for i in 0..<data[section].count {
            totalPrice += Float(data[section][i][4][0])!
            totalCount += Int(data[section][i][5][0])!
        }
        let totalL = UILabel(frame: CGRect(x: 0, y: 10, width: screenW, height: 20))
        totalL.text = "共 " + String(totalCount) + " 件商品  合计：¥" + String(format: "%.2f",totalPrice) + "元（含运费¥" + String(data[section][0][6][0]) + "）"
        totalL.font = UIFont.systemFontOfSize(13)
        totalL.textAlignment = NSTextAlignment.Right
        view.addSubview(totalL)
        
        let line = UILabel(frame: CGRect(x: 0, y: 40, width: screenW, height: 2))
        line.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
        view.addSubview(line)
       
        let deliverBtn = UIButton(frame: CGRect(x: (screenW - 210), y: 52, width: 60, height: 20))
        deliverBtn.setTitle("查看物流", forState: UIControlState.Normal)
        deliverBtn.titleLabel!.textAlignment = NSTextAlignment.Center
        deliverBtn.titleLabel!.font = UIFont.systemFontOfSize(13)
        deliverBtn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        deliverBtn.addTarget(self, action: "btnClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        deliverBtn.tag = 3
        view.addSubview(deliverBtn)
        
        let changeBtn = UIButton(frame: CGRect(x: (screenW - 140), y: 52, width: 60, height: 20))
        changeBtn.setTitle("退换货", forState: UIControlState.Normal)
        changeBtn.titleLabel!.textAlignment = NSTextAlignment.Center
        changeBtn.titleLabel!.font = UIFont.systemFontOfSize(13)
        changeBtn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        changeBtn.addTarget(self, action: "btnClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        changeBtn.tag = 4
        view.addSubview(changeBtn)
        
        let stateBtn = UIButton(frame: CGRect(x: (screenW - 70), y: 47, width: 60, height: 30))
        stateBtn.setTitle("评价", forState: UIControlState.Normal)
        stateBtn.titleLabel!.textAlignment = NSTextAlignment.Center
        stateBtn.titleLabel!.font = UIFont.systemFontOfSize(13)
        stateBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        stateBtn.layer.cornerRadius = 3.0
        stateBtn.backgroundColor = UIColor.orangeColor()
        stateBtn.addTarget(self, action: "btnClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        stateBtn.tag = 5
        view.addSubview(stateBtn)
        
        let line2 = UILabel(frame: CGRect(x: 0, y: 82, width: screenW, height: 10))
        line2.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
        view.addSubview(line2)
        view.tag = section * 1000
        return view
        }
        else {
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 92
    }
    //    //转跳时传递相应数据
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "ShoppingcarToDetail" {
//            let receive = (segue.destinationViewController as! UINavigationController)
//            let a = receive.viewControllers[0] as! GoodDetailTableViewController
//            a.goodMsgFromOther = String(1)
//        }
//    }
    

    
    func headerView()->UIView {
        let screenW = self.view.frame.size.width
        let view = UIView(frame: CGRect(x: 0, y: 0, width: screenW, height: 40))
        view.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
        
        let orderBtn = UIButton(frame: CGRect(x: (screenW - 90), y: 5, width: 80, height: 30))
        orderBtn.setTitle("预约维修店", forState: UIControlState.Normal)
        orderBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        orderBtn.backgroundColor = UIColor.orangeColor()
        orderBtn.titleLabel?.textAlignment = NSTextAlignment.Center
        orderBtn.titleLabel?.font = UIFont.systemFontOfSize(13)
        orderBtn.layer.cornerRadius = 5.0
        orderBtn.addTarget(self, action: "btnClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        orderBtn.tag = 111
        view.addSubview(orderBtn)
        
        return view
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 92
    }

}
