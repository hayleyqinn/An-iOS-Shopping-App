//
//  CollectionModel.swift
//  ico2o
//
//  Created by 覃红 on 16/5/17.
//  Copyright © 2016年 chingyam. All rights reserved.
//  收藏商品的model

import UIKit

class CollectionModel: NSObject {
    var proID: Int
    var proName: String
    var imagePath: String
    var place: String
    var shopPrice: Float
    var count: String
    var CollectionID: Int
    
    init(proID: Int, proName: String, imagePath: String, place: String, shopPrice: Float, count: String, CollectionID: Int) {
        self.proID = proID
        self.proName = proName
        self.imagePath = imagePath
        self.place = place
        self.shopPrice = shopPrice
        self.count = count
        self.CollectionID = CollectionID
    }

}
