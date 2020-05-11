//
//  CarShopModel.swift
//  ico2o
//
//  Created by chingyam on 15/12/11.
//  Copyright © 2015年 chingyam. All rights reserved.
//  维修店的模型类

import UIKit

class CarShopModel: NSObject {
    var id:Int
    var garage:String
    var address:String
    var tel:String
    var longitude:Double
    var latitude:Double
    var imgPath:String
    var star:Double
    var distance:Double
    var code:String
    init(id:Int,garage:String,address:String,tel:String,longitude:Double,latitude:Double,imgPath:String,star:Double,distance:Double,code:String) {
        self.id = id
        self.garage = garage
        self.address = address
        self.tel = tel
        self.longitude = longitude
        self.latitude = latitude
        self.imgPath = imgPath
        self.star = star
        self.distance = distance
        self.code = code
    }

}
