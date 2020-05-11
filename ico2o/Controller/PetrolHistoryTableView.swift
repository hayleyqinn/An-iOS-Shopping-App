//
//  PetrolHistoryTableView.swift
//  ico2o
//
//  Created by 曾裕璇 on 2015/12/10.
//  Copyright © 2015年 chingyam. All rights reserved.
//

import UIKit
import Alamofire
import JSONNeverDie


// 本次查询的所有记录
var petrolNoteObjects = Array<petrolNoteObject>()


class PetrolHistoryTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    

    // 每一列的标题和对应的宽度比例
    var petrolHistoryItem = [
        "日    期", "公里数", "油量", "单价", "百公里油耗", "金额"]
    var petrolHistoryItemWidthRatio = [
            0.27,    0.17,   0.14,   0.13,     0.1,     0.19]
    
    required init(coder aDecoder:NSCoder){
        super.init(coder:aDecoder)!
        self.dataSource = self
        self.delegate = self
        separatorStyle = UITableViewCellSeparatorStyle.None
        
        
//        let object = petrolNoteObject(
//            addTime : "2015-12-29",
//            driveKM : 123456,
//            total   : 50,
//            price   : 6,
//            oilWave : 3,
//            amount  : 300
//        )
//        for i in 0..<6 {
//            petrolNoteObjects.insert(object, atIndex: i)
//            let indexPath = NSIndexPath(forRow: i, inSection: 0)
//            self.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
//        }
//        
//        let finalObject = petrolNoteObject(
//            addTime: "总  计",
//            driveKM: 0,
//            total: 12345,
//            price: (Float(111) / Float(6)),
//            oilWave: Float(111) / Float(6),
//            amount: 123456
//        )
//        petrolNoteObjects.insert(finalObject, atIndex: 6)
//        let indexPath = NSIndexPath(forRow: 7, inSection: 0)
//        self.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        
    }
    
    
    // 每添加一条记录执行一次
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        // 判断是否是最后的总计行
        var isFinal:Bool = false
        if petrolNoteObjects[indexPath.row].addTime == "总  计" { isFinal = true }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")
        let screenWidth : CGFloat = self.frame.size.width
        var width       : CGFloat = 0
        var x           : CGFloat = 0
        
        for i in 0..<6 {
            
            width = screenWidth * CGFloat(petrolHistoryItemWidthRatio[i])
            let label = UILabel(frame: CGRect(x: x, y: 8, width: width, height: 15))
            label.font = UIFont.systemFontOfSize(14)
            label.textAlignment = NSTextAlignment.Center
            x += width
            
            switch i {
            case 0: label.text = petrolNoteObjects[indexPath.row].addTime;                          break
            case 1: label.text = String(petrolNoteObjects[indexPath.row].driveKM);                  break
            case 2: label.text = String(format: "%.1f",petrolNoteObjects[indexPath.row].total);     break
            case 3: label.text = String(format: "%.1f",petrolNoteObjects[indexPath.row].price);     break
            case 4: label.text = String(format: "%.1f",petrolNoteObjects[indexPath.row].oilWave);   break
            case 5: label.text = String(format: "%.1f",petrolNoteObjects[indexPath.row].amount);    break
            default:                                                                                break
            }
            
            if isFinal { label.textColor = UIColor.redColor() }
            cell?.contentView.addSubview(label)
        }
        
        if !isFinal {
            let middleLine = UILabel(frame: CGRect(x: 0, y: 29, width: screenWidth, height: 2))
            middleLine.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
            cell?.contentView.addSubview(middleLine)
        }
        
        // 取消单元格选中
        cell?.selectionStyle = UITableViewCellSelectionStyle.None
        return cell!
    }
    

    // 加油记录的标题栏
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let screenWidth : CGFloat = self.frame.size.width
        let view = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 30))
        var width   : CGFloat = 0
        var x       : CGFloat = 0
        
        for i in 0..<6 {
            
            width = screenWidth * CGFloat(petrolHistoryItemWidthRatio[i])
            var label = UILabel(frame: CGRect(x: x, y: 8, width: width, height: 15))
            x += width
            label.text = petrolHistoryItem[i]
            label.textColor = UIColor.brownColor()
            label.font = UIFont.systemFontOfSize(14)
            
            // 将百公里油耗分两行显示
            if i==4 {
                label = UILabel(frame: CGRect(x: x-width, y: 3, width: width, height: 11))
                label.text = "百公里"
                label.textColor = UIColor.brownColor()
                label.font = UIFont.systemFontOfSize(10)
                
                let oilLabel = UILabel(frame: CGRect(x: x-width, y: 15, width: width, height: 11))
                oilLabel.text = "油耗"
                oilLabel.textColor = UIColor.brownColor()
                oilLabel.font = UIFont.systemFontOfSize(10)
                oilLabel.textAlignment = NSTextAlignment.Center
                view.addSubview(oilLabel)
            }
            
            
            label.textAlignment = NSTextAlignment.Center
            view.addSubview(label)
            
            

        }
        view.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
        return view
    }
    

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 30
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return petrolNoteObjects.count
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    // Drawing code
    }*/
//    func insertObject(i:Int) {
//        let indexPath = NSIndexPath(forRow: i, inSection: 0)
//        self.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
//    }
}
