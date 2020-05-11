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
    //创建Dao对象，只能创建一个对象,单例模式
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
    //构造函数
    override init() {
        //iPhone会为每一个应用程序生成一个私有目录，这个目录位于：
        //Users/sundfsun2009/Library/Application Support/iPhone Simulator/User/Applications下，
        //并随即生成一个数字字母串作为目录名，在每一次应用程序启动时，这个字母数字串都是不同于上一次。
        
        //所以通常使用Documents目录进行数据持久化的保存，而这个Documents目录可以通过：
        let documentsFolder = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        //获得
        //获得路径
        let path = documentsFolder.stringByAppendingPathComponent("ico2o.sqlite")
        self.dbPath = path
        //创建databease对象
        dbBase = FMDatabase(path:self.dbPath as String)
        //打开并创建数据库表
        if dbBase.open(){
            let createSql:String = "create table if not exists T_Brand(id integer not null primary key autoincrement ,  Brand text , CarXi TEXT , year text , Engine text , gearbox text, configuration text , modelcode string)"
            let isSuccessed:Bool = dbBase.executeUpdate(createSql, withArgumentsInArray: nil)
            if isSuccessed{
                //print("数据库创建成功")
            }
            else{
                //print("数据库创建失败： failed:\(dbBase.lastErrorMessage())")
            }
        }
        else{
            print("unable to open databease!")
        }
    }
    //插入数据
    func addBrand(brand:BrandModel){
        dbBase.open()
        let data:[AnyObject] = [brand.brand,brand.carXi,brand.year,brand.engine,brand.gearBox,brand.configuration,brand.modelCode]
        let insertsql:String = "insert into T_Brand(Brand  , CarXi , year , Engine , gearbox , configuration , modelcode ) values(? , ? , ? , ? , ? , ? , ?)"
        if !self.dbBase.executeUpdate(insertsql, withArgumentsInArray: data){
            //print("添加1条数据失败！: \(dbBase.lastErrorMessage())")
        }else{
            //print("添加1条数据成功！: \(brand.brand)")
        }
        dbBase.close()
    }
    //删除数据并且再重新创建一个新的表
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
    
    //查询汽车品牌
    func queryBrand() -> [String]{
        dbBase.open()
        var brandNames:[String]=[]
        let rs = dbBase.executeQuery("select distinct Brand from T_Brand", withArgumentsInArray: nil)
        while rs.next(){
            let brandname:String = rs.stringForColumn("Brand") as String
            brandNames.append(brandname)
        }
        dbBase.close()
        return brandNames
    }
    //根据汽车品牌车型查询年份
    func queryYear(brandname:String , carxi:String) ->[String]{
        dbBase.open()
        let sql = "select distinct Year from T_Brand where Brand = ? and CarXi = ?"
        var years:[String] = []
        let rs = dbBase.executeQuery(sql, withArgumentsInArray:  [brandname , carxi])
        
        while rs.next(){
            let year:String = rs.stringForColumn("Year") as String
            years.append(year)
        }
        dbBase.close()
        return years
    }
    //根据汽车品牌车型年份查询排量
    func queryEngine(year:String ,brandname:String ,carxi:String) ->[String]{
        dbBase.open()
        let sql = "select distinct Engine from T_Brand where Brand = ? and Year = ? and CarXi = ?"
        var engines:[String] = []
        let rs = dbBase.executeQuery(sql, withArgumentsInArray:  [brandname , year , carxi])
            while rs.next(){
                let engine:String = rs.stringForColumn("Engine") as String
                engines.append(engine)
            }
            dbBase.close()
            return engines
    }
    //根据汽车品牌车型年份排量查询配置
    func queryVersion(year:String ,brandname:String ,engine:String , carxi:String) ->[String]{
        dbBase.open()
        let sql = "select distinct configuration from T_Brand where Brand = ? and Year = ? and Engine = ? and CarXi = ?"
        var versions:[String] = []
        let rs = dbBase.executeQuery(sql, withArgumentsInArray:  [brandname , year , engine , carxi])
        while rs.next(){
            let version:String = rs.stringForColumn("configuration") as String
            versions.append(version)
        }
        dbBase.close()
        return versions
    }
    //根据汽车品牌查询汽车车型
    func queryCarXi(brandname:String) ->[String]{
        dbBase.open()
        let sql = "select distinct CarXi from T_Brand where Brand = ?"
        var carXis:[String] = []
        let rs = dbBase.executeQuery(sql, withArgumentsInArray:  [brandname])
        
        while rs.next(){
            let carXi:String = rs.stringForColumn("CarXi") as String
            carXis.append(carXi)
        }
        dbBase.close()
        return carXis
    }
    //根据汽车品牌车型年份排量配置查询波箱
    func queryGearBox(brandname:String , carXi:String , year:String , engine:String , carversion:String )->[String]{
        dbBase.open()
        let sql = "select distinct gearbox from T_Brand where Brand = ? and CarXi = ? and Year = ? and Engine = ? and Configuration = ?"
        var gearBoxs:[String] = []
        let rs = dbBase.executeQuery(sql, withArgumentsInArray:  [brandname , carXi , year , engine ,carversion])
        while rs.next(){
            let gearbox:String = rs.stringForColumn("gearbox") as String
            gearBoxs.append(gearbox)
        }
        dbBase.close()
        return gearBoxs
    }
}



extension String{
    func stringByAppendingPathComponent(path:String)->String{
        let nsSt = self as NSString
        return nsSt.stringByAppendingPathComponent(path)
    }
}
