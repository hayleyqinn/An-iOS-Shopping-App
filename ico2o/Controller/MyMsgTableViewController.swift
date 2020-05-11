//
//  MyMsgTableViewController.swift
//  ico2o
//
//  Created by Katherine on 15/11/17.
//  Copyright © 2015年 chingyam. All rights reserved.
//

import UIKit

class MyMsgTableViewController: UITableViewController, UITextFieldDelegate, UIAlertViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    /*data：存储页面中的数据
    sexBtn、sexBtn2:性别单选按钮（男，女）
    sex：单选按钮的选中状态
    changePwd,changeMsg:修改密码、修改基本信息
    newPwdText:更改密码时新密码的暂存字符串，作校验用
    */
    var data:[String] = []
    var sexBtn = UIButton()
    var sexBtn2 = UIButton()
    var changePwd = UIButton(),changeMsg = UIButton()
    let titleText = ["登录账号：","性别：","Email：","手机号码："]
    var newPwdText = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        data = dataInit()
        //分隔单元格的横线
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }

    //初始化数据
    func dataInit()->[String] {
        let account = "QQ_CB88"
        let email = "127548634@qq.com"
        let tele = "13856742016"
        let sex = "男"
        let datalist = ["main_bottom_tab_mine_focus.png",account,sex,email,tele]
        return datalist
    }
    
    //各按钮的点击事件
    func btnClicked(btn:UIButton){
        let cells = tableView.visibleCells
        //1:修改头像,2:修改密码,3:基本,4、5:单选按钮，6:退出登录
        switch btn.tag {
        case 1:
            let alertV = UIAlertView(title: "", message: "上传图片", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "拍照","从相册选择" )
            alertV.tag = 0
            alertV.show()
        case 2:
            let alertV = UIAlertView(title: "请输入原密码", message: "", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定")
            alertV.alertViewStyle = UIAlertViewStyle.SecureTextInput
            alertV.tag = 1
            alertV.show()
        case 3:
            //先取得可修改的信息的textfield
            var tf:[UITextField] = []
            for i in 0..<cells.count {
                if i == 4 || i == 5 {
                    tf.append(cells[i].subviews[0].subviews[1] as! UITextField)
                }
            }
            //修改textfield的可编辑状态和btn的文字（需要修改或修改完成），根据信息是否为可修改状态显示性别按钮
            for textfield in tf {
                textfield.enabled = !textfield.enabled
                if btn.selected {
                    btn.setTitle("修改基本信息", forState: UIControlState.Normal)
                    textfield.layer.borderWidth = 0
                    if sexBtn.selected {
                        sexBtn2.hidden = true
                    }
                    else {
                        sexBtn.hidden = true
                        sexBtn2.frame = CGRect(x: 140, y: 5, width: 40, height: 20)
                    }
                }
                else {
                    btn.setTitle("确定", forState: UIControlState.Normal)
                    textfield.layer.borderWidth = 1
                    sexBtn.hidden = false
                    sexBtn2.hidden = false
                    sexBtn2.frame = CGRect(x: 190, y: 5, width: 40, height: 20)
                }
            }
            btn.selected = !btn.selected
        //修改性别的单选按钮
        case 4,5:
            if btn.tag == 5 {
                sexBtn.setImage(UIImage(named: "radioBtn_1"), forState: UIControlState.Normal)
                sexBtn.selected = false
            }
            else {
                sexBtn2.setImage(UIImage(named: "radioBtn_1"), forState: UIControlState.Normal)
                sexBtn2.selected = false
            }
            btn.setImage(UIImage(named: "radioBtn_2"), forState: UIControlState.Normal)
            btn.selected = true
        //退出登录
        case 6:
            self.dismissViewControllerAnimated(true, completion: nil)
            NSUserDefaults.standardUserDefaults().setObject(0, forKey: "UserID")
            NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "ModelCode")
            NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "avatar")
            NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "DefaultCar")
        default:
            break
        }
    }
    
    //弹出框的点击事件
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        //0:换头像,1:输入原密码，2:输入新密码，3:确认新密码
        switch alertView.tag {
        case 0:
            if buttonIndex != 0 {
                UploadPicture(buttonIndex)
            }
        case 1:
            if buttonIndex == 1 {
                //pwdCorect:判断用户输入的原密码是否正确
                var pwdCorrect = false
                if alertView.textFieldAtIndex(0)?.text != "" {//待补充检查密码是否正确
                    pwdCorrect = true
                }
                if pwdCorrect {
                    let alertV = UIAlertView(title: "请输入新密码", message: "", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定")
                    alertV.alertViewStyle = UIAlertViewStyle.SecureTextInput
                    alertV.tag = 2
                    alertV.show()
                }
                else {
                    let alertV = UIAlertView(title: nil, message: "密码错误", delegate: nil, cancelButtonTitle: "确定")
                    alertV.show()
                }
            }
        case 2:
            if buttonIndex == 1 {
                if alertView.textFieldAtIndex(0)?.text != "" {
                    newPwdText = (alertView.textFieldAtIndex(0)?.text!)!
                    let alertV = UIAlertView(title: "确认新密码", message: "", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定")
                    alertV.alertViewStyle = UIAlertViewStyle.SecureTextInput
                    alertV.tag = 3
                    alertV.show()
                }
                else {
                    let alertV = UIAlertView(title: nil, message: "新密码不能为空", delegate: self, cancelButtonTitle: "确定")
                    alertV.show()
                }
            }
        case 3:
            if buttonIndex == 1 {
                if alertView.textFieldAtIndex(0)?.text != "" {
                    if alertView.textFieldAtIndex(0)?.text == newPwdText {
                        let alertV = UIAlertView(title: nil, message: "修改成功", delegate: nil, cancelButtonTitle: "确定")
                        alertV.show()
                    }
                    else {
                        let alertV = UIAlertView(title: nil, message: "两次输入不统一，请重新确认", delegate: nil, cancelButtonTitle: "确定")
                        alertV.show()
                    }
                }
                else {
                    let alertV = UIAlertView(title: nil, message: "新密码不能为空", delegate: self, cancelButtonTitle: "确定")
                    alertV.show()
                }
            }
        default:
            break
        }
    }
    
    //打开相机或图库
    func UploadPicture(tag:Int) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true//设置图片可编辑
        //1:打开相机，2:打开图库
        if tag == 1 {
            //先设定sourceType为相机，然后判断相机是否可用（ipod），若不可用则将sourceType设为相片库
            var sourceType = UIImagePickerControllerSourceType.Camera
            if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
                sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            }
            picker.sourceType = sourceType
            
        }
        else if tag == 2 {
            if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary){
                picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                picker.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(picker.sourceType)!
            }
        }
        //进入照相界面
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    //选择好照片后choose后执行的方法
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        //获取头像的imageview
        let imgView = tableView.visibleCells[0].subviews[0].subviews[0] as! UIImageView
        let img = info[UIImagePickerControllerEditedImage] as! UIImage
        imgView.image = img
        let imgData:NSData = UIImageJPEGRepresentation(img, 0)!
        NSUserDefaults.standardUserDefaults().setObject(imgData, forKey: "avatar")
        picker.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    //cancel后执行的方法
    func imagePickerControllerDidCancel(picker: UIImagePickerController){
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    //每一行的具体内容设置
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
            }
        }
        
        //根据不同的section和行进行相应的操作来设置单元格内容
        switch indexPath.row {
        //头像
        case 0:
            let icon = UIImageView(frame: CGRect(x: (screenW / 2 - 45), y: 20, width: 90, height: 90))
            if(NSUserDefaults.standardUserDefaults().valueForKey("avatar") == nil){
                icon.image = UIImage(named: data[0])
            }else{
                let imgData = NSUserDefaults.standardUserDefaults().valueForKey("avatar") as! NSData
                icon.image = UIImage(data: imgData)
            }
            cell?.contentView.addSubview(icon)
        //修改头像按钮
        case 1:
            let changeIcon = UIButton(frame: CGRect(x: (screenW / 2 - 45), y: 0, width: 90, height: 20))
            changeIcon.setTitle("修改头像", forState: UIControlState.Normal)
            changeIcon.titleLabel!.textAlignment = NSTextAlignment.Center
            changeIcon.titleLabel!.font = UIFont.systemFontOfSize(13)
            changeIcon.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
            changeIcon.addTarget(self, action: #selector(MyMsgTableViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            changeIcon.tag = 1
            cell?.contentView.addSubview(changeIcon)
        //登录账号，性别，Email，手机号码
        case 2,3,4,5:
            let labelA = UILabel(frame: CGRect(x: 50, y: 5, width: 70, height: 20))
            labelA.text = titleText[indexPath.row - 2]
            labelA.font = UIFont.systemFontOfSize(13)
            labelA.textAlignment = NSTextAlignment.Right
            cell?.contentView.addSubview(labelA)
            //若是性别行则添加单选框
            //根据用户信息设置按钮的可见度
            if indexPath.row == 3 {
                sexBtn = UIButton(frame: CGRect(x: 140, y: 5, width: 40, height: 20))
                sexBtn.setTitle("男", forState: UIControlState.Normal)
                sexBtn.titleLabel!.textAlignment = NSTextAlignment.Center
                sexBtn.titleLabel!.font = UIFont.systemFontOfSize(13)
                sexBtn.setImage(UIImage(named: "radioBtn_2"), forState: UIControlState.Normal)
                sexBtn.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
                sexBtn.addTarget(self, action: #selector(MyMsgTableViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                sexBtn.selected = true
                sexBtn.hidden = false
                sexBtn.tag = 4
                cell?.contentView.addSubview(sexBtn)
                sexBtn2 = UIButton(frame: CGRect(x: 190, y: 5, width: 40, height: 20))
                sexBtn2.setTitle("女", forState: UIControlState.Normal)
                sexBtn2.titleLabel!.textAlignment = NSTextAlignment.Center
                sexBtn2.titleLabel!.font = UIFont.systemFontOfSize(13)
                sexBtn2.setImage(UIImage(named: "radioBtn_1"), forState: UIControlState.Normal)
                sexBtn2.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
                sexBtn2.addTarget(self, action: #selector(MyMsgTableViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                sexBtn2.selected = false
                sexBtn2.hidden = true
                sexBtn2.tag = 5
                cell?.contentView.addSubview(sexBtn2)
                //若用户性别为女，则隐藏“男”并修改“女”的位置
                if data[indexPath.row - 1] == "女" {
                    sexBtn.setImage(UIImage(named: "radioBtn_1"), forState: UIControlState.Normal)
                    sexBtn.selected = false
                    sexBtn.hidden = true
                    sexBtn2.setImage(UIImage(named: "radioBtn_2"), forState: UIControlState.Normal)
                    sexBtn2.selected = true
                    sexBtn2.hidden = false
                    sexBtn2.frame = CGRect(x: 140, y: 5, width: 40, height: 20)
                }
            }
            //具体内容
            else {
                let textfield = UITextField(frame: CGRect(x: 140, y: 2, width: 150, height: 25))
                textfield.text = data[indexPath.row - 1]
                textfield.font = UIFont.systemFontOfSize(13)
                textfield.textAlignment = NSTextAlignment.Left
                textfield.tag = indexPath.row
                textfield.enabled = false
                textfield.delegate = self
                cell?.contentView.addSubview(textfield)
                //若为手机号码行则只能输入数字
                if indexPath.row == 5 {
                    textfield.keyboardType = UIKeyboardType.PhonePad
                }
            }
        //修改密码，修改基本信息
        case 6:
            changePwd = UIButton(frame: CGRect(x: (screenW / 2 - 110), y: 20, width: 90, height: 30))
            changePwd.setTitle("修改密码", forState: UIControlState.Normal)
            changePwd.titleLabel!.textAlignment = NSTextAlignment.Center
            changePwd.titleLabel!.font = UIFont.systemFontOfSize(13)
            changePwd.layer.cornerRadius = 5.0
            changePwd.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            changePwd.backgroundColor = UIColor(red: 16/255, green: 123/255, blue: 244/255, alpha: 1.0)
            changePwd.addTarget(self, action: #selector(MyMsgTableViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            changePwd.selected = false
            changePwd.tag = 2
            cell?.contentView.addSubview(changePwd)
            changeMsg = UIButton(frame: CGRect(x: (screenW / 2 + 20), y: 20, width: 90, height: 30))
            changeMsg.setTitle("修改基本信息", forState: UIControlState.Normal)
            changeMsg.titleLabel!.textAlignment = NSTextAlignment.Center
            changeMsg.titleLabel!.font = UIFont.systemFontOfSize(13)
            changeMsg.layer.cornerRadius = 5.0
            changeMsg.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            changeMsg.backgroundColor = UIColor.orangeColor()
            changeMsg.addTarget(self, action: #selector(MyMsgTableViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            changeMsg.selected = false
            changeMsg.tag = 3
            cell?.contentView.addSubview(changeMsg)
        //退出登录
        case 7:
            let logout = UIButton(frame: CGRect(x: (screenW / 2 - 60), y: 20, width: 120, height: 30))
            logout.setTitle("退出登录", forState: UIControlState.Normal)
            logout.titleLabel!.textAlignment = NSTextAlignment.Center
            logout.titleLabel!.font = UIFont.systemFontOfSize(13)
            logout.layer.cornerRadius = 5.0
            logout.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            logout.backgroundColor = UIColor.orangeColor()
            logout.addTarget(self, action: #selector(MyMsgTableViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            logout.tag = 6
            cell?.contentView.addSubview(logout)
        default:
            break
        }
        //取消单元格的选中
        cell!.selectionStyle = UITableViewCellSelectionStyle.None
        return cell!
    }

    func textFieldDidEndEditing(textField: UITextField) {
        data[textField.tag - 1] = textField.text!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 120
        case 6,7:
            return 60
        default:
            return 30
        }
    }
    
}
