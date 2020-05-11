//
//  WannaMaintTableViewController.swift
//  ico2o
//
//  Created by Katherine on 15/11/6.
//  Copyright © 2015年 chingyam. All rights reserved.
//

import UIKit
import Alamofire
import JSONNeverDie

class WannaMaintTableViewController: UITableViewController, ChangeCountAlertViewDelegate{
    /*lineHeight:商品行的高度
    lastMile，lastTime：上次保养信息的textfield，可修改
    milesFromOther：首页中输入的公里数
    selectedIndex：常规保养中已选项目的下标
    maintenanceItemDao：常规保养数据库相关
    sMaintenanceItem：根据下标找到项目的名称
    listData，filePath，getMaintenanceItemURL：URl相关
    selectMaintanceItemModels：数据模型
    count:显示商品数量btn
    alertV:改变商品数量的弹出框
    productTypeTemp:当前点击的商品的productType暂存变量
    */
    var lineHeight:CGFloat = 40
    var lastMile,lastTime:UITextField?
    var milesFromOther:Int?
    var selectedIndex:[Int]?
    var sMaintenanceItem:String = ""
    var maintenanceItemDao:MaintenanceItemDao?
    var listData: NSDictionary = NSDictionary()
    var filePath = NSBundle.mainBundle().pathForResource("config.plist", ofType:nil )
    var getMaintenanceItemURL:String = ""
    var addShoppingCarURL:String = ""
    var selectMaintanceItemModels:[SelectMaintanceItemModel] = []
    var count = UIButton()
    var alertV:ChangeCountAlterView?
    var productMsg:[[[String]]] = []
    var temp:ProductModel?
    var productIndex:NSIndexPath?
    var modelCode:String = ""
    var isfromLoveCar:Bool = false
    var productTypeTemp = ""
    var checkNetwork = CheckNetWorking()

    override func viewDidLoad() {
        super.viewDidLoad()
        listData = NSDictionary(contentsOfFile: filePath!)!
        getMaintenanceItemURL = listData.valueForKey("url") as! String
        getMaintenanceItemURL += "/ASHX/MobileAPI/MaintenanceItem/GetProducts.ashx"
        addShoppingCarURL = listData.valueForKey("url") as! String
        addShoppingCarURL += "/ASHX/MobileAPI/ShopCar/Add.ashx"
        maintenanceItemDao = MaintenanceItemDao()
        dataInit()
        //导航栏
        self.navigationController?.navigationBar.pushNavigationItem(navInit(), animated: false)
        //取消单元格间的分割线
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }

    func dataInit() {
        sMaintenanceItem = "["
        for i in 0..<selectedIndex!.count {
            let temp = maintenanceItemDao?.getName(selectedIndex![i]+1)
            if i != (selectedIndex?.count)! - 1{
                sMaintenanceItem += "\(temp!),"
            }
            else{
                sMaintenanceItem += "\(temp!)"
            }
            productMsg.append([])
        }
        sMaintenanceItem += "]"
        if(isfromLoveCar == false){
            if NSUserDefaults.standardUserDefaults().stringForKey("ModelCode") != nil {
                modelCode = NSUserDefaults.standardUserDefaults().stringForKey("ModelCode")!

            } else {
                self.navigationController?.view.makeToast("您还没有选择车型哦！", duration: 3.0, position: .Center)

            }
        }
        
    if(!checkNetwork.checkNetwork()){
            return
    }
    
        
    getData(modelCode,sMaintenanceItem: sMaintenanceItem)
        
       
        
    }
    
    //导航栏的设置
    func navInit()->UINavigationItem {
        let navItem = UINavigationItem(title: "")
        let leftBtn = UIBarButtonItem(image: UIImage(named: "back"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(WannaMaintTableViewController.barButtonClicked(_:)))
        leftBtn.tag = 1
        navItem.setLeftBarButtonItem(leftBtn, animated: false)
        navItem.title = "我要保养"
        return navItem
    }
    
    //导航栏中按钮的点击事件
    func barButtonClicked(btn:UIButton){
        //返回上一页面
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //未完待续
    //除导航栏外的按钮的点击事件
    func functionBtnClicked(btn:UIButton){
        if btn.tag > 4000 {
            let cell = btn.superview?.superview as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)
            productIndex = indexPath
            
        }
        switch btn.tag {
            //加入购物车
        case 1111:
            var proID:[Int]=[]
            var proCount:[Int]=[]
            var sProID:String = "["
            var sProCount:String = "["
            for i in 0  ..< selectMaintanceItemModels.count {
                for j in 0  ..< selectMaintanceItemModels[i].products.count {
                    proID.append(selectMaintanceItemModels[i].products[j].proID)
                    proCount.append(selectMaintanceItemModels[i].products[j].count!)
                }
            }
            for i in 0  ..< proID.count  {
                if(i != proID.count - 1){
                    sProID += "\(proID[i]),"
                    sProCount += "\(proCount[i]),"
                }
                else{
                    sProID += "\(proID[i])]"
                    sProCount += "\(proCount[i])]"
                }
            }
            print("proID", sProID)
            let userID = NSUserDefaults.standardUserDefaults().integerForKey("UserID")
            let parameters = ["UserID":userID,"ProductID":sProID,"Quantity":sProCount]
            Alamofire.request(.POST, addShoppingCarURL, parameters: parameters as? [String : AnyObject]).response{
                request ,response ,data , eror in
                self.performSegueWithIdentifier("WannaMaintToShoppingcar", sender: self)
                //重新加载一次购物车数据才能实时刷新购物车数据
                var listData: NSDictionary = NSDictionary()
                var getShoppintCarURL = ""
                let filePath = NSBundle.mainBundle().pathForResource("config.plist", ofType:nil )
                listData = NSDictionary(contentsOfFile: filePath!)!
                getShoppintCarURL = listData.valueForKey("url") as! String
                getShoppintCarURL += "/ASHX/MobileAPI/ShopCar/Get.ashx"
            }
            
            //去保养－》选择维修店
        case 2222:
            self.performSegueWithIdentifier("WannaMainToStoreList", sender: self)
            //更正上次保养日期
        case 3333:
            if btn.titleLabel?.text == "更正" {
                lastMile?.enabled = true
                lastMile?.borderStyle = UITextBorderStyle.Line
                lastTime?.enabled = true
                lastTime!.borderStyle = UITextBorderStyle.Line
                btn.setTitle("确定", forState: UIControlState.Normal)
            }
            else {
                lastMile?.enabled = false
                lastMile?.borderStyle = UITextBorderStyle.None
                lastTime?.enabled = false
                lastTime!.borderStyle = UITextBorderStyle.None
                btn.setTitle("更正", forState: UIControlState.Normal)
            }
            //选择品牌
        case 5555:
            productTypeTemp = selectMaintanceItemModels[(productIndex?.section)!].products[(productIndex?.row)!].proType!
            self.performSegueWithIdentifier("WannaMainToChooseBrand", sender: self)
            //改变商品数量
        case 6666:
            alertV = ChangeCountAlterView(title: "修改商品数量", account: Int((btn.titleLabel?.text)!)!, delegate: self)
            alertV!.show()
        default:
            print("")
        }
    }
    
    
    
    func brandClosure(product:ProductModel)->Void {
        selectMaintanceItemModels[(productIndex?.section)!].products[(productIndex?.row)!] = product
        selectMaintanceItemModels[(productIndex?.section)!].products[(productIndex?.row)!].proType! = productTypeTemp
        tableView.reloadData()
    }
    
    //转跳时传递相应数据
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "WannaMainToChooseBrand" {
            let receive = (segue.destinationViewController as! UINavigationController)
            let a = receive.viewControllers[0] as! ChooseBrandTableViewController
            a.productNO = selectMaintanceItemModels[(productIndex?.section)!].products[(productIndex?.row)!].proNo
            a.productSelected = selectMaintanceItemModels[(productIndex?.section)!].products[(productIndex?.row)!]
            a.initWithClosure(brandClosure)
        }
    }
    
    
    //修改商品数量弹出框的确定按钮事件
    func selectOkButtonalertView() {
        //先获取弹出框中的数字，再将其设置为数量按钮count的内容，最后修改底部费汇总信息
        selectMaintanceItemModels[productIndex!.section].products[productIndex!.row].count = alertV!.account
        changeFootersData()
    }
    
    //滑动删除
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath){
        //删除数据源的对应数据
        selectMaintanceItemModels[indexPath.section].products.removeAtIndex(indexPath.row)
        //删除对应的cell
        self.tableView?.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top)
        //若section 中已无cell则删除该section
        if tableView.numberOfRowsInSection(indexPath.section) == 0 {
            selectMaintanceItemModels.removeAtIndex(indexPath.section)
            tableView.deleteSections(NSIndexSet(index: indexPath.section), withRowAnimation: UITableViewRowAnimation.Top)
        }
        changeFootersData()
    }
    //把delete改成中文
    override func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String {
        return "删除"
    }
    
    //更改footerview的数据
    func changeFootersData() {
        tableView.reloadData()
        //totalP:商品总价
        var totalP:Double = 0
        for i in 0..<tableView.numberOfSections {
            for j in 0..<tableView.numberOfRowsInSection(i) {
                totalP += (selectMaintanceItemModels[i].products[j].shopPrice * Double(selectMaintanceItemModels[i].products[j].count!))
            }
        }
        let footer = tableView.tableFooterView!
        let finalMsg = footer.subviews[2] as! UILabel
        finalMsg.text = "¥ " + String(format: "%.2f", totalP)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //根据从后台获取的数据量设置section的数量
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return selectMaintanceItemModels.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (selectMaintanceItemModels[section].products).count
    }
    
    //每一行的具体内容设置
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
        
        var labelX = 5
        var labelW = 75
        var labelH:[CGFloat] = [0,0]
        let model = selectMaintanceItemModels[indexPath.section].products[indexPath.row]
        var msg = model.proType
        //商品类别、商品名称
        for i in 0 ..< 2 {
            if i == 1 {
                labelX = 83
                labelW = Int(screenW - 88)
                msg = model.proName
            }
            let goodLabel = UILabel(frame: CGRect(x:labelX, y:5, width:labelW, height:0))
            //设置自动换行
            goodLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
            goodLabel.numberOfLines = 0
            goodLabel.text = msg
            goodLabel.font = UIFont.systemFontOfSize(14)
            if i == 0 {
                goodLabel.textAlignment = NSTextAlignment.Center
            }
            //计算label的高度
            let string:NSString = goodLabel.text!
            let options : NSStringDrawingOptions = NSStringDrawingOptions.UsesLineFragmentOrigin
            let boundingRect = string.boundingRectWithSize(CGSizeMake(CGFloat(labelW), 0), options: options, attributes: [NSFontAttributeName:goodLabel.font], context: nil)
            goodLabel.frame = CGRectMake(CGFloat(labelX), 5, boundingRect.size.width, boundingRect.size.height)
            cell!.contentView.addSubview(goodLabel)
            cell!.frame.size = CGSizeMake(boundingRect.size.width, boundingRect.size.height)
            labelH[i] = boundingRect.size.height
            
        }
        //比较保养项目及选购产品两栏的高度，选择较大的一项作为单元格的高度
        if labelH[0] > labelH[1] {
            lineHeight = CGFloat(labelH[0] + 55)
        }
        else {
            lineHeight = CGFloat(labelH[1] + 55)
        }
        
        let countL = UILabel(frame: CGRect(x: (screenW - 240), y: (lineHeight - 33), width: 40, height: 20))
        countL.text = "数量："
        countL.font = UIFont.systemFontOfSize(13)
        cell!.contentView.addSubview(countL)
        
        count = UIButton(frame: CGRect(x: (screenW - 205), y: (lineHeight - 35), width: 30, height: 28))
        count.setTitle(String(model.count!), forState: UIControlState.Normal)
        count.titleLabel!.textAlignment = NSTextAlignment.Center
        count.titleLabel!.font = UIFont.systemFontOfSize(14)
        count.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        count.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
        count.addTarget(self, action: #selector(WannaMaintTableViewController.functionBtnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        count.tag = 6666
        cell!.contentView.addSubview(count)
        
        //单元格中的小图标
        let labelx = [Int(screenW - 170),Int(screenW - 140)]
        let labely = [Int(lineHeight - 32),Int(lineHeight - 35)]
        let labelh = [20,25]
        let labelw = [20,70]
        for i in 0..<2 {
            let btn = UIButton(frame: CGRect(x:labelx[i], y:labely[i], width:labelw[i], height:labelh[i]))
            btn.layer.cornerRadius = 5.0
            if i == 0 {
                //这里删掉了小垃圾桶图标
            }
            else {
                btn.setTitle("选择品牌", forState: UIControlState.Normal)
                btn.titleLabel!.textColor = UIColor.whiteColor()
                btn.titleLabel!.textAlignment = NSTextAlignment.Center
                btn.titleLabel!.font = UIFont.systemFontOfSize(14)
                btn.backgroundColor = UIColor.orangeColor()
                btn.tag = 5555
            }
            btn.addTarget(self, action: #selector(WannaMaintTableViewController.functionBtnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell?.contentView.addSubview(btn)
        }
        let price = UILabel(frame: CGRect(x: screenW - 70, y: (lineHeight - 35), width: 65, height: 20))
        price.text = "¥" + String(format:"%.2f",model.shopPrice)
        price.font = UIFont.systemFontOfSize(14)
        price.textColor = UIColor.redColor()
        price.textAlignment = NSTextAlignment.Right
        cell?.contentView.addSubview(price)
        
        //分隔保养项目及产品的竖线
        let middleLine = UILabel(frame: CGRect(x: 76, y: 0, width: 2, height: lineHeight))
        middleLine.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
        cell?.contentView.addSubview(middleLine)
        
        //分隔单元格的横线
        let downLine = UILabel(frame: CGRect(x: 0, y: lineHeight - 2, width: screenW, height: 2))
        downLine.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
        cell?.contentView.addSubview(downLine)
        
        //取消单元格的选中
        cell?.selectionStyle = UITableViewCellSelectionStyle.None
        return cell!
    }
    
    //根据从前一页传递过来的数据设置保养项目的标题
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        /*screenW:屏幕宽度
        item：整个section的商品详情数组（［productModel］）
        img：section图标
        */
        let screenW = self.view.frame.size.width
        let item = selectMaintanceItemModels[section].products
        let view = UIView(frame: CGRect(x: 0, y: 0, width: screenW, height: 45))
        let img = UIImageView(frame: CGRect(x: 5, y: 8, width: 35, height: 30))
        //获取想要显示的部分的大小及位置
        let starPic = UIImage(named: (selectMaintanceItemModels[section].maintanceItem + String(2)))
        let rect = CGRectMake(0, 0, 166, 160)
        //将此部分从图片中剪切出来
        let ref = CGImageCreateWithImageInRect(starPic!.CGImage!, rect)
        //将剪切下来图片放入UIImageView中
        img.image = UIImage(CGImage: ref!)
        view.addSubview(img)
        //项目名称
        let titleText = selectMaintanceItemModels[section].maintanceItem
        let label1 = UILabel(frame: CGRect(x: 45, y: 13, width: titleText.calculateTextWidth(UIFont.systemFontOfSize(15)), height: 20))
        label1.text = titleText
        label1.font = UIFont.systemFontOfSize(15)
        label1.textColor = UIColor.redColor()
        view.addSubview(label1)
        //项目总价
        let label2 = UILabel(frame: CGRect(x: screenW - 100, y: 15, width: 40, height: 20))
        label2.text = "小计: "
        label2.font = UIFont.systemFontOfSize(13)
        view.addSubview(label2)
        
        var sectionMoney:Double = 0
        for i in 0..<item.count {
            sectionMoney += (item[i].shopPrice * Double(item[i].count!))
        }
        let label3 = UILabel(frame: CGRect(x: screenW - 70, y: 15, width: 70, height: 20))
        label3.text = "¥" + String(format:"%.2f",sectionMoney)
        label3.font = UIFont.systemFontOfSize(13)
        label3.textColor = UIColor.redColor()
        view.addSubview(label3)
        view.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
        return view
    }
    
    //顶部保养信息的提示
    func headerView()->UIView {
        let screenW = self.view.frame.size.width
        let view = UIView(frame: CGRect(x: 0, y: 0, width: screenW, height: 125))
        
        let lastMag = UILabel(frame: CGRect(x: 10, y: 10, width: 105, height: 20))
        lastMag.text = "上次保养公里数:"
        lastMag.font = UIFont.systemFontOfSize(14)
        lastMag.numberOfLines = 0;
        lastMag.lineBreakMode = NSLineBreakMode.ByWordWrapping
        view.addSubview(lastMag)
        
        lastMile = UITextField(frame: CGRect(x: 115, y: 10, width: screenW - 180, height: 20))
        lastMile!.text = "12345" + "公里 "
        lastMile?.font = UIFont.systemFontOfSize(14)
        lastMile!.enabled = false
        lastMile!.backgroundColor = UIColor.clearColor()
        view.addSubview(lastMile!)
        
        let lastT = UILabel(frame: CGRect(x: 10, y: 35, width: 100, height: 20))
        lastT.text = "上次保养日期:"
        lastT.font = UIFont.systemFontOfSize(14)
        lastT.numberOfLines = 0;
        lastT.lineBreakMode = NSLineBreakMode.ByWordWrapping
        view.addSubview(lastT)
        
        lastTime = UITextField(frame: CGRect(x: 100, y: 35, width: 100, height: 20))
        lastTime!.text = "2015/12/20"
        lastTime!.enabled = false
        lastTime!.font = UIFont.systemFontOfSize(14)
        lastTime!.backgroundColor = UIColor.clearColor()
        view.addSubview(lastTime!)
        
        let change = UIButton(frame: CGRect(x: screenW - 45, y: 15, width: 40, height: 30))
        change.setTitle("更正", forState: UIControlState.Normal)
        change.titleLabel!.textColor = UIColor.whiteColor()
        change.titleLabel!.textAlignment = NSTextAlignment.Center
        change.titleLabel!.font = UIFont.systemFontOfSize(14)
        change.backgroundColor = UIColor.orangeColor()
        change.layer.cornerRadius = 5.0
        change.tag = 3333
        change.addTarget(self, action: #selector(WannaMaintTableViewController.functionBtnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(change)
        
        let thisLabel = UILabel(frame: CGRect(x: 10, y: 55, width: 90, height: 25))
        thisLabel.text = "本次保养项目:"
        thisLabel.font = UIFont.systemFontOfSize(14)
        view.addSubview(thisLabel)
        let thisTips = UILabel(frame: CGRect(x: 100, y: 58, width: screenW - 50, height: 20))
        thisTips.text = "(每10000公里保养或一年保养一次)"
        thisTips.font = UIFont.systemFontOfSize(12.5)
        thisTips.textColor = UIColor.redColor()
        view.addSubview(thisTips)
        
        //主要用在顶部的保养项目栏
        let view2 = UIView(frame: CGRect(x: 0, y: 85, width: screenW, height: 40))
        let labeltext = ["保养项目","以选购产品","单价"]
        let labelW = 80
        let labelX = [5,(Int(screenW / 2) - Int(labelW / 2)),screenW - 70]
        for i in 0 ..< labeltext.count {
            let label = UILabel(frame: CGRect(x: Int(labelX[i] as! NSNumber), y: 10, width: labelW, height: 20))
            label.text = labeltext[i]
            label.textColor = UIColor.whiteColor()
            label.font = UIFont.systemFontOfSize(14)
            label.textAlignment = NSTextAlignment.Center
            view2.addSubview(label)
        }
        view2.backgroundColor = UIColor.grayColor()//(red: 129, green: 136, blue: 154, alpha: 1.0
        view.addSubview(view2)
        return view
    }
    
    //页面最底部的总价、转跳按钮等设置
    func footerView()->UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 150))
        let screenW = self.view.frame.size.width
        //价格栏
        let label1 = UILabel(frame: CGRect(x: screenW - 200, y: 10, width: 150, height: 20))
        label1.text = "总价              :"
        label1.font = UIFont.systemFontOfSize(17)
        label1.textColor = UIColor.redColor()
        
        let label2 = UILabel(frame: CGRect(x: screenW - 170, y: 12, width: 100, height: 20))
        label2.text = "（不含运费）"
        label2.font = UIFont.systemFontOfSize(12)
        label2.textColor = UIColor.redColor()
        
        var totalMoney:Double = 0
        for i in 0..<selectMaintanceItemModels.count {
            for j in 0..<selectMaintanceItemModels[i].products.count {
                totalMoney += (selectMaintanceItemModels[i].products[j].shopPrice * Double(selectMaintanceItemModels[i].products[j].count!))
            }
        }
        let label3 = UILabel(frame: CGRect(x: screenW - 110, y: 10, width: 100, height: 20))
        label3.text = "¥" + String(format:"%.2f",totalMoney)
        label3.font = UIFont.systemFontOfSize(17)
        label3.textColor = UIColor.redColor()
        label3.textAlignment = NSTextAlignment.Right
        
        //下一步
        let nextBtn = UIButton(frame: CGRect(x: screenW / 2 - 60, y: 55, width: 120, height: 30))
        nextBtn.setTitle("加入购物车", forState: UIControlState.Normal)
        nextBtn.titleLabel!.textColor = UIColor.whiteColor()
        nextBtn.titleLabel!.textAlignment = NSTextAlignment.Center
        nextBtn.backgroundColor = UIColor.orangeColor()
        nextBtn.layer.cornerRadius = 5.0
        nextBtn.tag = 1111
        nextBtn.addTarget(self, action: #selector(WannaMaintTableViewController.functionBtnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        //本次保养信息栏
        let date = NSDate()
        let timeFormatter = NSDateFormatter()
        timeFormatter.dateFormat = "yyy年MM月"
        let strNowTime = timeFormatter.stringFromDate(date) as String
        let text = "本次保养公里数:" + "12345" + "公里,保养日期:" + strNowTime
        let label4 = UILabel(frame: CGRect(x: 0, y: 95, width: (screenW - 45), height: 40))
        label4.text = text
        label4.font = UIFont.systemFontOfSize(12)
        label4.textColor = UIColor.grayColor()
        label4.textAlignment = NSTextAlignment.Center
        label4.numberOfLines = 0;
        label4.lineBreakMode = NSLineBreakMode.ByWordWrapping
        
        let toMStore = UIButton(frame: CGRect(x: screenW - 50, y: 105, width: 40, height: 20))
        toMStore.setTitle("去保养", forState: UIControlState.Normal)
        toMStore.titleLabel!.textColor = UIColor.whiteColor()
        toMStore.titleLabel!.textAlignment = NSTextAlignment.Center
        toMStore.titleLabel!.font = UIFont.systemFontOfSize(12)
        toMStore.backgroundColor = UIColor.blueColor()
        toMStore.layer.cornerRadius = 3.0
        toMStore.tag = 2222
        toMStore.addTarget(self, action: #selector(WannaMaintTableViewController.functionBtnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        let arr = [label1,label2,label3,nextBtn,label4,toMStore]
        for i in 0..<arr.count {
            view.addSubview(arr[i])
        }
        return view
        
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return lineHeight
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 15
    }
    
    func getData(modelCode:String , sMaintenanceItem:String){
        //设置加载动图
        let imgView = UIImageView(image: UIImage.gifWithName("loading2"))
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: tableView.frame.height))
        imgView.frame = CGRect(x: (view.frame.width) / 2 - 150, y: (view.frame.height) / 2 - 150, width: 300, height: 300)
        view.addSubview(imgView)
        tableView.backgroundView = view
     
        let parameters = ["ModelCode":modelCode , "MaintianceItem":sMaintenanceItem]
        Alamofire.request(.POST, getMaintenanceItemURL , parameters:parameters)
            .response { request ,response ,data , eror in
              
                let json = JSONND.initWithData(data!)
               
                let jsonarray = json.arrayValue
                //好像没有正常执行
                for i in 0  ..< jsonarray.count {
                    let maintanceItemName = jsonarray[i]["MaintanceItem"].stringValue
                    let products = jsonarray[i]["Products"].arrayValue
                    var productItems:[ProductModel] = []
                    for j in 0  ..< products.count   {
                        let proType = products[j]["ProType"].stringValue
                        let proID = products[j]["ProID"].intValue
                        let proName = products[j]["ProName"].stringValue
                        let proNO = products[j]["ProNO"].stringValue
                        let shopPrice = Double(products[j]["ShopPrice"].floatValue)
                        let marketPrice = Double(products[j]["MarketPrice"].floatValue)
                        let imagePath = products[j]["ImagePath"].stringValue
                        let productItem:ProductModel = ProductModel(proType: proType, proID: proID, proName: proName, proNo: proNO, shopPrice: shopPrice, marketPrice: marketPrice, imagePath: imagePath)
                        productItems.append(productItem)
                    }
                    let maintanceItem:SelectMaintanceItemModel = SelectMaintanceItemModel(maintanceItem: maintanceItemName, products: productItems)
                    self.selectMaintanceItemModels.append(maintanceItem)
                }
                self.tableView.backgroundView = nil
                self.tableView.reloadData()
                
                //设置头部、底部信息
                self.tableView.tableHeaderView = self.headerView()
                self.tableView.tableFooterView = self.footerView()
        }
    }
    
}
