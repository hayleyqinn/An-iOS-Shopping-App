//
//  MaintenanceItemDao.swift
//  ico2o
//
//  Created by chingyam on 15/12/15.
//  Copyright © 2015年 chingyam. All rights reserved.
//

import UIKit

class MaintenanceItemDao: NSObject {
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
            let createSql:String = "create table if not exists T_MaintenanceItem(id integer not null primary key autoincrement ,  name text , km int , factor int , level int )"
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
    //插入数据
    func insertData(maintenanceItem:MaintenanceItemModel){
        dbBase.open()
        let data:[AnyObject] = [maintenanceItem.name , maintenanceItem.km , maintenanceItem.factor , maintenanceItem.level]
        let sql = "insert into T_MaintenanceItem(name , km , factor , level) values(? , ? , ? , ?)"
        if !self.dbBase.executeUpdate(sql, withArgumentsInArray: data){
            print("添加1条数据失败！: \(dbBase.lastErrorMessage())")
        }else{
            print("添加1条数据成功！")
        }
    }
    //根据公里数查询数据
    func queryData(km:Int) ->[MaintenanceItemModel]{
        dbBase.open()
        var maintenances:[MaintenanceItemModel] = []
        let data:[AnyObject] = [km]
        let sql = "SELECT * FROM T_MaintenanceItem WHERE (round( ? * 1.0/5000,0))%Factor=0 "
        let rs = dbBase.executeQuery(sql, withArgumentsInArray: data)
        while rs.next(){
            let id = Int(rs.intForColumn("id"))
            let name = rs.stringForColumn("name")
            let km = Int(rs.intForColumn("km"))
            let factor = Int(rs.intForColumn("factor"))
            let level = Int(rs.intForColumn("level"))
            let maintenance:MaintenanceItemModel = MaintenanceItemModel(id: id, name: name, km: km, factor: factor, level: level)
            maintenances.append(maintenance)
        }
        return maintenances
    }
    //根据维修保养界面的图标下标 获取保养项目的名字
    func getName(index:Int)->String{
        dbBase.open()
        var name:String = ""
        let data:[AnyObject] = [index]
        let sql = "select * from T_MaintenanceItem where id = ?"
        let rs = dbBase.executeQuery(sql, withArgumentsInArray: data)
        while rs.next(){
            name = rs.stringForColumn("name")
        }
        return name
    }
}
