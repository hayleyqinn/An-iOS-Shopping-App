//
//  GoodEvaluateTableViewController.swift
//  ico2o
//
//  Created by Katherine on 16/1/14.
//  Copyright © 2016年 chingyam. All rights reserved.
//

import UIKit

class GoodEvaluateTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate, UITextViewDelegate {

    var screenW:CGFloat = 0
    var picArray:[[UIImage]] = [[],[]]
    var textViewText = ""
    var cover = UIButton()
    var picture = UIButton()
    var picView = UIView()
    var indexNow:NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenW = self.view.frame.width
        tableView.tableFooterView = footerView()
        //点击已上传图片的遮罩层部分
        //计算状态栏及导航栏的高度
        let rectStatus = UIApplication.sharedApplication().statusBarFrame
        let rectNav = self.navigationController?.navigationBar.frame
        let marginHeight = rectStatus.size.height + rectNav!.size.height
        
        cover = UIButton(frame: CGRect(x: 0, y: marginHeight, width: self.view.frame.size.width, height: self.view.frame.size.height - marginHeight))
        cover.backgroundColor = UIColor.blackColor()
        cover.tag = 3
        cover.alpha = 0
        cover.addTarget(self, action: #selector(GoodEvaluateTableViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        let picY = (self.view.frame.size.height - 200) / 2
        picture = UIButton(frame: CGRect(x: (self.view.frame.size.width - 200) / 2, y: picY, width: 200, height: 200))
        picture.addTarget(self, action: #selector(GoodEvaluateTableViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        picture.tag = 3
    }

    //返回上一页
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {        return 2
    }
    
    //btn点击事件
    func btnClicked(btn:UIButton) {
        //判断当前的btn所在cell的indexPath
        if btn.tag != 2 && btn.tag != 3 {
            var cell:UITableViewCell
            if btn.tag > 99 {
                cell = btn.superview?.superview?.superview as! UITableViewCell
            }
            else {
                cell = btn.superview?.superview as! UITableViewCell
            }
            indexNow = tableView.indexPathForCell(cell)
        }
        //n*100:点击放大所上传图片，n*1000:点击删除所上传的图片
        if btn.tag > 99 {
            if btn.tag > 999 {
                //先移除该图片及其删除按钮的组合，再调整显示图片区域中图片的位置（以免留空）
                let pic = btn.superview
                let picView = pic?.superview
                pic?.removeFromSuperview()
                picArray[(indexNow?.row)!].removeAtIndex(btn.tag / 1000 - 1)
                let margin = 10
                let btnW = 50
                var subX = 20
                if (picView!.subviews.count - 5) != 0 {
                    for i in 5..<picView!.subviews.count {
                        let index = i - 5
                        picView!.subviews[i].frame = CGRect(x: subX, y: 120, width: btnW + 5, height: btnW + 5)
                        //修改图片和btn的tag以免后续工作中下标越界
                        picView!.subviews[i].subviews[1].tag = (index + 1) * 1000
                        picView!.subviews[i].subviews[0].tag = (index + 1) * 100
                        subX = (margin + btnW + 10) * (index + 1) + 20
                    }
                }
                //更改添加按钮的位置
                for view in picView!.subviews {
                    if view.tag == 1 {
                        view.hidden = false
                        view.frame.origin.x = CGFloat(subX)
                    }
                }
            }
            else {
                //先添加遮罩层再添加图片
                let tag = btn.tag / 100 - 1
                cover.alpha = 0.6
                (UIApplication.sharedApplication().delegate as! AppDelegate).window!.addSubview(cover)
                picture.setImage(picArray[(indexNow?.row)!][tag], forState: UIControlState.Normal)
                (UIApplication.sharedApplication().delegate as! AppDelegate).window!.addSubview(picture)
            }
        }
        else {
            //1:插入图片,2:确定,3:放大的图片，遮罩层
            switch btn.tag {
            case 1:
                //限制不能多于四张
                if picArray.count == 4 {
                    let alertV = UIAlertView(title: nil, message: "上传图片不可多于4张", delegate: nil, cancelButtonTitle: "确定" )
                    alertV.show()
                }
                else {
                    picView = btn.superview!
                    let alertV = UIAlertView(title: "", message: "上传图片", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "拍照","从相册选择" )
                    alertV.tag = 0
                    alertV.show()
                }
            case 2:
                let alertV = UIAlertView(title: nil, message: "提交成功", delegate: self, cancelButtonTitle: "确定")
                    alertV.tag = 1
                    alertV.show()
            case 3:
                //点击遮罩层移除遮罩层及放大的图片
                cover.removeFromSuperview()
                picture.removeFromSuperview()
            default:
                break
            }
        }
    }
    
    //弹出框按钮的点击事件
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        //0:上传图片,1:提交
        if alertView.tag == 0 {
            if buttonIndex != 0 {
                UploadPicture(buttonIndex)
            }
        }
        else if alertView.tag == 1 {
            print("提交事件")
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
        //获取已选择的图片
        let img = info[UIImagePickerControllerEditedImage] as! UIImage
        //picView:底部用于显示已上传的图片的cell的contentView,subview:所添加的图片及删除按钮的整体,imgBtn:所添加的图片,deleteBtn:删除按钮
        let picView = (tableView.cellForRowAtIndexPath(indexNow!)?.subviews[0])!
        print(picView)
        let margin = 10
        let btnW = 50
        let num = picView.subviews.count - 5
        let subX = (margin + btnW + 10) * num + margin + 10
        let subview = UIView(frame: CGRect(x: subX, y: 120, width: btnW + 5, height: btnW + 5))
        
        let imgBtn = UIButton(frame: CGRect(x: 0, y: 10, width: btnW, height: btnW))
        imgBtn.setImage(img, forState: UIControlState.Normal)
        imgBtn.addTarget(self, action: #selector(GoodEvaluateTableViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        imgBtn.tag = (num + 1) * 100
        subview.addSubview(imgBtn)
        
        let deleteBtn = UIButton(frame: CGRect(x: 38, y: 0, width: 25, height: 25))
        deleteBtn.setImage(UIImage(named: "delete"), forState: UIControlState.Normal)
        deleteBtn.tag = (num + 1) * 1000
        deleteBtn.addTarget(self, action: #selector(GoodEvaluateTableViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        subview.addSubview(deleteBtn)
        
        picView.addSubview(subview)
        picArray[(indexNow?.row)!].append(img)
        //若当前上传图片达到最大（4）则隐藏添加按钮，否则调整其位置
        for view in picView.subviews {
            if view.tag == 1 {
                if picView.subviews.count - 5 == 4 {
                    view.hidden = true
                }
                else {
                    view.frame.origin.x = CGFloat((margin + btnW + 10) * (picView.subviews.count - 5) + margin + 10)
                }
            }
        }
        print(indexNow?.row,picArray[(indexNow?.row)!].count)
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //cancel后执行的方法
    func imagePickerControllerDidCancel(picker: UIImagePickerController){
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        textViewText = textView.text
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
            else if view.isKindOfClass(UITextView.self) {
                view.removeFromSuperview()
            }
        }
        
            //pic:商店图片,name:商店名称
            let pic = UIImageView(frame: CGRect(x: 10, y: 10, width: 40, height: 40))
            //            pic.kf_showIndicatorWhenLoading = true
            //            pic.kf_setImageWithURL(NSURL(string:storedata!.imgPath)!, placeholderImage: nil,
            //                optionsInfo: [.Transition(ImageTransition.Fade(1))],
            //                progressBlock: { receivedSize, totalSize in
            ////                    print("\(receivedSize)/\(totalSize)")
            //                },
            //                completionHandler: { image, error, cacheType, imageURL in
            ////                    print("Finished")
            //            })
            pic.image = UIImage(named: "store1")
            cell!.contentView.addSubview(pic)
            
            let name = UILabel(frame: CGRect(x: 60, y: 10, width: screenW - 70, height: 40))
            name.text = "珠海金装士汽车维修店"//storedata!.garage
            name.font = UIFont.systemFontOfSize(14)
            cell!.contentView.addSubview(name)
        
            
            let content = UITextView(frame: CGRect(x: 10, y: 60, width: screenW - 20, height: 50))
            content.layer.borderWidth = 1
            content.text = ""
            //content.delegate = self
            cell?.contentView.addSubview(content)
        
        let insertBtn = UIButton(frame: CGRect(x: 20, y: 130, width: 50, height: 50))
        insertBtn.setImage(UIImage(named: "addPicture"), forState: UIControlState.Normal)
        insertBtn.addTarget(self, action: #selector(GoodEvaluateTableViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        insertBtn.titleLabel!.font = UIFont.systemFontOfSize(14)
        insertBtn.layer.cornerRadius = 3.0
        insertBtn.tag = 1
        cell?.contentView.addSubview(insertBtn)
        
        let line = UILabel(frame: CGRect(x: 10, y: 189, width: screenW - 20, height: 1))
        line.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
        cell?.contentView.addSubview(line)
        
        cell?.selectionStyle = UITableViewCellSelectionStyle.None
        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 190
    }
    
    //底部已上传的图片及确认按钮
    func footerView()->UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: screenW, height: 80))
        
        let submitBtn = UIButton(frame: CGRect(x: (screenW - 80) / 2, y: 20, width: 100, height: 30))
        submitBtn.setTitle("确定", forState: UIControlState.Normal)
        submitBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        submitBtn.titleLabel?.textAlignment = NSTextAlignment.Center
        submitBtn.backgroundColor = UIColor(red: 24/255, green: 112/255, blue: 254/255, alpha: 1.0)
        submitBtn.layer.cornerRadius = 3.0
        submitBtn.addTarget(self, action: #selector(GoodEvaluateTableViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        submitBtn.titleLabel!.font = UIFont.systemFontOfSize(15)
        submitBtn.tag = 2
        view.addSubview(submitBtn)
        
        return view
    }
}
