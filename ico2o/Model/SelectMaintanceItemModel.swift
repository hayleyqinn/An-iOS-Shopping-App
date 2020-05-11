//
//  SelectMaintanceItemModel.swift
//  ico2o
//
//  Created by chingyam on 15/12/21.
//  Copyright © 2015年 chingyam. All rights reserved.
//  保养项目  模型类

import UIKit

class SelectMaintanceItemModel: NSObject {
    var maintanceItem:String
    var products:[ProductModel]
    init(maintanceItem:String , products:[ProductModel]) {
        self.maintanceItem = maintanceItem
        self.products = products
    }
}
