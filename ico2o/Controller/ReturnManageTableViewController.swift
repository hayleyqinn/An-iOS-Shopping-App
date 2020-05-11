//
//  ReturnManageTableViewController.swift
//  ico2o
//
//  Created by Katherine on 15/12/10.
//  Copyright © 2015年 chingyam. All rights reserved.
//

import UIKit

class ReturnManageTableViewController: UITableViewController, UIAlertViewDelegate, OrdersHeaderViewDelegate {
    /*data:页面中显示的订单信息
    */
    var data:[[[[String]]]] = []
    //var headerView:OrdersHeaderView?
    
    //返回上一页
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        data = dataInit()
        tableView.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }
    
    //根据dataType加载目标数据
    func dataInit()->[[[[String]]]] {
        let pic = ["good1"]
        let name = ["专用于海马M3鲨鱼鳍天线 m3改装配件天线 ramble收音机汽车天线收音机汽车天线"]
        let price = ["58.00"]
        let count = ["1"]
        let orderNum = ["15524783510001"]
        let orderNum2 = ["15524783510002"]
        let orderNum3 = ["15524783510003"]
        let state = ["审核中"]
        let good = [orderNum,pic,name,count,price,state]
        let good2 = [orderNum2,pic,name,count,price,state]
        let good3 = [orderNum3,pic,name,count,price,state]
        let goods = [[good,good,good],[good2,good],[good3,good]]
        return goods
        
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
//        var section = 0
//        if btn.tag != 1 {
//            section = (btn.superview!).tag / 1000
//        }
        //1:删除，2:退货说明,3:填写物流号
        switch btn.tag {
//        case 1:
//            print(tableView.headerViewForSection(0))
////            if (btn.superview?.tag)! == (tableView.headerViewForSection(0)!.tag) {
////                print(11111)
////            }
//            data.removeAtIndex(section)
////            tableView.deleteSections(NSIndexSet(index: section), withRowAnimation: UITableViewRowAnimation.Top)
//            tableView.reloadData()
        case 2:
            let alertV = UIAlertView(title: "退货说明", message: "退货说明内容退货说明内容退货说明内容退货说明内容", delegate: nil, cancelButtonTitle: "确定")
            alertV.show()
        case 3:
            let alertV = UIAlertView(title: "填写物流信息", message: "", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定")
            alertV.alertViewStyle = UIAlertViewStyle.LoginAndPasswordInput
            alertV.textFieldAtIndex(0)?.placeholder = "请输入物流公司名称"
            alertV.textFieldAtIndex(1)?.placeholder = "请输入物流号"
            alertV.textFieldAtIndex(1)?.secureTextEntry = false
            alertV.tag = 0
            alertV.show()
        default:
            break
        }
    }
    
    //弹出框按钮点击事件
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        //tag = 0:填写物流信息
        if alertView.tag == 0 && buttonIndex == 1 {
            let company = alertView.textFieldAtIndex(0)?.text
            let number = alertView.textFieldAtIndex(1)?.text
            if company != "" && number != "" {
                let alertV = UIAlertView(title: nil, message: "提交成功", delegate: nil, cancelButtonTitle: "确定")
                alertV.show()
            }
            else {
                let alertV = UIAlertView(title: nil, message: "请输入完整信息", delegate: nil, cancelButtonTitle: "确定")
                alertV.show()
            }
        }
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
            tips.text = "暂无退货记录"
            tips.font = UIFont.systemFontOfSize(14)
            tips.textAlignment = NSTextAlignment.Center
            cell?.contentView.addSubview(tips)
        }
        else {
            //pic:商品图片,name:商品名称,count：商品数量，price:价格
            let pic = UIImageView(frame: CGRect(x: 5, y: 10, width: 70, height: 70))
            pic.image = UIImage(named: data[indexPath.section][indexPath.row][1][0])
            cell?.contentView.addSubview(pic)
            
            let name = UILabel(frame: CGRect(x: 80, y: 10, width: screenW - 90, height: 40))
            name.text = data[indexPath.section][indexPath.row][2][0]
            name.font = UIFont.systemFontOfSize(14)
            name.numberOfLines = 0;
            name.lineBreakMode = NSLineBreakMode.ByWordWrapping
            cell?.contentView.addSubview(name)
            
            let count = UILabel(frame: CGRect(x: 80, y: 55, width: 80, height: 20))
            count.text = "数量：" + data[indexPath.section][indexPath.row][3][0]
            count.font = UIFont.systemFontOfSize(14)
            cell?.contentView.addSubview(count)
            
            let price = UILabel(frame: CGRect(x: screenW - 80, y: 55, width: 70, height: 20))
            let a = Float(data[indexPath.section][indexPath.row][4][0])!
            price.text = "¥" + String(format: "%.2f", a)
            price.font = UIFont.systemFontOfSize(15)
            price.textColor = UIColor.redColor()
            price.textAlignment = NSTextAlignment.Right
            cell?.contentView.addSubview(price)
            
            let line = UILabel(frame: CGRect(x: 0, y: 90, width: screenW, height: 2))
            line.backgroundColor = UIColor.whiteColor()
            cell?.contentView.addSubview(line)
            
        }
        cell?.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
        return cell!
    }
    
    //点击商品转跳至商品详情页面
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("ReturnManageToGoodDetail", sender: self)
    }
    
    //订单标题栏
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //若无信息则不显示
        if data.count != 0 {
            let screenW = self.view.frame.size.width
            let headerView = OrdersHeaderView(title1: "退货号", content1: data[section][0][0][0], style: OrdersHeaderViewStyle.defaultStyle, delegate: self,indexPath: NSIndexPath(index: section))
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
        _ = NSTimer.scheduledTimerWithTimeInterval(delayTime, target: self, selector: #selector(ReturnManageTableViewController.delayReload), userInfo: nil, repeats: false)
    }
    
    func delayReload() {
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    //订单底部信息
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if data.count != 0 {
            let screenW = self.view.frame.size.width
            let view = UIView(frame: CGRect(x: 0, y: 0, width: screenW, height: 40))
            view.backgroundColor = UIColor.whiteColor()
            
            var totalPrice:Float = 0
            for i in 0..<data[section].count {
                totalPrice += Float(data[section][i][4][0])!
            }
            let date = UILabel(frame: CGRect(x: 5, y: 10, width: 155, height: 20))
            date.text = "申请日期:" + "2015年12月20日"
            date.font = UIFont.systemFontOfSize(13)
            view.addSubview(date)
            
            let money = UILabel(frame: CGRect(x: 170, y: 10, width: screenW - 175, height: 20))
            money.text = "退货金额：" + String(format: "%.2f", totalPrice) + "元"
            money.font = UIFont.systemFontOfSize(13)
            money.textAlignment = NSTextAlignment.Right
            view.addSubview(money)
            
            let line = UILabel(frame: CGRect(x: 0, y: 40, width: screenW, height: 2))
            line.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
            view.addSubview(line)
            
            let descript = UIButton(frame: CGRect(x: (screenW - 300), y: 52, width: 100, height: 20))
            descript.setTitle("我的退货说明", forState: UIControlState.Normal)
            descript.titleLabel!.font = UIFont.systemFontOfSize(13)
            descript.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            descript.addTarget(self, action: #selector(ReturnManageTableViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            descript.tag = 2
            view.addSubview(descript)
            
            let num = UIButton(frame: CGRect(x: (screenW - 190), y: 52, width: 70, height: 20))
            num.setTitle("填写物流号", forState: UIControlState.Normal)
            num.titleLabel!.font = UIFont.systemFontOfSize(13)
            num.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            num.addTarget(self, action: #selector(ReturnManageTableViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            num.tag = 3
            view.addSubview(num)
            
            
            let stateL = UILabel(frame: CGRect(x: (screenW - 110), y: 52, width: 40, height: 20))
            stateL.text = "状态："
            stateL.font = UIFont.systemFontOfSize(13)
            stateL.textAlignment = NSTextAlignment.Right
            view.addSubview(stateL)
            
            let stateBtn = UIButton(frame: CGRect(x: (screenW - 70), y: 47, width: 60, height: 30))
            stateBtn.setTitle(data[section][0][5][0], forState: UIControlState.Normal)
            stateBtn.titleLabel!.textAlignment = NSTextAlignment.Center
            stateBtn.titleLabel!.font = UIFont.systemFontOfSize(14)
            stateBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            stateBtn.layer.cornerRadius = 3.0
            stateBtn.backgroundColor = UIColor.orangeColor()
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
    

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 92
    }
}
