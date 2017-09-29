//
//  AppDelegate.swift
//  MyTravel
//
//  Created by user20 on 2017/9/28.
//  Copyright © 2017年 Yvonne Big. All rights reserved.
//

import UIKit
import Alamofire
import MapKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var db:OpaquePointer? = nil
    var stmt:OpaquePointer? = nil
    
    var i = 0
    var nowId = ""
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let fmgr = FileManager.default
        let srcDB = Bundle.main.path(forResource: "iii", ofType: "db") //檔名 和副檔名
        let tagDB = NSHomeDirectory() + "/Documents/iii.db"
        if !fmgr.fileExists(atPath: tagDB) {
            try? fmgr.copyItem(atPath: srcDB!, toPath: tagDB)
            sqlite3_open(tagDB, &db)
            // 匯入遠端資料
            importRemoteData()
        }else{
            sqlite3_open(tagDB, &db)
        }
        
        print(NSHomeDirectory())  //找尋路徑
        return true
    }
    //撈資料
    private func importRemoteData(){
        Alamofire.request("http://data.coa.gov.tw/Service/OpenData/ODwsv/ODwsvAttractions.aspx").responseJSON { response in
            if let data = response.data {
                let sql = "insert into travel (tid,name,tel,intro,addr,city,town,lat,lng,photo) values (?,?,?,?,?,?,?,?,?,?)"
                sqlite3_prepare(self.db, sql, -1, &self.stmt, nil)
                
                let json = try? JSONSerialization.jsonObject(with: data, options:   JSONSerialization.ReadingOptions.allowFragments)
                for row in json as! [[String:String]] {
                    sqlite3_reset(self.stmt)
                    sqlite3_prepare(self.db, sql, -1, &self.stmt, nil)
                    
                    let temp = row["Coordinate"]
                    let latlng = temp?.characters.split(separator: ",").map(String.init)
                    let lat = latlng!.count<1 ? "" : latlng![0]
                    let lng = latlng!.count<2 ? "" : latlng![1]
                    
                    self.insertData(tid: row["ID"] ?? "xx", name: row["Name"] ?? "xx", tel: row["Tel"] ?? "xx", intro: row["Introduction"] ?? "xx", addr: row["Address"] ?? "xx", city: row["City"] ?? "xx", town: row["Town"] ?? "xx", lat: lat, lng: lng, photo: row["Photo"] ?? "xx")
                    
                }
                print("count:\(self.i)")
            }
        }
    }
    
    // insert into
    private func insertData(tid:String, name:String, tel:String, intro:String, addr:String, city:String, town:String, lat:String, lng:String, photo:String){
        // 整理傳遞參數 => cString
        let ctid = tid.cString(using: .utf8)
        let cname = name.cString(using: .utf8)
        let ctel = tel.cString(using: .utf8)
        let cintro = intro.cString(using: .utf8)
        let caddr = addr.cString(using: .utf8)
        let ccity = city.cString(using: .utf8)
        let ctown = town.cString(using: .utf8)
        let clat = lat.cString(using: .utf8)
        let clng = lng.cString(using: .utf8)
        let cphoto = photo.cString(using: .utf8)
        
        sqlite3_bind_text(stmt!, 1, ctid, -1, nil)
        sqlite3_bind_text(stmt!, 2, cname, -1, nil)
        sqlite3_bind_text(stmt!, 3, ctel, -1, nil)
        sqlite3_bind_text(stmt!, 4, cintro, -1, nil)
        sqlite3_bind_text(stmt!, 5, caddr, -1, nil)
        sqlite3_bind_text(stmt!, 6, ccity, -1, nil)
        sqlite3_bind_text(stmt!, 7, ctown, -1, nil)
        sqlite3_bind_text(stmt!, 8, clat, -1, nil)
        sqlite3_bind_text(stmt!, 9, clng, -1, nil)
        sqlite3_bind_text(stmt!, 10, cphoto, -1, nil)
        
        
        if sqlite3_step(stmt!) == SQLITE_DONE {
            i += 1
        }
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}
