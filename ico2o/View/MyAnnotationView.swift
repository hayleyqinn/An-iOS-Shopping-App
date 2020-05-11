//
//  MyAnnotationView.swift
//  ico2o
//
//  Created by chingyam on 15/12/11.
//  Copyright © 2015年 chingyam. All rights reserved.
//

import UIKit

class MyAnnotationView: UIView {

    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var context: UILabel!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    func setShowLabel(imageStr:String ,title:String!,context:String!){
        
        self.image.image = UIImage(named: imageStr)
        self.title.text = title
        self.context.text = context
    }

    
    @IBAction func btnAction(sender: AnyObject) {
        findController().performSegueWithIdentifier("mapToBooking", sender: self)
    }
    
   
}

extension UIView {
    
    
    func findController() -> UIViewController! {
        return self.findControllerWithClass(UIViewController.self)
    }
    
    func findNavigator() -> UINavigationController! {
        return self.findControllerWithClass(UINavigationController.self)
    }
    
    func findControllerWithClass<T>(clzz: AnyClass) -> T? {
        var responder = self.nextResponder()
        while(responder != nil) {
            if (responder!.isKindOfClass(clzz)) {
                return responder as? T
            }
            responder = responder?.nextResponder()
        }
        
        return nil
    }
    
}

