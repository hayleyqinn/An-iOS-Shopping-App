//
//  AddressModel.swift
//  ico2o
//
//  Created by Katherine on 16/1/6.
//  Copyright © 2016年 chingyam. All rights reserved.
//  收货地址

import UIKit

class AddressModel: NSObject {
    var ID:Int
    var Name:String
    var Mobile:String
    var Address:String
    var Province:String
    var City:String
    var District:String
    var PostCode:String
    var IsDefault:Bool
//    var UserName:String
//    var IsAudited:Bool
//    var LastUpdateDate:NSDate//DateTime
//    var LastUpdateUser:String
//    var LastUpdateIP:String
//    var CreatedDate:NSDate//DateTime
    
    init(ID:Int,Name:String,Mobile:String,Address:String,Province:String,City:String,District:String,PostCode:String,IsDefault:Bool) {
        self.ID = ID
        self.Name = Name
        self.Mobile = Mobile
        self.Address = Address
        self.Province = Province
        self.City = City
        self.District = District
        self.PostCode = PostCode
        self.IsDefault = IsDefault
//        self.UserName = UserName
//        self.LastUpdateDate = LastUpdateDate
//        self.LastUpdateUser = LastUpdateUser
//        self.LastUpdateIP = LastUpdateIP
//        self.CreatedDate = CreatedDate
//        self.IsAudited = IsAudited
    }
    
    //从nsobject解析回来
    init(coder aDecoder:NSCoder!){
        self.ID = aDecoder.decodeObjectForKey("id") as! Int
        self.Name = aDecoder.decodeObjectForKey("name") as! String
        self.Mobile = aDecoder.decodeObjectForKey("mobile") as! String
        self.Address = aDecoder.decodeObjectForKey("address") as! String
        self.Province = aDecoder.decodeObjectForKey("province") as! String
        self.City = aDecoder.decodeObjectForKey("city") as! String
        self.District = aDecoder.decodeObjectForKey("district") as! String
        self.PostCode = aDecoder.decodeObjectForKey("postCode") as! String
        self.IsDefault = aDecoder.decodeObjectForKey("isDefault") as! Bool
    }
    
    //编码成object
    func encodeWithCoder(aCoder:NSCoder!){
        aCoder.encodeObject(ID,forKey:"id")
        aCoder.encodeObject(Name,forKey:"name")
        aCoder.encodeObject(Mobile,forKey:"mobile")
        aCoder.encodeObject(Address,forKey:"address")
        aCoder.encodeObject(Province,forKey:"province")
        aCoder.encodeObject(City,forKey:"city")
        aCoder.encodeObject(District,forKey:"district")
        aCoder.encodeObject(PostCode,forKey:"postCode")
        aCoder.encodeObject(IsDefault,forKey:"isDefault")
    }
}
