//
//  StoreDetailDetailTableViewController.swift
//  ico2o
//
//  Created by Katherine on 15/12/17.
//  Copyright © 2015年 chingyam. All rights reserved.
//

import UIKit

class StoreDetailDetailTableViewController: UITableViewController {
    //根据dataType显示相应的内容
    /*dataType:基本信息, 服务项目, 优惠活动,评价
    */
    var dataType = ""
    var basicMsg = ["0756-2274852","广东省珠海市香洲区人民路"]
    let serviceData = [["更换前刹车片","200"],["更换前刹车片","200"]]
    let judgeGrade = ["4.8","4.8","4.8","4.8","4.8","4.8"]
    let judgeData = [["mine_focus","用户7563","很好"],["mine_focus","用户7563","很好"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else {
            switch dataType {
            case "基本信息","优惠活动":
                return 1
            case "服务项目":
                return serviceData.count
            case "评价":
                return judgeData.count
            default:
                return 0
            }
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch dataType {
        case "基本信息":
            if indexPath.section == 0 {
                return 80
            }
            else {
                return 40
            }
        case "服务项目":
            if indexPath.section == 0 {
                return 40
            }
            else {
                return 30
            }
        case "评价":
            return 110
        default:
            return 30
        }
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
            if view.isKindOfClass(UILabel.self) {
                view.removeFromSuperview()
            }
            else if view.isKindOfClass(UIButton.self) {
                view.removeFromSuperview()
            }
        }
        
        let font = UIFont.systemFontOfSize(14)
        //根据dataType显示相应的内容,section 0 为顶部信息，section 1 为具体内容
        switch dataType {
        case "基本信息":
            if indexPath.section == 0 {
                //电话、电话的图标、地址、地址图标
                let telText = "电话：" + basicMsg[0]
                let telWidth = telText.calculateTextWidth(font)
                let telLabel = UILabel(frame: CGRect(x: 10, y: 10, width: telWidth, height: 20))
                telLabel.text = telText
                telLabel.font = font
                cell?.contentView.addSubview(telLabel)
                
                let telImg = UIImageView(frame: CGRect(x: 20 + telWidth, y: 10, width: 20, height: 20))
                telImg.image = UIImage(named: "phone")
                cell?.contentView.addSubview(telImg)
                
                let addressText = "地址：" + basicMsg[1]
                let locationWidth = addressText.calculateTextWidth(font)
                let addressLabel = UILabel(frame: CGRect(x: 10, y: 40, width: locationWidth, height: 20))
                addressLabel.text = addressText
                addressLabel.font = font
                cell?.contentView.addSubview(addressLabel)
                
                let locationImg = UIImageView(frame: CGRect(x: 20 + locationWidth, y: 40, width: 20, height: 20))
                locationImg.image = UIImage(named: "location")
                cell?.contentView.addSubview(locationImg)
                
            }
            else {
                //分割线
                let line = UILabel(frame: CGRect(x: 0, y: 0, width: screenW, height: 10))
                line.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
                cell?.contentView.addSubview(line)
                let title = UILabel(frame: CGRect(x: 10, y: 20, width: screenW - 20, height: 20))
                title.text = "维修店详情:"
                title.font = UIFont.systemFontOfSize(14)
                cell?.contentView.addSubview(title)
            }
        case "服务项目":
            if indexPath.section == 0 {
                for i in 0..<2 {
                    let title1 = UILabel(frame: CGRect(x: Int(screenW / 2) * i, y: 10, width: Int(screenW / 3), height: 20))
                    title1.text = "项目"
                    title1.font = font
                    title1.textAlignment = NSTextAlignment.Center
                    cell?.contentView.addSubview(title1)
                    
                    let title2 = UILabel(frame: CGRect(x: (Int(screenW / 2) * i + Int(screenW / 3)), y: 10, width: Int(screenW / 6), height: 20))
                    title2.text = "工时费"
                    title2.font = font
                    title2.textAlignment = NSTextAlignment.Center
                    cell?.contentView.addSubview(title2)
                }
            }
            else {
//                let icon = UIButton(frame: CGRect(x: 5, y: 5, width: 20, height: 20))
//                icon.setImage(UIImage(name:""),forState: UIControlState.Normal)
//                cell?.contentView.addSubview(icon)
                for i in 0..<2 {
                    let itemName = UILabel(frame: CGRect(x: Int(screenW / 2) * i + 20, y: 10, width: Int(screenW / 3) - 20, height: 20))
                    itemName.text = serviceData[indexPath.row][0]
                    itemName.font = font
                    cell?.contentView.addSubview(itemName)
                    
                    let price = UILabel(frame: CGRect(x: (Int(screenW / 2) * i + Int(screenW / 3)), y: 10, width: Int(screenW / 6), height: 20))
                    price.text = serviceData[indexPath.row][1]
                    price.font = font
                    price.textColor = UIColor.redColor()
                    price.textAlignment = NSTextAlignment.Center
                    cell?.contentView.addSubview(price)
                }
            }
        case "优惠活动":
            if indexPath.section == 0 {
                
            }
            else {
                
            }
        case "评价":
            if indexPath.section == 0 {
                let text1 = UILabel(frame: CGRect(x: 10, y: 5, width: 100, height: 20))
                text1.text = "综合好评率："
                text1.font = font
                cell?.contentView.addSubview(text1)
                
                let stars = UIImageView(frame: CGRect(x: 80, y: 4, width: 80, height: 23))
                cell?.contentView.addSubview(stars)
                
                let starY = (ceil(Float(Float(judgeGrade[0])! * 10) / 5) - 2) * (Float(330 / 9))
                //获取想要显示的部分的大小及位置
                let starPic = UIImage(named: "stars")
                let rect = CGRectMake(0, CGFloat(starY), 170, 36)
                //将此部分从图片中剪切出来
                let ref = CGImageCreateWithImageInRect(starPic!.CGImage!, rect)
                //将剪切下来图片放入UIImageView中
                stars.image = UIImage(CGImage: ref!)
                
                let grade = UILabel(frame: CGRect(x: 170, y: 5, width: 40, height: 20))
                grade.text = judgeGrade[0]
                grade.font = font
                cell?.contentView.addSubview(grade)
                let text = ["","服务态度：","”0“推销：","收费合理：","店内环境：","技术水平："]
                var j = 0
                for i in 1..<text.count {
                    let titleLabel = UILabel(frame: CGRect(x: 110 * j + 10, y: 25 * (i / 2) + 30, width: 80, height: 20))
                    titleLabel.text = text[i]
                    titleLabel.font = font
                    cell?.contentView.addSubview(titleLabel)
                    
                    let numLabel = UILabel(frame: CGRect(x: 110 * j + 75, y: 25 * (i / 2)  + 30, width: 30, height: 20))
                    numLabel.text = judgeGrade[i]
                    numLabel.font = font
                    cell?.contentView.addSubview(numLabel)
                    j += 1
                    if j == 2 {
                        j = 0
                    }
                }
            }
            else {
                //头像、用户名、评价
                let icon = UIButton(frame: CGRect(x: 10, y: 20, width: 60, height: 60))
                icon.setImage(UIImage(named:judgeData[indexPath.row][0]),forState: UIControlState.Normal)
//                icon.addTarget(self, action: "", forControlEvents: UIControlEvents.TouchUpInside)
//                icon.tag =
                cell?.contentView.addSubview(icon)
                
                let name = UILabel(frame: CGRect(x: 5, y: 80, width: 70, height: 20))
                name.text = judgeData[indexPath.row][1]
                name.font = UIFont.systemFontOfSize(13)
                name.textAlignment = NSTextAlignment.Center
                cell?.contentView.addSubview(name)
                
                let judge = UILabel(frame: CGRect(x: 80, y: 10, width: screenW - 90, height: 90))
                judge.text = judgeData[indexPath.row][2]
                judge.font = UIFont.systemFontOfSize(13)
                judge.numberOfLines = 0;
                judge.lineBreakMode = NSLineBreakMode.ByWordWrapping
                judge.layer.borderWidth = 1
                cell?.contentView.addSubview(judge)
            }
        default:
            break
        }
        cell?.selectionStyle = UITableViewCellSelectionStyle.None
        return cell!
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if dataType == "评价" && section == 1 {
            return "用户评价"
        }
        else {
            return ""
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if dataType == "评价" && section == 1 {
            return 30
        }
        else {
            return 0
        }
    }
}
//计算某种字体下该字符串的宽度
//extension String {
//    func calculateTextWidth(font:UIFont)->CGFloat {
//        let attributes = [NSFontAttributeName: font]
//        let option = NSStringDrawingOptions.UsesLineFragmentOrigin
//        let text: NSString = NSString(CString: self.cStringUsingEncoding(NSUTF8StringEncoding)!,
//            encoding: NSUTF8StringEncoding)!
//        let rect = text.boundingRectWithSize(CGSizeMake(300, 300), options: option, attributes: attributes, context: nil)
//        return rect.width
//    }
//}
