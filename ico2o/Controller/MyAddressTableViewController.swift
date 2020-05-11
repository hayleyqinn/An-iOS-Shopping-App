//
//  MyAddressTableViewController.swift
//  ico2o
//
//  Created by Katherine on 15/12/4.
//  Copyright © 2015年 chingyam. All rights reserved.
//

import UIKit
import Alamofire
import JSONNeverDie

typealias sendAddressMsgClosure = (msg:AddressModel)->Void

class MyAddressTableViewController: UITableViewController {
    /*passSourceIndex:点击某个cell中修改按钮时，该往下一页面传递的值，及当前的indexPath.row
    comeFromMakeOrder：是否从确认订单页面转跳过来，是则当前为选择收货地址，否则为管理收货地址
    myClosure：用作返回给确认订单页面已选择的收货地址的闭包
    listData，filePath：URl相关
    headerURL:URL的ip地址部分
    getReceivingURL,updateDefaultReceivingURL，deleteReceivingURL：获得收货地址、更新默认地址、删除地址
    addressList:地址数据数组
    */
    var passSourceIndex:Int?
    var comeFromMakeOrder = false
    var myClosure:sendAddressMsgClosure?
    var listData: NSDictionary = NSDictionary()
    var filePath = NSBundle.mainBundle().pathForResource("config.plist", ofType:nil )
    var headerURL:String = ""
    let getReceivingURL:String = "/ASHX/MobileAPI/Receiving/GetReceiving.ashx"
    let updateDefaultReceivingURL = "/ASHX/MobileAPI/Receiving/UpdateDefaultReceiving.ashx"
    let deleteReceivingURL = "/ASHX/MobileAPI/Receiving/DeleteReceiving.ashx"
    var addressList:[AddressModel] = []
        var checkNetwork = CheckNetWorking()
    
    //返回上一页
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    //右上角的添加新地址按钮
    @IBAction func addAddressBtnClicked(sender: AnyObject) {
        self.performSegueWithIdentifier("AddressToNewAdd", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listData = NSDictionary(contentsOfFile: filePath!)!
        headerURL = listData.valueForKey("url") as! String
        getData(NSUserDefaults.standardUserDefaults().valueForKey("UserID") as! Int)
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }
   
    //连接并获取数据
    func getData(UserID:Int) {
        if(!checkNetwork.checkNetwork()){
            return
        }
        //设置加载动图
        let imgView = UIImageView(image: UIImage.gifWithName("loading2"))
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: tableView.frame.height))
        imgView.frame = CGRect(x: (view.frame.width) / 2 - 150, y: (view.frame.height) / 2 - 150, width: 300, height: 300)
        view.addSubview(imgView)
        tableView.backgroundView = view
        
        //清空addressList中的内容，以防从其它页面返回后影响数据
        addressList = []
        let parameters = ["UserID":UserID]
        Alamofire.request(.POST, (headerURL + getReceivingURL) , parameters:parameters)
            .response { request ,response ,data , eror in
                let json = JSONND.initWithData(data!)
                let jsonarray = json.arrayValue
                var District: String = ""
                for i in 0..<jsonarray.count {
                    let ID = jsonarray[i]["ID"].int!
                    let Name = jsonarray[i]["Name"].string!
                    let Mobile = jsonarray[i]["Mobile"].string!
                    let Address = jsonarray[i]["Address"].string!
                    let Province = jsonarray[i]["Province"].string!
                    let City = jsonarray[i]["City"].string!
                    if jsonarray[i]["District"].string != nil {
                        District = jsonarray[i]["District"].string!
                    }
                    let PostCode = jsonarray[i]["PostCode"].string!
                    var IsDefault = false
                    if jsonarray[i]["IsDefault"].int != 0 {
                        IsDefault = true
                    }
                    
                    let address = AddressModel(ID: ID, Name: Name, Mobile: Mobile, Address: Address, Province: Province, City: City, District: District, PostCode: PostCode, IsDefault: IsDefault)
                   self.addressList.append(address)
                    print("das")
                    print(jsonarray)
                }
                self.tableView.backgroundView = nil
                self.tableView.reloadData()
        }
    }
    
    //btn的点击事件
    func btnClicked(btn:UIButton) {
        //得到当前btn所在的cell及indexPath
        let cell = btn.superview?.superview as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        //1:删除,2:修改,3:设为默认
        //需与后台连接的操作，连接成功后再在本地进行修改
        switch btn.tag {
        case 1:
            //所需参数
            let parameters:[String:AnyObject] = ["ReceivingID":Int((addressList[indexPath!.row]).ID),"UserID":NSUserDefaults.standardUserDefaults().integerForKey("UserID")]
            //提交请求
            Alamofire.request(.POST, (headerURL + deleteReceivingURL) , parameters:parameters)
                .response { request ,response ,data , eror in
                    let result = JSONND.initWithData(data!)
                    let isSuccess:Bool = result["result"].bool!
                    if (isSuccess){
                        //若删除的为默认地址，则移除NSUserDefaults中的数据
                        if self.addressList[indexPath!.row].IsDefault {
                            NSUserDefaults.standardUserDefaults().removeObjectForKey("DefaultAddress")
                        }
                        //删除数据源的对应数据
                        self.addressList.removeAtIndex(indexPath!.row)
                        //删除对应的cell
                        self.tableView?.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Top)
                    }
                    else{
                        let alterWin = UIAlertView(title: nil, message: "网络故障，请重试", delegate: nil, cancelButtonTitle: "确定")
                        alterWin.show()
                    }
            }
        case 2:
            //设置需传递的数据标志
            passSourceIndex = indexPath?.row
            self.performSegueWithIdentifier("AddressToNewAdd", sender: self)
        case 3:
            //若已为默认则不作任何处理，节省流量？
            if btn.titleLabel?.text == "设为默认" {
                //所需参数
                let parameters:[String:AnyObject] = ["UserID":NSUserDefaults.standardUserDefaults().integerForKey("UserID"),"ReceivingID":Int((addressList[indexPath!.row]).ID)]
                //提交请求
                Alamofire.request(.POST, (headerURL + updateDefaultReceivingURL) , parameters:parameters)
                    .response { request ,response ,data , eror in
                        let result = JSONND.initWithData(data!)
                        let isSuccess:Bool = result["result"].boolValue
                        if (isSuccess){
                            //检查所删除的是否为默认地址，并修改本地数据信息
                            let defaultAddr = NSUserDefaults.standardUserDefaults().objectForKey("DefaultAddress")
                            if defaultAddr != nil {
                                let modelData = defaultAddr as! NSData
                                let temp = NSKeyedUnarchiver.unarchiveObjectWithData(modelData) as! AddressModel
                                if temp == self.addressList[indexPath!.row] {
                                    NSUserDefaults.standardUserDefaults().removeObjectForKey("DefaultAddress")
                                }
                            }
                            for obj in self.addressList {
                                obj.IsDefault = false
                            }
                            self.addressList[indexPath!.row].IsDefault = true
                            self.tableView.reloadData()
                        }
                        else{
                            let alterWin = UIAlertView(title: nil, message: "提交失败，请重试", delegate: nil, cancelButtonTitle: "确定")
                            alterWin.show()
                        }
                }
            }
        default:
            break
        }
    }
    
    //将一个addressModel设为默认
    func setDefaultAddress(obj:AddressModel) {
        //NSUserDefault不可直接存储自定义类型，需将其转化为NSData再进行存储
        //实例对象转换成NSData
        let modelData:NSData = NSKeyedArchiver.archivedDataWithRootObject(obj)
        //存储NSData对象
        NSUserDefaults.standardUserDefaults().setObject(modelData, forKey: "DefaultAddress")
    }
    
    //接收从其它页面传来的闭包，返回给确认订单页面已选择的收货地址用
    func initWithClosure(closure:sendAddressMsgClosure)->Void {
        myClosure = closure
    }
    
    //转跳时传递相应数据
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //点击添加收货地址
        if segue.identifier == "AddressToNewAdd" {
            let receive = (segue.destinationViewController as! UINavigationController)
            let a = receive.viewControllers[0] as! AddAddressViewController
            //将本VC传给下一个页面，以返回时作相应处理
            a.lastVC = self
            //若passSourceIndex！＝nil则为修改地址信息
            if passSourceIndex != nil {
                a.dataFromOther = addressList[passSourceIndex!]
                //传完后将passSourceIndex再设为nil，以免转跳回来后影响下一次转跳
                passSourceIndex = nil
            }
        }
    }
    
    //点击收货地址事件
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //若当前页面是从确认订单页面转跳过来，则通过闭包返回所选择的收货地址
        if comeFromMakeOrder {
            myClosure!(msg: addressList[indexPath.row])
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addressList.count
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
        }
        let screenW = self.view.frame.size.width
        if addressList.count != 0 {
            //获取当前行的model
            let model = addressList[indexPath.row]
            let name = UILabel(frame: CGRect(x: 10, y: 15, width: 120, height: 20))
            name.text = "收货人:" + model.Name
            name.font = UIFont.systemFontOfSize(15)
            cell?.contentView.addSubview(name)
            
            let tel = UILabel(frame: CGRect(x: 10, y: 45, width: 200, height: 20))
            tel.text = "联系电话:" + model.Mobile
            tel.font = UIFont.systemFontOfSize(15)
            cell?.contentView.addSubview(tel)
            
            let postage = UILabel(frame: CGRect(x: 220, y: 45, width: 100, height: 20))
            postage.text = "邮编:" + model.PostCode
            postage.font = UIFont.systemFontOfSize(15)
            cell?.contentView.addSubview(postage)
            
            let address = UILabel(frame: CGRect(x: 10, y: 75, width:screenW - 20, height:40 ))
            address.text = "地址:" + model.Province + model.City + model.District + model.Address
            address.font = UIFont.systemFontOfSize(15)
            address.numberOfLines = 0;
            address.lineBreakMode = NSLineBreakMode.ByWordWrapping
            cell?.contentView.addSubview(address)
            
            //去除单独删除按钮，只保留左滑删除
//            let delete = UIButton(frame: CGRect(x: screenW - 185, y: 12, width: 40, height: 25))
//            delete.setTitle("删除", forState: UIControlState.Normal)
//            delete.titleLabel!.textAlignment = NSTextAlignment.Center
//            delete.titleLabel!.font = UIFont.systemFontOfSize(13)
//            delete.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
//            delete.layer.cornerRadius = 3.0
//            delete.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
//            delete.addTarget(self, action: "btnClicked:", forControlEvents: UIControlEvents.TouchUpInside)
//            delete.tag = 1
//            cell?.contentView.addSubview(delete)
            
            let change = UIButton(frame: CGRect(x: screenW - 130, y: 12, width: 40, height: 25))
            change.setTitle("修改", forState: UIControlState.Normal)
            change.titleLabel!.textAlignment = NSTextAlignment.Center
            change.titleLabel!.font = UIFont.systemFontOfSize(13)
            change.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
            change.layer.cornerRadius = 3.0
            change.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
            change.addTarget(self, action: #selector(MyAddressTableViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            change.tag = 2
            cell?.contentView.addSubview(change)
            
            let chooseState = UIButton(frame: CGRect(x: screenW - 75, y: 12, width: 60, height: 25))
            chooseState.setTitle("设为默认", forState: UIControlState.Normal)
            chooseState.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
            if model.IsDefault {
                setDefaultAddress(model)
                chooseState.setTitle("默认", forState: UIControlState.Normal)
                chooseState.backgroundColor = UIColor(red: 17/255, green: 127/255, blue: 239/255, alpha: 1.0)
                chooseState.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            } else {
                chooseState.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)

            }
            chooseState.titleLabel!.textAlignment = NSTextAlignment.Center
            chooseState.titleLabel!.font = UIFont.systemFontOfSize(13)
           
            if  chooseState.titleLabel?.text == "默认" {
                

            } else {
                
                           }
           
         
            chooseState.addTarget(self, action: #selector(MyAddressTableViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            chooseState.tag = 3
            
            cell?.contentView.addSubview(chooseState)
            
            let line = UILabel(frame: CGRect(x: 0, y: 120, width: screenW, height: 4))
            line.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
            cell?.contentView.addSubview(line)
            
            cell?.selectionStyle = UITableViewCellSelectionStyle.None
        }
        return cell!
    }
    
    //滑动删除
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath){
//        //删除数据源的对应数据
//        addressList.removeAtIndex(indexPath.row)
//        //删除对应的cell
//        self.tableView?.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top)
        //所需参数
        let parameters:[String:AnyObject] = ["ReceivingID":Int((addressList[indexPath.row]).ID),"UserID":NSUserDefaults.standardUserDefaults().integerForKey("UserID")]
        //提交请求
        Alamofire.request(.POST, (headerURL + deleteReceivingURL) , parameters:parameters)
            .response { request ,response ,data , eror in
                let result = JSONND.initWithData(data!)
                let isSuccess:Bool = result["result"].bool!
                if (isSuccess){
                    //若删除的为默认地址，则移除NSUserDefaults中的数据
                    if self.addressList[indexPath.row].IsDefault {
                        NSUserDefaults.standardUserDefaults().removeObjectForKey("DefaultAddress")
                    }
                    //删除数据源的对应数据
                    self.addressList.removeAtIndex(indexPath.row)
                    //删除对应的cell
                    self.tableView?.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top)
                }
                else{
                    let alterWin = UIAlertView(title: nil, message: "网络故障，请重试", delegate: nil, cancelButtonTitle: "确定")
                    alterWin.show()
                }
        }
    }
    //把delete改成中文
    override func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String {
        return "删除"
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 124
    }
    
}
