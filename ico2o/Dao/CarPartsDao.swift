//
//  CarPartsDao.swift
//  ico2o
//
//  Created by chingyam on 15/12/8.
//  Copyright © 2015年 chingyam. All rights reserved.
//

import UIKit

class CarPartsDao: NSObject {
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
            let createSql:String = "create table if not exists T_CarParts(id integer not null primary key,  name text , parentID integer , depth integer)"
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
    func insertData(carPartsModel:CarPartsModel){
        dbBase.open()
        let data:[AnyObject] = [carPartsModel.id , carPartsModel.name ,carPartsModel.parentID , carPartsModel.depth]
        let insertsql:String = "insert into T_CarParts(ID , name , parentID , depth) values(? ,? , ? , ?)"
        if !self.dbBase.executeUpdate(insertsql, withArgumentsInArray: data){
            print("添加1条数据失败！: \(dbBase.lastErrorMessage())")
        }else{
            print("添加1条数据成功！")
        }
        dbBase.close()
    }
    //查询1级菜单
    func queryDepth1()->[CarPartsModel]{
        dbBase.open()
        var carsPartModel:[CarPartsModel]=[]
        let sql:String = "select * from T_CarParts where depth = 1"
        let rs = dbBase.executeQuery(sql, withArgumentsInArray: nil)
        while rs.next(){
            let id = Int(rs.intForColumn("ID"))
            let name = rs.stringForColumn("name")
            let parentID = Int(rs.intForColumn("parentID"))
            let depth = Int(rs.intForColumn("depth"))
            let carPartModel = CarPartsModel(id: id, name: name, parentID: parentID, depth: depth)
            carsPartModel.append(carPartModel)
        }
        return carsPartModel
    }
    //查询234级菜单
    func queryDepthOther(depth:Int ,id:Int )->[CarPartsModel]{
        dbBase.open()
        var carsPartModel:[CarPartsModel]=[]
        let sql:String = "select * from T_CarParts where depth = ? and parentID = ?"
        let data:[AnyObject] = [depth,id]
        let rs = dbBase.executeQuery(sql, withArgumentsInArray: data)
        while rs.next(){
            let id = Int(rs.intForColumn("ID"))
            let name = rs.stringForColumn("name")
            let parentID = Int(rs.intForColumn("parentID"))
            let depth = Int(rs.intForColumn("depth"))
            let carPartModel = CarPartsModel(id: id, name: name, parentID: parentID, depth: depth)
            carsPartModel.append(carPartModel)
        }
        return carsPartModel
    }

}
