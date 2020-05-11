//
//  CommodityModel.swift
//  ico2o
//
//  Created by chingyam on 16/1/12.
//  Copyright © 2016年 chingyam. All rights reserved.
//

import UIKit

class CommodityModel: NSObject {
    var bindingBoxCost:Double
    var isBindingBoxCost:Bool
    var netWeight:Int
    var unit:String
    var orderType:String
    var id:Int
    var typeValue:String
    var createdDate:String
    var imagePath:String
    var no:String
    var inventory:Int
    var isCheckStock:Bool
    var name:String
    var areas:String
    var productID:Int
    var otherID:Int
    var payType:String
    var amount:Double
    var quantity:Int
    var price:Double
    var surplus:Double
    
    init(bindingBoxCost:Double,isBindingBoxCost:Bool,netWeight:Int,unit:String,orderType:String,id:Int,typeValue:String,createdDate:String,imagePath:String,no:String,inventory:Int,isCheckStock:Bool,payType:String,amount:Double,quantity:Int,price:Double,surplus:Double , name:String , areas:String,productID:Int,otherID:Int) {
        self.bindingBoxCost = bindingBoxCost
        self.isBindingBoxCost = isBindingBoxCost
        self.netWeight = netWeight
        self.unit = unit
        self.orderType = orderType
        self.id = id
        self.typeValue = typeValue
        self.createdDate = createdDate
        self.imagePath = imagePath
        self.no = no
        self.inventory = inventory
        self.isCheckStock = isCheckStock
        self.payType = payType
        self.amount = amount
        self.quantity = quantity
        self.price = price
        self.surplus = surplus
        self.name = name
        self.areas = areas
        self.productID = productID
        self.otherID = otherID
    }
}
