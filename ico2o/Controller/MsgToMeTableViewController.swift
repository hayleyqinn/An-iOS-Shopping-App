//
//  MsgToMeTableViewController.swift
//  ico2o
//
//  Created by Katherine on 15/12/11.
//  Copyright © 2015年 chingyam. All rights reserved.
//

import UIKit

class MsgToMeTableViewController: UITableViewController {
    /*msg:存放留言信息数据
    systemMsg:存放系统信息数据
    first:留言信息的按钮
    second:系统信息的按钮
    choose:当前选择的信息分类：1为留言，2为系统信息
    */
    var data:[[String]] = []
    var msg:[[String]] = []
    var systemMsg:[[String]] = []
    var first = UIButton()
    var second = UIButton()
    var choose = 1
    
    //返回上一页
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //默认先显示留言信息
        data = dataInit(1)
    }

    //传入数据为当前选择的信息分类：1为留言，2为系统信息
    func dataInit(num:Int)->[[String]] {
        var dataList:[[String]] = []
        if num == 1 {
            msg = [["photo1","Helen","2015-12-14 06:25:30","喜欢了你的博文《你知道防冻液多久换一次吗？99%的人都想错了"],["photo1","Helen","2015-12-14 06:25:30","喜欢了你的博文《你知道防冻液多久换一次吗？99%的人都想错了"]]
            dataList = msg
        }
        else {
            systemMsg = [["photo1","管理员","2015-12-10 06:25:30","欢迎新用户注册"]]
            dataList = systemMsg
        }
        return dataList
    }
    
    //btn的点击事件
    func btnClicked(btn:UIButton) {
        //1:留言，2:系统信息
        //将当前选中的背景颜色设置为白色，另一个为灰色，将需显示的数据设为相应得内容
        if btn.tag == 1 {
            choose = 1
            second.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
        }
        else {
            choose = 2
            first.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
        }
        btn.backgroundColor = UIColor.whiteColor()
        let total = [msg,systemMsg]
        if total[btn.tag - 1].count == 0 {
            data = dataInit(btn.tag)
        }
        else {
            data = total[btn.tag - 1]
        }
        tableView.reloadData()
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

    //留言按钮、系统信息按钮
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let screenW = self.view.frame.width
        let view = UIView(frame: CGRect(x: 0, y: 0, width: screenW, height: 40))
        
        first = UIButton(frame: CGRect(x: 0, y: 0, width: screenW / 2, height: 40))
        first.setTitle("留   言", forState: UIControlState.Normal)
        first.titleLabel!.textAlignment = NSTextAlignment.Center
        first.titleLabel!.font = UIFont.systemFontOfSize(17)
        first.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        first.backgroundColor = UIColor.whiteColor()
        first.addTarget(self, action: #selector(MsgToMeTableViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        first.tag = 1
        view.addSubview(first)
        
        second = UIButton(frame: CGRect(x: screenW / 2, y: 0, width: screenW / 2, height: 40))
        second.setTitle("系统消息", forState: UIControlState.Normal)
        second.titleLabel!.textAlignment = NSTextAlignment.Center
        second.titleLabel!.font = UIFont.systemFontOfSize(17)
        second.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        second.layer.cornerRadius = 3.0
        second.backgroundColor = UIColor.whiteColor()
        second.addTarget(self, action: #selector(MsgToMeTableViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        second.tag = 2
        view.addSubview(second)
        
        if choose == 1 {
            second.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
        }
        else {
            first.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
        }
        return view
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    //点击查看详细信息
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        <#code#>
//    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let screenW = self.view.frame.width
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
            } else if view.isKindOfClass(UILabel.self) {
                view.removeFromSuperview()
            }
        }
        //头像、用户名、日期、信息内容
        let pic = UIImageView(frame: CGRect(x: 10, y: 15, width: 50, height: 50))
        pic.image = UIImage(named: data[indexPath.row][0])
        cell?.contentView.addSubview(pic)
        
        let name = UILabel(frame: CGRect(x: 70, y: 15, width: screenW - 70, height: 20))
        name.text = data[indexPath.row][1]
        name.font = UIFont.systemFontOfSize(16)
        name.textColor = UIColor.blueColor()
        cell?.contentView.addSubview(name)
        
        let date = UILabel(frame: CGRect(x: screenW - 150, y: 15, width: 140, height: 20))
        date.text = data[indexPath.row][2]
        date.font = UIFont.systemFontOfSize(13)
        date.textColor = UIColor.grayColor()
        date.textAlignment = NSTextAlignment.Right
        cell?.contentView.addSubview(date)
        
        let content = UILabel(frame: CGRect(x: 70, y: 40, width: screenW - 70, height: 20))
        content.text = data[indexPath.row][3]
        content.font = UIFont.systemFontOfSize(15)
        content.textColor = UIColor.grayColor()
        cell?.contentView.addSubview(content)
        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    //滑动删除
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath){
        //删除数据源的对应数据
        data.removeAtIndex(indexPath.row)
        //删除对应的cell
        self.tableView?.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top)
    }
    //把delete改成中文
    override func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String {
        return "删除"
    }
 
}
