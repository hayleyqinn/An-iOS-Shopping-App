//
//  orderListTableViewController.swift
//  
//
//  Created by 覃红 on 2017/1/8.
//
//

import UIKit
import Alamofire
import JSONNeverDie
import Kingfisher

class orderListTableViewController: UITableViewController {
    var screenW:CGFloat = 0

    var listData: NSDictionary = NSDictionary()
    var filePath = NSBundle.mainBundle().pathForResource("config.plist", ofType:nil )
    var getOrderURL = "/ASHX/MobileAPI/Order/GetOrder.ashx"
    var data:[[[[String]]]] = []
    var tempIndex: NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("hahahhh")
        screenW = self.view.frame.width

        listData = NSDictionary(contentsOfFile: filePath!)!
        getOrderURL = listData.valueForKey("url") as! String + getOrderURL
        
        self.tableView.separatorStyle = .None
        
    }

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

    
    //订单底部信息及按钮栏
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if data.count != 0 {
            let screenW = self.view.frame.size.width
            let view = UIView(frame: CGRect(x: 0, y: 0, width: screenW, height: 40))
            view.backgroundColor = UIColor.whiteColor()
            
            let changeBtn = UIButton(frame: CGRect(x: (screenW - 140), y: 52, width: 60, height: 20))
            changeBtn.setTitle("退换货", forState: UIControlState.Normal)
            changeBtn.titleLabel!.textAlignment = NSTextAlignment.Center
            changeBtn.titleLabel!.font = UIFont.systemFontOfSize(13)
            changeBtn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            changeBtn.addTarget(self, action: #selector(MyOrderViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            changeBtn.tag = 4
            view.addSubview(changeBtn)
            
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

    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 80
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
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

   
}
