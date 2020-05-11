//
//  StoreEvaluateTableViewController.swift
//  ico2o
//
//  Created by Katherine on 16/1/13.
//  Copyright © 2016年 chingyam. All rights reserved.
//

import UIKit

class StoreEvaluateTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate, RatingBarDelegate, UITextViewDelegate {
    /*storedata：要评价的维修店
    maintItem：保养项目
    itemCellHeight：保养项目栏的高度
    textViewText：评价内容
    picArray：要上传的图片数组
    cover：点击放大已上传图片时背后的遮罩层
    picture：显示放大已上传的图片的uiimageview
    screenW：屏幕宽度
    */
    var storedata:CarShopModel?
    var maintItem = ["小保养","洗车","换轮胎","洗车","换轮胎","洗车","换轮胎","洗车","换轮胎","洗车","换轮胎"]
    var itemCellHeight:CGFloat = 70
    var picArray:[UIImage] = []
    var starNum:[Double] = [0,0,0,0,0]
    var textViewText = ""
    var cover = UIButton()
    var picture = UIButton()
    var screenW:CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenW = self.view.frame.size.width
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.tableFooterView = footerView()
    }

    //返回上一页
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func btnClicked(btn:UIButton) {
        //n*100:点击放大所上传图片，n*1000:点击删除所上传的图片
        if btn.tag > 99 {
            if btn.tag > 999 {
                //先移除该图片及其删除按钮的组合，再调整显示图片区域中图片的位置（以免留空）
                let pic = btn.superview
                pic?.removeFromSuperview()
                picArray.removeAtIndex(btn.tag / 1000 - 1)
                let picView = (tableView.tableFooterView)!.subviews[0]
                let margin = 10
                let btnW = 60
                if picView.subviews.count != 0 {
                    for i in 0..<picView.subviews.count {
                        picView.subviews[i].frame = CGRect(x: (margin + btnW + 5) * i + margin, y: 0, width: btnW + 5, height: btnW + 5)
                        //修改图片和btn的tag以免后续工作中下标越界
                        picView.subviews[i].subviews[1].tag = (i + 1) * 1000
                        picView.subviews[i].subviews[0].tag = (i + 1) * 100
                    }
                }
            }
            else {
                //先添加遮罩层再添加图片
                let tag = btn.tag / 100 - 1
                cover.alpha = 0.6
                (UIApplication.sharedApplication().delegate as! AppDelegate).window!.addSubview(cover)
                picture.setImage(picArray[tag], forState: UIControlState.Normal)
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
                    let alertV = UIAlertView(title: "", message: "上传图片", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "拍照","从相册选择" )
                    alertV.tag = 0
                    alertV.show()
                }
            case 2:
                var isfinished = true
                for num in starNum {
                    if num == 0 {
                        let alertV = UIAlertView(title: nil, message: "评分不能为空", delegate: nil, cancelButtonTitle: "确定")
                        alertV.show()
                        isfinished = false
                        break
                    }
                }
                if isfinished {
                    let alertV = UIAlertView(title: nil, message: "提交成功", delegate: self, cancelButtonTitle: "确定")
                    alertV.tag = 1
                    alertV.show()
                }
            case 3:
                //点击遮罩层移除遮罩层及放大的图片
                cover.removeFromSuperview()
                picture.removeFromSuperview()
            default:
                break
            }
        }
    }
    
    //点击星星后
    func ratingDidChange(ratingBar: RatingBar, rating: CGFloat) {
        starNum[ratingBar.tag] = Double(rating)
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
        let picView = (tableView.tableFooterView)!.subviews[0]
        let margin = 10
        let btnW = 60
        let num = picView.subviews.count
        let subview = UIView(frame: CGRect(x: (margin + btnW + 5) * num + margin, y: 0, width: btnW + 5, height: btnW + 5))
        
        let imgBtn = UIButton(frame: CGRect(x: 0, y: 5, width: btnW, height: btnW))
        imgBtn.setImage(img, forState: UIControlState.Normal)
        imgBtn.addTarget(self, action: #selector(StoreEvaluateTableViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        imgBtn.tag = (num + 1) * 100
        subview.addSubview(imgBtn)
        
        let deleteBtn = UIButton(frame: CGRect(x: 40, y: 0, width: 25, height: 25))
        deleteBtn.setImage(UIImage(named: "delete"), forState: UIControlState.Normal)
        deleteBtn.tag = (num + 1) * 1000
        deleteBtn.addTarget(self, action: #selector(StoreEvaluateTableViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        subview.addSubview(deleteBtn)
        
        picView.addSubview(subview)
        picArray.append(img)
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //cancel后执行的方法
    func imagePickerControllerDidCancel(picker: UIImagePickerController){
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        textViewText = textView.text
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
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
            else if view.isKindOfClass(RatingBar.self) {
                view.removeFromSuperview()
            }
        }
        
        switch indexPath.row {
        case 0:
            //pic:商店图片,name:商店名称
            let pic = UIImageView(frame: CGRect(x: 10, y: 10, width: 70, height: 70))
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
            
            let name = UILabel(frame: CGRect(x: 90, y: 20, width: screenW - 100, height: 20))
            name.text = "珠海金装士汽车维修店"//storedata!.garage
            name.font = UIFont.systemFontOfSize(16)
            name.numberOfLines = 0;
            name.lineBreakMode = NSLineBreakMode.ByWordWrapping
            cell!.contentView.addSubview(name)
            
            let numberTitle = UILabel(frame: CGRect(x: 90, y: 50, width: 100, height: 20))
            numberTitle.text = "综合评价："
            numberTitle.font = UIFont.systemFontOfSize(15)
            numberTitle.textColor = UIColor.grayColor()
            cell?.contentView.addSubview(numberTitle)
            
            let star = RatingBar()
            star.frame = CGRect(x: 160, y: 50, width: 110, height: 20)
            star.numStars = 5
            star.ratingMax = 10
            star.rating = 3//CGFloat(storedata!.star)
            star.isIndicator = true
            cell?.contentView.addSubview(star)
            
            let starNum = UILabel(frame: CGRect(x: 280, y: 50, width: 30, height: 20))
            starNum.text = "3.0"//String(format:".2%f",storedata!.star)
            starNum.font = UIFont.systemFontOfSize(16)
            starNum.textColor = UIColor.grayColor()
            cell?.contentView.addSubview(starNum)
            
            let line = UILabel(frame: CGRect(x: 10, y: 89, width: screenW - 20, height: 1))
            line.backgroundColor = UIColor.blackColor()
            cell?.contentView.addSubview(line)
        case 1:
            let title = UILabel(frame: CGRect(x: 10, y: 10, width: 150, height: 20))
            title.text = "本次维修项目："
            title.font = UIFont.systemFontOfSize(16)
            cell?.contentView.addSubview(title)
            
            var labelX:CGFloat = 20
            var labelY:CGFloat = 40
            let labelFont = UIFont.systemFontOfSize(14)
            for i in 0..<maintItem.count {
                let text = maintItem[i]
                let label = UILabel(frame: CGRect(x: labelX, y: labelY, width: text.calculateTextWidth(labelFont), height: 20))
                label.text = text
                label.font = labelFont
                label.textColor = UIColor.grayColor()
                cell?.contentView.addSubview(label)
                //设置下一个项目的坐标
                labelX += (label.frame.width + 20)
                //若当前行放不下下一个项目，换行
                if i + 1 != maintItem.count {
                    if (labelX + maintItem[i + 1].calculateTextWidth(labelFont) + 20) > screenW {
                        labelX = 20
                        labelY += 30
                    }
                }
            }
            itemCellHeight = labelY
            let line = UILabel(frame: CGRect(x: 10, y: labelY - 1, width: screenW - 20, height: 1))
            line.backgroundColor = UIColor.blackColor()
            cell?.contentView.addSubview(line)
        case 2:
            let titleText = ["服务态度：","收费合理：","技术水平：","店内环境：","“0”推销："]
            var labelY:CGFloat = 10
            for i in 0..<5 {
                let title = UILabel(frame: CGRect(x: (screenW - 200) / 2, y: labelY, width: 70, height: 20))
                title.text = titleText[i]
                title.font = UIFont.systemFontOfSize(14)
                title.textColor = UIColor.grayColor()
                cell?.contentView.addSubview(title)
                
                let star = RatingBar()
                star.frame = CGRect(x: (screenW - 200) / 2 + 80, y: labelY, width: 110, height: 20)
                star.numStars = 5
                star.tag = i
                star.delegate = self
                cell?.contentView.addSubview(star)
                labelY += 30
            }
        case 3:
            let title = UILabel(frame: CGRect(x: 10, y: 10, width: 30, height: 20))
            title.text = "内容"
            title.font = UIFont.systemFontOfSize(14)
            title.textColor = UIColor.grayColor()
            cell?.contentView.addSubview(title)
            
            let content = UITextView(frame: CGRect(x: 50, y: 10, width: screenW - 60, height: 130))
            content.layer.borderWidth = 1
            content.text = textViewText
            content.delegate = self
            cell?.contentView.addSubview(content)
            
            let insertBtn = UIButton(frame: CGRect(x: screenW - 90, y: 150, width: 80, height: 25))
            insertBtn.setTitle("插入图片", forState: UIControlState.Normal)
            insertBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            insertBtn.backgroundColor = UIColor.orangeColor()
            insertBtn.addTarget(self, action: #selector(StoreEvaluateTableViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            insertBtn.titleLabel!.font = UIFont.systemFontOfSize(14)
            insertBtn.layer.cornerRadius = 3.0
            insertBtn.tag = 1
            cell?.contentView.addSubview(insertBtn)
        default:
            break
        }
        cell?.selectionStyle = UITableViewCellSelectionStyle.None
        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 90
        case 1:
            return itemCellHeight
        case 2:
            return 160
        case 3:
            return 190
        default:
            return 30
        }
    }
    
    //底部已上传的图片及确认按钮
    func footerView()->UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: screenW, height: 180))
        
        let pictureView = UIView(frame: CGRect(x: 0, y: 0, width: screenW, height: 90))
        view.addSubview(pictureView)
        
        let submitBtn = UIButton(frame: CGRect(x: (screenW - 80) / 2, y: 100, width: 100, height: 30))
        submitBtn.setTitle("确定", forState: UIControlState.Normal)
        submitBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        submitBtn.titleLabel?.textAlignment = NSTextAlignment.Center
        submitBtn.backgroundColor = UIColor(red: 24/255, green: 112/255, blue: 254/255, alpha: 1.0)
        submitBtn.layer.cornerRadius = 3.0
        submitBtn.addTarget(self, action: #selector(StoreEvaluateTableViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        submitBtn.titleLabel!.font = UIFont.systemFontOfSize(15)
        submitBtn.tag = 2
        view.addSubview(submitBtn)
        //遮罩层部分
        //计算状态栏及导航栏的高度
        let rectStatus = UIApplication.sharedApplication().statusBarFrame
        let rectNav = self.navigationController?.navigationBar.frame
        let marginHeight = rectStatus.size.height + rectNav!.size.height
        
        cover = UIButton(frame: CGRect(x: 0, y: marginHeight, width: self.view.frame.size.width, height: self.view.frame.size.height - marginHeight))
        cover.backgroundColor = UIColor.blackColor()
        cover.tag = 3
        cover.alpha = 0
        cover.addTarget(self, action: #selector(StoreEvaluateTableViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        let picY = (self.view.frame.size.height - 200) / 2
        picture = UIButton(frame: CGRect(x: (self.view.frame.size.width - 200) / 2, y: picY, width: 200, height: 200))
        picture.addTarget(self, action: #selector(StoreEvaluateTableViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        picture.tag = 3
        
        return view
    }
    
}
