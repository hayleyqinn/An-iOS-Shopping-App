//
//  MyOrderTableViewController.swift
//  ico2o
//
//  Created by Katherine on 16/1/13.
//  Copyright © 2016年 chingyam. All rights reserved.
//

import UIKit

class MyOrderTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //返回上一页
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        print(1111111)
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
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
        //分页部分
        let swiftPagesView : SwiftPages!
        swiftPagesView = SwiftPages(frame: CGRectMake(0, 0, screenW, self.view.frame.height))
        //VCID：storyboard中viewcontroller的id，buttonTitles：在界面中显示的分页标题
        let VCIDs : [String] = ["MyOrder", "MyOrder", "MyOrder", "MyOrder", "MyOrder"]
        let buttonTitles : [String] = ["全部", "待付款", "待发货", "待收货", "已评价"]
        
        swiftPagesView.setOriginY(0.0)
        swiftPagesView.setButtonsTextColor(UIColor.blackColor())
        swiftPagesView.setAnimatedBarColor(UIColor.blackColor())
        swiftPagesView.initializeWithVCIDsArrayAndButtonTitlesArray(VCIDs, buttonTitlesArray: buttonTitles)
        cell?.contentView.addSubview(swiftPagesView)
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let screenH = self.view.frame.size.height
        //计算状态栏及导航栏的高度
        let rectStatus = UIApplication.sharedApplication().statusBarFrame
        let rectNav = self.navigationController?.navigationBar.frame
        let marginHeight = rectStatus.size.height + rectNav!.size.height
        return (screenH - marginHeight)
    }
}
