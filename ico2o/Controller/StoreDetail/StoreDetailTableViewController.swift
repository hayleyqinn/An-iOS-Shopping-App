//
//  StoreDetailTableViewController.swift
//  ico2o
//
//  Created by Katherine on 15/12/16.
//  Copyright © 2015年 chingyam. All rights reserved.
//

import UIKit

class StoreDetailTableViewController: UITableViewController {
    /*scrollView:店铺轮播图
    pageControl：显示第几张图
    picNum：该店铺轮播图中的图片张数
    dataFromOther：从其它页面传过来的信息
    screenH：屏幕高度
    */
    var scrollView: UIScrollView!
    var pageControl: UIPageControl!
    var timer:NSTimer!
    var picNum = 1
    var dataFromOther = "金丰瑞达汽车维修店"
    var screenH:CGFloat = 0
    
    //返回上一页
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageControl = UIPageControl(frame: CGRect(x: (Int(self.view.frame.size.width) - 10) / 2, y: 160, width: 10, height: 20))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
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
            if view.isKindOfClass(UIScrollView.self) {
                view.removeFromSuperview()
            }
            else if view.isKindOfClass(UILabel.self) {
                view.removeFromSuperview()
            }
            else if view.isKindOfClass(UIButton.self) {
                view.removeFromSuperview()
            }
        }
        
        if indexPath.section == 0 {
            screenH = self.view.frame.height
            //图片轮播、店铺名称背景、店铺名称
            scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: screenW, height: 150))
            cell?.contentView.addSubview(scrollView)
            
            let line = UILabel(frame: CGRect(x: 0, y: 125, width: screenW, height: 25))
            line.backgroundColor = UIColor.blackColor()
            line.alpha = 0.7
            cell?.contentView.addSubview(line)
            
            let storeName = UILabel(frame: CGRect(x: 10, y: 130, width: 200, height: 20))
            storeName.text = dataFromOther
            storeName.textColor = UIColor.whiteColor()
            storeName.font = UIFont.systemFontOfSize(15)
            cell?.contentView.addSubview(storeName)
            
            cell?.contentView.addSubview(pageControl)
            pictureGallery()
        }
        else {
            //分页部分
            let swiftPagesView : SwiftPages!
            swiftPagesView = SwiftPages(frame: CGRectMake(0, 0, screenW, self.view.frame.height))
            //VCID：storyboard中viewcontroller的id，buttonTitles：在界面中显示的分页标题
            let VCIDs : [String] = ["StoreDetailDetail", "StoreDetailDetail", "StoreDetailDetail","StoreDetailDetail"]
            let buttonTitles : [String] = ["基本信息", "服务项目", "优惠活动","评价"]
            
            swiftPagesView.setOriginY(0.0)
            swiftPagesView.setButtonsTextColor(UIColor.blackColor())
            swiftPagesView.setAnimatedBarColor(UIColor.blackColor())
            swiftPagesView.initializeWithVCIDsArrayAndButtonTitlesArray(VCIDs, buttonTitlesArray: buttonTitles)
            cell?.contentView.addSubview(swiftPagesView)
        }

        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        //0:商店图片，1:详细情况
        if indexPath.section == 0 {
            return 150
        }
        else {
            return screenH
        }
    }
    
    //图片轮播
    func pictureGallery(){
        //获取Scrollview的宽高作为兔牌呢的宽高
        let imageW:CGFloat = self.view.frame.size.width
        let imageH:CGFloat = self.scrollView.frame.size.height
        //图片的y坐标就在scrollview的顶端
        let imageY:CGFloat = 0
        for index in 0..<picNum{
            let imageView:UIImageView = UIImageView(image: UIImage())
            let imageX:CGFloat = CGFloat(index) * imageW
            //设置图片大小，几张图片是按顺序从左向右依次放置在ScrollView中的，但是ScrollView在界面中显示的只是一张图片的大小，效果类似与画廊
            imageView.frame = CGRectMake(imageX, imageY, imageW, imageH)
            
            let name:String = String(format:"store%d",index + 1)
            imageView.image = UIImage(named: name)
            
            //不设置水平滚动条
            self.scrollView.showsHorizontalScrollIndicator = false
            //把图片加入到scrollview中，实现轮播效果
            self.scrollView.addSubview(imageView)
        }
        
        //ScrollView控件一定要设置contentSize;包括长和宽；
        let contentW:CGFloat = imageW * CGFloat(picNum)
        self.scrollView.contentSize = CGSizeMake(contentW, 0)
        self.scrollView.pagingEnabled = true
        self.scrollView.delegate = self
        //下面的页码提示器
        self.pageControl.numberOfPages = picNum
        self.addTimer();
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
        self.timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(StoreDetailTableViewController.nextImage(_:)), userInfo: nil, repeats: true)
    }
}
