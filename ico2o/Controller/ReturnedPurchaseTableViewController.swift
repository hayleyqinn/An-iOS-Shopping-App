//
//  ReturnedPurchaseTableViewController.swift
//  ico2o
//
//  Created by Katherine on 15/12/10.
//  Copyright © 2015年 chingyam. All rights reserved.
//
import Alamofire
import JSONNeverDie
import Kingfisher
import UIKit

class ReturnedPurchaseTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate, ChangeCountAlertViewDelegate,ChoosePropertyAlertViewDelegate, UIPickerViewDelegate,UIPickerViewDataSource{
    /*radioState:多选按钮的选中状态
    cover：点击放大已上传图片时背后的遮罩层
    picture：显示放大已上传的图片的uiimageview
    picArray：要上传的图片数组
    dataFromOther：从前一页从过来的数据textField
    */
    var rasonTextField = UITextField(frame: CGRect(x: 70, y: 40, width: 200, height: 20))
    var rason = []
    var count = UIButton()
    var listData: NSDictionary = NSDictionary()
    var filePath = NSBundle.mainBundle().pathForResource("config.plist", ofType:nil )
    var data:[[[String]]] = []
    var radioState:[Bool] = []
    var boxRadioState:[Bool] = []
    var dRadioState = false
    var countText = ""
    var alterV:ChangeCountAlterView?
    var cover = UIButton()
    var picture = UIButton()
    var picArray:[UIImage] = []
    var dataFromOther:[[[String]]] = []
    var returnReason: UITextView?
    var alter:ChangeCountAlterView?
    var itemsDetail: [Dictionary<String, String>] = []
    
    
    //返回上一页
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listData = NSDictionary(contentsOfFile: filePath!)!
        self.rason = ["r1", "r2", "r3"]
        var rasonPick: UIPickerView?
        rasonPick = UIPickerView(frame: CGRectMake(0, 200, view.frame.width, 200))
        rasonPick!.backgroundColor = .whiteColor()
        rasonPick!.showsSelectionIndicator = true
        radioState = stateInit()
        boxRadioState = stateInit()
        rasonPick!.delegate = self
        rasonPick!.dataSource = self
        rasonTextField.inputView = rasonPick
         tableView.separatorStyle = .None
        tableView.tableFooterView = footerView()
        
    }
    
    
    //初始化多选按钮radioState的状态，默认全为未选中
    func stateInit()->[Bool] {
        var arr:[Bool] = []
        for _ in 0..<data.count {
            arr.append(false)
        }
        return arr
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
    
    func btnClicked(btn:UIButton){
        
      
        //n*100:点击放大所上传图片，n*1000:点击删除所上传的图片
//        if btn.tag > 99 {
//            if btn.tag > 999 {
//                //先移除该图片及其删除按钮的组合，再调整显示图片区域中图片的位置（以免留空）
//                let pic = btn.superview
//                pic?.removeFromSuperview()
//                picArray.removeAtIndex(btn.tag / 1000 - 1)
//                let picView = (tableView.tableFooterView)!.subviews[5]
//                let margin = 10
//                let btnW = 60
//                if picView.subviews.count != 0 {
//                    for i in 0..<picView.subviews.count {
//                        picView.subviews[i].frame = CGRect(x: (margin + btnW + 5) * i + margin, y: 0, width: btnW + 5, height: btnW + 5)
//                        //修改图片和btn的tag以免后续工作中下标越界
//                        picView.subviews[i].subviews[1].tag = (i + 1) * 1000
//                        picView.subviews[i].subviews[0].tag = (i + 1) * 100
//                    }
//                }
//            }
//            else {
//                //先添加遮罩层再添加图片
//                let tag = btn.tag / 100 - 1
//                cover.alpha = 0.6
//                (UIApplication.sharedApplication().delegate as! AppDelegate).window!.addSubview(cover)
//                picture.setImage(picArray[tag], forState: UIControlState.Normal)
//                (UIApplication.sharedApplication().delegate as! AppDelegate).window!.addSubview(picture)
//            }
//        }
//        else {
            //0:上传图片,1:cell中的radioBtn,2:遮罩层,3:提交退货申请
            switch btn.tag {
//            case 0:
//                //限制不能多于四张
//                if picArray.count == 4 {
//                    let alertV = UIAlertView(title: nil, message: "上传图片不可多于4张", delegate: nil, cancelButtonTitle: "确定" )
//                    alertV.show()
//                }
//                else {
//                    let alertV = UIAlertView(title: "", message: "上传图片", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "拍照","从相册选择" )
//                    alertV.tag = 0
//                    alertV.show()
//                }
            case 0:
                let cell = btn.superview?.superview as! UITableViewCell
                let row = tableView.indexPathForCell(cell)?.row
                var img = "check2"
                
                if boxRadioState[row!] {
                    img = "check1"
                }
                boxRadioState[row!] = !boxRadioState[row!]
                btn.setImage(UIImage(named: img), forState: UIControlState.Normal)
                changeFootersData()
            case 1:
                let cell = btn.superview?.superview as! UITableViewCell
                let row = tableView.indexPathForCell(cell)?.row
                var img = "check2"
                
                if radioState[row!] {
                    img = "check1"
                }
                radioState[row!] = !radioState[row!]
                btn.setImage(UIImage(named: img), forState: UIControlState.Normal)
                changeFootersData()
            case 2:
                var img = "check2"
                if dRadioState {
                    img = "check1"
                }
                dRadioState = !dRadioState
                btn.setImage(UIImage(named: img), forState: UIControlState.Normal)
                changeFootersData()
//            case 2:
//                //点击遮罩层移除遮罩层及放大的图片
//                cover.removeFromSuperview()
//                picture.removeFromSuperview()
            case 3:
                //检查是否已选中需退货的商品
                var checked = false
                
                for i in 0..<radioState.count {
                    if radioState[i] {
                        checked = true
                        itemsDetail.append(["Name":"\(data[i][2][0])","OrderItemID":"\(data[i][14][0])","Price":"\(data[i][4][0])","Quantity":"\(data[i][5][0])","IsReturnOtherPrice":"0","OtherPrice": "0"])
                        
                    }
                }
                
                if checked {
                    let userID = NSUserDefaults.standardUserDefaults().integerForKey("UserID")
                    var  returnGoodUrl = listData.valueForKey("url") as! String
                    returnGoodUrl += "/ASHX/MobileAPI/ReturnGood/Add.ashx"
                    let footer = tableView.tableFooterView!
                    let priceLabel = footer.subviews[3] as! UILabel
                    
                    let parameters = ["UserID": userID, "IsReturnFreight":dRadioState, "Freight":10, "Reason":"\(rasonTextField.text! as String)", "Note":returnReason!.text, "Amount": (priceLabel.text! as NSString).floatValue , "OrderNO":"\(data[0][0][0])", "OrderID":"\(data[0][13][0])", "Items": itemsDetail]
                    print(parameters)
                    Alamofire.request(.POST, returnGoodUrl, parameters: parameters as? [String : AnyObject])
                        .response { (request, response, data, error) in
                            let json = JSONND.initWithData(data!)
                            
                            print(json["success"].boolValue)
                            UIAlertView(title: nil, message: "提交成功", delegate: nil, cancelButtonTitle: "确定").show()
                    }
                    
//                
//                    let alertV = UIAlertView(title: nil, message: "提交成功", delegate: nil, cancelButtonTitle: "确定")
//                    alertV.show()
                } else {
                    let alertV = UIAlertView(title: nil, message: "请选择需要退货的商品", delegate: nil, cancelButtonTitle: "确定")
                    alertV.show()
                }
            case 4:
                let cell = btn.superview?.superview as! UITableViewCell
                let row = tableView.indexPathForCell(cell)?.row
                alter = ChangeCountAlterView(title:"修改商品数量", account:Int(data[row!][5][0])!,delegate: self)
                alter!.show()
                count = btn 
                
            default:
                break
            }
        //}
    }
    
    //点击改变数量弹出框中的确定按钮后
    func selectOkButtonalertView() {
        //将弹出框中的数字设置为数量按钮count的内容，最后修改底部费汇总信息
        count.setTitle("数量：" + String(alter!.account), forState: UIControlState.Normal)
        let cell = count.superview?.superview as! UITableViewCell
        let row = tableView.indexPathForCell(cell)?.row
        data[row!][5][0] = String(alter!.account)
        changeFootersData()
    }

    
    //弹出框按钮的点击事件
//    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
//        //0:上传图片
//        if alertView.tag == 0 {
//            if buttonIndex != 0 {
//                UploadPicture(buttonIndex)
//            }
//        }
//    }
    
    //打开相机或图库
//    func UploadPicture(tag:Int) {
//        let picker = UIImagePickerController()
//        picker.delegate = self
//        picker.allowsEditing = true//设置图片可编辑
//        //1:打开相机，2:打开图库
//        if tag == 1 {
//            //先设定sourceType为相机，然后判断相机是否可用（ipod），若不可用则将sourceType设为相片库
//            var sourceType = UIImagePickerControllerSourceType.Camera
//            if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
//                sourceType = UIImagePickerControllerSourceType.PhotoLibrary
//            }
//            picker.sourceType = sourceType
//            
//        }
//        else if tag == 2 {
//            if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary){
//                picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
//                picker.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(picker.sourceType)!
//            }
//        }
//        //进入照相界面
//        self.presentViewController(picker, animated: true, completion: nil)
//    }
    
    //选择好照片后choose后执行的方法
//    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
//        //获取已选择的图片
//        let img = info[UIImagePickerControllerEditedImage] as! UIImage
//        //picView:底部用于显示已上传的图片的view,subview:所添加的图片及删除按钮的整体,imgBtn:所添加的图片,deleteBtn:删除按钮
//        let picView = (tableView.tableFooterView)!.subviews[5]
//        let margin = 10
//        let btnW = 60
//        let num = picView.subviews.count
//        let subview = UIView(frame: CGRect(x: (margin + btnW + 5) * num + margin, y: 0, width: btnW + 5, height: btnW + 5))
//        
//        let imgBtn = UIButton(frame: CGRect(x: 0, y: 5, width: btnW, height: btnW))
//        imgBtn.setImage(img, forState: UIControlState.Normal)
//        imgBtn.addTarget(self, action: #selector(ReturnedPurchaseTableViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
//        imgBtn.tag = (num + 1) * 100
//        subview.addSubview(imgBtn)
//        
//        let deleteBtn = UIButton(frame: CGRect(x: 40, y: 0, width: 25, height: 25))
//        deleteBtn.setImage(UIImage(named: "delete"), forState: UIControlState.Normal)
//        deleteBtn.tag = (num + 1) * 1000
//        deleteBtn.addTarget(self, action: #selector(ReturnedPurchaseTableViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
//        subview.addSubview(deleteBtn)
//        
//        picView.addSubview(subview)
//        picArray.append(img)
//        picker.dismissViewControllerAnimated(true, completion: nil)
//    }
    
    //cancel后执行的方法
//    func imagePickerControllerDidCancel(picker: UIImagePickerController){
//        picker.dismissViewControllerAnimated(true, completion: nil)
//    }
    
    //更改footerview的数据
    func changeFootersData() {
        let cells = tableView.subviews[0].subviews
        //amount:商品数量,totalP:商品总价
        var amount = 0
        var totalP:Float = 0
        for i in 0..<cells.count {
            if radioState[i] {
                amount += Int(data[i][5][0])!
                totalP += Float(Float(data[i][5][0])! * Float(Float(data[i][4][0])!))
            }
            //预设为40
            if boxRadioState[i]{
                totalP += 40
            }
        }
        //运费
        if dRadioState {
            totalP += 10
        }
        let footer = tableView.tableFooterView!
        let countLabel = footer.subviews[2] as! UILabel
        countLabel.text = "退货数量：" + String(amount) + "    退货总金额：￥"
        let priceLabel = footer.subviews[3] as! UILabel
        priceLabel.text = String(format: "%.2f", totalP)
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
        
        //radioBtn:多选框，pic:商品图片,name:商品名称,price:价格,countL：商品数量
        let radioBtn = UIButton(frame: CGRect(x: 10, y: 23, width: 25, height: 25))
        var img = "check1"
        if radioState[indexPath.row] {
            img = "check2"
        }
        radioBtn.setImage(UIImage(named: img), forState: UIControlState.Normal)
        radioBtn.addTarget(self, action: #selector(ReturnedPurchaseTableViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        radioBtn.tag = 1
        cell!.contentView.addSubview(radioBtn)
        
        
        let boxFee = UILabel(frame: CGRect(x: screenW - 80, y: 10, width: 80, height: 35))
        boxFee.text = "退钉箱费"
        boxFee.alpha = 0.6
        boxFee.font = UIFont.systemFontOfSize(13)
        cell!.contentView.addSubview(boxFee)

        
        //钉箱多选框
        let boxRadioBtn = UIButton(frame: CGRect(x: screenW - 20, y: 20, width: 13, height: 13))
        var img2 = "check1"
        if boxRadioState[indexPath.row] {
            img2 = "check2"
        }
        boxRadioBtn.setImage(UIImage(named: img2), forState: UIControlState.Normal)
        boxRadioBtn.addTarget(self, action: #selector(ReturnedPurchaseTableViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        boxRadioBtn.tag = 0
        cell!.contentView.addSubview(boxRadioBtn)
        
        let url = NSURL(string: listData.valueForKey("url") as! String + "/" + data[indexPath.row][1][0])!
        let pic = UIImageView(frame: CGRect(x: 40, y: 10, width: 70, height: 70))
        pic.kf_showIndicatorWhenLoading = true
        pic.kf_setImageWithURL(url, placeholderImage: nil,
                               optionsInfo: [.Transition(ImageTransition.Fade(1))],
                               progressBlock: { receivedSize, totalSize in
            },
                               completionHandler: { image, error, cacheType, imageURL in
        })
        cell!.contentView.addSubview(pic)
        
        let name = UILabel(frame: CGRect(x: 120, y: 10, width: screenW - 130, height: 35))
        name.text = data[indexPath.row][2][0]
        name.font = UIFont.systemFontOfSize(14)
        name.numberOfLines = 0;
        name.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cell!.contentView.addSubview(name)
        
        let countL = UIButton(frame: CGRect(x: 120, y: 55, width: 60, height: 20))
        countL.setTitle("数量：" + data[indexPath.row][5][0], forState: .Normal)
        countL.titleLabel?.textAlignment = .Center
        countL.titleLabel?.font = .systemFontOfSize(14)
        countL.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        countL.tag = 4
        countL.addTarget(self, action: #selector(ReturnedPurchaseTableViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)

        cell!.contentView.addSubview(countL)
        
        let price = UILabel(frame: CGRect(x: screenW - 70, y: 55, width: 60, height: 20))
        let a = Float(data[indexPath.row][4][0])!
        price.text = "¥" + String(format: "%.2f", a)
        price.font = UIFont.systemFontOfSize(14)
        price.textAlignment = NSTextAlignment.Right
        price.textColor = UIColor.redColor()
        cell!.contentView.addSubview(price)
        
        let line = UILabel(frame: CGRect(x: 0, y: 80, width: screenW, height: 1))
        line.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
        cell?.contentView.addSubview(line)
   
    
        cell!.tag = indexPath.row
        cell!.backgroundColor = UIColor.whiteColor()// UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
        return cell!
    }
    
//    //转跳页面
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        self.performSegueWithIdentifier("ReturnPurchaseToGoodDetail", sender: self)
//    }
    
    //转跳时传递相应数据
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "ReturnPurchaseToGoodDetail" {
//            let receive = (segue.destinationViewController as! UINavigationController)
//            let a = receive.viewControllers[0] as! GoodDetailTableViewController
//            a.goodMsgFromOther = 0
//        }
//    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "请选择需要退货的商品"
    }
    //pickerView 的轮子 设置为1个
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //选择的PickerView的选项设置为TextField的值
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
 
            rasonTextField.text = rason[row] as! String
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
     
        return rason.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return rason[row] as? String
    }

    
    func footerView()->UIView {
        let screenW = self.view.frame.size.width
        let view = UIView(frame: CGRect(x: 0, y: 0, width: screenW, height: 330))
        
        
        
        
        let dlabel = UILabel(frame: CGRect(x: 0, y: 5, width: 50, height: 30))
        dlabel.font = UIFont.systemFontOfSize(14)
        dlabel.text = "退运费"
        view.addSubview(dlabel)
        
        //运费选框
        let dRadioBtn = UIButton(frame: CGRect(x: 50, y: 13, width: 13, height: 13))
        var img2 = "check1"
        if dRadioState {
            img2 = "check2"
        }
        dRadioBtn.setImage(UIImage(named: img2), forState: UIControlState.Normal)
        dRadioBtn.addTarget(self, action: #selector(ReturnedPurchaseTableViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        dRadioBtn.tag = 2
        view.addSubview(dRadioBtn)
        
        
        
        let label1 = UILabel(frame: CGRect(x: -10, y: 5, width: screenW - 70, height: 30))
        label1.text = "退货数量：0" + "    退货总金额："
        label1.textAlignment = NSTextAlignment.Right
        label1.font = UIFont.systemFontOfSize(14)
        label1.numberOfLines = 0
        label1.lineBreakMode = NSLineBreakMode.ByWordWrapping
        view.addSubview(label1)
        
        let label2 = UILabel(frame: CGRect(x: screenW - 80, y: 3, width: 70, height: 30))
        label2.text = "¥0.00"
        label2.font = UIFont.systemFontOfSize(16)
        label2.textColor = UIColor.redColor()
        label2.numberOfLines = 0
        label2.lineBreakMode = NSLineBreakMode.ByWordWrapping
        view.addSubview(label2)
        
        
        
        
        
        let label3 = UILabel(frame: CGRect(x: 0, y: 35, width: 100, height: 30))
        label3.font = UIFont.systemFontOfSize(14)
        label3.text = "退货原因"
        view.addSubview(label3)
        
        rasonTextField.placeholder = "点击选择退货原因"
        rasonTextField.font = UIFont.systemFontOfSize(14)
        view.addSubview(rasonTextField)
        
        let label = UILabel(frame: CGRect(x: 0, y: 70, width: screenW, height: 20))
        label.text = "备注"
        label.font = UIFont.systemFontOfSize(15)
        view.addSubview(label)
        
        returnReason = UITextView(frame: CGRect(x: 0, y: 90, width: screenW , height: 60))
        returnReason!.layer.borderWidth = 1
        returnReason!.layer.cornerRadius = 3.0
        view.addSubview(returnReason!)
        
//        let uploadPic = UIButton(frame: CGRect(x: 10, y: 160, width: 70, height: 30))
//        uploadPic.setTitle("上传图片", forState: UIControlState.Normal)
//        uploadPic.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
//        uploadPic.backgroundColor = UIColor.grayColor()
//        uploadPic.titleLabel?.font = UIFont.systemFontOfSize(14)
//        uploadPic.titleLabel!.textAlignment = NSTextAlignment.Center
//        uploadPic.layer.cornerRadius = 5.0
//        uploadPic.addTarget(self, action: #selector(ReturnedPurchaseTableViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
//        uploadPic.tag = 0
//        view.addSubview(uploadPic)
        
//        let picView = UIView(frame: CGRect(x: 0, y: 200, width: screenW, height: 65))
//        view.addSubview(picView)
        
        let submit = UIButton(frame: CGRect(x: 0, y: 180, width: screenW, height: 40))
        submit.setTitle("提交退货申请", forState: UIControlState.Normal)
        submit.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        submit.backgroundColor = UIColor.orangeColor()//init(red: 18, green: 166, blue: 255, alpha: 1)
        submit.titleLabel?.textAlignment = NSTextAlignment.Center
        submit.titleLabel?.font = UIFont.systemFontOfSize(14)
        submit.layer.cornerRadius = 0
        submit.addTarget(self, action: #selector(ReturnedPurchaseTableViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        submit.tag = 3
        view.addSubview(submit)
        
        
        //遮罩层部分
//        //计算状态栏及导航栏的高度
//        let rectStatus = UIApplication.sharedApplication().statusBarFrame
//        let rectNav = self.navigationController?.navigationBar.frame
//        let marginHeight = rectStatus.size.height + rectNav!.size.height
//        
//        cover = UIButton(frame: CGRect(x: 0, y: marginHeight, width: self.view.frame.size.width, height: self.view.frame.size.height - marginHeight))
//        cover.backgroundColor = UIColor.blackColor()
//        cover.tag = 2
//        cover.alpha = 0
//        cover.addTarget(self, action: #selector(ReturnedPurchaseTableViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
//        let picY = (self.view.frame.size.height - 200) / 2
//        picture = UIButton(frame: CGRect(x: (self.view.frame.size.width - 200) / 2, y: picY, width: 200, height: 200))
//        picture.addTarget(self, action: #selector(ReturnedPurchaseTableViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
//        picture.tag = 2
        
        return view
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //取消选中的状态
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 85
    }
}
