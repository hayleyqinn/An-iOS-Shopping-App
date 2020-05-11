//
//  BrandDao.swift
//  ico2o
//
//  Created by chingyam on 15/11/18.
//  Copyright © 2015年 chingyam. All rights reserved.
//

import UIKit

class BrandDao: NSObject {
    let dbPath:String
    let dbBase:FMDatabase
    
    class func shareInstance()->BrandDao{
        struct brandSingle{
            static var onceToken:dispatch_once_t = 0
            static var instance:BrandDao? = nil
        }
        dispatch_once(&brandSingle.onceToken,{
            brandSingle.instance = BrandDao()
        })
        return brandSingle.instance!
    }
    override init() {
        let documentsFolder = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let path = documentsFolder.stringByAppendingPathComponent("brand.sqlite")
        self.dbPath = path
        dbBase = FMDatabase(path:self.dbPath as String)
        print("path: ----\(self.dbPath)")
        
        if dbBase.open(){
            let createSql:String = "create table if not exists T_Brand(id integer not null primary key autoincrement ,  Brand text , CarXi TEXT , year text , Engine text , gearbox text, configuration text , modelcode string)"
            let isSuccessed:Bool = dbBase.executeUpdate(createSql, withArgumentsInArray: nil)
            if isSuccessed{
                print("数据库创建成功")
            }
            else{
                print("数据库创建失败： failed:\(dbBase.lastErrorMessage())")
            }
        }
        else{
            print("unable to open databease!")
        }
    }
    func addBrand(brand:BrandModel){
        dbBase.open()
        let data:[AnyObject] = [brand.brand,brand.carXi,brand.year,brand.engine,brand.gearBox,brand.configuration,brand.modelCode]
        let insertsql:String = "insert into T_Brand(Brand  , CarXi , year , Engine , gearbox , configuration , modelcode ) values(? , ? , ? , ? , ? , ? , ?)"
        if !self.dbBase.executeUpdate(insertsql, withArgumentsInArray: data){
            print("添加1条数据失败！: \(dbBase.lastErrorMessage())")
        }else{
            print("添加1条数据成功！: \(brand.brand)")
        }
        dbBase.close()
    }
    
    func deleteBrand(){
        dbBase.open()
        if !self.dbBase.executeUpdate("drop table T_Brand", withArgumentsInArray: nil){
            print("删除失败")
        }
        else{
            print("删除成功")
        }
        let createSql:String = "create table if not exists T_Brand(id integer not null primary key autoincrement ,  Brand text , CarXi TEXT , year text , Engine text , gearbox text, configuration text , modelcode string)"
        let isSuccessed:Bool = dbBase.executeUpdate(createSql, withArgumentsInArray: nil)
        if isSuccessed{
            print("数据库创建成功")
        }
        else{
            print("数据库创建失败： failed:\(dbBase.lastErrorMessage())")
        }
        dbBase.close()
    }
    
    func queryBrand(){
        dbBase.open()
        let rs = dbBase.executeQuery("select * from T_Brand", withArgumentsInArray: nil)
        while rs.next(){
            let brandname:String = rs.stringForColumn("Brand") as String
            print(brandname)
        }
        dbBase.close()
    }
    
    
}


extension String{
    func stringByAppendingPathComponent(path:String)->String{
        let nsSt = self as NSString
        return nsSt.stringByAppendingPathComponent(path)
    }
}
