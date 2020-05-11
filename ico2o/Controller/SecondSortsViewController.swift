//
//  SecondSortsViewController.swift
//  ico2o
//
//  Created by Katherine on 16/1/18.
//  Copyright © 2016年 chingyam. All rights reserved.
//

import UIKit
import Alamofire
import JSONNeverDie

class SecondSortsViewController: UIViewController {
    var listData: NSDictionary = NSDictionary()
    var filePath = NSBundle.mainBundle().pathForResource("config.plist", ofType:nil )

    var search = UISearchBar()
    var firstMenuSelectedIndex: [NSIndexPath] = [NSIndexPath(forRow: 0, inSection: 0), NSIndexPath(forRow: 0, inSection: 0)]
    var multiMenuView: JZMultiMenuView?
    var searchingMsg = ""
    var secondSort:[SecondSortsModel] = []
    var firstlevel:[String] = []
    var secondlevel:[String] = []
    var horse:String = ""
    var selectItem:String = ""
    var getSecondSortsURL:String = ""
    let firstLevelItem = ["常规保养件","常换件","底盘故障修理件","发动机常规保养","发动机故障修理件","碰撞事故维修件","仪器设备开关"]
    //返回上一页
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func toShoppingCar(sender: AnyObject) {
            let nav = self.storyboard?.instantiateViewControllerWithIdentifier("shoppingCarNav")
            self.presentViewController(nav!, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
         listData = NSDictionary(contentsOfFile: filePath!)!
        getSecondSortsURL = listData.valueForKey("url") as! String
        getSecondSortsURL += "/ASHX/MobileAPI/LoveCarDocument/GetSecondSorts.ashx"
        let screenW = self.view.frame.size.width
        let screenH = self.view.frame.size.height
        //计算状态栏及导航栏的高度
        let rectStatus = UIApplication.sharedApplication().statusBarFrame
        let rectNav = self.navigationController?.navigationBar.frame
        let marginHeight = rectStatus.size.height + rectNav!.size.height
        //搜索栏
        let searchBar = UIView(frame: CGRect(x: 0, y: marginHeight, width: screenW, height: 35))
        searchBar.addSubview(searchBarView())
        self.view.addSubview(searchBar)
        
        //菜单列表
        let rect = CGRect(x: 0, y: marginHeight + 35, width: screenW, height: screenH - marginHeight - 35)
        multiMenuView = JZMultiMenuView(frame: rect, type: JZMultiMenuViewType.Double)
        multiMenuView!.style = JZMultiMenuViewStyle.AnyStyle
        multiMenuView!.dataSource = self
        multiMenuView!.delegate = self
        self.view.addSubview(multiMenuView!)

        multiMenuView?.reloadData()
    }
    override func viewWillAppear(animated: Bool) {
        secondlevel = []
        getData()
        
        multiMenuView?.reloadSingleData(0)
        multiMenuView?.reloadSingleData(1)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //btn的点击事件
    func click(btn:UIButton){
        //3:搜索按钮
        switch btn.tag {
        case 3:
            if search.text == "" {
                let alterV = UIAlertView(title: nil, message: "请输入配件名称或配件编号！", delegate: nil, cancelButtonTitle: "确定")
                alterV.show()
            }
            else {
                //先判断是否已选车型
                if (NSUserDefaults.standardUserDefaults().valueForKey("ModelCode") != nil) {
                    searchingMsg = search.text!
                    self.performSegueWithIdentifier("secondSortToGoodList", sender: self)
                }
                else {
                    let alterV = UIAlertView(title: nil, message: "请先选择车型！", delegate: nil, cancelButtonTitle: "确定")
                    alterV.show()
                }
            }
        default:
            break
        }
    }
    
    //搜索栏
    func searchBarView()->UIView {
        let screenW = self.view.frame.size.width
        search = UISearchBar(frame: CGRect(x: (screenW - 240) / 2, y: 5, width: 220, height: 25))
        search.barStyle = UIBarStyle.Default
        search.placeholder = "请输入配件名称或配件编号"
        let searchBtn = UIButton(frame: CGRect(x: screenW / 2 + 110, y: 10, width: 20, height: 20))
        searchBtn.setImage(UIImage(named: "search_icon_1"), forState: UIControlState.Normal)
        searchBtn.tag = 3
        searchBtn.addTarget(self, action: #selector(SecondSortsViewController.click(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        let view = UIView(frame: CGRect(x: 0, y: 0, width: screenW, height: 35))
        view.backgroundColor = UIColor(red: 187/255, green: 187/255, blue: 193/255, alpha: 1.0)
        view.addSubview(search)
        view.addSubview(searchBtn)
        return view
    }
    
    //转跳时传递数据
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "secondSortToGoodList" {
            let receive = (segue.destinationViewController as! UINavigationController)
            let a = receive.viewControllers[0] as! GoodsListTableViewController
            var tempParam:[String:AnyObject] = [:]
            //判断是从菜单点击商品类别的转跳或搜索栏的转跳
            if searchingMsg == "" {
                a.isSecondMenu = true
                a.horse = self.horse
                a.secondItem = self.selectItem
            }
            else {
                a.goodMsgFromOther = searchingMsg
                let modelCode = NSUserDefaults.standardUserDefaults().valueForKey("ModelCode")
                tempParam = ["KeyWord":searchingMsg, "ModelCode":modelCode!, "PageNO":0, "PageSize":1000]
                searchingMsg = ""
                search.text = ""
            }
            a.parameters = tempParam
        }
    }
    
    func getData(){
        let parameters = ["horse":horse]
        Alamofire.request(.POST, self.getSecondSortsURL ,parameters:parameters ).response{
            request , response , data , error in
            let json = JSONND.initWithData(data!)
            let jsonarray = json.arrayValue
            for i in 0  ..< jsonarray.count  {
                let secondLevelItemArray = jsonarray[i][self.firstLevelItem[i]].arrayValue
                var secondLevelItems:[String] = []
                for j in 0  ..< secondLevelItemArray.count  {
                    //print(secondLevelItemArray[j].string!)
                    secondLevelItems.append(secondLevelItemArray[j].string!)
                }
                self.secondSort.append(SecondSortsModel(name: self.firstLevelItem[i], secondSortsName: secondLevelItems))
            }
            for i in 0  ..< self.secondSort[0].secondSortsName.count  {
                self.secondlevel.append(self.secondSort[0].secondSortsName[i])
            }
        }

    }
    
}

extension SecondSortsViewController: JZMultiMenuViewDataSouce {
    func menuView(menuView: UITableView, forLevel level: Int, numberOfRowsInSection section: Int) -> Int {
        if level == 0 {
            return 7
            //return 1
        } else if level == 1 {
            return secondlevel.count
            //return 1
        } else {
            return 1
        }
    }
    func menuView(menuView: UITableView, forLevel level: Int, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier: String = "cell"
        var cell: UITableViewCell? = menuView.dequeueReusableCellWithIdentifier(cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier)
        }
        if level == 0 {
            print(firstlevel)
            cell!.textLabel?.text = firstLevelItem[indexPath.row]
            //cell!.textLabel?.text = "1"
        } else if level == 1 {
            cell!.textLabel?.text = secondlevel[indexPath.row]
            //cell!.textLabel?.text = "2"
        }
        return cell!
    }
}
extension SecondSortsViewController: JZMultiMenuViewDelegate {
    func menuView(menuView: UITableView, forLevel level: Int, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.firstMenuSelectedIndex[level] = indexPath
        if level == 0 {
            secondlevel = secondSort[indexPath.row].secondSortsName
            multiMenuView?.reloadSingleData(1)
        }
        else {
            selectItem = secondlevel[indexPath.row]
            self.performSegueWithIdentifier("secondSortToGoodList", sender: self)
        }
    }
    
}
