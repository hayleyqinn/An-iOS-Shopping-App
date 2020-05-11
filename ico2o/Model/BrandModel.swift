//
//  BrandModel.swift
//  ico2o
//
//  Created by chingyam on 15/11/17.
//  Copyright © 2015年 chingyam. All rights reserved.
//  选择车型的模型类

import UIKit

class BrandModel: NSObject {
    var brand:String
    var carXi:String
    var year:String
    var engine:String
    var gearBox:String
    var configuration:String
    var modelCode:String
    init(brand:String , carXi:String , year:String , engine:String , gearBox:String , configuration:String , modelCode:String) {
        self.brand = brand
        self.carXi = carXi
        self.year  = year
        self.engine = engine
        self.gearBox = gearBox
        self.configuration = configuration
        self.modelCode = modelCode
    }
}
