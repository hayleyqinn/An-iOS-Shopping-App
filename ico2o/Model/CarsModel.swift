//
//  CarsModel.swift
//  ico2o
//
//  Created by chingyam on 15/10/14.
//  Copyright (c) 2015年 chingyam. All rights reserved.
//  我的爱车 模型类

import UIKit

class CarsModel: NSObject {
    var id:String
    var userID:String
    var ImagePath:String
    var carNumber:String
    var models:String
    var link:String
    var proDate:String
    var config:String
    var createDate:String
    var isDefault:String
    var userName:String
    var engine:String
    var modelCode:String
    var brand:String
    var drive_KM:String
    var wave:String
    var licenseDate:String
    var lastMaintenanceDate:String
    var lastMaintenanceKM:String
    var motor_LastSixNumber:String
    init(id:String ,userID:String  ,ImagePath:String,carNumber:String,models:String,link:String,proDate:String,config:String,createDate:String,isDefault:String,userName:String,engine:String,modelCode:String,brand:String,drive_KM:String,wave:String,licenseDate:String,lastMaintenanceDate:String,lastMaintenanceKM:String,motor_LastSixNumber:String){
        self.id = id
        self.userID = userID
        self.ImagePath = ImagePath
        self.carNumber = carNumber
        self.models = models
        self.link = link
        self.proDate = proDate
        self.config = config
        self.createDate = createDate
        self.isDefault = isDefault
        self.userName = userName
        self.engine = engine
        self.modelCode = modelCode
        self.brand = brand
        self.drive_KM = drive_KM
        self.wave = wave
        self.licenseDate = licenseDate
        self.lastMaintenanceDate = lastMaintenanceDate
        self.lastMaintenanceKM = lastMaintenanceKM
        self.motor_LastSixNumber = motor_LastSixNumber
    }

}
