//
//  GoodListForMakeOrderTableViewController.swift
//  ico2o
//
//  Created by Katherine on 15/12/15.
//  Copyright © 2015年 chingyam. All rights reserved.
//

import UIKit
import Kingfisher
class GoodListForMakeOrderTableViewController: UITableViewController {
    var data:[CommodityModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
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
            if view.isKindOfClass(UIImageView.self) {
                view.removeFromSuperview()
            }
            else if view.isKindOfClass(UILabel.self) {
                view.removeFromSuperview()
            }
        }
        
        //pic:商品图片,name:商品名称,kind:属性，price:价格,countL：商品数量
        let model = data[indexPath.row]
        
        let pic = UIImageView(frame: CGRect(x: 5, y: 10, width: 70, height: 70))
        pic.kf_showIndicatorWhenLoading = true
        pic.kf_setImageWithURL(NSURL(string:model.imagePath)!, placeholderImage: nil,optionsInfo: [.Transition(ImageTransition.Fade(1))],
            
            progressBlock: { receivedSize, totalSize in
//                    print("\(receivedSize)/\(totalSize)")
            },
            completionHandler: { image, error, cacheType, imageURL in
//                    print("Finished")
        })
        
      
        cell!.contentView.addSubview(pic)
        
        let name = UILabel(frame: CGRect(x: 80, y: 10, width: screenW - 145, height: 50))
        name.text = model.name
        name.font = UIFont.systemFontOfSize(14)
        name.numberOfLines = 0;
        name.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cell!.contentView.addSubview(name)
        
//        let typeL = UILabel(frame: CGRect(x: 80, y: 60, width: 35, height: 20))
//        typeL.text = "属性:"
//        typeL.font = UIFont.systemFontOfSize(14)
//        cell!.contentView.addSubview(typeL)
//        
//        let type = UIButton(frame: CGRect(x: 115, y: 65, width: screenW - 200, height: 20))
//        type.setTitle(data[indexPath.row][2], forState: UIControlState.Normal)
//        type.titleLabel!.font = UIFont.systemFontOfSize(13)
//        type.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
//        type.titleLabel?.textAlignment = NSTextAlignment.Left
//        type.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        type.tag = 3
//        type.addTarget(self, action: "clicked:", forControlEvents: UIControlEvents.TouchUpInside)
//        cell!.contentView.addSubview(type)
        
        let price = UILabel(frame: CGRect(x: 80, y: 50, width: 100, height: 20))
        //let price = UILabel(frame: CGRect(x: screenW - 65, y: 40, width: 60, height: 20))
        let a = model.price
        price.text = "¥" + String(format: "%.2f", a)
        price.font = UIFont.systemFontOfSize(15)
        //price.textAlignment = NSTextAlignment.Right
        cell!.contentView.addSubview(price)
        
        let countL = UILabel(frame: CGRect(x: (screenW - 110), y: 50, width: 100, height: 20))
        countL.text = "数量：" + String(model.quantity)
        countL.font = UIFont.systemFontOfSize(14)
        countL.textAlignment = NSTextAlignment.Right
        cell!.contentView.addSubview(countL)
        
        let line = UILabel(frame: CGRect(x: 0, y: 90, width: screenW, height: 2))
        line.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
        cell?.contentView.addSubview(line)
        
        cell?.selectionStyle = UITableViewCellSelectionStyle.None
        return cell!
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 92
    }
}
