//
//  CarDetailViewController.swift
//  ico2o
//
//  Created by chingyam on 15/10/14.
//  Copyright (c) 2015年 chingyam. All rights reserved.
//

import UIKit
import Charts

class CarDetailViewController: UITableViewController {
    let sectionTitle = ["常规保养","维修记录","爱车估值","油耗统计"]
    var lastMsg = [["上次行驶公里数:","123456公里","  2015/09"],["下次保养公里数:","123456公里","  2015/10"]]
    var petrolCostText = [["百公里耗油量：","3.85升","每公里油费：","0.25元"],["每天油费：","33.33元","每月油费：","1013.98元"],["每天行驶：","133公里","总共耗油","64.3升"],["总里程：","12345公里"]]
    var petrolNotePart = ["日期","公里数","油量","单价","百公里油耗","金额"]
    let months = ["现有值", "磨损值"]
    let unitsSold = [90000.0, 30000.0]
    
    override func viewDidLoad() {
        //导航栏
        self.navigationController?.navigationBar.pushNavigationItem(navInit(), animated: false)
        //取消单元格间的分割线
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }
    
    //导航栏的设置
    func navInit()->UINavigationItem {
        let navItem = UINavigationItem(title: "")
        let leftBtn = UIBarButtonItem(image: UIImage(named: "back"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(CarDetailViewController.barButtonClicked(_:)))
        leftBtn.tag = 1
        navItem.setLeftBarButtonItem(leftBtn, animated: false)
        navItem.title = "爱车档案"
        return navItem
    }
    
    //饼状图的具体设置
    func setChart(pieChartView:PieChartView, dataPoints: [String], values: [Double]) {
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let pieChartDataSet = PieChartDataSet(yVals: dataEntries, label: "90000")
        let pieChartData = PieChartData(xVals: dataPoints, dataSet: pieChartDataSet)
        pieChartView.data = pieChartData
        
        var colors: [UIColor] = []
        
        for i in 0  ..< dataPoints.count  {
            if(i == 0){
                let color = UIColor(red: CGFloat(225.0/255), green: CGFloat(72.0/255), blue: CGFloat(114.0/255), alpha: 1)
                colors.append(color)
            }
            if(i == 1){
                let color = UIColor(red: CGFloat(24.0/255), green: CGFloat(189.0/255), blue: CGFloat(219.0/255), alpha: 1)
                colors.append(color)
            }
        }
        
        pieChartDataSet.colors = colors
        pieChartDataSet.valueTextColor = UIColor.blackColor()
        pieChartDataSet.valueFont = UIFont.systemFontOfSize(12)
    }
    
    //导航栏中按钮的点击事件
    func barButtonClicked(btn:UIButton){
        //返回上一页面
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //未完待续
    //除导航栏外的按钮的点击事件
    func btnClicked(btn:UIButton){
        switch btn.tag {
        //去保养
        case 111:
            print("")
        //查看
        case 112:
            print("")
        //更改维修记录时间
        case 222:
            print("")
        //更正数据
        case 333:
            print("")
        default:
            print("")
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
        
        let screenW = self.view.frame.size.width
        //根据不同的section和行进行相应的操作来设置单元格内容
        switch indexPath.section {
        //常规保养
        case 0:
            let btn = UIButton(frame: CGRect(x:screenW - 60, y:3, width:50, height:25))
            btn.titleLabel!.textColor = UIColor.whiteColor()
            btn.titleLabel!.textAlignment = NSTextAlignment.Center
            btn.titleLabel!.font = UIFont.systemFontOfSize(12)
            btn.layer.cornerRadius = 5.0
            btn.backgroundColor = UIColor.orangeColor()
            if indexPath.row == 0 {
                btn.setTitle("去保养", forState: UIControlState.Normal)
                btn.tag = 111
            }
            else {
                btn.setTitle("查看", forState: UIControlState.Normal)
                btn.tag = 112
            }
            btn.addTarget(self, action: #selector(CarDetailViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell?.contentView.addSubview(btn)
            
            let  label = UILabel(frame: CGRect(x: 10, y: 0, width: screenW - 60, height: 30))
            label.text = ""
            for i in 0 ..< lastMsg[indexPath.row].count {
                label.text! += lastMsg[indexPath.row][i]
            }
            label.font = UIFont.systemFontOfSize(13)
            label.numberOfLines = 0;
            label.lineBreakMode = NSLineBreakMode.ByWordWrapping
            cell?.contentView.addSubview(label)
            
        //维修记录
        case 1:
            let label = UILabel(frame: CGRect(x: 10, y: 0, width: screenW - 60, height: 40))
            label.text = "时间范围"
            label.font = UIFont.systemFontOfSize(13)
            cell?.contentView.addSubview(label)
            
            let btn = UIButton(frame: CGRect(x:screenW - 60, y:8, width:50, height:25))
            btn.titleLabel!.textColor = UIColor.whiteColor()
            btn.titleLabel!.textAlignment = NSTextAlignment.Center
            btn.titleLabel!.font = UIFont.systemFontOfSize(11.5)
            btn.layer.cornerRadius = 5.0
            btn.backgroundColor = UIColor.orangeColor()
            btn.setTitle("确定", forState: UIControlState.Normal)
            btn.tag = 222
            btn.addTarget(self, action: #selector(CarDetailViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell?.contentView.addSubview(btn)
            
        //爱车估值
        case 2:
            let pieChartView = PieChartView(frame: CGRect(x: screenW / 6, y: 0, width: screenW / 1.8, height: screenW / 1.8))
            cell!.contentView.addSubview(pieChartView)
            setChart(pieChartView,dataPoints: months, values: unitsSold)
            
            let btn = UIButton(frame: CGRect(x:(screenW  / 2) - 30, y:screenW / 1.8 + 10, width:60, height:25))
            btn.titleLabel!.textColor = UIColor.whiteColor()
            btn.titleLabel!.textAlignment = NSTextAlignment.Center
            btn.titleLabel!.font = UIFont.systemFontOfSize(11.5)
            btn.layer.cornerRadius = 5.0
            btn.backgroundColor = UIColor.orangeColor()
            btn.setTitle("更正数据", forState: UIControlState.Normal)
            btn.tag = 333
            btn.addTarget(self, action: #selector(CarDetailViewController.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell?.contentView.addSubview(btn)
            
        //油耗统计
        case 3:
            let label = UILabel(frame: CGRect(x: 15, y: 0, width: (screenW / 2 - 15), height: 30))
            label.text = petrolCostText[indexPath.row][0] + petrolCostText[indexPath.row][1]
            label.font = UIFont.systemFontOfSize(13)
            cell?.contentView.addSubview(label)
            if petrolCostText[indexPath.row].count > 2 {
                let label2 = UILabel(frame: CGRect(x: (screenW / 2 + 15), y: 0, width: (screenW / 2 - 15), height: 30))
                label2.text = petrolCostText[indexPath.row][2] + petrolCostText[indexPath.row][3]
                label2.font = UIFont.systemFontOfSize(13)
                cell?.contentView.addSubview(label2)
                
                let middleLine = UILabel(frame: CGRect(x: 0, y: 29, width: screenW, height: 2))
                middleLine.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
                cell?.contentView.addSubview(middleLine)
            }
            
        //加油记录
        case 4:
            let avergeW = screenW / (CGFloat(petrolNotePart.count) + 0.5)
            var currentW:CGFloat = 0
            var currentX:CGFloat = 0
            for i in 0..<6 {
                if i == 4 {
                    currentW = avergeW * 1.5
                }
                else {
                    currentW = avergeW
                }
                let label = UILabel(frame: CGRect(x: currentX, y: 8, width: currentW, height: 15))
                currentX += currentW
                label.text = "xxxxx"
                label.font = UIFont.systemFontOfSize(12)
                label.textAlignment = NSTextAlignment.Center
                if indexPath.row == 5 {
                    label.textColor = UIColor.redColor()
                }
                cell!.contentView.addSubview(label)
                
                let middleLine = UILabel(frame: CGRect(x: 0, y: 29, width: screenW, height: 2))
                middleLine.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
                cell?.contentView.addSubview(middleLine)
            }
            
        default:
            break
        }
        
        //取消单元格的选中
        cell?.selectionStyle = UITableViewCellSelectionStyle.None
        return cell!
    }
    
    //每行的高度
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        //0:常规保养，1:维修记录，2:爱车估值，3:油耗统计，4:加油记录
        switch indexPath.section {
        case 0:
            return 32
        case 1:
            return 40
        case 2:
            return (self.view.frame.size.width / 1.5 + 10)
        default:
            return 30
        }
    }
    
    //每个section的头部设置
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let screenW = self.view.frame.size.width
        let view = UIView(frame: CGRect(x: 0, y: 0, width: screenW, height: 30))
        if section != 4 {
            let label = UILabel(frame: CGRect(x: 10, y: 8, width: 100, height: 15))
            label.text = sectionTitle[section]
            label.textColor = UIColor.brownColor()
            label.font = UIFont.systemFontOfSize(13)
            view.addSubview(label)
        }
        else {
            //6项数据，宽度等分6.5份，其中数据名称较长的一项占1.5份
            let avergeW = screenW / (CGFloat(petrolNotePart.count) + 0.5)
            var currentW:CGFloat = 0
            var currentX:CGFloat = 0
            for i in 0..<6 {
                if i == 4 {
                    currentW = avergeW * 1.5
                }
                else {
                    currentW = avergeW
                }
                let label = UILabel(frame: CGRect(x: currentX, y: 8, width: currentW, height: 15))
                currentX += currentW
                label.text = petrolNotePart[i]
                label.textColor = UIColor.brownColor()
                label.font = UIFont.systemFontOfSize(12)
                label.textAlignment = NSTextAlignment.Center
                view.addSubview(label)
            }
        }
        view.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
        return view
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return (sectionTitle.count + 1)
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        //0:常规保养，1:维修记录，2:爱车估值，3:油耗统计，4:加油记录
        case 0:
            return 2
        case 1,2:
            return 1
        case 3:
            return 4
        case 4:
            return 6
        default:
            return 0
        }
    }
}
