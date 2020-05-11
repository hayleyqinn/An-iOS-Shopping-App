//
//  BeautyMViewController.swift
//  ico2o
//
//  Created by CatKatherine on 15/10/19.
//  Copyright (c) 2015年 chingyam. All rights reserved.
//

import UIKit

class BeautyMViewController: UITableViewController {
    var data:[[String]] = [["carbeauty_gray_01","carbeauty_gray_02","carbeauty_gray_03","carbeauty_gray_04"],["carbeauty_gray_05","carbeauty_gray_06","carbeauty_gray_07","carbeauty_gray_08"],["carbeauty_gray_09","carbeauty_gray_10","carbeauty_gray_11","carbeauty_gray_12"],["carbeauty_gray_13","carbeauty_gray_14"]]
    var btnState:[Bool] = []
    var selectedIndex:[Int] = []
    var projectBtn:[UIButton] = []
    var checkNetWork = CheckNetWorking()
    
    //返回上一页面
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //取消单元格间的分割线
        tableView.separatorStyle = .None
        
        data = dataInit(0)
        for _ in 0 ..< 14 {
            btnState.append(false)
        }
    }

    func dataInit(num:Int)->[[String]] {
//        var picName = ""
//        if num == 0 {
//            picName = "carbeauty_gray_"
//        }
        let pictures:[[String]] = [["carbeauty_gray_01","carbeauty_gray_02","carbeauty_gray_03","carbeauty_gray_04"],["carbeauty_gray_05","carbeauty_gray_06","carbeauty_gray_07","carbeauty_gray_08"],["carbeauty_gray_09","carbeauty_gray_10","carbeauty_gray_11","carbeauty_gray_12"],["carbeauty_gray_13","carbeauty_gray_14"]]

        return pictures
    }
    
    //button的点击事件
    func clicked(btn:UIButton){
        let tag = btn.tag
        btn.selected = !btn.selected
        var imgName = ""
        if tag != 111{
            if !btnState[tag - 1] {
                imgName = "carbeauty_orange_"
                
            }
            else{
                imgName = "carbeauty_gray_"
                
            }
        
            btnState[tag - 1] = !btnState[tag - 1]
            if btn.tag < 10 {
                btn.setImage(UIImage(named:imgName + "0" + String(tag)), forState: UIControlState.Normal)
                //projectBtn[tag].selected = true
                
                
                print(projectBtn.count)
            }
            else{
                btn.setImage(UIImage(named:imgName + String(tag)), forState: UIControlState.Normal)
                //projectBtn[tag].selected = false
            }
        }else if tag == 111{
            selectedIndex = []
            for i in 0  ..< projectBtn.count {
                if(projectBtn[i].selected == true){
                    selectedIndex.append(i)
                }
            }
            print(NSUserDefaults.standardUserDefaults().stringForKey("ModelCode"))
            if NSUserDefaults.standardUserDefaults().stringForKey("ModelCode") != nil{
                if checkSelected(projectBtn){
                    self.performSegueWithIdentifier("BeautyWanna", sender: self)
                }else{
                    let alterWin = UIAlertView(title: nil, message: "请选择美容项目", delegate: nil, cancelButtonTitle: "确定")
                    alterWin.show()
                }
            }else{
                let alterWin = UIAlertView(title: nil, message: "请选择默认车型", delegate: nil, cancelButtonTitle: "确定")
                alterWin.show()
            }
            
        }else {
            let nav = self.storyboard?.instantiateViewControllerWithIdentifier("NAVVV") as! UINavigationController
            self.presentViewController(nav, animated: true, completion: nil)
        }
    }
    
    //判断按钮是否选中
    func checkSelected(arr:[UIButton]) -> Bool {
        var result = false
        for button in arr{
            if button.selected{
                result = true
                break
            }
        }
        return result
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return data.count
        case 1:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "cell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier)
        }
        
        let btnW = 60
        let margin = (Int(self.view.frame.size.width) - (btnW * 4)) / 5
        switch indexPath.section {
        case 0:
            let content = data[indexPath.row]
            for i in 0 ..< content.count {
                let btn = UIButton(frame: CGRect(x: (margin + btnW) * i + margin, y: 10, width: btnW, height: btnW))
                btn.setImage(UIImage(named: content[i]), forState: UIControlState.Normal)
                btn.tag = indexPath.row * 4 + i + 1
                btn.addTarget(self, action: #selector(BeautyMViewController.clicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                
                cell?.contentView.addSubview(btn)
            }
        case 1:
            let btn = UIButton(frame: CGRect(x: (self.view.frame.size.width - 140) / 2, y: 20, width: 140, height: 20))
            btn.setTitle("下一步", forState: UIControlState.Normal)
            btn.titleLabel!.textAlignment = NSTextAlignment.Center
            btn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            btn.titleLabel!.font = UIFont.systemFontOfSize(14)
            btn.backgroundColor = UIColor.orangeColor()
            btn.tag = 111
            btn.addTarget(self, action: #selector(BeautyMViewController.clicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            cell?.contentView.addSubview(btn)
        default:
            break
        }
        cell!.selectionStyle = UITableViewCellSelectionStyle.None
        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 70
        }
        else if indexPath.section == 1{
            return 50
        }
        else {
            return 30
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }



}
