//
//  ChangeCountAlterView.swift
//  ico2o
//
//  Created by Katherine on 15/12/8.
//  Copyright © 2015年 chingyam. All rights reserved.
//
@objc protocol ChangeCountAlertViewDelegate : NSObjectProtocol{
    
    optional func  selectOkButtonalertView()
    
    optional func  selecttCancelButtonAlertView()
    
}


import UIKit

class ChangeCountAlterView: UIView {
    
    private let defaultWidth        = 280.0  //默认Alert宽度
    private let defaultHeight       = 136.0  //默认Alert高度
    private let defaultCornerRadius = 5.0    //默认Alert 圆角度数
    
    private var viewY:Double!
    private var viewWidth: Double!
    private var viewHeight: Double!
    
    private var cancelButtonTitle: String?
    private var oKButtonTitle: String?
    
    private var cancelButton: UIButton?
    private var oKButton: UIButton?
    
    private var title: String?
    
    private var titleLabel: UILabel!
    
    var cornerRadius: Double!
    
    weak var delegate: ChangeCountAlertViewDelegate? // delegate
    
    private var view: UIView?
    private var count:UILabel?
    private var addButton: UIButton?
    private var lessButton: UIButton?
     var account = 1
    
    
    
    //初始化
    init(title: String?, account:Int, delegate: ChangeCountAlertViewDelegate?) {
        
        super.init(frame: CGRect(x: 0, y: 0, width: defaultWidth, height: defaultHeight))
        
        setup(title,account: account,delegate: delegate)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //设置相关数据
    private func setup(title: String?,account:Int?,delegate: ChangeCountAlertViewDelegate?) {
        self.account = account!
        self.title = title
        self.delegate = delegate
        self.setUpDefaultValue()
        self.setUpElements()
    }
    
    //默认参数
    private func setUpDefaultValue() {
        
        clipsToBounds = true
        cancelButtonTitle = "取消"
        oKButtonTitle = "确定"
        viewWidth = defaultWidth
        viewHeight = defaultHeight
        cornerRadius = defaultCornerRadius
        layer.cornerRadius = CGFloat(cornerRadius)
        self.backgroundColor = UIColor.whiteColor()
    }
    
    //设置相关ui
    private func setUpElements() {
        titleLabel = UILabel(frame: CGRectZero)
        view = UIView(frame: CGRect(x: 10, y: 20, width: defaultWidth - 20, height: 70))
        //view!.backgroundColor = UIColor.blueColor()
        if title != nil {
            titleLabel.text = title
            titleLabel.numberOfLines = 0
            titleLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
            titleLabel.textColor = UIColor.blackColor()
            titleLabel.font = UIFont.boldSystemFontOfSize(17)
            titleLabel.textAlignment = NSTextAlignment.Center
            titleLabel.backgroundColor = UIColor.clearColor()
            addSubview(titleLabel)
        }
        addSubview(view!)
        
        addButton = UIButton(frame: CGRect(x: ((view?.frame.size.width)! - 100) / 2, y: 30, width: 20, height: 25))
        addButton?.setTitle("-", forState: UIControlState.Normal)
        addButton?.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        addButton?.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1.0)
        addButton?.addTarget(self, action: #selector(ChangeCountAlterView.countBtnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        addButton?.tag = 2
        view!.addSubview(addButton!)
        
        count = UILabel(frame: CGRect(x: ((view?.frame.size.width)! - 110) / 2 + 30, y: 30, width: 40, height: 25))
        count?.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1.0)
        count?.textAlignment = NSTextAlignment.Center
        count?.text = String(account)
        view!.addSubview(count!)
        
        lessButton = UIButton(frame: CGRect(x: ((view?.frame.size.width)! - 110) / 2 + 80, y: 30, width: 20, height: 25))
        lessButton?.setTitle("+", forState: UIControlState.Normal)
        lessButton?.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        lessButton?.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1.0)
        lessButton?.addTarget(self, action: #selector(ChangeCountAlterView.countBtnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        lessButton?.tag = 1
        view!.addSubview(lessButton!)
        
        let line = UILabel(frame: CGRect(x: 0, y: 68, width: view!.frame.size.width, height: 2))
        line.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
        view?.addSubview(line)
        
        if let cancelTitle = cancelButtonTitle {
            cancelButton = UIButton(type: UIButtonType.Custom)
            cancelButton!.setTitle(cancelTitle, forState: UIControlState.Normal)
            cancelButton!.backgroundColor = UIColor.clearColor()
            cancelButton!.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            cancelButton!.titleLabel?.font = UIFont.boldSystemFontOfSize(17)
            cancelButton?.tag = 9
            addSubview(cancelButton!)
        }
        
        if let okTitle = oKButtonTitle {
            oKButton = UIButton(type: UIButtonType.Custom)
            oKButton!.setTitle(okTitle, forState: UIControlState.Normal)
            oKButton!.backgroundColor = UIColor.clearColor()
            oKButton!.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            oKButton!.titleLabel?.font = UIFont.boldSystemFontOfSize(17)
            oKButton?.tag = 10
            addSubview(oKButton!)
        }
    }
    
    private func layoutFrameshowing() {
        cancelButton!.addTarget(self, action: #selector(ChangeCountAlterView.cancelButtonClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        cancelButton!.frame = CGRect(x: viewWidth/2 + 2, y: viewHeight-40, width: viewWidth/2 - 1, height: 40)
        let line = UILabel(frame: CGRect(x: viewWidth/2, y: viewHeight-40, width: 2, height: 35))
        line.backgroundColor = UIColor(red: 237/255, green: 239/255, blue: 241/255, alpha: 1.0)
        addSubview(line)
        oKButton!.addTarget(self, action: #selector(ChangeCountAlterView.okButtonClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        oKButton!.frame = CGRect(x:0, y: viewHeight-40, width: viewWidth/2 - 1, height: 40)
        if title != nil {
            titleLabel.frame = CGRect(x: 10, y: 5, width: viewWidth - 20, height: 20)
        }
    }
    
    private func labelHeightToFit(label: UILabel) {
        let maxWidth = label.frame.size.width - 20
        let maxHeight : CGFloat = 500
        let rect = label.attributedText?.boundingRectWithSize(CGSizeMake(maxWidth, maxHeight),
            options: .UsesLineFragmentOrigin, context: nil)
        var frame = label.frame
        frame.size.height = rect!.size.height
        label.frame = frame
    }
    
    func countBtnClicked(btn:UIButton) {
        if btn.tag == 1 {
            account += 1
            count?.text = String(account)
        }
        else {
            if account == 1 {
                count?.text = "1"
            }
            else {
                account -= 1
                count?.text = String(account)
            }
        }
    }
    
    func cancelButtonClicked(button: UIButton) {
        self.removeFromSuperview()
        if delegate?.respondsToSelector(#selector(ChangeCountAlertViewDelegate.selecttCancelButtonAlertView)) == true {
            delegate?.selecttCancelButtonAlertView!()
        }
    }
    
    func okButtonClicked(button: UIButton) {
        self.removeFromSuperview()
        if delegate?.respondsToSelector(#selector(ChangeCountAlertViewDelegate.selectOkButtonalertView)) == true {
            delegate?.selectOkButtonalertView!()
        }
    }
    
    func show() {
        if let window: UIWindow = UIApplication.sharedApplication().keyWindow {
            show(window)
        }
    }
    
    func show(view: UIView) {
        layoutFrameshowing()
        self.viewY = (Double(view.frame.size.height) - viewHeight)/2
        self.frame = CGRect(x: (Double(view.frame.size.width) - viewWidth)/2, y: viewY, width: viewWidth, height: viewHeight)
        view.addSubview(self)
        view.bringSubviewToFront(self)
        self.alpha = 0.3
        UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: {
            self.alpha = 1;
            self.transform =  CGAffineTransformMakeScale(0.8, 0.8)
            }, completion: { finished in
                UIView.animateWithDuration(0.2, animations: {() -> Void in
                    self.transform = CGAffineTransformMakeScale(1.2, 1.2)
                    }) { (Bool) -> Void in
                        UIView.animateWithDuration(0.1, animations: { () -> Void in
                            self.transform = CGAffineTransformMakeScale(1, 1)
                        })
                }
        })
    }
}

