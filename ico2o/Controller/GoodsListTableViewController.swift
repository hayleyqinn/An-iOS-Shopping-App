//
//  GoodsListTableViewController.swift
//  ico2o
//
//  Created by Katherine on 15/11/17.
//  Copyright © 2015年 chingyam. All rights reserved.
//

import UIKit
import Alamofire
import JSONNeverDie
import Kingfisher

class GoodsListTableViewController: UITableViewController, UISearchBarDelegate {

    /*
    data:在本页面中显示的商品数据
    goodMsgFromOther:从其他页面传来的需查找的商品信息
    */
    //var data:[[String]] = []
    //let test: UISearchBarDelegate?
    var goodMsgFromOther:String = ""
    var parameters:[String:AnyObject] = [:]
    var search: UISearchBar?
    var listData: NSDictionary = NSDictionary()
    var filePath = NSBundle.mainBundle().pathForResource("config.plist", ofType:nil )
    var headerURL:String = ""
    var getProductListURL = "/ASHX/MobileAPI/Product/Get.ashx"
    var getBySearchURL = "/ASHX/MobileAPI/Product/GetBySearch.ashx"
    var addShoppingCarURL = "/ASHX/MobileAPI/ShopCar/Add.ashx"
    var finalURL = ""
    var productList:[ProductModel] = []
    var nodata = false
    var proID:Int = 0
    var isSecondMenu:Bool = false
    var horse:String = ""
    var secondItem:String = ""
    var checkNetwork = CheckNetWorking()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        search?.becomeFirstResponder()
       
        listData = NSDictionary(contentsOfFile: filePath!)!
        headerURL = listData.valueForKey("url") as! String
        addShoppingCarURL = headerURL + addShoppingCarURL
        //导航栏
        self.navigationController?.navigationBar.pushNavigationItem(navInit(), animated: false)
        //判断当前查询数据的方式，goodMsgFromOther != "" 时，从搜索栏搜索，否则从上一页菜单中点击搜索
        if goodMsgFromOther != "" {
            finalURL = headerURL + getBySearchURL
        }
        else{
            finalURL = headerURL + getProductListURL
        }
        if isSecondMenu == true{
            finalURL = headerURL + "/ASHX/MobileAPI/LoveCarDocument/GetProducts.ashx"
        }
        dataInit()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }
    
    //导航栏的设置
    func navInit()->UINavigationItem {
        let navItem = UINavigationItem(title: "")
        search = UISearchBar(frame: CGRect(x: -40, y: 5, width: 280, height: 25))
        search!.delegate  = self
        search!.barStyle = UIBarStyle.Default
        search!.placeholder = "请输入配件名称或配件编号"
        
        navItem.titleView = search
        
        let leftBtn = UIBarButtonItem(image: UIImage(named: "back"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(GoodsListTableViewController.btnClicked(_:)))
        leftBtn.tag = 1
        let rightBtn = UIBarButtonItem(image: UIImage(named: "top_shoppingcart"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(GoodsListTableViewController.btnClicked(_:)))
        rightBtn.tag = 2
        navItem.setLeftBarButtonItem(leftBtn, animated: false)
        navItem.setRightBarButtonItem(rightBtn, animated: false)
    
        return navItem
    }
    
    //初始化数据
    func dataInit() {
        //将数组和标记清空，防止上一次查询的数据残留影响下一次查询结果
        productList = []
        nodata = false
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
        if(isSecondMenu){
            parameters = ["Horse":horse,"SortSecondName":secondItem]
        }
        if(!checkNetwork.checkNetwork()){
            return
        }
        
        print("pra\(parameters)")
        //加载数据
        Alamofire.request(.POST, finalURL , parameters:parameters)
            .response { request ,response ,data , eror in
                let json = JSONND.initWithData(data!)
                print(response)
                let jsonarray = json.arrayValue
                for i in 0..<jsonarray.count {
                    self.proID = jsonarray[i]["ProID"].intValue
                    let proName = jsonarray[i]["ProName"].stringValue
                    let proNo = jsonarray[i]["ProNO"].stringValue
                    let shopPrice = jsonarray[i]["ShopPrice"].floatValue
                    let marketPrice = jsonarray[i]["MarketPrice"].floatValue
                    var imagePath = self.listData.valueForKey("url") as! String
                    if jsonarray[i]["ImagePath"].string != nil {
                        imagePath += "/\(jsonarray[i]["ImagePath"].string!)"
                    }
                    let proEvaluationCount = jsonarray[i]["ProEvaluationCount"].intValue
                    let netWeight = jsonarray[i]["NetWeight"].intValue
                    let product = ProductModel(proID: self.proID, proName: proName, proNo: proNo, shopPrice: Double(shopPrice), marketPrice: Double(marketPrice), imagePath: imagePath, proEvaluationCount: proEvaluationCount, netWeight: netWeight)
                    self.productList.append(product)
                }
                if jsonarray.count == 0 {
                    self.nodata = true
                    self.productList.append(ProductModel(proID: 1, proName: "", proNo: "", shopPrice: 1, marketPrice: 1, imagePath: "", proEvaluationCount: 1, netWeight: 1))
                
                }
                _ = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(GoodsListTableViewController.iii), userInfo: nil, repeats: false)
        }
    }
    
    func iii() {
        self.tableView.backgroundView = nil
        self.tableView.reloadData()
    }
    
    func AddCarbtnClicked (btn:UIButton) {
        let userID = NSUserDefaults.standardUserDefaults().integerForKey("UserID")
        let goodID = productList[btn.tag].proID
        let quantity = 1
        let parameters = ["UserID":userID, "ProductID":"[\(goodID)]", "Quantity": "[\(quantity)]"]
        print(parameters)
        Alamofire.request(.POST, addShoppingCarURL, parameters:parameters as? [String : AnyObject])
            .response { (request, response, data, error) in
                print(data)
        }
        self.navigationController?.view.makeToast("成功加入购物车！")
    }
    //button的点击事件
    func btnClicked(btn:UIButton) {
        //1:菜单，2:购物车，3:搜索
        switch btn.tag {
        case 1:
            goodMsgFromOther = ""
            self.dismissViewControllerAnimated(true, completion: nil)
        case 2:
            self.performSegueWithIdentifier("GoodsListToShoppingcar", sender: self)
        default:
            break
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if search!.text != "" {
            goodMsgFromOther = search!.text!
            search!.text = ""
            finalURL = headerURL + getBySearchURL
            let modelCode = NSUserDefaults.standardUserDefaults().valueForKey("ModelCode")
            parameters = ["KeyWord":goodMsgFromOther, "ModelCode":modelCode!, "PageNO":0, "PageSize":1000]
            dataInit()
        }
        else {
            let alertV = UIAlertView(title: nil, message: "搜索信息不能为空！", delegate: nil, cancelButtonTitle: "确定")
            alertV.show()
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productList.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let screenW = self.view.frame.size.width
        //设置单元格重用，重用标记为“cell”
        let cellIdentifier = "cell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier)
        }
        
        //清除单元格内容，以免上下滑动后内容重叠
        cell!.textLabel!.text = ""
        for view in cell!.contentView.subviews {
            if view.isKindOfClass(UIButton.self) {
                view.removeFromSuperview()
            } else if view.isKindOfClass(UILabel.self) {
                view.removeFromSuperview()
            } else if view.isKindOfClass(UIImageView.self) {
                view.removeFromSuperview()
            }
        }
        //productList.count == 0时数据未加载完
        if productList.count != 0 {
            //nodata为false则有数据，true为无数据
            if nodata {
                let tips = UILabel(frame: CGRect(x: 0, y: 65, width: screenW, height: 25))
                tips.text = "当前车型暂无相关商品"
                tips.font = UIFont.systemFontOfSize(17)
                tips.textAlignment = NSTextAlignment.Center
                tips.numberOfLines = 0;
                tips.lineBreakMode = NSLineBreakMode.ByWordWrapping
                cell?.contentView.addSubview(tips)
            }
            else {
                let model = productList[indexPath.row]
                //pic:商品图片,name:商品名称,currentP:现价,oldP;原价,oldL:原价上的横线,add:加入购物车
                //初始化URL并且获取图片地址
                let url : NSURL = NSURL(string: "\(model.imagePath)")!
                //初始化data。从URL中获取数据
               // let data : NSData = NSData(contentsOfURL:url)!
                //创建图片
                //let picture = UIImage(data:data, scale: 1.0)
                //初始化imageview并获取image
                let pic = UIImageView()
                pic.kf_showIndicatorWhenLoading = true
                pic.kf_setImageWithURL(url, placeholderImage: nil,
                    optionsInfo: [.Transition(ImageTransition.Fade(1))],
                    progressBlock: { receivedSize, totalSize in
                    },
                    completionHandler: { image, error, cacheType, imageURL in
                })

                pic.frame = CGRect(x: 10, y: 10, width: 70, height: 70)
                cell?.contentView.addSubview(pic)
                
                let name = UILabel(frame: CGRect(x: 90, y: 17, width: screenW - 100, height: 35))
                name.text = model.proName
                name.font = UIFont.systemFontOfSize(13)
                name.numberOfLines = 0;
                name.lineBreakMode = NSLineBreakMode.ByWordWrapping
                cell?.contentView.addSubview(name)
                
                let currentP = UILabel(frame: CGRect(x: 90, y: 58, width: 70, height: 20))
                currentP.text = String(format:"%.2f",model.shopPrice)
                currentP.font = UIFont.systemFontOfSize(13)
                currentP.textColor = UIColor.redColor()
                currentP.textAlignment = NSTextAlignment.Center
                cell?.contentView.addSubview(currentP)
                
                let oldP = UILabel(frame: CGRect(x: 160, y: 58, width: 70, height: 20))
                oldP.text = String(format:"%.2f",model.marketPrice)
                oldP.font = UIFont.systemFontOfSize(13)
                oldP.textColor = UIColor.grayColor()
                oldP.textAlignment = NSTextAlignment.Center
                cell?.contentView.addSubview(oldP)
                
                let oldL = UILabel(frame: CGRect(x: 160, y: 68, width: 60, height: 1))
                oldL.backgroundColor = UIColor.grayColor()
                cell?.contentView.addSubview(oldL)
                
                let add = UIButton(frame: CGRect(x: (screenW - 85), y: 58, width: 80, height: 20))
                add.setTitle("加入购物车", forState: UIControlState.Normal)
                add.titleLabel!.textAlignment = NSTextAlignment.Center
                add.titleLabel!.font = UIFont.systemFontOfSize(13)
                add.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                add.layer.cornerRadius = 3.0
                add.backgroundColor = UIColor.orangeColor()
                add.addTarget(self, action: #selector(GoodsListTableViewController.AddCarbtnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                add.tag = indexPath.row
                cell?.contentView.addSubview(add)
            }
        }
        
        cell?.selectionStyle = UITableViewCellSelectionStyle.None
        return cell!
    }
    
    //点击商品转跳至商品详情页面
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.proID = productList[indexPath.row].proID
        self.performSegueWithIdentifier("GoodsListToDetail", sender: self)
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 90
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "GoodsListToDetail" {
            let receive = (segue.destinationViewController as! UINavigationController)
            let a = receive.viewControllers[0] as! GoodDetailTableViewController
            a.proID = proID
            
        }
    }
    
}
