//
//  ProcurementTableViewController.swift
//  ico2o
//
//  Created by Katherine on 15/11/30.
//  Copyright © 2015年 chingyam. All rights reserved.
//

import UIKit
import Alamofire
import JSONNeverDie

class ProcurementTableViewController: UITableViewController,ChangeCountAlertViewDelegate {
    /*data:页面所显示的数据内容
    textSize:页面字体大小
    count:显示商品数量的btn
    alterwin:点击数量btn后供用户改变数量的弹出框
    countText：商品数量
    checkBtn:是否全部到货后统一发货的复选框
    */
    var data:[[String]] = []
    let textSize:CGFloat = 13
    var count = UIButton()
    var alterwin:ChangeCountAlterView?
    var countText = ""
    var checkBtn:UIButton?
    
    //返回上一页
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        data = dataInit()
    }

    func dataInit()->[[String]] {
        
        let pic = "good1"
        let name = "专用于海马M3鲨鱼鳍天线 m3改装配件天线 ramble收音机汽车天线收音机汽车天线"
        let date = "2016年12月10日"
        let price = "58.00"
        let count = "1"
        let good = [pic,name,date,price,count]
        let goods = [good,good,good,good]
        return goods
    }
    
    //btn的点击事件
    func btnClicked(btn:UIButton) {
        //1:数量，110:底部复选框，111:提交申请
        switch btn.tag {
        case 1:
            alterwin = ChangeCountAlterView(title:"修改商品数量", account:1,delegate: self)
            alterwin!.show()
            count = btn
        case 110:
            //根据选中情况设置图片
            if btn.selected {
                btn.setImage(UIImage(named: "check1"), forState: UIControlState.Normal)
            }
            else {
                btn.setImage(UIImage(named: "check2"), forState: UIControlState.Normal)
            }
            btn.selected = !btn.selected
        case 111:
            //若复选框已勾选
            if ((checkBtn?.selected) != nil) {
                
            }
            else {
                
            }
            break
        default:
            break
        }
    }
    
    //点击改变数量弹出框中的确定按钮后
    func selectOkButtonalertView() {
        countText = String(alterwin!.account)
        count.setTitle(countText, forState: UIControlState.Normal)
        let cell = count.superview?.superview as! UITableViewCell
        let row = tableView.indexPathForCell(cell)?.row
        data[row!][4] = countText
        if countText == "" {
            count.setTitle("1", forState: UIControlState.Normal)
            data[row!][4] = "1"
        }
        let price = cell.subviews[0].subviews[4] as! UILabel
        price.text = "¥" + String(format: "%.2f", Float(data[row!][3])! * Float(
            data[row!][4])!)
        changeFootersData()
    }
    
    //更改footerview的数据
    func changeFootersData() {
        //部分删除后的cell仍然存在
        let cells = tableView.visibleCells
        //amount:商品数量,totalP:商品总价
        var amount = 0
        var totalP:Float = 0
        let views = cells[0].subviews[0].subviews
        for i in 0..<cells.count {
            amount += Int(data[i][4])!
            totalP += Float(Float(data[i][3])! * Float(Float(data[i][4])!))
        }
        let footer = tableView.tableFooterView!
        let finalMsg = footer.subviews[0] as! UILabel
        finalMsg.text = "共 " + String(amount) + " 件商品合计：¥" + String(format: "%.2f", totalP) + "元（不含运费）"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        for view in cell!.contentView.subviews {
            if view.isKindOfClass(UIImageView.self) {
                view.removeFromSuperview()
            }
            else if view.isKindOfClass(UILabel.self) {
                view.removeFromSuperview()
            }
            else if view.isKindOfClass(UIButton.self) {
                view.removeFromSuperview()
            }
        }
        let screenW = self.view.frame.size.width
        
        //pic:商品图片,name:商品名称,dateL:预计到货日期的标签,date:预计到货日期，price:价格,count:商品数量
        let pic = UIImageView(frame: CGRect(x: 5, y: 10, width: 70, height: 70))
        pic.image = UIImage(named: data[indexPath.row][0])
        cell!.contentView.addSubview(pic)
        
        let name = UILabel(frame: CGRect(x: 80, y: 10, width: screenW - 140, height: 35))
        name.text = data[indexPath.row][1]
        name.font = UIFont.systemFontOfSize(textSize)
        name.numberOfLines = 0;
        name.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cell!.contentView.addSubview(name)
        
//        let dateL = UILabel(frame: CGRect(x: 80, y: 45, width: 95, height: 20))
//        dateL.text = "预计到货日期:"
//        dateL.font = UIFont.systemFontOfSize(textSize)
//        cell!.contentView.addSubview(dateL)
//        
//        let date = UILabel(frame: CGRect(x: 80, y: 65, width: 120, height: 20))
//        date.text = data[indexPath.row][2]
//        date.font = UIFont.systemFontOfSize(textSize)
//        date.textColor = UIColor.redColor()
//        cell!.contentView.addSubview(date)
        
        let price = UILabel(frame: CGRect(x: screenW - 65, y: 20, width: 60, height: 20))
        let a = Float(data[indexPath.row][3])!
        price.text = "¥" + String(format: "%.2f", a)
        price.font = UIFont.systemFontOfSize(textSize)
        price.textAlignment = NSTextAlignment.Right
        price.textColor = UIColor.redColor()
        cell!.contentView.addSubview(price)
        
        count = UIButton(frame: CGRect(x: (screenW - 45), y: 50, width: 40, height: 20))
        count.setTitle(data[indexPath.row][4], forState: UIControlState.Normal)
        count.titleLabel!.textAlignment = NSTextAlignment.Center
        count.titleLabel!.font = UIFont.systemFontOfSize(12)
        count.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        count.backgroundColor = UIColor.whiteColor()
        count.addTarget(self, action: #selector(ProcurementTableViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        count.tag = 1
        cell!.contentView.addSubview(count)
        
        let line = UILabel(frame: CGRect(x: 0, y: 90, width: screenW, height: 2))
        line.backgroundColor = UIColor.whiteColor()
        cell?.contentView.addSubview(line)
        
        cell!.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
        return cell!
    }
    
    //滑动删除
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath){
        //删除数据源的对应数据
        data.removeAtIndex(indexPath.row)
        //删除对应的cell
        self.tableView?.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top)
        changeFootersData()
    }
    //把delete 该成中文
    override func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String {
        return "删除"
    }
    
    //点击商品转跳至商品详情页面
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("ProcurementToGoodDetail", sender: self)
    }
    
    //转跳时传递相应数据
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //点击商品转跳至商品详情页面
        if segue.identifier == "ProcurementToGoodDetail" {
            let receive = (segue.destinationViewController as! UINavigationController)
            let a = receive.viewControllers[0] as! GoodDetailTableViewController
            a.goodMsgFromOther = 0
        }
    }
    
    //底部汇总信息及提交申请栏
    func footerView()->UIView {
        let screenW = self.view.frame.size.width
        let view = UIView(frame: CGRect(x: 0, y: 0, width: screenW, height: 140))
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: screenW, height: 50))
        var account:Int = 0
        var totalP:Float = 0
        for i in 0..<data.count {
            account += Int(data[i][4])!
            totalP += Float(data[i][3])!
        }
        label.text = "共 " + String(account) + " 件商品合计：¥" + String(format: "%.2f", totalP) + "元（不含运费）"
        label.textAlignment = NSTextAlignment.Right
        label.font = UIFont.systemFontOfSize(textSize)
        label.backgroundColor = UIColor.whiteColor()
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        view.addSubview(label)
        
        checkBtn = UIButton(frame: CGRect(x: (screenW - 265) / 2 , y: 80, width: 25, height: 25))
        checkBtn!.setImage(UIImage(named: "check1"), forState: UIControlState.Normal)
        checkBtn!.addTarget(self, action: #selector(ProcurementTableViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        checkBtn!.selected = false
        checkBtn!.tag = 110
        view.addSubview(checkBtn!)
        let tips = UILabel(frame: CGRect(x: (screenW - 265) / 2 + 35, y: 80, width: 160, height: 25))
        tips.text = "是否全部到货后统一发货"
        tips.font = UIFont.systemFontOfSize(textSize + 1)
        view.addSubview(tips)
        
        let nextBtn = UIButton(frame: CGRect(x: (screenW - 256) / 2 + 195, y: 80, width: 70, height: 25))
        nextBtn.setTitle("提交申请", forState: UIControlState.Normal)
        nextBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        nextBtn.backgroundColor = UIColor.orangeColor()
        nextBtn.titleLabel?.textAlignment = NSTextAlignment.Center
        nextBtn.titleLabel?.font = UIFont.systemFontOfSize(textSize + 1)
        nextBtn.layer.cornerRadius = 5.0
        nextBtn.addTarget(self, action: #selector(ProcurementTableViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        nextBtn.tag = 111
        view.addSubview(nextBtn)
        
        return view
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 92
    }
    override func viewDidAppear(animated: Bool) {
        data = dataInit()
        tableView.tableFooterView = footerView()
        tableView.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)

    }
}
