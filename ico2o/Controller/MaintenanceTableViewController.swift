//
//  MaintenanceTableViewController.swift
//  ico2o
//
//  Created by CatKatherine on 15/10/20.
//  Copyright (c) 2015年 chingyam. All rights reserved.
//

import UIKit
import Alamofire
import JSONNeverDie
class MaintenanceTableViewController: UITableViewController {
    
    /*data：项目名称数据
    milesFromOther:从其他页面传过来的保养公里数
    */
    var listData: NSDictionary = NSDictionary()
    var filePath = NSBundle.mainBundle().pathForResource("config.plist", ofType:nil )
    var maintenanceURL:String = ""
    var versionURL:String = ""
    let distanceProject:[Int] = [5000 , 10000 , 30000 , 40000 , 60000 , 100000]
    var maintenanceItemDao:MaintenanceItemDao?
    var maintenanceItems:[MaintenanceItemModel] = []
    var data:[[String]] = []
    var selectedIndex:[Int] = []
    
    var topBtn:[UIButton] = []
    var downBtn:[UIButton] = []
    var checkNetwork = CheckNetWorking()
    
    //返回上一页面
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        maintenanceItemDao = MaintenanceItemDao()
        listData = NSDictionary(contentsOfFile: filePath!)!
        maintenanceURL = listData.valueForKey("url") as! String
        versionURL = listData.valueForKey("url") as! String
        maintenanceURL += "/ASHX/MobileAPI/MaintenanceItem/Update.ashx"
        versionURL += "/ASHX/MobileAPI/MaintenanceItem/Version.ashx"
        //初始化数据
        //取消单元格间的分割线
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        //初始化下部按钮的选择状态
        
    }
    override func viewWillAppear(animated: Bool) {
        if(!checkNetwork.checkNetwork()){
            return
        }
        getData()
    }
    //初始化数据
    func dataInit(b:[String])->[[String]]{
        //顶部
        var a:[String] = []
        for i in 0..<6{
            a.append("maintenanceTop_" + String(i + 1))
        }
        let data = [a,b]
        return data
    }
    
    //button的点击事件
    func clicked(btn:UIButton){
        //改变该按钮的选中状态
        btn.selected = !btn.selected
        if(btn.tag <= 6){
            maintenanceItems = (maintenanceItemDao?.queryData(distanceProject[btn.tag - 1]))!
            resetBtn()
            for i in 0  ..< maintenanceItems.count {
                print(maintenanceItems[i].id - 1)
                downBtn[maintenanceItems[i].id - 1].selected = true
                tableView.reloadData()
            }
        }
        
        //若点击的为下部按钮，根据选中情况更改图标
        if btn.tag > 6 && btn.tag != 40{
            var imgName = "1"
            if btn.selected {
                imgName = "2"
            }
            btn.setImage(UIImage(named: data[1][btn.tag - 7] + imgName), forState: UIControlState.Normal)
        }
        
        //若有选中项目并点击了“下一步”按钮，转跳至我要保养页面,否则弹出框提示选择需选择
        if btn.tag == 40 {
            selectedIndex = []
            for i in 0  ..< downBtn.count {
                if(downBtn[i].selected == true){
                    selectedIndex.append(i)
                }
            }
            if NSUserDefaults.standardUserDefaults().stringForKey("ModelCode") != nil{
                if checkSelected(topBtn) || checkSelected(downBtn) {
                    self.performSegueWithIdentifier("MaintWanna", sender: self)
                }
                else {
                    let alterWin = UIAlertView(title: nil, message: "请选择保养项目", delegate: nil, cancelButtonTitle: "确定")
                    alterWin.show()
                    }
                }
            else{
                let alterWin = UIAlertView(title: nil, message: "请选择默认车型", delegate: nil, cancelButtonTitle: "确定")
                alterWin.show()
            }
        }
    }
    //判断某部分的按钮是否有选中
    func checkSelected(arr:[UIButton])->Bool {
        var result = false
        for button in arr{
            if button.selected {
                result = true
                break
            }
        }
        return result
    }
    
    func resetBtn(){
        for i in 0  ..< downBtn.count {
            downBtn[i].selected = false
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return (data.count + 1)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if data.count == 0 {
            return 0
        }
        else {
            switch section {
            case 0:
                return Int(ceil(CGFloat(data[section].count) / CGFloat(3)))
            case 1:
                return Int(ceil(CGFloat(data[section].count) / CGFloat(4)))
            default:
                return 1
            }
        }
    }
    
    func btnCreate() {
        //
        var lineNum = 3
        var totalNum = 6
        if data.count != 0 {
            for i in 0..<2 {
                if i == 1 {
                    totalNum = data[1].count
                    lineNum = 4
                }
                var n = 0//标记当前行里有几个btn,是否需要换行
                for j in 0..<totalNum {
                    if n == lineNum {
                        n = 0
                    }
                    
                    let btn: UIButton = UIButton(frame: CGRectZero)
                    btn.addTarget(self, action: #selector(MaintenanceTableViewController.clicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                    btn.setImage(UIImage(named: data[i][j]), forState: UIControlState.Normal)
                    if i == 1 {
                        btn.tag = j + 7
                        downBtn.append(btn)
                    }
                    else {
                        btn.tag = j + 1
                        topBtn.append(btn)
                    }
                }
            }
        }
    }
    
    //每一行的具体内容设置
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
        
        //不同部分作不同处理
        switch indexPath.section {
        case 0,1:
            if data.count != 0 && (topBtn.count != 0){
                //设置btn的位置、大小
                var lineNum = 3
                var btnSize = 90
                //var totalNum = 6
                let margin = (Int(self.view.frame.size.width) - (btnSize * lineNum)) / (lineNum + 1)
                //若section为1，作修改
                if indexPath.section == 1 {
                    lineNum = 4
                    btnSize = 60
                    //totalNum = data[1].count
                }
                var count = lineNum
                //当前section的行数，判断当前行是否为最后一行，是否需要修改当前行的btn数量
                let lines = Int(ceil(CGFloat(data[indexPath.section].count) / CGFloat(lineNum)))
                if (indexPath.row == (lines - 1)) && (data[indexPath.section].count % lineNum != 0) {
                    count = data[indexPath.section].count % lineNum
                }
                for i in 0 ..< count {
                    var btn = UIButton()
                    var theRect: CGRect = CGRect(x:((btnSize + margin) * i + margin), y:8, width:btnSize, height:btnSize )
                    if indexPath.section == 0 {
                        theRect = CGRect(x:((btnSize + margin) * i + margin), y:10, width:btnSize, height:btnSize - 20 )
                        btn = topBtn[lineNum * indexPath.row + i]
                    }
                    else {
                        btn = downBtn[lineNum * indexPath.row + i]
                        if btn.selected {
                            btn.setImage(UIImage(named: (data[1][btn.tag - 7] + String(2))), forState: UIControlState.Normal)
                        }
                        else {
                            btn.setImage(UIImage(named: (data[1][btn.tag - 7] + String(1))), forState: UIControlState.Normal)
                        }
                    }
                    btn.frame = theRect
                    cell?.contentView.addSubview(btn)
                }
            }
        case 2:
            let nextBtnLeftMargin = Int(self.view.frame.size.width - 100) / 2
            let next_btn: UIButton = UIButton(frame: CGRect(x:nextBtnLeftMargin, y:10, width:100, height:30))
            next_btn.setTitle("下一步", forState: UIControlState.Normal)
            next_btn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            next_btn.backgroundColor = UIColor.orangeColor()
            next_btn.layer.cornerRadius = 5.0
            next_btn.tag = 40
            next_btn.addTarget(self, action: #selector(MaintenanceTableViewController.clicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell!.contentView.addSubview(next_btn)
        default:
            break
        }
        
        //取消单元格间的分割线
        cell!.selectionStyle = UITableViewCellSelectionStyle.None
        return cell!
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1{
            let label = UILabel(frame: CGRectMake(0, 0, self.view.frame.size.width, 30))
            label.text = "  保养项目"
            label.textColor = UIColor.grayColor()
            label.backgroundColor = UIColor(red: 254/255, green: 179/255, blue: 37/255, alpha: 1.0)
            return label
        }
        else{
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 30
        }
        else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 80
        }
        else {
            return 70
        }
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 10))
        view.backgroundColor = UIColor.whiteColor()
        return view
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func getData(){
        //设置加载动图
        let imgView = UIImageView(image: UIImage.gifWithName("loading2"))
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: tableView.frame.height))
        imgView.frame = CGRect(x: (view.frame.width) / 2 - 150, y: (view.frame.height) / 2 - 150, width: 300, height: 300)
        view.addSubview(imgView)
        tableView.backgroundView = view
        
        maintenanceItemDao = MaintenanceItemDao()
        var mainData:[String] = []
        var version:Int = 0
        Alamofire.request(.POST, versionURL).response{
            resquest , response , result , error in
            let json = JSONND.initWithData(result!)
            version = json["MainItemVersion"].int!
            print(version)
            
            
            Alamofire.request(.POST, self.maintenanceURL )
                .response { request ,response ,result , error in
                    let json = JSONND.initWithData(result!)
                    let maintenanceData = json.arrayValue
                    let defultVersion = NSUserDefaults.standardUserDefaults().integerForKey("MaintenanceItemVersion")
                    
                    
                        for i in 0  ..< maintenanceData.count  {
                            mainData.append(maintenanceData[i]["Name"].string!)
                            let id = i
                            let name = maintenanceData[i]["Name"].string!
                            let km = maintenanceData[i]["KM"].int!
                            let factor = maintenanceData[i]["Factor"].int!
                            let level = maintenanceData[i]["Level"].int!
                            if( version != defultVersion){
                            self.maintenanceItemDao?.insertData(MaintenanceItemModel(id: id, name: name, km: km, factor: factor, level: level))
                        }
                    }
                    NSUserDefaults.standardUserDefaults().setObject(version, forKey: "MaintenanceItemVersion")
                    self.data = self.dataInit(mainData)
                    self.btnCreate()
                    self.tableView.backgroundView = nil
                    self.tableView.reloadData()
                    
            }
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "MaintWanna"{
            let receive = (segue.destinationViewController as! UINavigationController)
            let a = receive.viewControllers[0] as! WannaMaintTableViewController
            a.selectedIndex = selectedIndex
        }
    }
    
    
}
