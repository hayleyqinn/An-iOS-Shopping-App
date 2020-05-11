//
//  MakeOrderTableViewController.swift
//  ico2o
//
//  Created by Katherine on 15/12/13.
//  Copyright © 2015年 chingyam. All rights reserved.
//

import UIKit
import Alamofire
import JSONNeverDie

class MakeOrderTableViewController: UITableViewController,UIAlertViewDelegate,UITextFieldDelegate {
    /*choice:订单信息
    address:收货地址信息
    lastMsg：底部的备注信息输入框
    data：订单中的商品信息
    total：底部汇总的数据:商品数量，总重量，商品总价，运费，合计，赠送积分
    ticketType:发票类型
    isFromBooking：是否从订购车页面转跳过来
    ticketNum:发票税号
    bookingTime:预约时间
    */
    var tradeNO = ""
    var price: String = ""
    var choice:[String] = ["","","","","","",""]
    var address:AddressModel?
    var ticketAddress = ""
    var lastMsg:UITextField?
    var data:[CommodityModel] = []
    var totalData:[Double] = [0,10,0,10,0,0]
    var ticketType = ""
    var isFromBooking = false
    var ticketNum = ""
    var bookingTime = ""
    var addOrderURL = ""
    var listData: NSDictionary = NSDictionary()
    var filePath = NSBundle.mainBundle().pathForResource("config.plist", ofType:nil )
    //返回上一页
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //修复了重新设置默认地址后订单页面还没更改的问题
    override func viewWillAppear(animated: Bool) {
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = footerView()
    
        listData = NSDictionary(contentsOfFile: filePath!)!
        addOrderURL = listData.valueForKey("url") as! String
        addOrderURL += "/ASHX/MobileAPI/Order/AddOrder.ashx"

    }
    
    //btn的点击事件
    func btnClicked(btn:UIButton) {
        //点击底部提交按钮
        if btn.tag == 1 {
            if (choice[0] == "") || (choice[1] == "") || (choice[2] == "") || (choice[3] == "") || (choice[4] == "") {
                let alterV = UIAlertView(title: "", message: "请填写完整信息", delegate: nil, cancelButtonTitle: "确定")
                alterV.show()
            }
            else if (lastMsg?.text!.characters.count > 20) {
                let alterV = UIAlertView(title: "", message: "备注信息不能多于20字", delegate: nil, cancelButtonTitle: "确定")
                alterV.show()
            }else if (choice[3] == "自提预约") && (bookingTime == "") {
                let alterV = UIAlertView(title: "", message: "请填写自提预约时间", delegate: nil, cancelButtonTitle: "确定")
                alterV.show()
            }
            else {
                var boxCost = false
                if choice[2] == "需要" {
                    boxCost = true
                }
                var ticketName = choice[4]
                if ticketName == "不需要" {
                    ticketType = ""
                    ticketName = ""
                }
                var IsShopToBooking = false
                if choice[3] == "自提预约" {
                    IsShopToBooking = true
                }
                var paymentID = 3
                if choice[1] == "易付宝" {
                    paymentID = 4
                }
                let shopcarsID = getShopCarID()
                //生成支付参数choice[1]
                
                let parameters:[String:AnyObject] = ["UserID":NSUserDefaults.standardUserDefaults().integerForKey("UserID"),"ShopCarsID":"\(shopcarsID)","Address":(address?.Province)! + (address?.City)! + (address?.District)!,"Mobile":(address?.Mobile)!,"ExpresPrice":13,"Name":(address?.Name)!,"InvoiceType":ticketType,"InvoiceAddress":ticketAddress,"InvoiceName":ticketName,"InvoiceTariff":ticketNum,"BookingDate":bookingTime,"Description":choice[6],"IsShopper":isFromBooking,"IsBindingBoxCost":boxCost,"LogisticsCompany":choice[0],"PaymentID":paymentID,"PayMethod":"AliPay","PostCode":(address?.PostCode)!,"TypeValue":choice[3],"IsShopToBooking":"\(IsShopToBooking)","Province":"", "City":"", "District":""]
                
//                 let parameters:[String:AnyObject] = ["UserID":NSUserDefaults.standardUserDefaults().integerForKey("UserID"),"ShopCarsID":"\(shopcarsID)","Address":(address?.Province)! + (address?.City)! + (address?.District)!,"Mobile":(address?.Mobile)!,"ExpresPrice":13,"Name":(address?.Name)!,"BookingDate":"2016-12-05 05:04:35","Description":choice[6],"IsShopper":isFromBooking,"IsBindingBoxCost":boxCost,"PaymentID":paymentID,"PayMethod":"AliPay","TypeValue":choice[3],"IsShopToBooking":"\(IsShopToBooking)"]
//                
                
                print(parameters)
                Alamofire.request(.POST, addOrderURL, parameters: parameters).response{
                        (request ,response, data, error) in
                    
                    let json = JSONND.initWithData(data!)
                   
   
                    self.tradeNO = json["OrderNO"].stringValue
                   
                    print(json,data)
                    print("order: " + json["OrderNO"].stringValue)
                }
                
                
                let alterV = UIAlertView(title: "", message: "提交成功", delegate: self, cancelButtonTitle: "确定")
                alterV.tag = 1
                alterV.show()
            }
        }
    }
    
    
    //设置优惠券信息
    func closureForSettingCoupon(string:String) -> Void {
        choice[5] = string
        tableView.reloadData()
    }
    
    //设置收货地址信息
    func closureForSettingAddress(msg:AddressModel)->Void {
        address = msg
//        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 6
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            return 4
        }
        else {
            return 1
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
            if view.isKindOfClass(UITextField.self) {
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

        switch indexPath.section {
        //收货地址
        case 0:
            let textL = UILabel(frame: CGRect(x: 15, y: 10, width: 70, height: 20))
            textL.text = "收货地址"
            textL.font = UIFont.systemFontOfSize(15)
            cell?.contentView.addSubview(textL)
      
            let defaultAddr = NSUserDefaults.standardUserDefaults().objectForKey("DefaultAddress")
            //在有默认地址的情况下，优先选择用户选择的地址
            if defaultAddr != nil {
                let addressLabel = UILabel(frame: CGRect(x: 145, y: 10, width: screenW - 160, height: 20))
                var temp:AddressModel!//存储要显示的addressModel用
                
                if address != nil {
                    temp = address!
                } else {
                    let modelData = defaultAddr as! NSData
                    temp = NSKeyedUnarchiver.unarchiveObjectWithData(modelData) as! AddressModel
                    address = temp
                }
                addressLabel.text = (temp.Name) + "-" + (temp.Address)
                addressLabel.textColor = UIColor.blueColor()
                addressLabel.font = UIFont.systemFontOfSize(15)
                cell?.contentView.addSubview(addressLabel)
            }
        //商品清单
        case 1:
            let textL = UILabel(frame: CGRect(x: 15, y: 10, width: 80, height: 20))
            textL.text = "商品清单"
            textL.font = UIFont.systemFontOfSize(15)
            cell?.contentView.addSubview(textL)
            
            let count = UILabel(frame: CGRect(x: 120, y: 10, width: 100, height: 20))
            count.text = "共 \(String(data.count)) 件"
            count.textColor = UIColor.blueColor()
            count.textAlignment = NSTextAlignment.Center
            count.font = UIFont.systemFontOfSize(15)
            cell?.contentView.addSubview(count)
        //配送方式，支付方式，钉箱
        case 2:
            let text = ["配送方式","支付方式","钉箱","提货方式"]
            let textL = UILabel(frame: CGRect(x: 15, y: 10, width: 130, height: 20))
            textL.text = text[indexPath.row]
            textL.font = UIFont.systemFontOfSize(15)
            cell?.contentView.addSubview(textL)
            
            if indexPath.row == 2 {
                let tips = UILabel(frame: CGRect(x: 40, y: 10, width: 90, height: 20))
                tips.text = "（需额外收费）"
                tips.font = UIFont.systemFontOfSize(12)
                cell?.contentView.addSubview(tips)
            }
            //若已选择则显示，未选则无
            if choice[indexPath.row] != "" {
                let choose = UILabel(frame: CGRect(x: 150, y: 10, width: screenW - 210, height: 20))
                choose.text = choice[indexPath.row]
//                if indexPath.row == 2 {
//                    choose.frame = CGRect(x: 150, y: 10, width: 40, height: 20)
//                }
                choose.textColor = UIColor.blueColor()
                choose.font = UIFont.systemFontOfSize(15)
                cell?.contentView.addSubview(choose)
            }
        //发票
        case 3:
            let textL = UILabel(frame: CGRect(x: 15, y: 10, width: 80, height: 20))
            textL.text = "发票信息"
            textL.font = UIFont.systemFontOfSize(15)
            cell?.contentView.addSubview(textL)
            
            let content = UILabel(frame: CGRect(x: 150, y: 10, width: screenW - 140, height: 20))
            content.text = choice[4]
            content.textColor = UIColor.blueColor()
            content.font = UIFont.systemFontOfSize(15)
            cell?.contentView.addSubview(content)
        //优惠劵
        case 4:
            let textL = UILabel(frame: CGRect(x: 15, y: 10, width: 100, height: 20))
            textL.text = "优惠劵"
            textL.font = UIFont.systemFontOfSize(15)
            cell?.contentView.addSubview(textL)
            
            let couponLabel = UILabel(frame: CGRect(x: 150, y: 10, width: screenW - 140, height: 20))
            couponLabel.text = choice[5]
            couponLabel.textColor = UIColor.blueColor()
            couponLabel.font = UIFont.systemFontOfSize(15)
            cell?.contentView.addSubview(couponLabel)
       //订单备注信息
        case 5:
            lastMsg = UITextField(frame: CGRect(x: 10, y: 10, width: screenW - 20, height: 30))
            lastMsg!.layer.borderWidth = 1;
            lastMsg!.layer.cornerRadius = 5.0;
            lastMsg?.font = UIFont.systemFontOfSize(15)
            lastMsg!.placeholder = "订单备注信息（20字以内）"
            if choice[6] != "" {
                lastMsg?.text = choice[6]
            }
            cell?.contentView.addSubview(lastMsg!)
        default:
            break
        }
        if indexPath.section != 5 {
            cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }
        cell?.selectionStyle = UITableViewCellSelectionStyle.None
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            self.performSegueWithIdentifier("MakeOrderToAddress", sender: self)
            
        case 1:
            self.performSegueWithIdentifier("MakeOrderToItsGoodList", sender: self)
        case 2:
            switch indexPath.row {
            case 0:
                let alterV = UIAlertView(title: "", message: "请选择配送方式", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "物流", "普通快递","顺丰")
                alterV.tag = 21
                alterV.show()
            case 1:
                let alterV = UIAlertView(title: "", message: "请选择支付方式", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "支付宝","易付宝")
                alterV.tag = 22
                alterV.show()
            case 2:
                let alterV = UIAlertView(title: "", message: "是否需要钉箱", delegate: self, cancelButtonTitle: "需要", otherButtonTitles: "不需要")
                alterV.tag = 23
                alterV.show()
            case 3:
                let alterV = UIAlertView(title: "", message: "请选择提货方式", delegate: self, cancelButtonTitle: "发货到定点维修站", otherButtonTitles: "自提预约","送货上门")
                alterV.tag = 24
                alterV.show()
            default:
                break
            }
        case 3:
            let alterV = UIAlertView(title: "", message: "是否需要发票", delegate: self, cancelButtonTitle: "不需要", otherButtonTitles: "个人","公司")
            alterV.tag = 31
            alterV.show()
        case 4:
            self.performSegueWithIdentifier("MakeOrderToCoupon", sender: self)
        default :
            break
        }
    }
    
    //转跳时传递相应数据
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "MakeOrderToAddress" {
            let receive = (segue.destinationViewController as! UINavigationController)
            let a = receive.viewControllers[0] as! MyAddressTableViewController
            a.comeFromMakeOrder = true
            a.initWithClosure(closureForSettingAddress)
            
        }
        else if segue.identifier == "MakeOrderToItsGoodList" {
            let receive = segue.destinationViewController as! GoodListForMakeOrderTableViewController
            receive.data = data
        }
        else if segue.identifier == "MakeOrderToCoupon" {
           let receive = segue.destinationViewController as! CouponTableViewController
            receive.initWithClosure(closureForSettingCoupon)
        }
        
    }
    
    //弹出框的按钮点击事件
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if (alertView.buttonTitleAtIndex(buttonIndex)!) != "取消" {
            if alertView.tag > 30 {
                //发票相关
                if alertView.tag == 31 {
                    ticketType = alertView.buttonTitleAtIndex(buttonIndex)!
                    switch buttonIndex {
                    case 0,1:
                        choice[4] = alertView.buttonTitleAtIndex(buttonIndex)!
                        tableView.reloadData()
                    case 2:
                        let alterV = UIAlertView(title: "", message: "请输入发票信息（发票将在确认收货后单独寄出）", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定")
                        alterV.alertViewStyle = UIAlertViewStyle.LoginAndPasswordInput
                        alterV.textFieldAtIndex(0)?.placeholder = "发票抬头"
                        alterV.textFieldAtIndex(1)?.placeholder = "接收地址"
                        alterV.textFieldAtIndex(1)?.secureTextEntry = false
                        alterV.tag = 32
                        alterV.show()
                    default:
                        break
                    }
                }
                else if alertView.tag == 32 {
                    if buttonIndex == 1 {
                        let ticketName = (alertView.textFieldAtIndex(0)?.text!)!
                        ticketAddress = (alertView.textFieldAtIndex(1)?.text!)!
                        if ticketName != "" && ticketAddress != "" {
                            choice[4] = ticketName
                            tableView.reloadData()
                            let alertV = UIAlertView(title: "", message: "请输入发票税号", delegate: nil, cancelButtonTitle: "取消", otherButtonTitles: "确定")
                            alertV.alertViewStyle = UIAlertViewStyle.PlainTextInput
                            alertV.tag = 33
                            alertV.show()
                        }
                        else {
                            let alertV = UIAlertView(title: nil, message: "发票信息不能为空", delegate: nil, cancelButtonTitle: "确定")
                            alertV.show()
                        }
                    }
                }
                else if alertView.tag == 33 {
                    if buttonIndex == 1 {
                        if alertView.textFieldAtIndex(0) != "" {
                            ticketNum = (alertView.textFieldAtIndex(0)?.text)!
                        }
                    }
                }
            }
            else if alertView.tag > 20 {
                //配送、支付 、钉箱
                if alertView.tag != 25 {
                    choice[alertView.tag % 20 - 1] = alertView.buttonTitleAtIndex(buttonIndex)!
                }
                else {
                    bookingTime = (alertView.textFieldAtIndex(0)?.text)!
                }
                if alertView.tag == 24 {
                    if buttonIndex == 1 {
                        let alertV = UIAlertView(title: nil, message: "请选择预约时间", delegate: nil, cancelButtonTitle: "确定")
                        alertV.alertViewStyle = UIAlertViewStyle.PlainTextInput
                        alertV.tag = 25
                        alertV.show()
                    }
                }
                tableView.reloadData()
            }
            else if alertView.tag == 1 {
            let alertV = UIAlertView(title: "", message: "现在去付款", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定")
            alertV.tag = 2
            alertV.show()
        }
            else if alertView.tag == 2 {
            //去支付
                if buttonIndex == 1 {
                    AliplayFunc()
                }
                else {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
    }
    
    //提示信息
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        if section == 0 {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 30))
            view.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
            let content = UILabel(frame: CGRect(x: 15, y: 5, width: 300, height: 20))
            content.text = "当日17点之前下单，预计2-3天可送达"
            content.font = UIFont.systemFontOfSize(15)
            content.textColor = UIColor.whiteColor()
            view.addSubview(content)
            view.backgroundColor = UIColor(red: 47/255, green: 137/255, blue: 227/255, alpha: 1)
            return view
        } else {
            return nil
        }
    }
    
    
//    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if section == 1 {
//            let screenW = self.view.frame.size.width
//            let currentB = UIButton(frame: CGRect(x: 13, y: 8, width: 90, height: 30))
//            currentB.setTitle( isEnglish ? "CarType" : "当前车型：", forState: UIControlState.Normal)
//            currentB.titleLabel?.font = UIFont.systemFontOfSize(15)
//            currentB.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
//            currentB.titleEdgeInsets = UIEdgeInsetsMake(3, -20, 3, 0)
//            currentB.titleLabel!.textAlignment = NSTextAlignment.Right
//            self.carL = UILabel(frame: CGRect (x: 85, y: 10, width: screenW - 165, height: 25))
//            carL.text = isEnglish ? "Please choose your car type" : "请选择车型"
//            carL.textColor = UIColor.grayColor()
//            carL.font = UIFont.systemFontOfSize(15)
//            let changeB = UIButton(frame: CGRect(x: 0, y: 8, width: screenW, height: 25))
//            changeB.backgroundColor = UIColor.clearColor()
//            changeB.tag = 222
//            changeB.layer.cornerRadius = 7.0
//            changeB.addTarget(self, action: #selector(PersonalMsgTableViewController.btnClick(_:)), forControlEvents: UIControlEvents.TouchUpInside)
//            let cell = UITableViewCell()
//            cell.addSubview(currentB)
//            cell.addSubview(carL)
//            cell.addSubview(changeB)
//            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
//            cell.backgroundColor = UIColor.whiteColor()
//            return cell
//        }
//        else{
//            return nil
//        }
//    }

    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
                return 30
        }
        
        return 15
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 5 {
            return 50
        }
        else {
            return 40
        }
    }
    
    //备注信息输入完后将其内容赋值给choice[6]
    func textFieldDidEndEditing(textField: UITextField) {
        choice[6] = textField.text!
    }
    
    //底部的汇总信息及确认按钮栏
    func footerView()->UIView {
        let screenW = self.view.frame.width
        let titleText = ["商品总价：","运费：","合计：","赠送积分："]
        //处理具体数据，
        //totalData:商品数量，总重量，商品总价，运费，合计，赠送积分
        for i in 0..<data.count {
            totalData[0] += Double(data[i].quantity)
            totalData[2] += Double(data[i].amount)
        }
        //运费部分待处理
        totalData[4] = totalData[2] + totalData[3]
        totalData[5] = totalData[2]
        let view = UIView(frame: CGRect(x: 0, y: 0, width: Int(screenW), height: Int((titleText.count + 1) * 30 + 60)))
        
        let totalMsg = UILabel(frame: CGRect(x: 10, y: 10, width: screenW - 20, height: 20))
        totalMsg.text = "共" + String(Int(totalData[0])) + "件商品，总重" + String(totalData[1]) + "kg"
        totalMsg.font = UIFont.systemFontOfSize(14)
        totalMsg.textAlignment = NSTextAlignment.Right
        view.addSubview(totalMsg)
        
        for i in 0..<titleText.count {
            let content = UILabel(frame: CGRectZero)
            //计算label的高度
            var contentText:NSString = "¥" + String(format:"%.2f",totalData[i + 2])
            if i == 3 {
                contentText = String(format:"%.2f",totalData[i + 2])
            }
            price = String(format:"%.2f",totalData[i + 2])
            let font = UIFont.systemFontOfSize(14)
            let attributes = [NSFontAttributeName: UIFont.systemFontOfSize(14)]
            let option = NSStringDrawingOptions.UsesLineFragmentOrigin
            let text: NSString = NSString(CString: contentText.cStringUsingEncoding(NSUTF8StringEncoding),
                encoding: NSUTF8StringEncoding)!
            var rect = text.boundingRectWithSize(CGSizeMake(200, 300), options: option, attributes: attributes, context: nil)
            rect.origin.x = screenW - rect.width - 10
            rect.origin.y = CGFloat(i * 20 + 40)
            content.font = font
            content.frame = rect
            content.text = contentText as String
            content.textColor = UIColor.redColor()
            view.addSubview(content)
            
            let title = UILabel(frame: CGRectMake((screenW - 90 - rect.width), CGFloat(i * 20 + 40), 80, 20))
            title.text = titleText[i]
            title.textAlignment = NSTextAlignment.Right
            title.font = UIFont.systemFontOfSize(14)
            view.addSubview(title)
            
            let submit = UIButton(frame: CGRect(x: 0, y: (titleText.count + 1) * 30, width: Int(screenW) , height: 40))
            submit.setTitle("提交", forState: UIControlState.Normal)
            submit.titleLabel!.textAlignment = NSTextAlignment.Center
            submit.titleLabel!.font = UIFont.systemFontOfSize(15)
            submit.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            submit.layer.cornerRadius = 3.0
            submit.backgroundColor = UIColor.orangeColor()
            submit.addTarget(self, action: #selector(MakeOrderTableViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            submit.tag = 1
            view.addSubview(submit)
        }
        return view
        
    }
    
    func getShopCarID()->[Int]{
            var shopCarIDs:[Int] = []
            for i in 0..<self.data.count {
                shopCarIDs.append(self.data[i].id)
            }
            return shopCarIDs
    }
    
    func AliplayFunc(){
                let Orders = Order()
                Orders.partner = AlipayConfig.partner
                Orders.seller = AlipayConfig.seller
                Orders.productName = "购买配件"
                Orders.productDescription = "配件"
//                Orders.amount = self.price ;//（价格必须小数点两位）
        Orders.amount = "0.01" ;//（价格必须小数点两位）
                Orders.tradeNO = self.tradeNO
                Orders.notifyURL = "http://www.ico2o.cn";//
                Orders.service = "mobile.securitypay.pay"
                Orders.paymentType = "1"
                Orders.inputCharset = "utf-8"
                Orders.itBPay = "30m"
                Orders.showUrl = "m.alipay.com"
                let appScheme = "AlipayDemo"
                let orderSpec = Orders.description;
                let signer = CreateRSADataSigner(AlipayConfig.privateKey);
                let signedString = signer.signString(orderSpec);
                let orderString = "\(orderSpec)&sign=\"\(signedString)\"&sign_type=\"RSA\"";
                AlipaySDK.defaultService().payOrder(orderString, fromScheme: appScheme, callback: { (resultDic) -> Void in
                    print("reslut = \(resultDic)");
                    if let Alipayjson = resultDic as? NSDictionary{
                    let resultStatus = Alipayjson.valueForKey("resultStatus") as! String
                    if resultStatus == "9000"{
                    print("OK")
                }else if resultStatus == "8000" {
                    print("正在处理中")
                    self.navigationController?.popViewControllerAnimated(true)
                }else if resultStatus == "4000" {
                    print("订单支付失败");
                    self.navigationController?.popViewControllerAnimated(true)
                }else if resultStatus == "6001" {
                    print("用户中途取消")
                    self.navigationController?.popViewControllerAnimated(true)
                }else if resultStatus == "6002" {
                    print("网络连接出错")
                    self.navigationController?.popViewControllerAnimated(true)
                    }
                    }
                    })
    }
}
