//
//  GoodDetailTableViewController.swift
//  ico2o
//
//  Created by Katherine on 15/11/26.
//  Copyright © 2015年 chingyam. All rights reserved.
//
import Alamofire
import UIKit
import JSONNeverDie
import Kingfisher
class GoodDetailTableViewController: UITableViewController,UIPageViewControllerDelegate, ChoosePropertyAlertViewDelegate {
    /*scrollView,pageControl,timer:顶部图片轮播相关
    picNum:顶部图片数量
    goodMsgFromOther：从其它页面传过来的商品信息
    properties：商品属性
    choiceText：选择属性的结果s
    */
    var scrollView: UIScrollView!
    var pageControl: UIPageControl!
    var timer:NSTimer!
    var picNum = 4
    var goodMsgFromOther:Int = 0
    var data:[[[String]]]?
    let properties = [["白色","黑色","灰色","蓝色","红色","黄色"],["小号","大号"]]
    var choiceText = ""
    var proID:Int = 0
    var result:[[[String]]]?
    var proNo:String = ""
    var proName: String = ""
    var shopPrice:Float = 0
    var quan: Int = 1
    var imagePath: String = ""
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    //
    var listData: NSDictionary = NSDictionary()
    var listData2: NSDictionary = NSDictionary()
    var listData111: NSDictionary = NSDictionary()
    var listData3: NSDictionary = NSDictionary()
    var filePath = NSBundle.mainBundle().pathForResource("config.plist", ofType:nil )
    var addGoodURL:String = ""
    var addShoppingCarURL:String = ""
    var buyURL:String = ""
    var goodsDetailURL:String = ""
    //
    override func viewWillAppear(animated: Bool) {
        self.tableView.reloadData()
    }

    
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        self.navigationController?.toolbarHidden = false
        self.navigationController?.toolbar.addSubview(toolInit((self.navigationController?.toolbar.frame.size.height)!))
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.tableFooterView = footerView()
        pageControl = UIPageControl(frame: CGRect(x: (Int(self.view.frame.size.width) - 10) / 2, y: 160, width: 10, height: 20))
        
        print(proID)
        //读取plist构造”收藏商品“URL
        listData111 = NSDictionary(contentsOfFile: filePath!)!
        addGoodURL = listData111.valueForKey("url") as! String
        addGoodURL += "/ASHX/MobileAPI/Collection/Add.ashx"
        
        //读取plist构造“加入购物车”URL
        listData2 = NSDictionary(contentsOfFile: filePath!)!
        addShoppingCarURL = listData2.valueForKey("url") as! String
        addShoppingCarURL += "/ASHX/MobileAPI/ShopCar/Add.ashx"
      
        //读取plist构造“立即购买”URL
        listData3 = NSDictionary(contentsOfFile: filePath!)!
        buyURL = listData3.valueForKey("url") as! String
        buyURL += "/ASHX/MobileAPI/Collection/Add.ashx"
        dataInit()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }
 
   
    //商品介绍
    func dataInit() {
        //获取商品详细介绍url
        listData = NSDictionary(contentsOfFile: filePath!)!
        goodsDetailURL = listData.valueForKey("url") as! String
        goodsDetailURL += "/ASHX/MobileAPI/Product/GetDetail.ashx"
        if goodMsgFromOther != 0 {
            proID = goodMsgFromOther 
        }
        let goodID = proID
        let parameters = ["ProID":goodID]
        //加载数据
        Alamofire.request(.POST, goodsDetailURL , parameters:parameters)
            .response{ (request ,response ,data2 , error) in
                let json = JSONND.initWithData(data2!)
                self.proName = json["ProName"].stringValue
                self.imagePath = self.listData.valueForKey("url") as! String
                self.imagePath += "/\(json["ImagePath"].stringValue)"
                let goodName = ["\(json["ProName"].stringValue)"]
                let goodMsg = ["\(json["ProNO"].stringValue)","\(json["ShopPrice"].floatValue)"]
                let others = [["goodDetail3","避光垫","¥280.00"],["goodDetail3","避光垫","¥280.00"],["goodDetail3","避光垫","¥280.00"]]
                let group = [["goodDetail1","避光垫"],["goodDetail1","避光垫"],["goodDetail1","避光垫"]]
                let datalist = [[goodName,goodMsg],others,group]
    
                self.data = datalist
            

        _ = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(GoodDetailTableViewController.iii), userInfo: nil, repeats: false)
        }
    }
    
    func iii() {
        self.tableView.backgroundView = nil
        self.tableView.reloadData()
    }
    
    //底部的工具栏
    func toolInit(toolH:CGFloat)->UIView {
        let screenW = Int(self.view.frame.size.width)
        let btnW = Int(self.view.frame.size.width / 2)
        let toolh = Int(toolH)
        let toolbar = UIView(frame: CGRect(x: 0, y: 0, width: screenW , height: toolh))
        
        let addBtn = UIButton(frame: CGRect(x: 0, y: 0, width: btnW, height: toolh))
        addBtn.setTitle("加入购物车", forState: UIControlState.Normal)
        addBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        addBtn.titleLabel?.font = UIFont.systemFontOfSize(14)
        addBtn.backgroundColor = UIColor.redColor()
        addBtn.addTarget(self, action:#selector(GoodDetailTableViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        addBtn.tag = 2
        toolbar.addSubview(addBtn)
        
        let buyBtn = UIButton(frame: CGRect(x: screenW - btnW, y: 0, width: screenW - btnW, height: toolh))
        buyBtn.setTitle("立即购买", forState: UIControlState.Normal)
        buyBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        buyBtn.titleLabel?.font = UIFont.systemFontOfSize(14)
        buyBtn.backgroundColor = UIColor.orangeColor()
        buyBtn.addTarget(self, action: #selector(GoodDetailTableViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        buyBtn.tag = 3
        toolbar.addSubview(buyBtn)
        return toolbar
    }
    
    //btn点击事件
    func btnClicked(btn:UIButton){
        //2:加入购物车,3:立即购买,111:收藏,21-23:其他品牌商品,31-33套餐组合商品
        if btn.tag > 20 && btn.tag < 40{
            //点击商品跟据tag对数据源进行处理，再刷新页面显示新的商品信息
            
            tableView.reloadData()
        }
        else {
            switch btn.tag {
            //加入购物车
            case 2:
                let userID = NSUserDefaults.standardUserDefaults().integerForKey("UserID")
                let goodID = proID
                let quantity = quan
                let parameters = ["UserID":userID, "ProductID":"[\(goodID)]", "Quantity": "[\(quantity)]"]
                Alamofire.request(.POST, addShoppingCarURL, parameters:parameters as? [String : AnyObject])
                    .response { (request, response, data, error) in
                        print(data)
                }
               self.navigationController?.view.makeToast("成功加入购物车！")
            //立即购买
            case 3:
                let userID = NSUserDefaults.standardUserDefaults().integerForKey("UserID")
                let goodID = proID
                let quantity = quan
                let parameters = ["UserID":userID, "ProductID":"[\(goodID)]", "Quantity": "[\(quantity)]"]
                print(parameters)
                Alamofire.request(.POST, addShoppingCarURL, parameters:parameters as? [String : AnyObject])
                    .response { (request, response, data, error) in
                        print(data)
                }
                
               self.performSegueWithIdentifier("gooddatailToCar", sender: self)
                
                
                
            //收藏
            case 111:
                let userID = NSUserDefaults.standardUserDefaults().integerForKey("UserID")
                let goodID = proID
                let parameters = ["UserID":userID,"ProID":goodID]
            
                Alamofire.request(.POST, addGoodURL , parameters:parameters)
                    .response { (request, response, data, error) in
                        print(request)
                        print(response)
                        print(error)
                }
                
                self.navigationController?.view.makeToast("成功收藏！")
            default:
                break
            }
        }
    }
    
    //分页部分
    func footerView()->UIView {
        let screenW = self.view.frame.size.width
        //计算状态栏及导航栏的高度
        let rectStatus = UIApplication.sharedApplication().statusBarFrame
        let rectNav = self.navigationController?.navigationBar.frame
        let marginHeight = rectStatus.size.height + rectNav!.size.height
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: screenW, height: self.view.frame.height - marginHeight - 30))
        //与其它内容间的分割线
        let line = UILabel(frame: CGRect(x: 0, y: 0, width: screenW, height: 10))
        line.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
        view.addSubview(line)
//        
//        let swiftPagesView : SwiftPages!
//        swiftPagesView = SwiftPages(frame: CGRectMake(0, 10, screenW, self.view.frame.height))
//        //VCID：storyboard中viewcontroller的id，buttonTitles：在界面中显示的分页标题
//        let VCIDs : [String] = ["GoodDetailDetail", "GoodDetailDetail", "GoodDetailDetail"]
//        let buttonTitles : [String] = ["图文详情", "产品参数", "售后服务"]
//        
//        swiftPagesView.setOriginY(0.0)
//        swiftPagesView.setButtonsTextColor(UIColor.blackColor())
//        swiftPagesView.setAnimatedBarColor(UIColor.blackColor())
//        swiftPagesView.initializeWithVCIDsArrayAndButtonTitlesArray(VCIDs, buttonTitlesArray: buttonTitles)
//        view.addSubview(swiftPagesView)
        
        let webView = UIWebView(frame: CGRectMake(0, 10, screenW, view.frame.height - 10))
        view.addSubview(webView)
        let URL = NSURL(string: "http://www.2cto.com/kf/201503/380591.html")
        let request = NSURLRequest(URL: URL!)
        webView.loadRequest(request)
        return view
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 && indexPath.row == 2 {
            let alertV = ChoosePropertyAlertView(title: data![0][0][0], tips: "库存：100件", delegate: self, properties: properties, style: ChoosePropertyAlertViewStyle.defaultStyle)
            alertV.show()
        }
    }
    
    //获取已选择的商品属性
    func ChoosePropertyAlertViewOKBtnCliceked(alertView: ChoosePropertyAlertView) {
        var propertySelected = ""
        for i in 0..<(properties.count) {
            propertySelected += (alertView.propertySelected[i] + " ")
        }
        propertySelected += ("数量：" +  (alertView.count?.text)!)
        quan = (Int)((alertView.count?.text)!)!
        choiceText = propertySelected
        tableView.reloadData()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0 :
            return 1
        case 1 :
            return 3
        default:
            return 1
        }
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
            }
        }
        
      
        if data?.count != nil {
            //0:商品图片，1:商品基本信息，2:其它品牌的商品，3:套餐组合
            switch indexPath.section {
            case 0:
                scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: screenW, height: 200))
                cell?.contentView.addSubview(scrollView)
                cell?.contentView.addSubview(pageControl)
                pictureGallery()
            case 1:
                //goodName：商品名称、collect：收藏按钮、numLabel1：配件编号标签、numLabel2：配件编号、price：价格、choose：选择属性
                switch indexPath.row {
                case 0:
                
                    let goodName = UILabel(frame: CGRect(x: 10, y: 2, width: screenW - 60, height: 35))
                    goodName.text = data![indexPath.section - 1][0][0]
                    goodName.font = UIFont.systemFontOfSize(13)
                    goodName.numberOfLines = 0
                    goodName.lineBreakMode = NSLineBreakMode.ByWordWrapping
                    cell?.contentView.addSubview(goodName)
                    
                    let collect = UIButton(frame: CGRect(x: (screenW - 50), y: 0, width: 50, height: 40))
                    collect.setTitle("收藏", forState: UIControlState.Normal)
                    collect.titleLabel!.textAlignment = NSTextAlignment.Center
                    collect.titleLabel!.font = UIFont.systemFontOfSize(13)
                    collect.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                    collect.backgroundColor = UIColor(red: 53/255, green: 136/255, blue: 251/255, alpha: 1.0)
                    collect.addTarget(self, action: #selector(GoodDetailTableViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                    collect.tag = 111
                    cell?.backgroundColor = UIColor(red: 235/255, green: 233/255, blue: 232/255, alpha: 1.0)
                    cell?.contentView.addSubview(collect)
                case 1:
                    let numLabel1 = UILabel(frame: CGRect(x: 10, y: 5, width: 60, height: 20))
                    numLabel1.text = "配件编号"
                    numLabel1.font = UIFont.systemFontOfSize(13)
                    numLabel1.numberOfLines = 0;
                    numLabel1.lineBreakMode = NSLineBreakMode.ByWordWrapping
                    cell?.contentView.addSubview(numLabel1)
                    
                    let numLabel2 = UILabel(frame: CGRect(x: 80, y: 5, width: 100, height: 20))
                    numLabel2.text = data![indexPath.section - 1][1][0]
                    numLabel2.font = UIFont.systemFontOfSize(13)
                    numLabel2.numberOfLines = 0;
                    numLabel2.lineBreakMode = NSLineBreakMode.ByWordWrapping
                    cell?.contentView.addSubview(numLabel2)
                    
                    let price = UILabel(frame: CGRect(x: screenW - 100, y: 5, width: 90, height: 20))
                    price.text = "价格: " + data![indexPath.section - 1][1][1]
                    price.font = UIFont.systemFontOfSize(14)
                    price.textColor = UIColor.redColor()
                    price.textAlignment = NSTextAlignment.Right
                    price.numberOfLines = 0;
                    price.lineBreakMode = NSLineBreakMode.ByWordWrapping
                    cell?.contentView.addSubview(price)
                    let line = UILabel(frame: CGRect(x: 5, y: 28, width: screenW, height: 2))
                    line.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
                    cell?.contentView.addSubview(line)
                case 2:
                    let choose = UILabel(frame: CGRect(x: 10, y: 5, width: 80, height: 20))
                    choose.text = "选择属性"
                    choose.font = UIFont.systemFontOfSize(13)
                    cell?.contentView.addSubview(choose)
                    
                    let choice = UILabel(frame: CGRect(x: screenW - 130, y: 5, width: 120, height: 20))
                    choice.text = choiceText
                    choice.textAlignment = NSTextAlignment.Right
                    choice.textColor = UIColor.redColor()
                    choice.font = UIFont.systemFontOfSize(13)
                    cell?.contentView.addSubview(choice)
                    
                    let line = UILabel(frame: CGRect(x: 5, y: 28, width: screenW, height: 2))
                    line.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
                    cell?.contentView.addSubview(line)
                    
                default:
                    break
                }
            case 2:
                for i in 0..<3 {
                    let btnW = 70
                    let margin = (Int(screenW) - (btnW * 3)) / 4
                    let goodBtn = UIButton(frame: CGRect(x: (margin + btnW) * i + margin, y: 10, width: btnW, height: btnW))
                    goodBtn.setImage(UIImage(named: data![indexPath.section - 1][i][0]), forState: UIControlState.Normal)
                    goodBtn.addTarget(self, action: #selector(GoodDetailTableViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                    goodBtn.tag = 21 + i
                    cell?.contentView.addSubview(goodBtn)
                    let goodName = UILabel(frame: CGRect(x:  (margin + btnW) * i + margin, y: btnW + 15, width: btnW, height: 20))
                    goodName.text = data![indexPath.section - 1][i][1]
                    goodName.font = UIFont.systemFontOfSize(13)
                    goodName.textAlignment = NSTextAlignment.Center
                    cell?.contentView.addSubview(goodName)
                    let goodPrice = UILabel(frame: CGRect(x:  (margin + btnW) * i + margin, y: btnW + 35
                        , width: btnW, height: 20))
                    goodPrice.text = data![indexPath.section - 1][i][2]
                    goodPrice.font = UIFont.systemFontOfSize(13)
                    goodPrice.textColor = UIColor.redColor()
                    goodPrice.textAlignment = NSTextAlignment.Center
                    cell?.contentView.addSubview(goodPrice)
                }
            case 3:
                for i in 0..<3 {
                    let btnW = 60
                    let margin = 5//(Int(screenW) - ((btnW + 45) * 3)) / 4
                    let addBtn = UIButton(frame: CGRect(x: Int(margin + btnW + 40) * i + margin, y: 40, width: 30, height: 10))
                    addBtn.backgroundColor = UIColor.orangeColor()
                    cell?.contentView.addSubview(addBtn)
                    let goodBtn = UIButton(frame: CGRect(x: (margin + btnW + 40) * i + margin + 35, y: 10, width: btnW, height: btnW))
                    goodBtn.setImage(UIImage(named: data![indexPath.section - 1][i][0]), forState: UIControlState.Normal)
                    goodBtn.addTarget(self, action: #selector(GoodDetailTableViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                    goodBtn.tag = 31 + i
                    cell?.contentView.addSubview(goodBtn)
                    let goodName = UILabel(frame: CGRect(x:  (margin + btnW + 40) * i + margin + 35, y: btnW + 15, width: btnW, height: 20))
                    goodName.text = data![indexPath.section - 1][i][1]
                    goodName.font = UIFont.systemFontOfSize(13)
                    goodName.textAlignment = NSTextAlignment.Center
                    cell?.contentView.addSubview(goodName)
                }
            default:
                break
            }

        }
        cell?.selectionStyle = UITableViewCellSelectionStyle.None
        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 200
        case 1:
            if indexPath.row == 0 {
                return 40
            }
            else {
                return 30
            }
        case 2:
            return 130
        case 3:
            return 100
        default:
            return 30
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 2:
            return "其他品牌"
        case 3:
            return "套餐组合"
        default:
            return ""
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 2,3:
            return 30
        default:
            return 0
        }
    }
    
    //图片轮播
    func pictureGallery(){
        //获取Scrollview的宽高作为兔牌呢的宽高
        let imageW:CGFloat = self.view.frame.size.width
        let imageH:CGFloat = self.scrollView.frame.size.height
        //图片的y坐标就在scrollview的顶端
        //let imageY:CGFloat = 0
        if imagePath != "" {
            let url : NSURL = NSURL(string: "\(imagePath)")!
            let pic = UIImageView()
            pic.kf_showIndicatorWhenLoading = true
            pic.kf_setImageWithURL(url, placeholderImage: nil,
                                   optionsInfo: [.Transition(ImageTransition.Fade(1))],
                                   progressBlock: { receivedSize, totalSize in
                },
                                   completionHandler: { image, error, cacheType, imageURL in
            })
            pic.contentMode = .ScaleAspectFit
           
            pic.frame = CGRect(x:2 , y: 0, width: imageW, height: imageH)
            //不设置水平滚动条
            self.scrollView.showsHorizontalScrollIndicator = false
            //把图片加入到scrollview中，实现轮播效果
            //self.scrollView.addSubview(imageView)
            self.scrollView.addSubview(pic)

        }
        
        
//        for index in 0..<picNum{
//            let imageView:UIImageView = UIImageView(image: UIImage())
//            let imageX:CGFloat = CGFloat(index) * imageW
//            //设置图片大小，几张图片是按顺序从左向右依次放置在ScrollView中的，但是ScrollView在界面中显示的只是一张图片的大小，效果类似与画廊
//            imageView.frame = CGRectMake(imageX, imageY, imageW, imageH)
//            
//            let name:String = String(format:"goodDetail%d",index + 1)
//            imageView.image = UIImage(named: name)
//            
//            //不设置水平滚动条
//            self.scrollView.showsHorizontalScrollIndicator = false
//            //把图片加入到scrollview中，实现轮播效果
//            self.scrollView.addSubview(imageView)
//        }
//        
        //ScrollView控件一定要设置contentSize;包括长和宽；
//        let contentW:CGFloat = imageW * CGFloat(picNum)
//        self.scrollView.contentSize = CGSizeMake(contentW, 0)
//        self.scrollView.pagingEnabled = true
//        self.scrollView.delegate = self
//        //下面的页码提示器
//        self.pageControl.numberOfPages = picNum
//        self.addTimer();
    }
    
    //图片轮播
    func nextImage(sender:AnyObject!){
        var page:Int = self.pageControl.currentPage
        if(page == (picNum - 1)){
            page = 0
        }else{
            page += 1
        }
        
        let x:CGFloat = CGFloat(page) * self.view.frame.size.width
        //contentOffset就是设置ScrollView的偏移
        self.scrollView.contentOffset = CGPointMake(x , 0)
    }
    
    //处理所有ScrollView的滚动之后的事件，不是执行滚动的事件
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        //这里只是为了设置下面的页码提示器；该操作是在图片滚动之后操作的
    
        let scrollviewW:CGFloat = self.view.frame.size.width
        let x:CGFloat = scrollView.contentOffset.x
        let page:Int = (Int)((x + scrollviewW / CGFloat(picNum)) / scrollviewW)
        pageControl.currentPage = page
    }
    
    func addTimer(){
        self.timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(GoodDetailTableViewController.nextImage(_:)), userInfo: nil, repeats: true)
    }
}
