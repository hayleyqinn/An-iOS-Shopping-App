//
//  ChoosePropertyAlertView.swift
//  ico2o
//
//  Created by Katherine on 15/12/25.
//  Copyright © 2015年 chingyam. All rights reserved.
//
@objc protocol ChoosePropertyAlertViewDelegate : NSObjectProtocol{
    
    optional func  ChoosePropertyAlertViewOKBtnCliceked(alertView:ChoosePropertyAlertView)
    
}

enum ChoosePropertyAlertViewStyle {
    case defaultStyle
    case noCountStyle
}

import UIKit

class ChoosePropertyAlertView: UIView {
    //屏幕宽高
    var windowWidth:CGFloat = 0
    var windowHeight:CGFloat = 0
    
    private var title:String?
    private var tips:String?
    private var properties:[[String]]?
    private var style:ChoosePropertyAlertViewStyle?
    var delegate: ChoosePropertyAlertViewDelegate? // delegate
    
    var cover:UIButton?//底部遮罩层
    var contentView:UIView?//放置具体内容的view
    
    var propBtns:[[UIButton]] = []//属性按钮
    var count:UILabel?//显示商品数量
    private var addButton: UIButton?//增加商品数量
    private var lessButton: UIButton?//减少商品数量
    var propertySelected:[String] = []
    
    //初始化
    init(title: String, tips:String, delegate: ChoosePropertyAlertViewDelegate?,properties:[[String]],style:ChoosePropertyAlertViewStyle) {
        let window: UIWindow = UIApplication.sharedApplication().keyWindow!
        windowWidth = window.frame.width
        windowHeight = window.frame.height
        for _ in 0..<properties.count {
            propertySelected.append("")
        }
        super.init(frame: CGRect(x: 0, y: 0, width: windowWidth, height: windowHeight))
        setup(title, tips: tips, properties: properties, delegate: delegate,style:style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //设置相关数据
    private func setup(title: String, tips:String, properties:[[String]], delegate: ChoosePropertyAlertViewDelegate?,style:ChoosePropertyAlertViewStyle) {
        self.title = title
        self.tips = tips
        self.properties = properties
        self.delegate = delegate
        self.style = style
        self.setUpFrame()
    }

    //设置界面相关内容
    private func setUpFrame() {
        cover = UIButton(frame: CGRect(x: 0, y: 0, width: windowWidth, height: windowHeight))
        cover?.backgroundColor = UIColor.blackColor()
        cover?.alpha = 0.7
        cover?.tag = 0
        cover?.addTarget(self, action: #selector(ChoosePropertyAlertView.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        addSubview(cover!)
        
        contentView = UIView(frame: CGRect(x: 0, y: 200, width: windowWidth, height: windowHeight - 200))
        contentView?.backgroundColor = UIColor.whiteColor()
        addSubview(contentView!)
        
        let scrollview = UIScrollView(frame: CGRectZero)
        contentView?.addSubview(scrollview)
        
        let titleLabel = UILabel(frame: CGRect(x: 10, y: 10, width: windowWidth - 20, height: 20))
        titleLabel.text = title
        titleLabel.font = UIFont.systemFontOfSize(15)
        scrollview.addSubview(titleLabel)
        
        let tipsLabel = UILabel(frame: CGRect(x: 10, y: 40, width: windowWidth - 20, height: 20))
        tipsLabel.text = tips
        tipsLabel.font = UIFont.systemFontOfSize(14)
        scrollview.addSubview(tipsLabel)
        //分割线
        let line = UILabel(frame: CGRect(x: 5, y: 70, width: windowWidth - 10, height: 2))
        line.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1.0)
        scrollview.addSubview(line)
        
        var btnY:CGFloat = 80
        //选择属性
        //添加不同的btn（根据内容的长度调整位置
        for i in 0..<(properties?.count)! {
            btnY = btnY + CGFloat(40 * i)
            let arr:[UIButton] = []
            propBtns.append(arr)
            let margin:CGFloat = 20
            var btnX:CGFloat = margin
            for j in 0..<properties![i].count {
                let text = properties![i][j]
                let btnW = text.calculateTextWidth(UIFont.systemFontOfSize(14)) + 30
                if (btnX + btnW) > windowWidth {
                    btnX = margin
                    btnY += 30
                }
                let btn = UIButton(frame: CGRect(x: btnX, y: btnY, width: btnW, height: 20))
                btn.setTitle(text, forState: UIControlState.Normal)
                btn.titleLabel!.textAlignment = NSTextAlignment.Center
                btn.titleLabel!.font = UIFont.systemFontOfSize(14)
                btn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                btn.layer.cornerRadius = 3.0
                btn.backgroundColor = UIColor.grayColor()
                btn.addTarget(self, action: #selector(ChoosePropertyAlertView.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                btn.tag = i * 100 + j + 1//从1开始，区别于遮罩层的tag ＝ 0
                btn.selected = false
                scrollview.addSubview(btn)
                propBtns[i].append(btn)
                btnX += (btnW + margin)
            }
            let line2 = UILabel(frame: CGRect(x: 5, y: btnY + 30, width: windowWidth - 10, height: 2))
            line2.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1.0)
            scrollview.addSubview(line2)
        }
        
        if style == ChoosePropertyAlertViewStyle.defaultStyle {
            //选择数量
            let countL = UILabel(frame: CGRect(x: 10, y: btnY + 40, width: 100, height: 20))
            countL.text = "数量："
            countL.font = UIFont.systemFontOfSize(14)
            scrollview.addSubview(countL)
            
            addButton = UIButton(frame: CGRect(x: 95, y: btnY + 70, width: 20, height: 30))
            addButton?.setTitle("+", forState: UIControlState.Normal)
            addButton?.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            addButton?.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1.0)
            addButton?.addTarget(self, action: #selector(ChoosePropertyAlertView.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            addButton?.tag = 888
            scrollview.addSubview(addButton!)
            
            count = UILabel(frame: CGRect(x: 50, y: btnY + 70, width: 40, height: 30))
            count?.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1.0)
            count?.textAlignment = NSTextAlignment.Center
            count?.text = "1"
            scrollview.addSubview(count!)
            
            lessButton = UIButton(frame: CGRect(x: 25, y: btnY + 70, width: 20, height: 30))
            lessButton?.setTitle("-", forState: UIControlState.Normal)
            lessButton?.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            lessButton?.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1.0)
            lessButton?.addTarget(self, action: #selector(ChoosePropertyAlertView.btnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            lessButton?.tag = 999
            scrollview.addSubview(lessButton!)
        }
        
        scrollview.contentSize.height = btnY + 110
        scrollview.frame = CGRect(x: 0, y: 0, width: windowWidth, height: windowHeight - 240)
        
        //底部确认按钮
        let OKbtn = UIButton(frame: CGRect(x: 10, y: windowHeight - 240, width: windowWidth - 20, height: 30))
        OKbtn.setTitle("确定", forState: UIControlState.Normal)
        OKbtn.titleLabel!.textAlignment = NSTextAlignment.Center
        OKbtn.titleLabel!.font = UIFont.systemFontOfSize(14)
        OKbtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        OKbtn.layer.cornerRadius = 3.0
        OKbtn.backgroundColor = UIColor.orangeColor()
        OKbtn.addTarget(self, action: #selector(ChoosePropertyAlertView.OKBtnCliceked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        contentView!.addSubview(OKbtn)
    }
    
    func btnClicked(btn:UIButton) {
        //0:遮罩，888:增加数量，999减少数量,default:属性按钮
        switch btn.tag {
        case 0:
            self.removeFromSuperview()
        case 888:
            let account = Int((count?.text)!)
            count?.text = String(account! + 1)
        case 999:
            let account = Int((count?.text)!)
            if account > 1 {
                count?.text = String(account! - 1)
            }
        default:
            let index = btn.tag / 100
            for i in 0..<propBtns[index].count {
                propBtns[index][i].backgroundColor = UIColor.grayColor()
                propBtns[index][i].selected = false
            }
            btn.selected = true
            btn.backgroundColor = UIColor.orangeColor()
            propertySelected[index] = (btn.titleLabel?.text)!
        }
    }
    /******************/
    func OKBtnCliceked(button: UIButton) {
        var finishedSelected = true
        for text in propertySelected {
            if text == "" {
                finishedSelected = false
                break
            }
        }
        if finishedSelected {
            self.removeFromSuperview()
        }
        else {
            let alertV = UIAlertView(title: nil, message: "请选择完整属性", delegate: nil, cancelButtonTitle: "确定")
            alertV.show()
        }
        if delegate?.respondsToSelector(#selector(ChoosePropertyAlertViewDelegate.ChoosePropertyAlertViewOKBtnCliceked(_:))) == true {
            delegate?.ChoosePropertyAlertViewOKBtnCliceked!(self)
        }
    }
    
    func show() {
        if let window: UIWindow = UIApplication.sharedApplication().keyWindow {
            show(window)
        }
    }
    
    func show(view: UIView) {
        self.frame = CGRect(x: 0, y: 0, width: windowWidth, height: windowHeight)
        
        view.addSubview(self)
        view.bringSubviewToFront(self)
//        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
//            self.contentView!.transform = CGAffineTransformMakeTranslation(-0, 200)
//            }, completion: nil)
    }
}

//计算某种字体下该字符串的宽度
extension String {
    func calculateTextWidth(font:UIFont)->CGFloat {
        let attributes = [NSFontAttributeName: font]
        let option = NSStringDrawingOptions.UsesLineFragmentOrigin
        let text: NSString = NSString(CString: self.cStringUsingEncoding(NSUTF8StringEncoding)!,
            encoding: NSUTF8StringEncoding)!
        let rect = text.boundingRectWithSize(CGSizeMake(300, 300), options: option, attributes: attributes, context: nil)
        return rect.width
    }
}
