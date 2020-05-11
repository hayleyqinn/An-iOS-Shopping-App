//
//  CustomerServiceTableViewController.swift
//  ico2o
//
//  Created by Katherine on 15/12/2.
//  Copyright © 2015年 chingyam. All rights reserved.
//

import UIKit
import MessageUI

class CustomerServiceTableViewController: UITableViewController,UIAlertViewDelegate,MFMessageComposeViewControllerDelegate {

    var data:[[String]] = []
    var phoneNumBtn = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        data = dataInit()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }

    func dataInit()->[[String]] {
        let person = ["photo1","豪车时代汽车维修(吉莲店)","付金龙","广东省珠海市香洲区莲兴路银成大厦","0756-8877338","hcsd-ZS"]
        let dataList = [person,person]
        return dataList
    }
    
    func btnClicked(btn:UIButton) {
        //点击电话号码弹出框，可选择电话或短信
        let alterwin = UIAlertView(title: "", message: (btn.titleLabel?.text!)!, delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "发送信息", "呼叫")
        alterwin.show()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        var url = NSURL()
        //0:取消,1:短信,2:呼叫
        switch buttonIndex {
        case 1:
            //url = NSURL(string: "sms://" + (phoneNumBtn.titleLabel?.text!)!)!
            if self.canSendText(){
                let messageVC = self.configuredMessageComposeViewController((phoneNumBtn.titleLabel?.text!)!)
                presentViewController(messageVC, animated: true, completion: nil)
            }
        case 2:
            url = NSURL(string: "tel://" + (phoneNumBtn.titleLabel?.text!)!)!
        default:
            break
        }
        UIApplication.sharedApplication().openURL(url)
    }
    
    
    //实现短信代理
    func canSendText() -> Bool{
        return MFMessageComposeViewController.canSendText()
    }
    //用来指示一条消息能否从用户处发送
    func configuredMessageComposeViewController(num:String) -> MFMessageComposeViewController{
        let messageComposeVC = MFMessageComposeViewController()
        messageComposeVC.messageComposeDelegate = self
        messageComposeVC.body = ""
        messageComposeVC.recipients = [num]
        return messageComposeVC
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let screenW = self.view.frame.size.width
        //设置单元格重用，重用标记为“cell”
        let cellIdentifier = "cell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier)
        }
        
        //清除单元格内容，以免上下滑动后内容重叠
        cell!.textLabel!.text = ""
        for view in cell!.contentView.subviews {
            if view.isKindOfClass(UIButton.self) {
                view.removeFromSuperview()
            } else if view.isKindOfClass(UILabel.self) {
                view.removeFromSuperview()
            } else if view.isKindOfClass(UIImageView.self) {
                view.removeFromSuperview()
            }
        }
        if data.count == 0 {
            let tips = UILabel(frame: CGRect(x: 0, y: 60, width: screenW, height: 25))
            tips.text = "暂无客服数据"
            tips.font = UIFont.systemFontOfSize(14)
            tips.textAlignment = NSTextAlignment.Center
            cell?.contentView.addSubview(tips)
        }
        else {
            //photo：客服照片、storeNameLabel：店铺名称、nameLabel：客服名称、addressLabel：店铺地址、phoneTextLabel：客服电话标签、phoneNumBtn：客服电话、wechatNum：微信
            let photo = UIImageView(frame: CGRect(x: 11, y: 10, width: 68, height: 95))
            photo.image = UIImage(named: data[indexPath.section][0])
            cell?.contentView.addSubview(photo)
            
            let storeNameLabel = UILabel(frame: CGRect(x: 90, y: 10, width: screenW - 130, height: 20))
            storeNameLabel.text = data[indexPath.section][1]
            storeNameLabel.font = UIFont.systemFontOfSize(14)
            storeNameLabel.numberOfLines = 0;
            storeNameLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
            cell?.contentView.addSubview(storeNameLabel)
            
            let nameLabel = UILabel(frame: CGRect(x: screenW - 70, y: 10, width: 60, height: 20))
            nameLabel.text = data[indexPath.section][2]
            nameLabel.font = UIFont.systemFontOfSize(13)
            nameLabel.textAlignment = NSTextAlignment.Right
            cell?.contentView.addSubview(nameLabel)
            
            let addressLabel = UILabel(frame: CGRect(x: 90, y: 35, width: screenW - 100, height: 20))
            addressLabel.text = "地址：" + data[indexPath.section][3]
            addressLabel.font = UIFont.systemFontOfSize(13)
            addressLabel.numberOfLines = 0;
            addressLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
            cell?.contentView.addSubview(addressLabel)
            
            let phoneTextLabel = UILabel(frame: CGRect(x: 90, y: 60, width: 40, height: 20))
            phoneTextLabel.text = "电话："
            phoneTextLabel.font = UIFont.systemFontOfSize(13)
            cell?.contentView.addSubview(phoneTextLabel)
            
            phoneNumBtn = UIButton(frame: CGRect(x: 125, y: 60, width: 100, height: 20))
            phoneNumBtn.setTitle(data[indexPath.section][4], forState: UIControlState.Normal)
            phoneNumBtn.titleLabel!.font = UIFont.systemFontOfSize(13)
            phoneNumBtn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            phoneNumBtn.addTarget(self, action: #selector(CustomerServiceTableViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            phoneNumBtn.tag = 1
            cell?.contentView.addSubview(phoneNumBtn)
            
            let wechatNum = UILabel(frame: CGRect(x: 90, y: 85, width: 100, height: 20))
            wechatNum.text = "微信：" + data[indexPath.section][5]
            wechatNum.font = UIFont.systemFontOfSize(13)
            cell?.contentView.addSubview(wechatNum)
            
            let line = UILabel(frame: CGRect(x: 10, y: 114, width: screenW - 20, height: 1))
            line.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
            cell?.contentView.addSubview(line)
            
        }
        
        return cell!
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 115
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if data.count == 0 {
            return 1
        }
        else {
            return data.count
        }
    }


}
