//
//  ShowDetailAlertView.swift
//  ico2o
//
//  Created by Katherine on 16/1/12.
//  Copyright © 2016年 chingyam. All rights reserved.
//

import UIKit

class ShowDetailAlertView: UIView {
    //屏幕宽高
    var windowWidth:CGFloat = 0
    var windowHeight:CGFloat = 0
    
    var cover:UIButton?//底部遮罩层
    private var img:UIImage
    private var title:String
    private var content:NSString?
    private var pictures:[String]?
    var imgView:UIImageView?
    var titleLabel:UILabel?
    var contentLabel:UILabel?
    
    //初始化
    init(img:UIImage,title:String,content:String?,pictures:[String]?) {
        let window: UIWindow = UIApplication.sharedApplication().keyWindow!
        windowWidth = window.frame.width
        windowHeight = window.frame.height
        
        self.img = img
        self.title = title
        self.content = content
        self.pictures = pictures
        super.init(frame: CGRect(x: 0, y: 0, width: windowWidth, height: windowHeight))
        setupFrame()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupFrame() {
        cover = UIButton(frame: CGRect(x: 0, y: 0, width: windowWidth, height: windowHeight))
        cover?.backgroundColor = UIColor.blackColor()
        cover?.alpha = 0.7
        cover?.tag = 0
        cover?.addTarget(self, action: #selector(ShowDetailAlertView.cancel), forControlEvents: UIControlEvents.TouchUpInside)
        addSubview(cover!)
        
        let view = UIView(frame: CGRect(x: 20, y: 55, width: windowWidth - 40, height: windowHeight - 95))
        view.backgroundColor = UIColor.whiteColor()
        addSubview(view)
        
        let cancelBtn = UIButton(frame: CGRect(x: windowWidth - 35, y: 45, width: 30, height: 30))
        cancelBtn.setImage(UIImage(named: "delete"), forState: UIControlState.Normal)
        cancelBtn.addTarget(self, action: #selector(ShowDetailAlertView.cancel), forControlEvents: UIControlEvents.TouchUpInside)
        addSubview(cancelBtn)
        
        let imgView = UIImageView(frame: CGRect(x: 10, y: 5, width: 40, height: 40))
        imgView.image = img
        view.addSubview(imgView)
        
        let titleLabel = UILabel(frame: CGRect(x: 70, y: 15, width: view.frame.width - 60, height: 20))
        titleLabel.text = title
        titleLabel.font = UIFont.systemFontOfSize(16)
        view.addSubview(titleLabel)
        
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 55, width: view.frame.width, height: view.frame.height - 60))
        view.addSubview(scrollView)
        
        let contentWidth = scrollView.frame.width - 40
        contentLabel = UILabel(frame: CGRectZero)
        contentLabel!.text = String(content)
        contentLabel!.font = UIFont.systemFontOfSize(14)
        contentLabel!.textColor = UIColor.grayColor()
        contentLabel!.numberOfLines = 0;
        contentLabel!.lineBreakMode = NSLineBreakMode.ByWordWrapping
        scrollView.addSubview(contentLabel!)
        //计算label的高度
        let options : NSStringDrawingOptions = NSStringDrawingOptions.UsesLineFragmentOrigin
        let boundingRect = content!.boundingRectWithSize(CGSizeMake(CGFloat(contentWidth), 0), options: options, attributes: [NSFontAttributeName:contentLabel!.font], context: nil)
        contentLabel!.frame = CGRectMake(20, 10, boundingRect.size.width, boundingRect.size.height)
        
        var contentY = boundingRect.size.height + 20
        if pictures != nil {
            for pic in pictures! {
                let imgView = UIImageView(frame: CGRect(x: 20, y: contentY, width: contentWidth, height: 200))
                imgView.image = UIImage(named: pic)
                scrollView.addSubview(imgView)
                contentY += 210
            }
        }
        
        scrollView.contentSize = CGSizeMake(scrollView.frame.width, contentY)
    }
    
    func cancel() {
        self.removeFromSuperview()
    }
    
    func show() {
        if let window: UIWindow = UIApplication.sharedApplication().keyWindow {
            
            self.frame = CGRect(x: 0, y: 0, width: windowWidth, height: windowHeight)
            window.addSubview(self)
            window.bringSubviewToFront(self)
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
    
}
