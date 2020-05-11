//
//  MaintenanceItemModel.swift
//  ico2o
//
//  Created by chingyam on 15/12/9.
//  Copyright © 2015年 chingyam. All rights reserved.
//  维修保养 模型类

import UIKit

class MaintenanceItemModel: NSObject {
    var id:Int
    var name:String
    var km:Int
    var factor:Int
    var level:Int
    init(id:Int ,name:String , km:Int , factor:Int , level:Int) {
        self.id = id
        self.name = name
        self.km = km
        self.factor = factor
        self.level = level
    }
}
