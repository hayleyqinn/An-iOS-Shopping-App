//
//  ShareTableViewController.swift
//  ico2o
//
//  Created by Katherine on 16/1/12.
//  Copyright © 2016年 chingyam. All rights reserved.
//

import UIKit
//, UIScrollViewDelegate
class ShareTableViewController: UITableViewController, ViewPagerIndicatorDelegate {

    var scrollView: UIScrollView!
    var viewPagerIndicator: ViewPagerIndicator!
    var scrollViewHeight: CGFloat!
    var screenW:CGFloat = 0
    let maintItem:[String] = ["小保养","1","1","小保养","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1"]
    let itemdata = [["store1","珠海金装士汽车维修店","4.8","商店评价商店评价商店评价商店评价商店评价商店评价商店评价商店评价商店评价商店评价商店评价商店评价商店评价商店评价商店评价商店评价","用户12794421","23"],["store1","珠海金装士汽车维修店","4.8","商店评价商店评价商店评价商店评价商店评价商店评价商店评价商店评价商店评价商店评价商店评价商店评价商店评价商店评价商店评价商店评价","用户17511421","20"],["store1","珠海金装士汽车维修店","4.8","商店评价商店评价商店评价商店评价商店评价商店评价商店评价商店评价商店评价商店评价商店评价商店评价商店评价商店评价商店评价商店评价","用户1852421","18"]]
    let contentItem = ["小保养","洗车","换轮胎"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenW = self.view.frame.width
        
        tableView.tableHeaderView = headerView()
    }

    //返回上一页
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //点击上方项目名称按钮更改当前显示数据
    func itemChange(btn:UIButton) {
        print(btn.tag)
        tableView.reloadData()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return itemdata.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let alertV = ShowDetailAlertView(img: UIImage(named: "mine_normal")!, title: itemdata[indexPath.section][4], content: itemdata[indexPath.section][3], pictures: ["store1","store1"])
        alertV.show()
    }
    
    //顶部选项栏
    func headerView()->UIView {
        let view = UIView(frame:CGRect(x: 0, y: 0, width: screenW, height: 135))
        viewPagerIndicator = ViewPagerIndicator(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 10))
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 10, width: view.frame.width, height: 130))
        view.addSubview(viewPagerIndicator)
        view.addSubview(scrollView)
        
        viewPagerIndicator.titles = [" "," "," "," "]
        viewPagerIndicator.frame.size.height = 10
        //监听ViewPagerIndicator选中项变化
        viewPagerIndicator.delegate = self
        scrollViewHeight = self.view.bounds.height - viewPagerIndicator.bounds.height - 20
        //样式
        scrollView.pagingEnabled = true
        scrollView.bounces = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        //内容大小
        scrollView.contentSize = CGSize(width: self.view.bounds.width * CGFloat(viewPagerIndicator.count ), height: 120)
        //根据顶部的数量加入子Item
        for i in 0..<viewPagerIndicator.count {
            let subview = UIView(frame: CGRectMake(self.view.bounds.width * CGFloat(i), 0, self.view.bounds.width, scrollViewHeight))
            //分页加入不同的btn
            var btnX:CGFloat = 10
            var btnY:CGFloat = 5
            let btnW = (screenW - 40) / 3
            for j in 0..<12 {
                let btn = UIButton(frame: CGRect(x: btnX, y: btnY, width: btnW, height: CGFloat(20)))
                btn.setTitle(maintItem[i * 11 + j], forState: UIControlState.Normal)
                btn.titleLabel!.textAlignment = NSTextAlignment.Center
                btn.titleLabel!.font = UIFont.systemFontOfSize(15)
                btn.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
                btn.addTarget(self, action: #selector(ShareTableViewController.itemChange(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                btn.tag = i * 12 + j
                subview.addSubview(btn)
                //设置下一个btn的坐标
                btnX += (10 + btnW)
                if (j + 1) % 3 == 0 {
                    btnY += 28
                    btnX = 10
                }
            }
            scrollView.addSubview(subview)
        }
        viewPagerIndicator.indicatorDirection = .Top
        
        return view
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame:CGRect(x: 0, y: 0, width: screenW, height: 145))
        view.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
        
        //初始化imageview并获取image
        let pic = UIImageView(image: UIImage(named: itemdata[section][0]))
        pic.frame = CGRect(x: 10, y: 8, width: 65, height: 65)
        view.addSubview(pic)
        
        let name = UILabel(frame: CGRect(x: 85, y: 10, width: screenW - 90, height: 20))
        name.text = itemdata[section][1]
        name.font = UIFont.systemFontOfSize(16)
        view.addSubview(name)
        
        //显示等级的图标
        let grade = Float(itemdata[section][2])
        let starY = (ceil(Float(grade! * 10) / 5) - 2) * (Float(330 / 9))
        //获取想要显示的部分的大小及位置
        let rect = CGRectMake(25, CGFloat(starY), 170, 36)
        let img = UIImageView(frame: CGRect(x: 85, y: 32, width: 100, height: 25))
        img.image = UIImage(named: "stars")?.cutPicture(rect)
        view.addSubview(img)
        
        let starNum = UILabel(frame: CGRect(x: 175, y: 35, width: 70, height: 20))
        starNum.text = itemdata[section][2]
        starNum.font = UIFont.systemFontOfSize(14)
        view.addSubview(starNum)
        
        var text = "维修项目："
        for str in contentItem {
            text += (str + "  ")
        }
        let item = UILabel(frame: CGRect(x: 85, y: 55, width: screenW - 90, height: 20))
        item.text = text
        item.font = UIFont.systemFontOfSize(14)
        view.addSubview(item)
        
        return view
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame:CGRect(x: 0, y: 0, width: screenW, height: 50))
        view.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
        
        let imgV = UIImageView(frame: CGRect(x: 20, y: 8, width: 25, height: 25))
        imgV.image = UIImage(named: "mine_normal")
        view.addSubview(imgV)
        
        let name = UILabel(frame: CGRect(x: 60, y: 10, width: 100, height: 20))
        name.text = itemdata[section][4]
        name.font = UIFont.systemFontOfSize(15)
        view.addSubview(name)
        
        let zanBtn = UIButton(frame: CGRect(x: screenW - 70, y: 2, width: 80, height: 30))
        zanBtn.setImage(UIImage(named: "zan2"), forState: UIControlState.Normal)
        zanBtn.imageEdgeInsets = UIEdgeInsets(top: 6, left: 0, bottom: 1, right: 58)
        zanBtn.titleEdgeInsets = UIEdgeInsets(top: 5, left: -40, bottom: 0, right: 0)
        zanBtn.setTitle(itemdata[section][5], forState: UIControlState.Normal)
        zanBtn.setTitleColor(UIColor.orangeColor(), forState: UIControlState.Normal)
        zanBtn.tag = section
        zanBtn.addTarget(self, action: #selector(ShareTableViewController.zanClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(zanBtn)
        
        let line = UILabel(frame: CGRect(x: 0, y: 40, width: screenW, height: 10))
        line.backgroundColor = UIColor.whiteColor()
        view.addSubview(line)
        
        return view
    }
    
    func zanClicked(btn:UIButton) {
        let num = Int((btn.titleLabel?.text)!)! + 1
        btn.setTitle(String(num), forState: UIControlState.Normal)
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
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

        let judge = UILabel(frame: CGRect(x: 15, y: 5, width: screenW - 30, height: 50))
        judge.text = itemdata[indexPath.section][3]
        judge.font = UIFont.systemFontOfSize(15)
        judge.textColor = UIColor.grayColor()
        judge.textAlignment = NSTextAlignment.Center
        judge.numberOfLines = 0;
        judge.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cell?.contentView.addSubview(judge)
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    //点击顶部选中后回调
    func indicatorChange(indicatorIndex: Int){
        scrollView.scrollRectToVisible(CGRectMake(self.view.bounds.width * CGFloat(indicatorIndex), 0, self.view.bounds.width, scrollViewHeight), animated: true)
    }
    //滑动scrollview回调
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let xOffset: CGFloat = scrollView.contentOffset.x
        let x: Float = Float(xOffset)
        let width:Float = Float(self.view.bounds.width)
        let index = Int((x + (width * 0.5)) / width)
        viewPagerIndicator.setSelectedIndex(index)//改变顶部选中
    }
}
