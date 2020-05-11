//
//  BookingStoreViewController.swift
//  ico2o
//
//  Created by Katherine on 15/12/12.
//  Copyright © 2015年 chingyam. All rights reserved.
//

import UIKit

class BookingStoreViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var bookingStoreDateTextField: UITextField!
    /*titleText：每行数据的标题
    itemNameSelected:存放已选择的预约项目数据
    otherMsg：存放除预约项目以外的内容
    */
    let titleText = ["车牌号","手机号码","预约日期","联系人","预约项目","维修店","预约描述"]
    var itemNameSelected:[String] = []
    var otherMsg:[String] = ["","","2","","1",""]
    var itemPartHeight = 40
    var storeSelected:CarShopModel?
    
    //返回上一页
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        //创建datePicker对象
        let bookingstoredatePick = UIDatePicker()
        //设置DatePicker的模式为日期
        bookingstoredatePick.datePickerMode = UIDatePickerMode.Date
        //当Picker的值改变时，添加事件
        bookingstoredatePick.addTarget(self, action: #selector(BookingStoreViewController.bookingStoreDateChange(_:)), forControlEvents: UIControlEvents.ValueChanged)
    }

    //预约维修店时间的事件方法
    func bookingStoreDateChange(sender : UIDatePicker){
        let df = NSDateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        bookingStoreDateTextField.text = df.stringFromDate(sender.date)
    }
    
    func btnClicked(btn:UIButton) {
        //111:选择维修店,222:提交，333:增加项目，444:预约日期，default:保养项目的删除按钮
        switch btn.tag {
        case 111://未完成
            self.performSegueWithIdentifier("BookingToStoreList", sender: self)
        case 222:
            //判断信息是否填写完整，是则可提交
            var nextTag = true
            if itemNameSelected.count == 0 {
                let alertV = UIAlertView(title: nil, message: "请填写完整预约信息", delegate: nil, cancelButtonTitle: "确定")
                alertV.show()
                nextTag = false
            }
            else {
                for i in 0..<(otherMsg.count - 1) {//预约描述可为空
                    if otherMsg[i] == "" {
                        let alertV = UIAlertView(title: nil, message: "请填写完整预约信息", delegate: nil, cancelButtonTitle: "确定")
                        alertV.show()
                        nextTag = false
                        break
                    }
                }
            }
            if nextTag {
                let alertV = UIAlertView(title: nil, message: "提交成功", delegate: nil, cancelButtonTitle: "确定")
                alertV.show()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        case 333:
            itemNameSelected.append("item")
            tableView.reloadData()
        case 444:
            //bookingStoreDateChange(UIDatePicker)
            break
        default:
            print(itemPartHeight)
            itemNameSelected.removeAtIndex(btn.tag)
            itemPartHeight -= 30
            tableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
   
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 5
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 4
        case 1,2,3,4:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 45
        case 1:
            return CGFloat(itemPartHeight)
        case 2:
            return 50
        case 3:
            return 150
        case 4:
            return 70
        default:
            return 0
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
            if view.isKindOfClass(UITextField.self) || view.isKindOfClass(UILabel.self) || view.isKindOfClass(UIButton.self) || view.isKindOfClass(UITextView.self) {
                view.removeFromSuperview()
            }
        }
        let screenW = self.view.frame.width
        switch indexPath.section {
        case 0:
            let title = UILabel(frame: CGRect(x: 10, y: 10, width: 60, height: 25))
            title.text = titleText[indexPath.row]
            title.font = UIFont.systemFontOfSize(15)
            title.textAlignment = NSTextAlignment.Center
            cell?.contentView.addSubview(title)
            
            let textField = UITextField(frame: CGRect(x: 80, y: 7, width: 180, height: 30))
            textField.layer.borderWidth = 1
            textField.layer.cornerRadius = 3.0
            textField.delegate = self
            textField.text = otherMsg[indexPath.row]
            textField.tag = indexPath.row
            cell?.contentView.addSubview(textField)
            //1:手机号码行，只能输入数字，预约日期点击弹出选择
            if indexPath.row == 1{
                textField.keyboardType = UIKeyboardType.NumberPad
            }
            else if indexPath.row == 2 {
                textField.removeFromSuperview()
                let date = UIButton(frame: CGRect(x: 80, y: 7, width: 180, height: 25))
                date.setTitle("", forState: UIControlState.Normal)
                date.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
                date.titleLabel?.font = UIFont.systemFontOfSize(14)
                date.addTarget(self, action: #selector(BookingStoreViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                date.layer.borderWidth = 1
                date.tag = 444
                cell?.contentView.addSubview(date)
            }
            if indexPath.row != 3 {
                let star = UILabel(frame: CGRect(x: 270, y: 10, width: 20, height: 20))
                star.text = "*"
                star.font = UIFont.systemFontOfSize(15)
                star.textColor = UIColor.redColor()
                cell?.contentView.addSubview(star)
            }
        case 1:
            let title = UILabel(frame: CGRect(x: 10, y: 10, width: 60, height: 20))
            title.text = titleText[4]
            title.font = UIFont.systemFontOfSize(15)
            title.textAlignment = NSTextAlignment.Center
            cell?.contentView.addSubview(title)
            
            let addItem = UIButton(frame: CGRect(x: 80, y: 10, width: 100, height: 20))
            addItem.setTitle("增加项目：", forState: UIControlState.Normal)
            addItem.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
            addItem.titleLabel?.font = UIFont.systemFontOfSize(15)
            addItem.addTarget(self, action: #selector(BookingStoreViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            addItem.tag = 333
            cell?.contentView.addSubview(addItem)
            //所添加的项目名及其删除按钮
            for i in 0..<itemNameSelected.count {
                let text = itemNameSelected[i] + String(i)
                let length = text.calculateTextWidth(UIFont.systemFontOfSize(14))
                let itemName = UILabel(frame: CGRectMake(80, CGFloat(40 + 35 * i), length, 20))
                itemName.text = itemNameSelected[i]
                itemName.font = UIFont.systemFontOfSize(15)
                cell?.contentView.addSubview(itemName)
                
                let delete = UIButton(frame: CGRectMake(90 + length, CGFloat(40 + 30 * i), 20, 20))
                delete.setImage(UIImage(named: "delete"), forState: UIControlState.Normal)
                delete.tag = i
                delete.addTarget(self, action: #selector(BookingStoreViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                cell?.contentView.addSubview(delete)
            }
            //添加以后更改该行的高度
            itemPartHeight = 40 + (30 * itemNameSelected.count)
        case 2:
            let title = UILabel(frame: CGRect(x: 10, y: 10, width: 60, height: 20))
            title.text = titleText[5]
            title.font = UIFont.systemFontOfSize(15)
            title.textAlignment = NSTextAlignment.Center
            cell?.contentView.addSubview(title)
            
            let chooseStore = UIButton(frame: CGRect(x: 80, y: 10, width: 40, height: 20))
            chooseStore.setTitle("选择", forState: UIControlState.Normal)
            chooseStore.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
            chooseStore.titleLabel?.font = UIFont.systemFontOfSize(15)
            chooseStore.addTarget(self, action: #selector(BookingStoreViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            chooseStore.tag = 111
            cell?.contentView.addSubview(chooseStore)
            
            if storeSelected != nil {
                var w = storeSelected?.garage.calculateTextWidth(UIFont.systemFontOfSize(15))
                if w > (screenW - 140) {
                    w = screenW - 140
                }
                let store = UILabel(frame: CGRect(x: 80, y: 10, width: w!, height: 20))
                store.text = storeSelected!.garage
                store.font = UIFont.systemFontOfSize(15)
                cell?.contentView.addSubview(store)
                
                chooseStore.frame = CGRect(x: 95 + w!, y: 10, width: 40, height: 20)
            }
        case 3:
            let title = UILabel(frame: CGRect(x: 10, y: 10, width: 60, height: 20))
            title.text = titleText[6]
            title.font = UIFont.systemFontOfSize(15)
            cell?.contentView.addSubview(title)
            
            let description = UITextView(frame: CGRect(x: 10, y: 35, width: self.view.frame.width - 20, height: 80))
            description.layer.borderWidth = 1
            description.layer.cornerRadius = 3.0
            description.font = UIFont.systemFontOfSize(15)
            cell?.contentView.addSubview(description)
            
            let tips = UILabel(frame: CGRect(x: 10, y: 115, width: 100, height: 20))
            tips.text = "*限制500字以内"
            tips.font = UIFont.systemFontOfSize(14)
            tips.textColor = UIColor.redColor()
            cell?.contentView.addSubview(tips)
        case 4:
            let submit = UIButton(frame: CGRect(x: (self.view.frame.width - 80) / 2, y: 20, width: 80, height: 30))
            submit.setTitle("提交", forState: UIControlState.Normal)
            submit.titleLabel!.textAlignment = NSTextAlignment.Center
            submit.titleLabel!.font = UIFont.systemFontOfSize(15)
            submit.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            submit.layer.cornerRadius = 3.0
            submit.backgroundColor = UIColor.orangeColor()
            submit.addTarget(self, action: #selector(BookingStoreViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            submit.tag = 222
            cell?.contentView.addSubview(submit)
        default:
            break
        }
        cell?.selectionStyle = UITableViewCellSelectionStyle.None
        return cell!
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        otherMsg[textField.tag] = textField.text!
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        otherMsg[5] = textView.text
    }
}
