//
//  CheckNetWorking.swift
//  ico2o
//
//  Created by chingyam on 16/1/21.
//  Copyright © 2016年 chingyam. All rights reserved.
//

import UIKit

class CheckNetWorking: NSObject ,UIAlertViewDelegate{

    var alertView:UIAlertView?

    func check(error:String)->Bool{
        if(error.rangeOfString("断开") != nil){
            let alterWin = UIAlertView(title: nil, message: "服务器好像出了点问题，请稍后再试", delegate: nil, cancelButtonTitle: "确定")
            alterWin.show()
            return false
        }
        else {
            return true
        }
    }
    func checkNetwork()->Bool{
        let reachability = Reachability.reachabilityForInternetConnection()
        if !reachability!.isReachable(){
            alertView = UIAlertView(title: "", message: "无网络连接", delegate: self, cancelButtonTitle: "好的", otherButtonTitles: "连接" )
            alertView?.show()
            return false
        }
        return true
    }
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        var alertView = alertView
        switch(buttonIndex){
        case 1:
            let reachability = Reachability.reachabilityForInternetConnection()
            if !reachability!.isReachable(){
                alertView = UIAlertView(title: "", message: "无网络连接", delegate: self, cancelButtonTitle: "好的", otherButtonTitles: "连接" )
                alertView.show()
            }
            else{
                
            }
        default: break
            
        }
    }
}
