//
//  OrdersHeaderView.swift
//  ico2o
//
//  Created by Katherine on 15/12/29.
//  Copyright © 2015年 chingyam. All rights reserved.
//
@objc protocol OrdersHeaderViewDelegate : NSObjectProtocol{
    
    optional func  OrdersHeaderViewDeleteBtnClicked(headerView:OrdersHeaderView)
    
}
enum OrdersHeaderViewStyle {
    case radioStyle
    case defaultStyle
    case noDeleteBtn
}

import UIKit

class OrdersHeaderView: UIView {
    //屏幕宽高
    private var windowWidth:CGFloat = 0
    
    var viewHeight:CGFloat = 40
    var radioSelected:Bool?
    var titleText1:String?
    var contentText1:String?
    var titleText2:String?
    var contentText2:String?
    var indexPath:NSIndexPath?
    var delegate: OrdersHeaderViewDelegate?
    private var viewStyle:OrdersHeaderViewStyle?
    private var deleteBtn:UIButton?
    var radioBtn:UIButton?
    var radioState = false
    
    //初始化
    init(title1:String,content1:String,style:OrdersHeaderViewStyle,delegate:OrdersHeaderViewDelegate,indexPath:NSIndexPath) {
        let window: UIWindow = UIApplication.sharedApplication().keyWindow!
        windowWidth = window.frame.width
        self.titleText1 = title1
        self.contentText1 = content1
        self.delegate = delegate
        self.viewStyle = style
        self.indexPath = indexPath
        super.init(frame: CGRect(x: 0, y: 0, width: windowWidth, height: viewHeight))
        setupFrame()
    }
    
    init(title1:String,content1:String,title2:String?,content2:String?,indexPath:NSIndexPath) {
        let window: UIWindow = UIApplication.sharedApplication().keyWindow!
        windowWidth = window.frame.width
        self.titleText1 = title1
        self.contentText1 = content1
        self.titleText2 = title2
        self.contentText2 = content2
        self.viewStyle = OrdersHeaderViewStyle.noDeleteBtn
        self.indexPath = indexPath
        super.init(frame: CGRect(x: 0, y: 0, width: windowWidth, height: viewHeight))
        setupFrame()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupFrame() {
        self.backgroundColor = UIColor.whiteColor()
        let orderNum = UILabel(frame: CGRect(x: 10, y: 8, width: (windowWidth - 50), height: 25))
        orderNum.text = titleText1! + "：" + contentText1!
        orderNum.font = UIFont.systemFontOfSize(14)
        orderNum.textColor = UIColor.blackColor()
        addSubview(orderNum)
        
        deleteBtn = UIButton(frame: CGRect(x: (windowWidth - 40), y: 10, width: 30, height: 20))
        deleteBtn!.setTitle("删除", forState: UIControlState.Normal)
        deleteBtn!.titleLabel!.font = UIFont.systemFontOfSize(14)
        deleteBtn!.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        deleteBtn!.addTarget(self, action: #selector(OrdersHeaderView.deleteBtnClicked), forControlEvents: UIControlEvents.TouchUpInside)
        deleteBtn!.tag = 2
        addSubview(deleteBtn!)
        
        if viewStyle == OrdersHeaderViewStyle.radioStyle {
            
            radioBtn = UIButton(frame: CGRect(x: 5, y: 8, width: 25, height: 25))
            if radioState {
                radioBtn!.setImage(UIImage(named: "radioBtn_2"), forState: UIControlState.Normal)
            }
            else {
                radioBtn!.setImage(UIImage(named: "radioBtn_1"), forState: UIControlState.Normal)
            }
            radioBtn!.addTarget(self, action: #selector(OrdersHeaderView.radioBtnClicked), forControlEvents: UIControlEvents.TouchUpInside)
            radioBtn!.tag = 1
            addSubview(radioBtn!)
            
            orderNum.frame = CGRect(x: 35, y: 8, width: (windowWidth - 90), height: 25)
        }
        else if viewStyle == OrdersHeaderViewStyle.noDeleteBtn {
            deleteBtn?.removeFromSuperview()
            orderNum.frame = CGRect(x: 5, y: 8, width: windowWidth / 2 - 10, height: 25)
            orderNum.font = UIFont.systemFontOfSize(13)
            
            let otherText = UILabel(frame: CGRect(x: windowWidth / 2 + 5, y: 8, width: (windowWidth / 2 - 10), height: 25))
            otherText.text = titleText2! + ":" + contentText2!
            otherText.font = UIFont.systemFontOfSize(13)
            otherText.textColor = UIColor.blackColor()
            addSubview(otherText)
        }
    }
    
    func radioBtnClicked() {
        if radioState {
            radioBtn!.setImage(UIImage(named: "radioBtn_1"), forState: UIControlState.Normal)
            radioState = false
        }
        else {
            radioBtn!.setImage(UIImage(named: "radioBtn_2"), forState: UIControlState.Normal)
            radioState = true
        }
    }
    
    func deleteBtnClicked() {
        if delegate?.respondsToSelector(#selector(OrdersHeaderViewDelegate.OrdersHeaderViewDeleteBtnClicked(_:))) == true {
            delegate?.OrdersHeaderViewDeleteBtnClicked!(self)
        }
    }
}
