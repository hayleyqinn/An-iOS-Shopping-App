//
//  orderDetailViewController.swift
//  ico2o
//
//  Created by 覃红 on 2016/7/14.
//  Copyright © 2016年 chingyam. All rights reserved.
//


import UIKit
import Alamofire
import JSONNeverDie
import Kingfisher

class orderDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var data:[[[String]]] = []
    var price = ""
    var row = 0
    var proID = 0
    var listData: NSDictionary = NSDictionary()
    var filePath = NSBundle.mainBundle().pathForResource("config.plist", ofType:nil )
    @IBOutlet weak var stateT: UITextField!
    @IBOutlet weak var orderID: UITextField!
    @IBOutlet weak var orderDate: UITextField!
    @IBOutlet weak var receiveName: UITextField!
    @IBOutlet weak var addr: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var priceText: UITextField!
    
    override func viewDidLoad() {
        listData = NSDictionary(contentsOfFile: filePath!)!
        tableView.delegate = self
        //取消选中的状态
        tableView.dataSource = self
        orderID.text = data[0][0][0]
        orderDate.text = (data[0][9][0]).stringByReplacingOccurrencesOfString("T", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil)
        priceText.text = price
        receiveName.text = data[0][10][0] + " " +  data[0][11][0]
        addr.text = data[0][12][0]
        tableView.separatorStyle = .None
        
        switch data[0][7][0] {
        case "HasOrder":
            stateT.text = "待付款"
        case "OrderHadCancelled":
            stateT.text = "已取消"
        case "OrderAlreadyForIncomed", "OrderPayed", "WaitToConsignment":
            stateT.text = "待发货"
        case "OrderAlreadyForDeliver":
            stateT.text = "已发货"
        case "OrderHadFinished":
            stateT.text = "交易成功"
        default: break
        }
       
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //取消选中的状态
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.proID = Int(data[indexPath.row][8][0])!
        self.performSegueWithIdentifier("orderDetailToGoodDetail", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "orderDetailToGoodDetail" {
            let receive = (segue.destinationViewController as! UINavigationController)
            let a = receive.viewControllers[0] as! GoodDetailTableViewController
            a.goodMsgFromOther = proID
            
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let screenW = self.view.frame.size.width
        //let screenH = self.view.frame.size.height
        //设置单元格重用，重用标记为“cell”
        let cell = tableView.dequeueReusableCellWithIdentifier("itemCell")
     
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
        
        let url = NSURL(string: listData.valueForKey("url") as! String + "/" + data[indexPath.row][1][0])!
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
        name.text = data[indexPath.row][2][0]
        name.font = UIFont.systemFontOfSize(13)
        name.numberOfLines = 0;
        name.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cell?.contentView.addSubview(name)
        
        let kind = UILabel(frame: CGRect(x: 80, y: 60, width: 170, height: 20))
        kind.text = "编码:" + data[indexPath.row][3][0]
        kind.font = UIFont.systemFontOfSize(13)
        cell?.contentView.addSubview(kind)
        
        let price = UILabel(frame: CGRect(x: screenW - 75, y: 10, width: 70, height: 20))
        let a = Float(data[indexPath.row][4][0])
        price.text = "¥" + String(format: "%.2f", a!)
        price.font = UIFont.systemFontOfSize(13)
        price.textAlignment = NSTextAlignment.Right
        cell?.contentView.addSubview(price)
        
        let countL = UILabel(frame: CGRect(x: (screenW - 45), y: 42, width: 40, height: 20))
        countL.text = "x" + data[indexPath.row][5][0]
        countL.font = UIFont.systemFontOfSize(14)
        countL.textAlignment = NSTextAlignment.Center
        cell?.contentView.addSubview(countL)
        
        let line = UILabel(frame: CGRect(x: 0, y: 90, width: screenW, height: 1))
        line.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
        cell?.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        cell?.contentView.addSubview(line)
        return cell!
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 92
    }
    
    
}
