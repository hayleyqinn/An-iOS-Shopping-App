//
//  SecondSortsModel.swift
//  ico2o
//
//  Created by chingyam on 16/1/18.
//  Copyright © 2016年 chingyam. All rights reserved.
//

import UIKit

class SecondSortsModel: NSObject {
    var name:String
    var secondSortsName:[String]
    init(name:String , secondSortsName:[String]) {
        self.name = name
        self.secondSortsName = secondSortsName
    }
}
