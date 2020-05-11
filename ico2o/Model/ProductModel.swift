//
//  ProductModel.swift
//  ico2o
//
//  Created by chingyam on 15/12/21.
//  Copyright © 2015年 chingyam. All rights reserved.
//  保养项目下产品 模型类

import UIKit

class ProductModel: NSObject {
    var proNo:String
    var proID:Int
    var proName:String
    var shopPrice:Double
    var marketPrice:Double
    var imagePath:String
    var proType:String?
    var count:Int?
    var ProEvaluationCount:Int?
    var NetWeight:Int?
    
    //常规保养中的model
    init(proType:String , proID:Int , proName:String , proNo:String , shopPrice:Double , marketPrice:Double , imagePath:String) {
        self.proType = proType
        self.proID = proID
        self.proName = proName
        self.proNo = proNo
        self.shopPrice = shopPrice
        self.marketPrice = marketPrice
        self.imagePath = imagePath
        self.count = 1
    }
    //商品列表的model
    init(proID:Int , proName:String , proNo:String , shopPrice:Double , marketPrice:Double , imagePath:String,proEvaluationCount:Int,netWeight:Int) {
        self.proID = proID
        self.proName = proName
        self.proNo = proNo
        self.shopPrice = shopPrice
        self.marketPrice = marketPrice
        self.imagePath = imagePath
        self.ProEvaluationCount = proEvaluationCount
        self.NetWeight = netWeight
    }
}
