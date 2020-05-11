//
//  oderListTableViewController.swift
//  ico2o
//
//  Created by 覃红 on 2017/1/9.
//  Copyright © 2017年 chingyam. All rights reserved.
//

import UIKit
import Alamofire
import JSONNeverDie
import Kingfisher

class oderListTableViewController: UITableViewController,OrdersHeaderViewDelegate {
    
    var data:[[[[String]]]] = []
    var screenW:CGFloat = 0

    var orderList:[ProductModel] = []
    var listData: NSDictionary = NSDictionary()
    var filePath = NSBundle.mainBundle().pathForResource("config.plist", ofType:nil )
    var getOrderURL = "/ASHX/MobileAPI/Order/GetOrder.ashx"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenW = self.view.frame.width

        listData = NSDictionary(contentsOfFile: filePath!)!
        getOrderURL = listData.valueForKey("url") as! String + getOrderURL
        self.tableView.separatorStyle = .None

        dataInit()

    }

    func dataInit() {
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

        
    
    }
    
    
    func iii() {
        self.tableView.backgroundView = nil
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.data.count
    }
    

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if data.count == 0 {
            return 1
        }
        else {
            return data[section].count
        }
    }
    
    func btnClicked(btn:UIButton){
        //若所点击的为headerview或footerview里的按钮，判断其属于哪一个section
        var section = 0
        if btn.tag == 1 || btn.tag == 2 {
            section = (btn.superview!).tag / 100
        }
        else if btn.tag == 3 || btn.tag == 4 || btn.tag == 5 {
            section = (btn.superview!).tag / 1000
        }
        //使用通知将订单号呈现至上一次页面
        print(data[section][0][0][0])
        NSNotificationCenter.defaultCenter().postNotificationName("NotificationIdentifier", object: data[section][0][0][0])
        self.navigationController?.popViewControllerAnimated(true)
    
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
    

    //订单底部信息及按钮栏
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if data.count != 0 {
            let screenW = self.view.frame.size.width
            let view = UIView(frame: CGRect(x: 0, y: 0, width: screenW, height: 10))
            view.backgroundColor = UIColor.whiteColor()
            
            let stateBtn = UIButton(frame: CGRect(x: (screenW / 2) - 140, y: 2, width: 280, height: 30))
            stateBtn.setTitle("选择此订单", forState: UIControlState.Normal)
            stateBtn.backgroundColor = UIColor.orangeColor()
            stateBtn.titleLabel!.textAlignment = NSTextAlignment.Center
            stateBtn.titleLabel!.font = UIFont.systemFontOfSize(13)
            stateBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            stateBtn.layer.cornerRadius = 3.0
            stateBtn.addTarget(self, action: #selector(MyOrderViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            stateBtn.tag = 5
            view.addSubview(stateBtn)
            let line2 = UILabel(frame: CGRect(x: 0, y: 40, width: screenW, height: 5))
            line2.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
            view.addSubview(line2)
            view.tag = section * 1000
            return view
        }
        else {
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 92
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 92
    }


}
