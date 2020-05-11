//
//  MyCollectionTableViewController.swift
//  ico2o
//
//  Created by Katherine on 15/12/10.
//  Copyright © 2015年 chingyam. All rights reserved.
//

import UIKit
import Alamofire
import JSONNeverDie
import Kingfisher

class MyCollectionTableViewController: UITableViewController,ChangeCountAlertViewDelegate,ChoosePropertyAlertViewDelegate {
    /*count:显示数量的按钮
    countText：用作设置count的内容
    alter：点击count后修改数量的弹出框
    typeClickedIndex：当前点击的属性按钮位置
    properties：商品属性
    */
    var data:[CollectionModel] = []
    var count = UIButton()
    var countText = ""
    var alter:ChangeCountAlterView?
    var typeClickedIndex = 0
    var properties:[[String]] = []
    var listData: NSDictionary = NSDictionary()
    var filePath = NSBundle.mainBundle().pathForResource("config.plist", ofType:nil )
    var getCollectionURL = ""
    var addShoppingCarURL = ""
    var deleteCollectionURL = ""
    //返回上一页
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listData = NSDictionary(contentsOfFile: filePath!)!
        getCollectionURL = listData.valueForKey("url") as! String + "/ASHX/MobileAPI/Collection/Get.ashx"
        addShoppingCarURL = listData.valueForKey("url") as! String + "/ASHX/MobileAPI/ShopCar/Add.ashx"
        deleteCollectionURL = listData.valueForKey("url") as! String +  "/ASHX/MobileAPI/Collection/Delete.ashx"
        dataInit()
    }
    
    //加载数据
    func dataInit() {
        data = []
        let place = "白色"
   
        let count = "1"
       
        
        //移除已存在的cell以免影响后边“Loading”的显示效果
        for cell in tableView.visibleCells {
            cell.removeFromSuperview()
        }
        //设置加载动图
        let imgView = UIImageView(image: UIImage.gifWithName("loading2"))
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: tableView.frame.height))
        imgView.frame = CGRect(x: (view.frame.width) / 2 - 150, y: (view.frame.height) / 2 - 150, width: 300, height: 300)
        view.addSubview(imgView)
        tableView.backgroundView = view
        
        
        let parameters = ["UserID": NSUserDefaults.standardUserDefaults().integerForKey("UserID")
            , "PageNO": 1, "PageSize:int": 1]

        //加载数据
        Alamofire.request(.POST, getCollectionURL , parameters:parameters)
            .response { request ,response ,data , eror in
                let json = JSONND.initWithData(data!)
                print(json)
                let jsonarray = json.arrayValue
                for i in 0..<jsonarray.count {
                    let proID = jsonarray[i]["ProID"].intValue
                    let proName = jsonarray[i]["Product"]["ProName"].stringValue
                    let CollectionID = jsonarray[i]["ID"].intValue
                    let shopPrice = jsonarray[i]["Product"]["ShopPrice"].floatValue
                    let imagePath = self.listData.valueForKey("url") as! String + "/\(jsonarray[i]["Product"]["ImagePath"].stringValue)"
                    //过滤空的数据
                    
                    if (proName != "") {
                        let product = CollectionModel(proID: proID, proName: proName, imagePath: imagePath, place: place, shopPrice: shopPrice, count: count, CollectionID: CollectionID)
                        self.data.append(product)
                    }
                 
                }
                _ = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(GoodsListTableViewController.iii), userInfo: nil, repeats: false)
        }
    }
    
    func iii() {
        self.tableView.backgroundView = nil
        self.tableView.reloadData()
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
        //0:删除多项,1:加入购物车,2:更改商品数量,3:属性,111:下一步
        let cell = btn.superview!.superview as! UITableViewCell
        typeClickedIndex = tableView.indexPathForCell(cell)!.row
        switch btn.tag {
        case 0:
            break
        case 1:
            let userID = NSUserDefaults.standardUserDefaults().integerForKey("UserID")
            let goodID = data[typeClickedIndex].proID
            let quantity = data[typeClickedIndex].count
            let parameters = ["UserID":userID, "ProductID":"[\(goodID)]", "Quantity": "[\(quantity)]"]
            print(parameters)
            Alamofire.request(.POST, addShoppingCarURL, parameters:parameters as? [String : AnyObject])
                .response { (request, response, data, error) in
            }
            self.navigationController?.view.makeToast("成功加入购物车！")
            break
        case 2:
            alter = ChangeCountAlterView(title:"修改商品数量", account:1,delegate: self)
            alter!.show()
            count = btn
        case 3:
            //先取得当前的indexPath，根据indexPath更新属性数据源，再弹出框供用户修改
           
            properties = [["白色","黑色","灰色","蓝色","红色","紫色","黄色","绿色"],["aaaaa","xxxx"]]
            let alertV = ChoosePropertyAlertView(title:  data[typeClickedIndex].proName , tips: "库存：100件", delegate: self, properties: properties,style :ChoosePropertyAlertViewStyle.noCountStyle)
            alertV.show()
        case 111:
            break
        default:
            break
        }
    }
    
    //获取已选择的商品属性
    func ChoosePropertyAlertViewOKBtnCliceked(alertView: ChoosePropertyAlertView) {
        var propertySelected = ""
        for i in 0..<(properties.count) {
            propertySelected += (alertView.propertySelected[i] + " ")
        }
        let typeBtn = tableView.visibleCells[typeClickedIndex].subviews[0].subviews[4] as! UIButton
        typeBtn.setTitle(propertySelected, forState: UIControlState.Normal)
    }
    
    //点击改变数量弹出框中的确定按钮后
    func selectOkButtonalertView() {
        //修改count和数据源的内容
        countText = String(alter!.account)
        count.setTitle(countText, forState: UIControlState.Normal)
        let cell = count.superview?.superview as! UITableViewCell
        let row = tableView.indexPathForCell(cell)?.row
        data[row!].count = countText
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
        
      
            let model = data[indexPath.row]
            //初始化URL并且获取图片地址
            let url : NSURL = NSURL(string: "\(model.imagePath)")!
            //初始化imageview并获取image
            let pic = UIImageView(frame: CGRect(x: 5, y: 10, width: 70, height: 70))
            pic.kf_showIndicatorWhenLoading = true
            pic.kf_setImageWithURL(url, placeholderImage: nil,
                                   optionsInfo: [.Transition(ImageTransition.Fade(1))],
                                   progressBlock: { receivedSize, totalSize in
                                    //print("\(receivedSize)/\(totalSize)")
                },
                                   completionHandler: { image, error, cacheType, imageURL in
            })
            cell!.contentView.addSubview(pic)
            
            let name = UILabel(frame: CGRect(x: 80, y: 10, width: screenW - 140, height: 35))
            name.text = data[indexPath.row].proName
            name.font = UIFont.systemFontOfSize(13)
            name.numberOfLines = 0;
            name.lineBreakMode = NSLineBreakMode.ByWordWrapping
            cell!.contentView.addSubview(name)
            
            let typeL = UILabel(frame: CGRect(x: 80, y: 70, width: 35, height: 20))
            typeL.text = "属性:"
            typeL.font = UIFont.systemFontOfSize(13)
            cell!.contentView.addSubview(typeL)
            
            let type = UIButton(frame: CGRect(x: 115, y: 70, width: screenW - 220, height: 20))
            type.setTitle(data[indexPath.row].place, forState: UIControlState.Normal)
            type.titleLabel!.font = UIFont.systemFontOfSize(13)
            type.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
            type.titleLabel?.textAlignment = NSTextAlignment.Left
            type.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            type.tag = 3
            type.addTarget(self, action: #selector(MyCollectionTableViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell!.contentView.addSubview(type)
            
            let price = UILabel(frame: CGRect(x: screenW - 70, y: 10, width: 65, height: 20))
            let a = Float(data[indexPath.row].shopPrice)
            price.text = "¥" + String(format: "%.2f", a)
            price.font = UIFont.systemFontOfSize(14)
            price.textAlignment = NSTextAlignment.Right
            price.textColor = UIColor.redColor()
            cell!.contentView.addSubview(price)
            
            let countL = UILabel(frame: CGRect(x: (screenW - 85), y: 44, width: 40, height: 20))
            countL.text = "数量："
            countL.font = UIFont.systemFontOfSize(13)
            countL.textAlignment = NSTextAlignment.Center
            cell!.contentView.addSubview(countL)
            
            count = UIButton(frame: CGRect(x: (screenW - 45), y: 43, width: 40, height: 20))
            count.setTitle(data[indexPath.row].count, forState: UIControlState.Normal)
            count.titleLabel!.textAlignment = NSTextAlignment.Center
            count.titleLabel!.font = UIFont.systemFontOfSize(13)
            count.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            count.backgroundColor = UIColor.whiteColor()
            count.addTarget(self, action: #selector(MyCollectionTableViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            count.tag = 2
            cell!.contentView.addSubview(count)
            
            let add = UIButton(frame: CGRect(x: (screenW - 85), y: 70, width: 80, height: 20))
            add.setTitle("加入购物车", forState: UIControlState.Normal)
            add.titleLabel!.textAlignment = NSTextAlignment.Center
            add.titleLabel!.font = UIFont.systemFontOfSize(13)
            add.layer.cornerRadius = 3.0
            add.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            add.backgroundColor = UIColor(red: 10/255, green: 108/255, blue: 255/255, alpha: 1.0)
            add.addTarget(self, action: #selector(MyCollectionTableViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            add.tag = 1
            cell!.contentView.addSubview(add)
            
            cell!.tag = indexPath.row
            cell!.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
        
        
        return cell!
    }
    
    //滑动删除
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath){
        //删除数据源的对应数据
        let parameters = ["UserID": NSUserDefaults.standardUserDefaults().integerForKey("UserID"), "CollectionID": data[indexPath.row].CollectionID]
        Alamofire.request(.POST, deleteCollectionURL, parameters:parameters)
            .response { (request, response, data, error) in
        }
        
        data.removeAtIndex(indexPath.row)
        //删除对应的cell
        self.tableView?.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top)
        
        //tableView.reloadData()
        
    }
    //把delete改成中文
    override func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String {
        return "删除"
    }
    
    //点击商品转跳至商品详情页面
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("MyCollectionToGoodDetail", sender: self)
    }
    
    //转跳时传递相应数据
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //点击商品转跳至商品详情页面
        if segue.identifier == "MyCollectionToGoodDetail" {
            let receive = (segue.destinationViewController as! UINavigationController)
            let a = receive.viewControllers[0] as! GoodDetailTableViewController
            let indexPath: NSIndexPath = self.tableView.indexPathForSelectedRow!
            a.goodMsgFromOther = data[indexPath.row].proID
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 97
    }
}
