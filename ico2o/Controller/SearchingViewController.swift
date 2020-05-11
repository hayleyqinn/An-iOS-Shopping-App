//
//  SearchingViewController.swift
//  ico2o
//
//  Created by Katherine on 15/11/18.
//  Copyright © 2015年 chingyam. All rights reserved.
//
import UIKit
import Alamofire
import JSONNeverDie

class SearchingViewController: UIViewController, UISearchBarDelegate {
    /*search:顶部的搜索栏
    firstMenuSelectedIndex：记录每级菜单的点击indexpath
    multiMenuView：菜单列表
    searchingMsg:顶栏搜索栏的信息
    */
    var search:UISearchBar?
    var firstMenuSelectedIndex: [NSIndexPath] = [NSIndexPath(forRow: 0, inSection: 0), NSIndexPath(forRow: 0, inSection: 0), NSIndexPath(forRow: 0, inSection: 0), NSIndexPath(forRow: 0, inSection: 0)]
    
    var carPartsDao:CarPartsDao?
    var carPartsArray1:[CarPartsModel] = []
    var carPartsArray2:[CarPartsModel] = []
    var carPartsArray3:[CarPartsModel] = []
    var carPartsArray4:[CarPartsModel] = []
    var multiMenuView: JZMultiMenuView?
    var searchingMsg = ""
    let firstLevelItem = ["常规保养件","常换件","底盘故障维修件","发动机常规保养","发动机故障修理件","碰撞事故维修件","仪器设备开关"]
    var ischooseCar:Bool = false
    //返回上一页
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        carPartsDao = CarPartsDao()
        carPartsArray1 = (carPartsDao?.queryDepth1())!
        carPartsArray2 = (carPartsDao?.queryDepthOther(2, id: 1))!
        carPartsArray3 = (carPartsDao?.queryDepthOther(3, id: 19))!
        let screenW = self.view.frame.size.width
        let screenH = self.view.frame.size.height
        //计算状态栏及导航栏的高度
        let rectStatus = UIApplication.sharedApplication().statusBarFrame
        let rectNav = self.navigationController?.navigationBar.frame
        let marginHeight = rectStatus.size.height + rectNav!.size.height
        //搜索栏
        self.view.addSubview(searchBarView())
        
        //菜单列表
        let rect = CGRect(x: 0, y: 35, width: screenW, height: screenH - marginHeight - 35)
        //若已选车型，显示2级菜单
        if ischooseCar == true {
            multiMenuView = JZMultiMenuView(frame: rect, type: JZMultiMenuViewType.Double)
        }
        else {
        //若未选车型，显示4级菜单
            multiMenuView = JZMultiMenuView(frame: rect, type: JZMultiMenuViewType.Multiple)
        }
        multiMenuView!.style = JZMultiMenuViewStyle.AnyStyle
        multiMenuView!.dataSource = self
        multiMenuView!.delegate = self
        self.view.addSubview(multiMenuView!)
    }
    
    
    //搜索栏
    func searchBarView()->UIView {
        let screenW = self.view.frame.size.width
        search = UISearchBar(frame: CGRect(x: 0, y: 5, width: screenW, height: 25))
        search!.barStyle = UIBarStyle.Default
        search?.delegate = self
        search!.placeholder = "请输入配件名称或配件编号"
       
        let view = UIView(frame: CGRect(x: 0, y: 0, width: screenW, height: 35))
        view.backgroundColor = UIColor(red: 187/255, green: 187/255, blue: 193/255, alpha: 1.0)
        view.addSubview(search!)
       
        return view
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if search!.text == "" {
            let alterV = UIAlertView(title: nil, message: "请输入配件名称或配件编号！", delegate: nil, cancelButtonTitle: "确定")
            alterV.show()
        }
        else {
            //先判断是否已选车型
            if (NSUserDefaults.standardUserDefaults().valueForKey("ModelCode") != nil) {
                searchingMsg = search!.text!
                self.performSegueWithIdentifier("searchingToGoodsList", sender: self)
            }
            else {
                let alterV = UIAlertView(title: nil, message: "请先选择车型！", delegate: nil, cancelButtonTitle: "确定")
                alterV.show()
            }
        }
    }

    
    //转跳时传递数据
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "searchingToGoodsList" {
            let receive = (segue.destinationViewController as! UINavigationController)
            let a = receive.viewControllers[0] as! GoodsListTableViewController
            var tempParam:[String:AnyObject] = [:]
            //判断是从菜单点击商品类别的转跳或搜索栏的转跳
            if searchingMsg == "" {
                let key = ["sortOneID","sortSecondID","sortThreeID","sortFourID"]
                let value = [carPartsArray1,carPartsArray2,carPartsArray3,carPartsArray4]
                //最多有四个参数（菜单深度）
                for i in 0..<4 {
                    //若该级内容为空，不加入参数列表
                    if value[i].count == 0 {
                        break
                    }
                    else {
                        tempParam[key[i]] = value[i][firstMenuSelectedIndex[i].row].id
                    }
                }
            }
            else {
                a.goodMsgFromOther = searchingMsg
                let modelCode = NSUserDefaults.standardUserDefaults().valueForKey("ModelCode")
                tempParam = ["KeyWord":searchingMsg, "ModelCode":modelCode!, "PageNO":0, "PageSize":1000]
                searchingMsg = ""
                search!.text = ""
            }
            a.parameters = tempParam
        }
    }
}

extension SearchingViewController: JZMultiMenuViewDataSouce {
    func menuView(menuView: UITableView, forLevel level: Int, numberOfRowsInSection section: Int) -> Int {
        if level == 0 {
            return carPartsArray1.count
        } else if level == 1 {
            return carPartsArray2.count
        } else if level == 2 {
            return carPartsArray3.count
        } else if level == 3 {
            return carPartsArray4.count
        } else {
            return 0
        }
    }
    func menuView(menuView: UITableView, forLevel level: Int, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier: String = "cell"
        var cell: UITableViewCell? = menuView.dequeueReusableCellWithIdentifier(cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier)
        }
        if level == 0 {
            cell!.textLabel?.text = carPartsArray1[indexPath.row].name
            
        } else if level == 1 {
            cell!.textLabel?.text = carPartsArray2[indexPath.row].name
        } else if level == 2 {
            cell!.textLabel?.text = carPartsArray3[indexPath.row].name
        } else if level == 3 {
            cell!.textLabel?.text = carPartsArray4[indexPath.row].name
        }
        return cell!
    }
}
extension SearchingViewController: JZMultiMenuViewDelegate {
    func menuView(menuView: UITableView, forLevel level: Int, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //先记录当前所点击的indexPath，再从数据库中读取下一级的数据，若为第四级（level＝3）则转跳至商品列表
        //因每项数据的子项级数不一定，因此每读取一级需将存放其下一级数据的数组清空，以免用户返回上一级时旧记录影响下一次操作
        self.firstMenuSelectedIndex[level] = indexPath
        var tempArray = carPartsArray1
        if level == 0 {
            carPartsArray2 = (carPartsDao?.queryDepthOther(2, id: carPartsArray1[indexPath.row].id))!
            tempArray = carPartsArray2
            carPartsArray3 = []
            carPartsArray4 = []
        }
        else if level == 1 {
            //若当前为四级菜单则弹出下一级菜单，否则转跳至下一页面
            if multiMenuView?.type == JZMultiMenuViewType.Multiple {
                carPartsArray3 = (carPartsDao?.queryDepthOther(3, id: carPartsArray2[indexPath.row].id))!
                tempArray = carPartsArray3
                carPartsArray4 = []
            }
            else if multiMenuView?.type == JZMultiMenuViewType.Double {
                self.performSegueWithIdentifier("searchingToGoodsList", sender: self)
            }
        }
        else if level == 2 {
            carPartsArray4 = (carPartsDao?.queryDepthOther(4, id: carPartsArray3[indexPath.row].id))!
            tempArray = carPartsArray4
        }
        else {
            self.performSegueWithIdentifier("searchingToGoodsList", sender: self)
        }
        //若下一级列表数据项为0，则点击后直接转跳，否则重新加载下一级数据
        if tempArray.count != 0 {
            multiMenuView!.reloadSingleData(level + 1)
        }
        else {
            self.performSegueWithIdentifier("searchingToGoodsList", sender: self)
        }
    }
}


