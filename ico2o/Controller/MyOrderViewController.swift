//
//  MyOrderViewController.swift
//  ico2o
//
//  Created by Katherine on 16/1/20.
//  Copyright © 2016年 chingyam. All rights reserved.
//

import UIKit
import Alamofire
import JSONNeverDie
import Kingfisher

class MyOrderViewController: UIViewController, OrdersHeaderViewDelegate, UITableViewDataSource, UITableViewDelegate {
    var orderList:[ProductModel] = []
    let dd = ["dad", 13, "adad"]
    var listData: NSDictionary = NSDictionary()
    var filePath = NSBundle.mainBundle().pathForResource("config.plist", ofType:nil )
    var getOrderURL = "/ASHX/MobileAPI/Order/GetOrder.ashx"
    @IBOutlet weak var titleBtnView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var screenW:CGFloat = 0
    let titleText = ["全部","待付款","待发货","已发货","已评价"]
    var titleBtn:[UIButton] = []
    var data:[[[[String]]]] = []
    //为了下一个界面弹回时动画不错乱
    var isPop = true
    var radioState:[Bool] = []
    var pageSelected = 0
    var tempIndex: NSIndexPath?
    var totalPrice:Float = 10.0
    var stateText = ""
    var priceArr = [String]()
    var btnTagForReturnGoods  = 0
    
    //返回上一页
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        //上一个界面来的，则执行，pop来的不必执行此函数也有数据
        if !isPop {
            dataInit("全部")
            isPop = true
        }
    }
    override func viewDidLoad() {
        listData = NSDictionary(contentsOfFile: filePath!)!
        getOrderURL = listData.valueForKey("url") as! String + getOrderURL
        super.viewDidLoad()
        screenW = self.view.frame.width
        setTitleView(titleText)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .None
        tableView.tableHeaderView = headerView()
    
        radioState = stateInit()
    }
    //根据dataType加载目标数据
    func dataInit(dataType:String) {
        self.data = []
        let postage = ["10"]
        let userID = NSUserDefaults.standardUserDefaults().integerForKey("UserID")
        let parameters = ["UserID":"\(userID)", "IsShopper":"false", "PageNO": "0", "Status":""]
        //移除已存在的cell以免影响后边“Loading”的显示效果
        for cell in tableView.visibleCells {
            cell.removeFromSuperview()
        }
        //设置加载动图
        let imgView = UIImageView(image: UIImage.gifWithName("loading2"))
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: tableView.frame.height))
        imgView.frame = CGRect(x: (view.frame.width) / 2 - 150, y: (view.frame.height) / 2 - 150, width: 300, height: 300)
        view.addSubview(imgView)
        self.tableView.backgroundView = view
        
        switch dataType {
        case "全部":
            Alamofire.request(.POST, getOrderURL , parameters:parameters)
                .response { request ,response ,data , eror in
                    let json = JSONND.initWithData(data!)
                 // print(json)
                    let jsonarray = json.arrayValue
                    if jsonarray.count != 0 {
                        //获取数据
                        for i in 0..<jsonarray.count {
                            self.data.append([])
                            let secItem = jsonarray[i]["ListOrdersItem"].arrayValue
                            for j in 0..<secItem.count{
                                let orderNum = ["\(jsonarray[i]["OrderNO"].stringValue)"]
                                let state = ["\(jsonarray[i]["Status"].stringValue)"]
                                let pic = ["\(secItem[j]["ImagePath"].stringValue)"]
                                let proNO = ["\(secItem[j]["ProductID"].intValue)"]
                                let name = ["\(secItem[j]["Name"].stringValue)"]
                                let price = ["\(secItem[j]["Price"].floatValue)"]
                                let count = ["\(secItem[j]["Quantity"].intValue)"]
                                let no = ["\(secItem[j]["NO"].stringValue)"]
                                let createdDate = ["\(jsonarray[i]["CreatedDate"].stringValue)"]
                                let receiveName = ["\(jsonarray[i]["Name"].stringValue)"]
                                let receiveMobile = ["\(jsonarray[i]["Mobile"].stringValue)"]
                                let orderID = ["\(jsonarray[i]["ID"].stringValue)"]
                                
//                              let receiveAddress = ["\(jsonarray[i]["Address"].stringValue)\(jsonarray[i]["Areas"].stringValue)\(jsonarray[i]["City"].stringValue)\(jsonarray[i]["District"].stringValue)"]
                                let OrderItemID = ["\(secItem[j]["OrderID"].intValue)"]
                                
                                
                                let receiveAddress = ["\(jsonarray[i]["Address"].stringValue)"]
                                let good = [orderNum,pic,name,no,price,count,postage,state,proNO,createdDate,receiveName,receiveMobile,receiveAddress,orderID,OrderItemID]
                                self.data[i].append(good)
                                
                            }
                        }
                        if self.data.count == 0{
                            let tips = UILabel(frame: CGRect(x: 0, y: 0, width: self.screenW, height: 500))
                            tips.text = "暂无已发货订单"
                            tips.font = UIFont.systemFontOfSize(20)
                            tips.textAlignment = NSTextAlignment.Center
                            self.tableView.backgroundView = tips
                        }else {
                            //以0.1秒的间隔刷新table直到请求完成
                            _ = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(MyOrderViewController.iii), userInfo: nil, repeats: false)
                        }
                    }
            }
        case "待付款":
            Alamofire.request(.POST, getOrderURL , parameters:parameters)
                .response { request ,response ,data , eror in
                    let json = JSONND.initWithData(data!)
                    let jsonarray = json.arrayValue
                    if jsonarray.count != 0 {
                        //获取数据
                        for i in 0..<jsonarray.count {
                            if jsonarray[i]["Status"].stringValue != "HasOrder" {
                                continue
                            }
                            self.data.append([])
                            let secItem = jsonarray[i]["ListOrdersItem"].arrayValue
                            for j in 0..<secItem.count{
                                let orderNum = ["\(jsonarray[i]["OrderNO"].stringValue)"]
                                let state = ["\(jsonarray[i]["Status"].stringValue)"]
                                let pic = ["\(secItem[j]["ImagePath"].stringValue)"]
                                let proNO = ["\(secItem[j]["ProductID"].intValue)"]
                                let name = ["\(secItem[j]["Name"].stringValue)"]
                                let price = ["\(secItem[j]["Price"].floatValue)"]
                                let count = ["\(secItem[j]["Quantity"].intValue)"]
                                let no = ["\(secItem[j]["NO"].stringValue)"]
                                let createdDate = ["\(jsonarray[i]["CreatedDate"].stringValue)"]
                                let receiveName = ["\(jsonarray[i]["Name"].stringValue)"]
                                let receiveMobile = ["\(jsonarray[i]["Mobile"].stringValue)"]
                                let orderID = ["\(jsonarray[i]["ID"].stringValue)"]
                                //                                let receiveAddress = ["\(jsonarray[i]["Address"].stringValue)\(jsonarray[i]["Areas"].stringValue)\(jsonarray[i]["City"].stringValue)\(jsonarray[i]["District"].stringValue)"]
                                let receiveAddress = ["\(jsonarray[i]["Address"].stringValue)"]
                                let good = [orderNum,pic,name,no,price,count,postage,state,proNO,createdDate,receiveName,receiveMobile,receiveAddress,orderID]
                                self.data[self.data.count - 1].append(good)
                            }
                        }
                        if self.data.count == 0{
                            let tips = UILabel(frame: CGRect(x: 0, y: 0, width: self.screenW, height: 500))
                            tips.text = "暂无待付款订单"
                            tips.font = UIFont.systemFontOfSize(20)
                            tips.textAlignment = NSTextAlignment.Center
                            self.tableView.backgroundView = tips
                        }else {
                            //以0.1秒的间隔刷新table直到请求完成
                            _ = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(MyOrderViewController.iii), userInfo: nil, repeats: false)
                        }
                    }
            }
        case "待发货":
            Alamofire.request(.POST, getOrderURL , parameters:parameters)
                .response { request ,response ,data , eror in
                    let json = JSONND.initWithData(data!)
                    let jsonarray = json.arrayValue
                    if jsonarray.count != 0 {
                        //获取数据
                        for i in 0..<jsonarray.count {
                            if jsonarray[i]["Status"].stringValue != "WaitToConsignment" && jsonarray[i]["Status"].stringValue != "OrderAlreadyForIncomed" && jsonarray[i]["Status"].stringValue != "OrderPayed"  {
                                continue
                            }
                            self.data.append([])
                            let secItem = jsonarray[i]["ListOrdersItem"].arrayValue
                            for j in 0..<secItem.count{
                                let orderNum = ["\(jsonarray[i]["OrderNO"].stringValue)"]
                                let state = ["\(jsonarray[i]["Status"].stringValue)"]
                                let pic = ["\(secItem[j]["ImagePath"].stringValue)"]
                                let proNO = ["\(secItem[j]["ProductID"].intValue)"]
                                let name = ["\(secItem[j]["Name"].stringValue)"]
                                let price = ["\(secItem[j]["Price"].floatValue)"]
                                let count = ["\(secItem[j]["Quantity"].intValue)"]
                                let no = ["\(secItem[j]["NO"].stringValue)"]
                                let createdDate = ["\(jsonarray[i]["CreatedDate"].stringValue)"]
                                let receiveName = ["\(jsonarray[i]["Name"].stringValue)"]
                                let receiveMobile = ["\(jsonarray[i]["Mobile"].stringValue)"]
                                let orderID = ["\(jsonarray[i]["ID"].stringValue)"]
                                //                                let receiveAddress = ["\(jsonarray[i]["Address"].stringValue)\(jsonarray[i]["Areas"].stringValue)\(jsonarray[i]["City"].stringValue)\(jsonarray[i]["District"].stringValue)"]
                                let receiveAddress = ["\(jsonarray[i]["Address"].stringValue)"]
                                let good = [orderNum,pic,name,no,price,count,postage,state,proNO,createdDate,receiveName,receiveMobile,receiveAddress,orderID]
                                self.data[self.data.count - 1].append(good)
                            }
                        }
                        if self.data.count == 0{
                            let tips = UILabel(frame: CGRect(x: 0, y: 0, width: self.screenW, height: 500))
                            tips.text = "暂无待发货订单"
                            tips.font = UIFont.systemFontOfSize(20)
                            tips.textAlignment = NSTextAlignment.Center
                            self.tableView.backgroundView = tips
                        }else {
                            //以0.1秒的间隔刷新table直到请求完成
                            _ = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(MyOrderViewController.iii), userInfo: nil, repeats: false)
                        }
                    }
            }
        case "已发货":
            Alamofire.request(.POST, getOrderURL , parameters:parameters)
                .response { request ,response ,data , eror in
                    let json = JSONND.initWithData(data!)
                    let jsonarray = json.arrayValue
                    if jsonarray.count != 0 {
                        //获取数据
                        for i in 0..<jsonarray.count {
                            if jsonarray[i]["Status"].stringValue != "OrderAlreadyForDeliver"{
                                continue
                            }
                            self.data.append([])
                            let secItem = jsonarray[i]["ListOrdersItem"].arrayValue
                            for j in 0..<secItem.count{
                                let orderNum = ["\(jsonarray[i]["OrderNO"].stringValue)"]
                                let state = ["\(jsonarray[i]["Status"].stringValue)"]
                                let pic = ["\(secItem[j]["ImagePath"].stringValue)"]
                                let proNO = ["\(secItem[j]["ProductID"].intValue)"]
                                let name = ["\(secItem[j]["Name"].stringValue)"]
                                let price = ["\(secItem[j]["Price"].floatValue)"]
                                let count = ["\(secItem[j]["Quantity"].intValue)"]
                                let no = ["\(secItem[j]["NO"].stringValue)"]
                                let createdDate = ["\(jsonarray[i]["CreatedDate"].stringValue)"]
                                let receiveName = ["\(jsonarray[i]["Name"].stringValue)"]
                                let receiveMobile = ["\(jsonarray[i]["Mobile"].stringValue)"]
                                let orderID = ["\(jsonarray[i]["ID"].stringValue)"]
                                //                                let receiveAddress = ["\(jsonarray[i]["Address"].stringValue)\(jsonarray[i]["Areas"].stringValue)\(jsonarray[i]["City"].stringValue)\(jsonarray[i]["District"].stringValue)"]
                                let receiveAddress = ["\(jsonarray[i]["Address"].stringValue)"]
                                let good = [orderNum,pic,name,no,price,count,postage,state,proNO,createdDate,receiveName,receiveMobile,receiveAddress,orderID]
                                self.data[self.data.count - 1].append(good)
                            }
                        }
                        if self.data.count == 0{
                            let tips = UILabel(frame: CGRect(x: 0, y: 0, width: self.screenW, height: 500))
                            tips.text = "暂无已发货订单"
                            tips.font = UIFont.systemFontOfSize(20)
                            tips.textAlignment = NSTextAlignment.Center
                            self.tableView.backgroundView = tips
                        }else {
                            //以0.1秒的间隔刷新table直到请求完成
                            _ = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(MyOrderViewController.iii), userInfo: nil, repeats: false)
                        }
                    }
            }
        default:
            break
        }
        
       
       
    }
    
    
    func iii() {
        self.tableView.backgroundView = nil
        self.tableView.reloadData()
    }
    
    //设置订单的多选按钮的选中的初始状态，默认为false为选中
    func stateInit()->[Bool] {
        var arr:[Bool] = []
        for _ in 0..<data.count {
            arr.append(false)
        }
        return arr
    }
    
    func setTitleView(title:[String]) {
        let width = Int(screenW) / title.count
//        let view = UIView(frame: CGRect(x: 0, y: 0, width: screenW, height: 41))
        for i in 0..<title.count {
            let btn = UIButton(frame: CGRect(x: width * i, y: 0, width: width, height: 40))
            btn.setTitle(title[i], forState: UIControlState.Normal)
            btn.titleLabel!.textAlignment = NSTextAlignment.Center
            btn.titleLabel!.font = UIFont.systemFontOfSize(15)
            btn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            btn.addTarget(self, action: #selector(MyOrderViewController.changePage(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            btn.tag = i
         
            titleBtnView.addSubview(btn)
            titleBtn.append(btn)
            if i == pageSelected {
                btn.setTitleColor(.blueColor(), forState: UIControlState.Normal)
            }
        }
        let line = UILabel(frame: CGRect(x: 0, y: 40, width: screenW, height: 1))
        line.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
        titleBtnView.addSubview(line)
        
    }
    
    func headerView()->UIView {
        let screenW = self.view.frame.size.width
        let view = UIView(frame: CGRect(x: 0, y: 0, width: screenW, height: 40))
        view.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1.0)
        
        let orderBtn = UIButton(frame: CGRect(x: (screenW - 90), y: 5, width: 80, height: 30))
        orderBtn.setTitle("预约维修店", forState: UIControlState.Normal)
        orderBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        orderBtn.backgroundColor = UIColor.orangeColor()
        orderBtn.titleLabel?.textAlignment = NSTextAlignment.Center
        orderBtn.titleLabel?.font = UIFont.systemFontOfSize(13)
        orderBtn.layer.cornerRadius = 5.0
        orderBtn.addTarget(self, action: #selector(MyOrderViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        orderBtn.tag = 111
        view.addSubview(orderBtn)
        
        return view
    }
    
    func changePage(btn:UIButton) {
        dataInit((btn.titleLabel?.text)!)
        self.tableView.setContentOffset(CGPointMake(0, 0),animated:false)
        for i in 0..<titleBtn.count {
            titleBtn[i].setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        }
        btn.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        tableView.reloadData()
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.data.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if data.count == 0 {
            return 1
        }
        else {
            return data[section].count
        }
        
    }
   
    //btn的点击事件
    func btnClicked(btn:UIButton){
        
        //若所点击的为headerview或footerview里的按钮，判断其属于哪一个section
        var section = 0
        if btn.tag == 1 || btn.tag == 2 {
            section = (btn.superview!).tag / 100
        }
        else if btn.tag == 3 || btn.tag == 4 || btn.tag == 5 {
            section = (btn.superview!).tag / 1000
        }
        
        //付款或评价
//        if btn.titleLabel!.text == "评价" {
//            self.performSegueWithIdentifier("MyOrderToGoodEvaluate", sender: self)
//        } else if btn.titleLabel!.text == "付款"{
//            AliplayFunc(btn.tag)
//        } else if btn.titleLabel!.text == "退换货" {
//            btnTagForReturnGoods = btn.tag
//            self.performSegueWithIdentifier("MyOrderToReturnedPurchase", sender: self)
//        }
        

        //111:预约维修店,1:radioBtn,2:删除订单,3:查看物流,4:退换货，5:订单状态修改（付款、评价等）
        switch btn.tag {
        case 111:
            self.performSegueWithIdentifier("MyOrderAllToStoreList", sender: self)
        case 1:
            var img = "radioBtn_2"
            if radioState[section] {
                img = "radioBtn_1"
            }
            btn.setImage(UIImage(named: img), forState: UIControlState.Normal)
            radioState[section] = !radioState[section]
        case 2:
            data.removeAtIndex(section)
            radioState.removeAtIndex(section)
            tableView.reloadData()
        case 3:
            let alertV = UIAlertView(title: "物流信息", message: "物流信息\n物流信息\n物流信息\n物流信息\n物流信息", delegate: nil, cancelButtonTitle: "确定")
            alertV.show()
        case 5:
            if btn.titleLabel!.text == "评价" {
                self.performSegueWithIdentifier("MyOrderToGoodEvaluate", sender: self)
            } else if btn.titleLabel!.text == "付款"{
                AliplayFunc(section)
            }
        case 4:
            btnTagForReturnGoods = section
            self.performSegueWithIdentifier("MyOrderToReturnedPurchase", sender: self)
        default:
            break
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let screenW = self.view.frame.size.width
            //let screenH = self.view.frame.size.height
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
        }
        
        if data.count != 0 {
            //pic:商品图片,name:商品名称,kind:属性，price:价格,countL：商品数量
            let url : NSURL = NSURL(string: listData.valueForKey("url") as! String + "/" + data[indexPath.section][indexPath.row][1][0])!
            let pic = UIImageView(frame: CGRect(x: 5, y: 10, width: 70, height: 70))
            pic.kf_showIndicatorWhenLoading = true
            pic.kf_setImageWithURL(url, placeholderImage: nil,
                                   optionsInfo: [.Transition(ImageTransition.Fade(1))],
                                   progressBlock: { receivedSize, totalSize in
                },
                                   completionHandler: { image, error, cacheType, imageURL in
            })
            cell?.contentView.addSubview(pic)
       
            let name = UILabel(frame: CGRect(x: 80, y: 10, width: screenW - 145, height: 50))
            name.text = data[indexPath.section][indexPath.row][2][0]
            name.font = UIFont.systemFontOfSize(13)
            name.numberOfLines = 0;
            name.lineBreakMode = NSLineBreakMode.ByWordWrapping
            cell?.contentView.addSubview(name)
            
            let kind = UILabel(frame: CGRect(x: 80, y: 60, width: 170, height: 20))
            kind.text = "编码:" + data[indexPath.section][indexPath.row][3][0]
            kind.font = UIFont.systemFontOfSize(13)
            cell?.contentView.addSubview(kind)
            
            let price = UILabel(frame: CGRect(x: screenW - 75, y: 10, width: 70, height: 20))
            let a = Float(data[indexPath.section][indexPath.row][4][0])!
            price.text = "¥" + String(format: "%.2f", a)
            price.font = UIFont.systemFontOfSize(13)
            price.textAlignment = NSTextAlignment.Right
            cell?.contentView.addSubview(price)
            
            let countL = UILabel(frame: CGRect(x: (screenW - 45), y: 42, width: 40, height: 20))
            countL.text = "x" + data[indexPath.section][indexPath.row][5][0]
            countL.font = UIFont.systemFontOfSize(14)
            countL.textAlignment = NSTextAlignment.Center
            cell?.contentView.addSubview(countL)
            
            let line = UILabel(frame: CGRect(x: 0, y: 90, width: screenW, height: 1))
            line.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
            cell?.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
            cell?.contentView.addSubview(line)
            cell?.selectionStyle = .None
        
        } else {
            
            cell?.removeFromSuperview()
            cell?.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1.0)
        }
        return cell!
        
    }
    
    //点击商品跳转到订单详情
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //取消选中的状态
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        tempIndex = indexPath
        self.performSegueWithIdentifier("orderToDetail", sender: self)
    }
    
    //跳转前传递数据
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "orderToDetail" {
            let receive = segue.destinationViewController as! orderDetailViewController
            receive.data = data[tempIndex!.section]
            receive.price = "￥" + "\(priceArr[(tempIndex?.section)!])"
        }
        if segue.identifier == "MyOrderToReturnedPurchase" {
            let receive = (segue.destinationViewController as! UINavigationController)
            let a = receive.viewControllers[0] as! ReturnedPurchaseTableViewController
            a.data = data[btnTagForReturnGoods]
        }
        
        
    }
    
    //订单标题栏
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //若无信息则不显示
        if data.count != 0 {
            let screenW = self.view.frame.size.width
            let headerView = OrdersHeaderView(title1: "订单号", content1: data[section][0][0][0], style: OrdersHeaderViewStyle.radioStyle, delegate: self,indexPath: NSIndexPath(index: section))
            headerView.frame = CGRect(x: 0, y: 0, width: screenW, height: 40)
            return headerView
        }
        else {
            return nil
        }
    }
    
    //删除整个订单记录
    func OrdersHeaderViewDeleteBtnClicked(headerView: OrdersHeaderView) {
        //先移除数据，再对tableview作处理
        let section = (headerView.indexPath?.section)!
        data.removeAtIndex(section)
        var delayTime:Double = 0
        //订单数目大于1时删除section，并延迟0.25秒reload tableview以更新headerview中的indexpath，否则直接reload
        if data.count != 0 {
            tableView.deleteSections(NSIndexSet(index: section), withRowAnimation: UITableViewRowAnimation.Top)
            delayTime = 0.25
        }
        _ = NSTimer.scheduledTimerWithTimeInterval(delayTime, target: self, selector: #selector(MyOrderViewController.delayReload), userInfo: nil, repeats: false)
    }
    
    func delayReload() {
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    //订单底部信息及按钮栏
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if data.count != 0 {
            let screenW = self.view.frame.size.width
            let view = UIView(frame: CGRect(x: 0, y: 0, width: screenW, height: 40))
            view.backgroundColor = UIColor.whiteColor()
            var totalCount = 0
            totalPrice = 10.0
            for i in 0..<data[section].count {
                totalPrice = totalPrice + Float(data[section][i][4][0])! * Float(data[section][i][5][0])!
                totalCount += Int(data[section][i][5][0])!
            }
            priceArr.append(String(format: "%.2f",totalPrice))
            let totalL = UILabel(frame: CGRect(x: 0, y: 10, width: screenW, height: 20))
            totalL.text = "共 " + String(totalCount) + " 件商品  合计：¥" + String(format: "%.2f",totalPrice) + "元（含运费¥" + String(data[section][0][6][0]) + "）"
            totalL.font = UIFont.systemFontOfSize(13)
            totalL.textAlignment = NSTextAlignment.Right
            view.addSubview(totalL)
            
            let line = UILabel(frame: CGRect(x: 0, y: 40, width: screenW, height: 2))
            line.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
            view.addSubview(line)
            
            let deliverBtn = UIButton(frame: CGRect(x: (screenW - 210), y: 52, width: 60, height: 20))
            deliverBtn.setTitle("查看物流", forState: UIControlState.Normal)
            deliverBtn.titleLabel!.textAlignment = NSTextAlignment.Center
            deliverBtn.titleLabel!.font = UIFont.systemFontOfSize(13)
            deliverBtn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            deliverBtn.addTarget(self, action: #selector(MyOrderViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            deliverBtn.tag = 3
            view.addSubview(deliverBtn)
            
            let changeBtn = UIButton(frame: CGRect(x: (screenW - 140), y: 52, width: 60, height: 20))
            changeBtn.setTitle("退换货", forState: UIControlState.Normal)
            changeBtn.titleLabel!.textAlignment = NSTextAlignment.Center
            changeBtn.titleLabel!.font = UIFont.systemFontOfSize(13)
            changeBtn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            changeBtn.addTarget(self, action: #selector(MyOrderViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            changeBtn.tag = 4
            view.addSubview(changeBtn)
            
            let stateBtn = UIButton(frame: CGRect(x: (screenW - 70), y: 47, width: 60, height: 30))
            //设置状态
            switch data[section][0][7][0] {
            case "HasOrder":
                stateBtn.setTitle("付款", forState: UIControlState.Normal)
                stateBtn.backgroundColor = .orangeColor()
            case "OrderHadCancelled":
                stateBtn.setTitle("已取消", forState: UIControlState.Normal)
                stateBtn.backgroundColor = .grayColor()
            case "OrderAlreadyForIncomed", "OrderPayed", "WaitToConsignment":
                stateBtn.setTitle("待发货", forState: UIControlState.Normal)
                stateBtn.backgroundColor = .greenColor()
            case "OrderAlreadyForDeliver":
                    stateBtn.setTitle("已发货", forState: UIControlState.Normal)
                    stateBtn.backgroundColor = .greenColor()
            case "OrderHadFinished":
                    stateBtn.setTitle("交易成功", forState: UIControlState.Normal)
                    stateBtn.backgroundColor = .greenColor()
            default:
                stateBtn.setTitle("\(data[section][0][7][0])", forState: UIControlState.Normal)
                stateBtn.backgroundColor = .greenColor()

            }
                
            stateBtn.titleLabel!.textAlignment = NSTextAlignment.Center
            stateBtn.titleLabel!.font = UIFont.systemFontOfSize(13)
            stateBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            stateBtn.layer.cornerRadius = 3.0
            stateBtn.addTarget(self, action: #selector(MyOrderViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            stateBtn.tag = 5
            view.addSubview(stateBtn)
            let line2 = UILabel(frame: CGRect(x: 0, y: 82, width: screenW, height: 10))
            line2.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
            view.addSubview(line2)
            view.tag = section * 1000
            return view
        }
        else {
            return nil
        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 92
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 92
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func AliplayFunc(section: Int){
        let Orders = Order()
        Orders.partner = AlipayConfig.partner
        Orders.seller = AlipayConfig.seller
        Orders.productName = "购买配件"
        Orders.productDescription = "配件"
        //Orders.amount = priceArr[section] ;//（价格必须小数点两位）
        Orders.amount = "0.01"
        Orders.tradeNO = data[section][0][0][0]
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
