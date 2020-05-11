//
//  ShoppingcarTableViewController.swift
//  ico2o
//
//  Created by Katherine on 15/11/19.
//  Copyright © 2015年 chingyam. All rights reserved.
//

import UIKit
import Alamofire
import JSONNeverDie
import Kingfisher

class ShoppingcarTableViewController: UITableViewController, ChangeCountAlertViewDelegate ,ChoosePropertyAlertViewDelegate {
    /*radioState:多选按钮的选中状态，默认为false
    count：显示商品数量的按钮
    countText：用作设置count中的内容
    alter：点击count后弹出的修改数量的对话框
    typeClickedIndex：当前点击的属性按钮位置
    properties：商品属性
    isNoData:判断当前数据是否为空
    */
    var radioState:[Bool] = []
    var count = UIButton()
    var countText = ""
    var alter:ChangeCountAlterView?
    var typeClickedIndex = 0
    var properties:[[String]] = []
    var getShoppintCarURL = ""
    var deleteCarItemURL = ""
    var updateShoppingCarURL = ""
    var commodityList:[CommodityModel] = []
    var isNoData = false
    var proIDArray:[Int] = []
    var listData: NSDictionary = NSDictionary()
    var filePath = NSBundle.mainBundle().pathForResource("config.plist", ofType:nil )
    var checkNetwork = CheckNetWorking()
    var id: Int = 0

    
    //返回上一页
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //全选按钮
    @IBAction func chooseAll(sender: AnyObject) {
        //先检查当前各多选按钮的选中情况，若有false，则全部设置为选中，否则全设为未选中，再重新加载（根据radioState的状况设置多选按钮的图片）
        var tag = false
        for i in 0..<radioState.count {
            if radioState[i] == false {
                tag = true
                break
            }
        }
        
        for i in 0..<radioState.count {
            radioState[i] = tag
        }
        
        tableView.reloadData()
        if isNoData {
              self.navigationController?.view.makeToast("暂时没有商品哦，现在去挑选吧～")
        } else {
            changeFootersData()
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listData = NSDictionary(contentsOfFile: filePath!)!
        getShoppintCarURL = listData.valueForKey("url") as! String
        getShoppintCarURL += "/ASHX/MobileAPI/ShopCar/Get.ashx"
        deleteCarItemURL = listData.valueForKey("url") as! String
        deleteCarItemURL += "/ASHX/MobileAPI/ShopCar/Delete.ashx"
        updateShoppingCarURL = listData.valueForKey("url") as! String
        updateShoppingCarURL += "/ASHX/MobileAPI/ShopCar/Update.ashx"
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
    }

    //加载数据
    func dataInit() {
        //设置加载动图
        let imgView = UIImageView(image: UIImage.gifWithName("loading2"))
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: tableView.frame.height))
        imgView.frame = CGRect(x: (view.frame.width) / 2 - 150, y: (view.frame.height) / 2 - 150, width: 300, height: 300)
        view.addSubview(imgView)
        tableView.backgroundView = view
        if(!checkNetwork.checkNetwork()){
            return
        }

        commodityList = []
        isNoData = false
        let userID = NSUserDefaults.standardUserDefaults().integerForKey("UserID")
        let parameters = ["UserID":userID,"PageNO":"1","IsShopper":0]
            Alamofire.request(.POST, getShoppintCarURL , parameters:parameters as? [String : AnyObject])
                .response { request ,response ,data , eror in
                    let json = JSONND.initWithData(data!)
                    let result = json.arrayValue

                    for i in 0..<result.count {
                        let bindingBoxCost = Double(result[i]["BindingBoxCost"].floatValue)
                        let isBindingBoxCost = result[i]["IsBindingBoxCost"].boolValue
                        let netWeight = result[i]["NetWeight"].intValue
                        let unit = result[i]["Unit"].stringValue
                        let orderType = result[i]["OrderType"].stringValue
                        self.id = result[i]["ID"].intValue
                        print("idddd = \(self.id)")
                        //let userID = result[i]["UserID"].intValue
                        let typeValue = result[i]["TypeValue"].stringValue
                        var createdDate = result[i]["CreatedDate"].stringValue
                        var imagePath = self.listData.valueForKey("url") as! String
                        imagePath += "/\(result[i]["ImagePath"].stringValue)"
                        let no = result[i]["NO"].stringValue
                        let inventory = result[i]["Inventory"].intValue
                        let isCheckStock = result[i]["IsCheckStock"].boolValue
                        let name = result[i]["Name"].stringValue
                        let areas = ""
                        let productID = result[i]["ProductID"].intValue
                        let otherID = result[i]["OtherID"].intValue
                        let payType = result[i]["PayType"].stringValue
                        let amount = Double(result[i]["Amount"].floatValue)
                        let quantity = result[i]["Quantity"].intValue
                        let price = Double(result[i]["Price"].floatValue)
                        let surplus = Double(result[i]["Surplus"].floatValue)
                        createdDate = createdDate.subString(createdDate)
                        self.proIDArray.append(productID)
                        let commodity = CommodityModel(bindingBoxCost: bindingBoxCost, isBindingBoxCost: isBindingBoxCost, netWeight: netWeight, unit: unit, orderType: orderType, id: self.id, typeValue: typeValue, createdDate: createdDate, imagePath: imagePath, no: no, inventory: inventory, isCheckStock: isCheckStock, payType: payType, amount: amount, quantity: quantity, price: price, surplus: surplus, name: name, areas: areas, productID: productID, otherID: otherID)
                        self.commodityList.append(commodity)
                      
                    }
                    if result.count == 0 {
                        let commodity = CommodityModel(bindingBoxCost: 1, isBindingBoxCost: false, netWeight: 1, unit: "", orderType: "", id: 1, typeValue: "", createdDate: "", imagePath: "", no: "", inventory: 1, isCheckStock: false, payType: "", amount: 1, quantity: 1, price: 1, surplus: 1, name: "", areas: "", productID: 1, otherID: 1)
                        self.commodityList.append(commodity)
                        self.isNoData = true
                    }
                    self.radioState = self.stateInit()
                    self.tableView.backgroundView = nil
                    self.tableView.reloadData()
                    self.tableView.tableFooterView = self.footerView()
        }
    }
    
    //设置多选按钮的初始状态，默认为false无选中
    func stateInit()->[Bool] {
        var arr:[Bool] = []
        for _ in 0..<commodityList.count {
            arr.append(false)
        }
        return arr
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commodityList.count
    }

    func clicked(obj: UIButton){
        //temp:存放已选中的数据下标
        var temp:[Int] = []
        for i in 0..<radioState.count {
            if radioState[i] {
                temp.append(i)
            }
        }
        var btn = obj
        if obj.tag != 3 {
            btn = obj 
        }
        //0:删除多项,1:cell中的radioBtn,2:更改商品数量,3:属性，111:下一步
        switch btn.tag {
        case 0:
            //若为0，提示需选中删除项，否则从数组后边开始进行删除，以免影响其它数据下标
            if temp.count == 0 {
                let alter = UIAlertView(title: "", message: "请选择要删除的商品", delegate: nil, cancelButtonTitle: "确定")
                alter.show()
            }
            else {
                for i in (0...(temp.count - 1)).reverse() {
                    let parameters = ["id":commodityList[temp[i]].id]
                    Alamofire.request(.POST, deleteCarItemURL, parameters:parameters)
                        .response { (request, response, data, error) in
                    }
                    radioState.removeAtIndex(temp[i])
                    commodityList.removeAtIndex(temp[i])
                }
                tableView.reloadData()
                changeFootersData()
            }
        case 1:
            var img = "radioBtn_2"
            let cell = btn.superview?.superview as! UITableViewCell
            let index = (tableView.indexPathForCell(cell))!.row
            if radioState[index] {
                img = "radioBtn_1"
                print(index)
            }
            radioState[index] = !radioState[index]
            btn.setImage(UIImage(named: img), forState: UIControlState.Normal)
            changeFootersData()
        case 2:
            let cell = btn.superview?.superview as! UITableViewCell
            let index = (tableView.indexPathForCell(cell))!.row
            alter = ChangeCountAlterView(title:"修改商品数量", account:commodityList[index].quantity,delegate: self)
            alter!.show()
            count = btn 
            
        case 3:
            //先取得当前的indexPath，根据indexPath更新属性数据源，再弹出框供用户修改
            let cell = btn.superview!.superview as! UITableViewCell
            typeClickedIndex = tableView.indexPathForCell(cell)!.row
            properties = [["白色","黑色","灰色","蓝色","红色","紫色","黄色","绿色"],["aaaaa","xxxx"]]
            let alertV = ChoosePropertyAlertView(title: commodityList[typeClickedIndex].name, tips: "库存：100件", delegate: self, properties: properties,style :ChoosePropertyAlertViewStyle.noCountStyle)
            alertV.show()
        case 111:
            //若为0，提示需选中结账项，转跳至订单页
            if temp.count == 0 {
                let alter = UIAlertView(title: "", message: "请选择要下单的商品", delegate: nil, cancelButtonTitle: "确定")
                alter.show()
            }
            else {
                self.performSegueWithIdentifier("ShoppingcarToMakeOrder", sender: self)
            }
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
        //将弹出框中的数字设置为数量按钮count的内容，最后修改底部费汇总信息
        count.setTitle(String(alter!.account), forState: UIControlState.Normal)
        let cell = count.superview?.superview as! UITableViewCell
        let row = tableView.indexPathForCell(cell)?.row
        commodityList[row!].quantity = alter!.account
        commodityList[row!].amount = Double(commodityList[row!].quantity) * commodityList[row!].price
        changeFootersData()
        let updateParameters = ["id":commodityList[row!].id, "quantity":alter!.account]
        Alamofire.request(.POST, updateShoppingCarURL, parameters: updateParameters)
            .response { (request, response, data, error) in
        }
    
    }
    
    //更改footerview的数据
    func changeFootersData() {
        self.tableView.reloadData()
        //temp:存放已选中的数据下标
        var temp:[Int] = []
        for i in 0..<radioState.count {
            if radioState[i] {
                temp.append(i)
            }
        }
        //amount:商品数量,totalP:商品总价
        var amount = 0
        var totalP:Double = 0
        for i in 0..<temp.count {
            amount += commodityList[temp[i]].quantity
            totalP += commodityList[temp[i]].amount
        }
        let footer = tableView.tableFooterView!
        //获取汇总信息的label
        let finalMsg = footer.subviews[0] as! UILabel
        finalMsg.text = "共 " + String(amount) + " 件商品\n合计：¥" + String(format: "%.2f", totalP) + "元（不含运费）"
        if commodityList.count == 0 {
            let commodity = CommodityModel(bindingBoxCost: 1, isBindingBoxCost: false, netWeight: 1, unit: "", orderType: "", id: 1, typeValue: "", createdDate: "", imagePath: "", no: "", inventory: 1, isCheckStock: false, payType: "", amount: 1, quantity: 1, price: 1, surplus: 1, name: "", areas: "", productID: 1, otherID: 1)
            commodityList.append(commodity)
            isNoData = true
            tableView.reloadData()
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
        
        if commodityList.count != 0 {
            if isNoData {
                let name = UILabel(frame: CGRect(x: 0, y: 50, width: screenW, height: 25))
                name.text = "购物车为空"
                name.font = UIFont.systemFontOfSize(16)
                name.textAlignment = NSTextAlignment.Center
                cell!.contentView.addSubview(name)
                cell?.userInteractionEnabled = false
                cell?.backgroundColor = UIColor.whiteColor()
            }
            else {
                let model = commodityList[indexPath.row]
                //pic:商品图片,name:商品名称,radioBtn:多选框，typeL:属性的标签,type:属性，price:价格,countL：商品数量标签，count:商品数量
                let pic = UIImageView(frame: CGRect(x: 5, y: 10, width: 70, height: 70))
                pic.kf_showIndicatorWhenLoading = true
                pic.kf_setImageWithURL(NSURL(string:model.imagePath)!, placeholderImage: nil,
                    optionsInfo: [.Transition(ImageTransition.Fade(1))],
                    progressBlock: { receivedSize, totalSize in
                        //                    print("\(receivedSize)/\(totalSize)")
                    },
                    completionHandler: { image, error, cacheType, imageURL in
                        //                    print("Finished")
                })
                cell!.contentView.addSubview(pic)
                
                let name = UILabel(frame: CGRect(x: 80, y: 10, width: screenW - 140, height: 50))
                name.text = model.name
                name.font = UIFont.systemFontOfSize(14)
                name.numberOfLines = 0;
                name.lineBreakMode = NSLineBreakMode.ByWordWrapping
                cell!.contentView.addSubview(name)
                
                let radioBtn = UIButton(frame: CGRect(x: (screenW - 30), y: 20, width: 25, height: 25))
                var img = "radioBtn_1"
                if radioState[indexPath.row] {
                    img = "radioBtn_2"
                }
                radioBtn.setImage(UIImage(named: img), forState: UIControlState.Normal)
                radioBtn.addTarget(self, action: #selector(ShoppingcarTableViewController.clicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                radioBtn.tag = 1
                cell!.contentView.addSubview(radioBtn)
                let price = UILabel(frame:CGRect(x: 80, y: 65, width: 100, height: 20))
                //let price = UILabel(frame: CGRect(x: screenW - 65, y: 40, width: 60, height: 20))
                let a = model.price
                price.text = "¥" + String(format: "%.2f", a)
                price.font = UIFont.systemFontOfSize(14)
                //price.textAlignment = NSTextAlignment.Right
                cell!.contentView.addSubview(price)
                
                let countL = UILabel(frame: CGRect(x: (screenW - 90), y: 65, width: 45, height: 20))
                countL.text = "数量："
                countL.font = UIFont.systemFontOfSize(14)
                countL.textAlignment = NSTextAlignment.Center
                cell!.contentView.addSubview(countL)
                
                count = UIButton(frame: CGRect(x: (screenW - 45), y: 63, width: 40, height: 20))
                count.setTitle(String(model.quantity), forState: UIControlState.Normal)
                count.titleLabel!.textAlignment = NSTextAlignment.Center
                count.titleLabel!.font = UIFont.systemFontOfSize(14)
                count.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
                count.backgroundColor = UIColor.whiteColor()
                count.addTarget(self, action: #selector(ShoppingcarTableViewController.clicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                count.tag = 2
                cell!.contentView.addSubview(count)
                cell!.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
            }
        }

        let line = UILabel(frame: CGRect(x: 10, y: 91, width: screenW - 20, height: 1))
        line.backgroundColor = UIColor.whiteColor()
        cell?.contentView.addSubview(line)
        cell!.tag = indexPath.row
        return cell!
    }
    
    //滑动删除
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath){
        //删除数据源的对应数据
    
            let parameters = ["id":commodityList[indexPath.row].id]
            Alamofire.request(.POST, deleteCarItemURL, parameters:parameters)
                .response { (request, response, data, error) in
            }
        
        
        
            radioState.removeAtIndex(indexPath.row)
            commodityList.removeAtIndex(indexPath.row)
            self.tableView?.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top)
            
            changeFootersData()
    }
    //把delete改成中文
    override func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String {
        return "删除"
    }
    
    //转跳页面
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if !isNoData {
            self.performSegueWithIdentifier("ShoppingcarToDetail", sender: self)
        }
    }
    
    //转跳时传递相应数据
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //点击商品转跳到商品详情页面
        if segue.identifier == "ShoppingcarToDetail" {
            let receive = (segue.destinationViewController as! UINavigationController)
            let a = receive.viewControllers[0] as! GoodDetailTableViewController
            let indexPath: NSIndexPath = self.tableView.indexPathForSelectedRow!
            a.goodMsgFromOther = proIDArray[indexPath.row]
         
        }
        //转跳到确认订单页面
        else if segue.identifier == "ShoppingcarToMakeOrder" {
            //筛选出需传递的数据(已选中的）
            var dataNeedPass:[CommodityModel] = []
            for i in 0..<radioState.count {
                if radioState[i] {
                    dataNeedPass.append(commodityList[i])
                }
            }
            let receive = (segue.destinationViewController as! UINavigationController)
            let a = receive.viewControllers[0] as! MakeOrderTableViewController
            a.data = dataNeedPass
        }
        
    }
    
    //设置底部汇总信息、删除多项、生成订单的部分
    func footerView()->UIView {
        let screenW = self.view.frame.size.width
        let view = UIView(frame: CGRect(x: 0, y: 0, width: screenW, height: 120))
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: screenW-10, height: 80))
//        var count:Int = 0
//        var totalP:Double = 0
//        for i in 0..<commodityList.count {
//            count += commodityList[i].quantity
//            totalP += commodityList[i].amount
//        }
        label.text = "共选择 " + String(0) + " 件商品\n合计：¥" + String(format: "%.2f", String(0)) + "元（不含运费）"
        label.textAlignment = NSTextAlignment.Right
        label.font = UIFont.systemFontOfSize(14)
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        view.addSubview(label)
        
        let deletes = UIButton(frame: CGRect(x: 20, y: 70, width: 90, height: 30))
        deletes.setTitle("删除", forState: UIControlState.Normal)
        deletes.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        deletes.titleLabel?.font = UIFont.systemFontOfSize(15)
        deletes.setImage(UIImage(named: "trashbin"), forState: UIControlState.Normal)
        deletes.imageEdgeInsets = UIEdgeInsetsMake(5, 0, 5, 60)
        deletes.titleEdgeInsets = UIEdgeInsetsMake(3, -240, 3, 0)
        deletes.titleLabel!.textAlignment = NSTextAlignment.Right
        deletes.addTarget(self, action: #selector(ShoppingcarTableViewController.clicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        deletes.tag = 0
        view.addSubview(deletes)
        
        let nextBtn = UIButton(frame: CGRect(x: (screenW - 90), y: 70, width: 80, height: 30))
        nextBtn.setTitle("下一步", forState: UIControlState.Normal)
        nextBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        nextBtn.backgroundColor = UIColor.orangeColor()
        nextBtn.titleLabel?.textAlignment = NSTextAlignment.Center
        nextBtn.titleLabel?.font = UIFont.systemFontOfSize(14)
        nextBtn.layer.cornerRadius = 5.0
        nextBtn.addTarget(self, action: #selector(ShoppingcarTableViewController.clicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        nextBtn.tag = 111
        view.addSubview(nextBtn)
        
        return view
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 92
    }
    
    override func viewWillAppear(animated: Bool) {
        commodityList = []
        dataInit()
        radioState = stateInit()
        if commodityList.count != 0 {
            //底部汇总信息、删除多项、生成订单部分
            tableView.tableFooterView = footerView()
        }
        self.tableView.reloadData()
    }
}
