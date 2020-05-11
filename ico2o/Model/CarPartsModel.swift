//
//  CarPartsModel.swift
//  ico2o
//
//  Created by chingyam on 15/12/8.
//  Copyright © 2015年 chingyam. All rights reserved.
//  查找配件 模型类

import UIKit

class CarPartsModel: NSObject {
    var id :Int
    var name :String
    var parentID :Int
    var depth:Int
    init(id:Int , name:String , parentID:Int ,depth:Int) {
        self.id = id
        self.name = name
        self.parentID = parentID
        self.depth = depth
    }
}
