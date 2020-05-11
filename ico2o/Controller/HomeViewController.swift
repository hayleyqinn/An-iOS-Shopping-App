//
//  HomeViewController.swift
//  ico2o
//
//  Created by chingyam on 15/10/15.
//  Copyright (c) 2015年 chingyam. All rights reserved.
//

import UIKit
import Alamofire
class HomeViewController: UIViewController ,UIScrollViewDelegate, UISearchBarDelegate,UITextFieldDelegate, UIAlertViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var gotoman: UIButton!

  
    @IBOutlet weak var milesTF: UITextField!
    let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 280, height: 25))
    var maintainItemIndex:[Int] = []
    //图片轮播计时器
    var timer:NSTimer!
    
    // 根据指定线的ID跳转到目标vc
    @IBAction func toMaintenance(sender: AnyObject) {
        if NSUserDefaults.standardUserDefaults().integerForKey("UserID") == 0 {
            searchBar.resignFirstResponder()
            let alterWin = UIAlertView(title: nil, message: "请登陆账户后操作", delegate: nil, cancelButtonTitle: "确定")
            alterWin.show()
            
        } else {
            if milesTF.text != "" {
                var miles:Int = 0
                if(Int(milesTF.text!)! <= 5000){
                    miles = 5000
                }else{
                    miles = Int(milesTF.text!)!
                }
                maintainItemIndex = []
                let maintainDao = MaintenanceItemDao()
                let maintainItem = maintainDao.queryData(miles)

                for i in 0  ..< maintainItem.count {
                    maintainItemIndex.append(maintainItem[i].id-1)
                }
                self.performSegueWithIdentifier("HomeToWanna", sender: self)
            }
            else {
                let alterWin = UIAlertView(title: nil, message: "请输入行驶公里数", delegate: nil, cancelButtonTitle: "确定")
                alterWin.show()
            }

        }
    }
    //如果没有登录，则关闭键盘
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        if NSUserDefaults.standardUserDefaults().integerForKey("UserID") == 0 {
            searchBar.resignFirstResponder()
            let alterWin = UIAlertView(title: nil, message: "请登陆账户后操作", delegate: nil, cancelButtonTitle: "确定")
            alterWin.show()
         
       
        }
    }
    //如果没有登录，则关闭键盘
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if NSUserDefaults.standardUserDefaults().integerForKey("UserID") == 0 {
            searchBar.resignFirstResponder()
            let alterWin = UIAlertView(title: nil, message: "请登陆账户后操作", delegate: nil, cancelButtonTitle: "确定")
            alterWin.show()
        } else {
            self.performSegueWithIdentifier("homeToGoodsList", sender: self)
        }
    }
    @IBAction func toGoodsList(sender: AnyObject) {
        if searchBar.text != "" {
            self.performSegueWithIdentifier("homeToGoodsList", sender: self)
        }
        else {
            let alterWin = UIAlertView(title: nil, message: "请输入配件名称或配件号", delegate: nil, cancelButtonTitle: "确定")
            alterWin.show()
        }
    }
    //转跳时传递相应数据
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "HomeToWanna" {
            let receive = (segue.destinationViewController as! UINavigationController)
            let a = receive.viewControllers[0] as! WannaMaintTableViewController
            print(milesTF.text,Double(milesTF.text!))
            a.selectedIndex = maintainItemIndex
        }
        else if segue.identifier == "homeToGoodsList" {
            let receive = (segue.destinationViewController as! UINavigationController)
            let a = receive.viewControllers[0] as! GoodsListTableViewController
            a.goodMsgFromOther = searchBar.text!
            
            if NSUserDefaults.standardUserDefaults().stringForKey("ModelCode") != nil {
                let modelCode = NSUserDefaults.standardUserDefaults().stringForKey("ModelCode")!
                let tempParam:[String:AnyObject] = ["KeyWord":searchBar.text!, "ModelCode":modelCode, "PageNO":0, "PageSize":1000]
                searchBar.text! = ""
                a.parameters = tempParam
                
            } else {
                self.navigationController?.view.makeToast("您还没有选择车型哦！", duration: 3.0, position: .Center)
                
            }

//            let modelCode = NSUserDefaults.standardUserDefaults().valueForKey("ModelCode")
//            let tempParam:[String:AnyObject] = ["KeyWord":searchBar.text!, "ModelCode":modelCode!, "PageNO":0, "PageSize":1000]
//            searchBar.text! = ""
//            a.parameters = tempParam
        }
    }

    //构造URL
    var listData: NSDictionary = NSDictionary()
    var filePath = NSBundle.mainBundle().pathForResource("config.plist", ofType:nil )
    var loginURL:String = ""

    override func viewDidLoad() {
        let homeIcon = self.tabBarItem
        
        searchBar.placeholder = "请输入配件名称或配件号"
        gotoman.layer.cornerRadius = 1
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar
       milesTF.delegate = self
        homeIcon.selectedImage = UIImage(named:"home_focus")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        //图片轮播
        pictureGallery()
        milesTF.keyboardType = UIKeyboardType.DecimalPad
        print(NSUserDefaults.standardUserDefaults().integerForKey("UserID"))
        //重新获得COOKIE
        listData = NSDictionary(contentsOfFile: filePath!)!
        loginURL = listData.valueForKey("url") as! String
        loginURL += "/ASHX/MobileAPI/Login.ashx"
        
        if NSUserDefaults.standardUserDefaults().integerForKey("UserID") != 0 {
           
            let userName: String = NSUserDefaults.standardUserDefaults().stringForKey("userName")!
            let pwd = String(NSUserDefaults.standardUserDefaults().integerForKey("pwd"))
            let parameters = ["UserName": userName, "Pwd": pwd]
            //print(parameters)
            Alamofire.request(.POST, loginURL , parameters:parameters)
                .response { request ,response ,data , eror in
                    //print(response)
            }
        }
      
    }
    //清楚记录
    func textFieldDidEndEditing(textField: UITextField) {
        milesTF.text = ""
    }
    //图片轮播
    func pictureGallery(){
        //获取Scrollview的宽高作为兔牌呢的宽高
        let imageW:CGFloat = self.view.frame.size.width
        let imageH:CGFloat = self.scrollView.frame.size.height
        //图片的y坐标就在scrollview的顶端
        let imageY:CGFloat = 0
        let totalCount:NSInteger = 2
        for index in 0..<totalCount{
            let imageView:UIImageView = UIImageView(image: UIImage())
            let imageX:CGFloat = CGFloat(index) * imageW
            //设置图片大小，几张图片是按顺序从左向右依次放置在ScrollView中的，但是ScrollView在界面中显示的只是一张图片的大小，效果类似与画廊
            imageView.frame = CGRectMake(imageX, imageY, imageW, imageH)
            
            let name:String = String(format:"top_ad%d",index + 1)
            imageView.image = UIImage(named: name)
            
            //不设置水平滚动条
            self.scrollView.showsHorizontalScrollIndicator = false
            //把图片加入到scrollview中，实现轮播效果
            self.scrollView.addSubview(imageView)
        }
        
        //ScrollView控件一定要设置contentSize;包括长和宽；
        let contentW:CGFloat = imageW * CGFloat(totalCount)
        self.scrollView.contentSize = CGSizeMake(contentW, 0)
        self.scrollView.pagingEnabled = true
        self.scrollView.delegate = self
        //下面的页码提示器
        self.pageControl.numberOfPages = totalCount
        self.addTimer();
    }
    //4个功能按钮
    @IBAction func autoMiantenance(sender: AnyObject) {
        loginFirst("maintenance")
    }
    @IBAction func searchAc(sender: AnyObject) {
        loginFirst("searching")
    }
   
    @IBAction func nearMaintenance(sender: AnyObject) {
        let vc = (self.storyboard?.instantiateViewControllerWithIdentifier("nearMaintenance"))!
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    @IBAction func petrolNote(sender: AnyObject) {
        loginFirst("petrolNote")
    }
    
    func loginFirst(vcName:String) {
        
        NSUserDefaults.standardUserDefaults().setObject(vcName, forKey: "goToView")
        
        // 如果没有登陆则跳转到登陆界面
        if NSUserDefaults.standardUserDefaults().stringForKey("UserID") == nil ||
            NSUserDefaults.standardUserDefaults().integerForKey("UserID")==0 {
            UIAlertView(
                title               : "",
                message             : "请先登陆账户",
                delegate            : self,
                cancelButtonTitle   : "取消",
                otherButtonTitles   : "前往"
                ).show()
            
        }else{
            let vc = (self.storyboard?.instantiateViewControllerWithIdentifier(vcName))!
            self.presentViewController(vc, animated: true, completion: nil)
        }
    }
    
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == alertView.cancelButtonIndex { return }
        // “前往”按钮
        let vc = (self.storyboard?.instantiateViewControllerWithIdentifier("login"))!
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    
    //图片轮播
    func nextImage(sender:AnyObject!){
        var page:Int = self.pageControl.currentPage
        if(page == 1){
            page = 0
        }else{
            page += 1
        }
        let x:CGFloat = CGFloat(page) * self.view.frame.size.width
        //contentOffset就是设置ScrollView的偏移
        self.scrollView.contentOffset = CGPointMake(x , 0)
    }
    //处理所有ScrollView的滚动之后的事件，不是执行滚动的事件
    func scrollViewDidScroll(scrollView: UIScrollView) {
        //这里只是为了设置下面的页码提示器；该操作是在图片滚动之后操作的
        let scrollviewW:CGFloat = self.view.frame.size.width
        let x:CGFloat = scrollView.contentOffset.x
        let page:Int = (Int)((x + scrollviewW / 2) / scrollviewW)
        self.pageControl.currentPage = page
    }
    
    func addTimer(){
        self.timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(HomeViewController.nextImage(_:)), userInfo: nil, repeats: true)
    }
   
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        toGoodsList("")
        return true
    }
}
