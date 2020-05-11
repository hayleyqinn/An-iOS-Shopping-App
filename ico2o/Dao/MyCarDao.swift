//
//  MyCarDao.swift
//  ico2o
//
//  Created by chingyam on 15/12/1.
//  Copyright © 2015年 chingyam. All rights reserved.
//

import UIKit

class MyCarDao: NSObject {
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
            let createSql:String = "create table if not exists T_LoveCar(id integer not null primary key autoincrement ,checkID  text ,  UserID text , ImagePath TEXT , CarNumber text , Models text , Link text, ProDate text ,Config text , CreatedDate string , IsDefault text , UserName text , Engine text , ModelCode text, Brand text , Drive_KM text , Wave text , LicenseDate text , LastMaintenanceDate text , LastMaintenanceKM text)"
            let isSuccessed:Bool = dbBase.executeUpdate(createSql, withArgumentsInArray: nil)
            if isSuccessed{
                //print("数据库创建成功")
            }
            else{
                print("数据库创建失败： failed:\(dbBase.lastErrorMessage())")
            }
        }
        else{
            print("unable to open databease!")
        }
    }
    //插入数据
    func addMyCar(carmodel:CarsModel){
        dbBase.open()
        let data:[AnyObject] = [carmodel.id,carmodel.userID,carmodel.ImagePath,carmodel.carNumber,carmodel.models,carmodel.link,carmodel.proDate,carmodel.config,carmodel.createDate,carmodel.isDefault,carmodel.userName,carmodel.engine,carmodel.modelCode,carmodel.brand,carmodel.drive_KM,carmodel.wave,carmodel.licenseDate,carmodel.lastMaintenanceDate,carmodel.lastMaintenanceKM,carmodel.motor_LastSixNumber]
        let insertsql:String = "insert into T_LoveCar(checkID , UserID , ImagePath , CarNumber , Models , Link , ProDate ,config , CreatedDate , IsDefault , UserName , Engine , ModelCode , Brand , Drive_KM , Wave , LicenseDate , LastMaintenanceDate , LastMaintenanceKM ) values(? ,? , ? , ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
        if !self.dbBase.executeUpdate(insertsql, withArgumentsInArray: data){
            print("添加1条数据失败！: \(dbBase.lastErrorMessage())")
        }else{
            print("添加1条数据成功！")
        }
        dbBase.close()
    }
    //查询表中与后台对应的ID
    func check(carID:Int) -> Bool{
        dbBase.open()
        let sql = "select * from T_LoveCar where checkID = ? "
        let rs = dbBase.executeQuery(sql, withArgumentsInArray: [carID])
        while(rs.next()){
            return true
        }
    
        return false
    
    }
    //查询modelCode
    func queryModelCode(carID:Int) ->[String]{
        dbBase.open()
        var modelCodes:[String] = []
        let sql = "select ModelCode from T_LoveCar where checkID = ?"
        var modelCode:String = ""
        let rs = dbBase.executeQuery(sql, withArgumentsInArray: [carID])
        while(rs.next()){
            modelCode = rs.stringForColumn("ModelCode") as String
            modelCodes.append(modelCode)
        }
        return modelCodes
    }
    //删除我的爱车的数据
    func deleteMyCar(carID:Int)->Bool{
        dbBase.open()
        let data = [carID]
        let sql = "delete from T_LoveCar where checkID = ? "
         if !self.dbBase.executeUpdate(sql, withArgumentsInArray: data){
             print("删除数据失败！: \(dbBase.lastErrorMessage())")
            return false
        }
         else{
            return true
        }
    }
    //查询我的爱车
    func queryMyCar() ->[String]{
        dbBase.open()
        var temps = [String]()
        let sql = "select *  from T_LoveCar"
        let rs = self.dbBase.executeQuery(sql, withArgumentsInArray: nil)
        while(rs.next()){
            let brand = rs.stringForColumn("Brand")
            let carXi = rs.stringForColumn("Models")
            let year = rs.stringForColumn("ProDate")
            let temp = "\(year)年版 \(brand) \(carXi) "
            temps.append(temp)
        }
        return temps
    }
    
    //根据ID查询我的爱车
    func queryMyCar(carID:Int) ->String{
        dbBase.open()
        var temp = ""
        let data = [carID]
        let sql = "select *  from T_LoveCar where checkID = ? "
        let rs = self.dbBase.executeQuery(sql, withArgumentsInArray: data)
        while(rs.next()){
            let brand = rs.stringForColumn("Brand")
            let carXi = rs.stringForColumn("Models")
            let year = rs.stringForColumn("ProDate")
            temp = "\(year)年版 \(brand) \(carXi) "
        }
        return temp
    }
    
}
