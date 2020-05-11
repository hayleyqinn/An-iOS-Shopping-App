//
//  ChooseBrandTableViewController.swift
//  ico2o
//
//  Created by Katherine on 16/1/5.
//  Copyright © 2016年 chingyam. All rights reserved.
//
import Kingfisher
import UIKit
import Alamofire
import JSONNeverDie
//类似于OC中的typedef
typealias setProductMsgClosure=(msg:ProductModel)->Void

class ChooseBrandTableViewController: UITableViewController {
    /*screenW:屏幕宽度
    productNO:上一页传过来的商品信息
    listData,filePath,headerURL,chooseBrandURL:URL相关
    productSelected:已选数据
    data:本页所显示数据的数据
    myClosure:返回本页中已选数据
    */
    var screenW:CGFloat = 0
    var productNO = ""
    var listData: NSDictionary = NSDictionary()
    var filePath = NSBundle.mainBundle().pathForResource("config.plist", ofType:nil )
    var headerURL = ""
    let chooseBrandURL = "/ASHX/MobileAPI/Product/GetReplacementProduct.ashx"
    var productSelected:ProductModel!
    var data:[ProductModel] = []
    var isNoData = false
    var myClosure:setProductMsgClosure?
    var checkNetwork = CheckNetWorking()
    override func viewDidLoad() {
        super.viewDidLoad()
        screenW = self.view.frame.size.width
        listData = NSDictionary(contentsOfFile: filePath!)!
        headerURL = listData.valueForKey("url") as! String
        tableView.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
    }

    override func viewDidAppear(animated: Bool) {
        getData()
    }
    
    func getData() {
//        "SOA427V1410"
        if(!checkNetwork.checkNetwork()){
            return 
        }
        let parameters:[String:AnyObject] = ["ProNO":productNO, "PageNO":1,"PageSize":30,"ModelCode": NSUserDefaults.standardUserDefaults().stringForKey("ModelCode")!]
        print(parameters)
        Alamofire.request(.POST, (headerURL + chooseBrandURL) , parameters:parameters)
            .response { request ,response ,data , eror in
                let json = JSONND.initWithData(data!)
                let jsonarray = json.arrayValue
                if jsonarray.count == 0 {
                    self.isNoData = true
                    self.data.append(ProductModel(proType: "", proID: 1, proName: "", proNo: "", shopPrice: 1, marketPrice: 1, imagePath: ""))
                }
                else {
                    //,,,,,"ProductBrand":"美孚","AutomobileBrand":"斯巴鲁"
                    for i in 0..<jsonarray.count {
                        let proID = jsonarray[i]["ID"].int!
                        let proName = jsonarray[i]["ProName"].string!
                        let proNO = jsonarray[i]["ProNO"].string!
                        let shopPrice = Double(jsonarray[i]["ShopPrice"].float!)
                        let imagePath = jsonarray[i]["ImagePath"].string!
                        let product:ProductModel = ProductModel(proType: "", proID: proID, proName: proName, proNo: proNO, shopPrice: shopPrice, marketPrice: shopPrice, imagePath: imagePath)
                        self.data.append(product)
                    }
                }
                self.tableView.reloadData()
        }
    }
    
    //返回上一页
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func initWithClosure(closure:setProductMsgClosure?){
        myClosure = closure
    }
    
    func chooseBtnClicked(btn:UIButton) {
        productSelected = data[btn.tag]
        //判空
        if (myClosure != nil){
            //闭包隐式调用someFunctionThatTakesAClosure函数：回调。
            myClosure!(msg:productSelected)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
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
            if view.isKindOfClass(UIButton.self) {
                view.removeFromSuperview()
            } else if view.isKindOfClass(UILabel.self) {
                view.removeFromSuperview()
            }
        }
        if data.count != 0 {
            if isNoData {
                let tips = UILabel(frame: CGRect(x: (screenW - 150) / 2, y: 30, width: 150, height: 25))
                tips.text = "暂无替换商品"
                tips.textAlignment = NSTextAlignment.Center
                tips.font = UIFont.systemFontOfSize(15)
                cell?.contentView.addSubview(tips)
            }
            else {
                //img：商品图片，name：商品名称，price：商品价格，choose：选中该商品
                let img = UIImageView(frame: CGRect(x: 10, y: 10, width: 60, height: 60))
                img.kf_showIndicatorWhenLoading = true
                img.kf_setImageWithURL(NSURL(string: headerURL + "/" + data[indexPath.row].imagePath)!, placeholderImage: nil,
                    optionsInfo: [.Transition(ImageTransition.Fade(1))],
                    progressBlock: { receivedSize, totalSize in
                        print("\(receivedSize)/\(totalSize)")
                    },
                    completionHandler: { image, error, cacheType, imageURL in
                        print("Finished")
                })
                cell?.contentView.addSubview(img)
                
                
                let name = UILabel(frame: CGRect(x: 80, y: 10, width: screenW - 90, height: 35))
                name.text = data[indexPath.row].proName
                name.font = UIFont.systemFontOfSize(14)
                name.numberOfLines = 0;
                name.lineBreakMode = NSLineBreakMode.ByWordWrapping
                cell?.contentView.addSubview(name)
                
                let price = UILabel(frame: CGRect(x: 80, y: 50, width: 150, height: 20))
                price.text = "¥" + String(format:"%.2f",data[indexPath.row].shopPrice)
                price.font = UIFont.systemFontOfSize(14)
                cell?.contentView.addSubview(price)
                
                let choose = UIButton(frame: CGRect(x: screenW - 70, y: 48, width: 60, height: 25))
                choose.setTitle("选中", forState: UIControlState.Normal)
                choose.titleLabel!.textAlignment = NSTextAlignment.Center
                choose.titleLabel!.font = UIFont.systemFontOfSize(14)
                choose.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                choose.layer.cornerRadius = 3.0
                choose.backgroundColor = UIColor.orangeColor()
                choose.addTarget(self, action: #selector(ChooseBrandTableViewController.chooseBtnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                choose.tag = indexPath.row
                cell?.contentView.addSubview(choose)
            }
        }
        
        cell?.selectionStyle = UITableViewCellSelectionStyle.None
        return cell!
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 85
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: screenW, height: 100))
        
        //title:标题栏，img：商品图片，name：商品名称，price：商品价格，choose：选中该商品,line:分割线
        let title = UILabel(frame: CGRect(x: 0, y: 0, width: screenW, height: 30))
        title.text = "   已选中"
        title.font = UIFont.systemFontOfSize(15)
        title.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
        view.addSubview(title)
        
        
        let img = UIImageView(frame: CGRect(x: (screenW - 80) / 2, y: 40, width: 80, height: 80))
        img.kf_showIndicatorWhenLoading = true
        img.kf_setImageWithURL(NSURL(string: headerURL + "/" + productSelected.imagePath)!, placeholderImage: nil,
            optionsInfo: [.Transition(ImageTransition.Fade(1))],
            progressBlock: { receivedSize, totalSize in
                print("\(receivedSize)/\(totalSize)")
            },
            completionHandler: { image, error, cacheType, imageURL in
                print("Finished")
        })//productSelected[0]
        view.addSubview(img)
        
        let name = UILabel(frame: CGRect(x: 20, y: 120, width: screenW - 40, height: 35))
        name.text = productSelected.proName//productSelected[1]//
        name.font = UIFont.systemFontOfSize(15)
        name.textAlignment = NSTextAlignment.Center
        name.numberOfLines = 0
        name.lineBreakMode = NSLineBreakMode.ByWordWrapping
        view.addSubview(name)
        
        let price = UILabel(frame: CGRect(x: (screenW - 150) / 2, y: 165, width: 150, height: 20))
        price.text = "单价：¥" + String(format:"%.2f",productSelected.shopPrice)//productSelected[2]//
        price.font = UIFont.systemFontOfSize(14)
        price.textAlignment = NSTextAlignment.Center
        view.addSubview(price)
        
        let line = UILabel(frame: CGRect(x: 0, y: 193, width: screenW, height: 2))
        line.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
        view.addSubview(line)
        
        view.backgroundColor = UIColor.whiteColor()
        return view
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 195
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 15
    }
}
