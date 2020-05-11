//
//  personalDetailController.swift
//  ico2o
//
//  Created by 覃红 on 2016/9/23.
//  Copyright © 2016年 chingyam. All rights reserved.
//

import UIKit

class personalDetailController: UITableViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var cell1: UITableViewCell!
    @IBOutlet weak var gender: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var qq: UILabel!
    @IBOutlet weak var wechat: UILabel!
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var Headphoto: UIImageView!
    @IBOutlet weak var nickname: UILabel!

    

    
    var content: String?
    var contentTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let sex = NSUserDefaults.standardUserDefaults().stringForKey("Gender") {
            self.gender.text = sex
        }
        
        
        let singleTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(personalDetailController.imageViewTouch))
        
        Headphoto.addGestureRecognizer(singleTap)


        //print(phone.text)
    }

    
    func imageViewTouch(){
        let optionMenu = UIAlertController(title: nil, message: "更改头像", preferredStyle: .ActionSheet)
        let deleteAction = UIAlertAction(title: "相册", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            //判断设置是否支持图片库
            if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary){
                //初始化图片控制器
                let picker = UIImagePickerController()
                //设置代理
                picker.delegate = self
                //指定图片控制器类型
                picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                //设置是否允许编辑
                //            picker.allowsEditing = editSwitch.on
                //弹出控制器，显示界面
                self.presentViewController(picker, animated: true, completion: {
                    () -> Void in
                })
            }else{
                print("读取相册错误")
            }
        })
        
        let saveAction = UIAlertAction(title: "照相", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.Camera){
                
                //创建图片控制器
                let picker = UIImagePickerController()
                //设置代理
                picker.delegate = self
                //设置来源
                picker.sourceType = UIImagePickerControllerSourceType.Camera
                //允许编辑
                picker.allowsEditing = true
                //打开相机
                self.presentViewController(picker, animated: true, completion: { () -> Void in
                    
                })
            }else{
                debugPrint("找不到相机")
            }
        })
        let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)
        self.presentViewController(optionMenu, animated: true, completion: nil)

    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //待优化
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                self.content = nickname.text!
                self.contentTitle = "昵称"
            }
            
            if indexPath.row == 1 {
                self.content = email.text!
                self.contentTitle = "Email"
            }
            
            if indexPath.row == 2 {
                let optionMenu = UIAlertController(title: nil, message: "请选择你要修改的性别", preferredStyle: .ActionSheet)
                
                let deleteAction = UIAlertAction(title: "男", style: .Default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    self.gender.text = "男"
                    NSUserDefaults.standardUserDefaults().setObject(self.gender.text, forKey: "Gender")
                })
                let saveAction = UIAlertAction(title: "女", style: .Default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    self.gender.text = "女"
                    NSUserDefaults.standardUserDefaults().setObject(self.gender.text, forKey: "Gender")
                })
                let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
                optionMenu.addAction(deleteAction)
                optionMenu.addAction(saveAction)
                optionMenu.addAction(cancelAction)
                self.presentViewController(optionMenu, animated: true, completion: nil)
            }
        }
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                self.content = qq.text!
                self.contentTitle = "QQ"
            }
            
            if indexPath.row == 1 {
                self.content = wechat.text!
                self.contentTitle = "微信"
            }
            
            if indexPath.row == 2 {
                self.content = phone.text
                self.contentTitle = "手机号"
            }
        }
        
        
        
        
        print(self.content)
        self.performSegueWithIdentifier("ToInformmationSetting", sender: self)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    //跳转前传递数据
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ToInformmationSetting" {
            let receive = segue.destinationViewController as! ChangeInformationViewController
            receive.viewTitle = self.contentTitle
            receive.content = self.content
        }
//        if segue.identifier == "orderToDetail" {
//            let receive = segue.destinationViewController as! orderDetailViewController
//            receive.data = data[tempIndex!.section]
//            receive.price = "￥" + "\(priceArr[(tempIndex?.section)!])"
//        }
//        if segue.identifier == "MyOrderToReturnedPurchase" {
//            let receive = (segue.destinationViewController as! UINavigationController)
//            let a = receive.viewControllers[0] as! ReturnedPurchaseTableViewController
//            a.data = data[btnTagForReturnGoods]
//        }
        
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

  
}
