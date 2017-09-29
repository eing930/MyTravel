//
//  DetallVC.swift
//  MyTravel
//
//  Created by user20 on 2017/9/28.
//  Copyright © 2017年 Yvonne Big. All rights reserved.
//

import UIKit

class DetallVC: UIViewController {
    let app = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var photoImage: UIImageView!
  
    @IBOutlet weak var textView: UITextView!
    
    private let q1 = DispatchQueue(label: "q1", qos: DispatchQoS.background, attributes: DispatchQueue.Attributes.concurrent)

    
    override func viewDidLoad() {
       super.viewDidLoad()
       print("Detail:\(app.nowId)") // id,not tid (拿這個去url 問name)
       let mydata = getData(id: app.nowId)
       print("return:\(mydata.name):\(mydata.photo)")
        
       nameLabel.text = mydata.name   //要show 圖
        
       indicator.isHidden = false
        indicator.startAnimating()
        q1.async {
            if let url = URL(string: mydata.photo) {
                if let imgData = try? Data(contentsOf: url) {
                    let img = UIImage(data: imgData)
                    DispatchQueue.main.async {
                        self.photoImage.image = img
                        self.indicator.isHidden = true
                    }
                    
                }else{
                    print("errro: network failue")
                    DispatchQueue.main.async {
                        self.indicator.isHidden = true
                    }
                    
                }
            }else {
                print("photo:\(mydata.photo)")
                DispatchQueue.main.async {
                    self.indicator.isHidden = true
                }
            }
        }
        
        
    }
    
    private func getData(id:String) -> (name:String, photo:String, intro:String) {
        if let _ = app.db {
            let sql = "select id,name,photo,intro from travel where id = ?"
            var stmt:OpaquePointer? = nil
            
            if sqlite3_prepare(app.db, sql, -1, &stmt, nil) != SQLITE_OK {
                // 出錯
                print("error1: id :\(app.nowId)")
                return ("error1","error1","")
            }
            
            let cid = id.cString(using: .utf8);
            if sqlite3_bind_text(stmt, 1, cid, -1, nil) != SQLITE_OK {
                // 出錯
                print("error2: id :\(app.nowId)")
                return ("error2","error2","")
            }
            
            if sqlite3_step(stmt) == SQLITE_ROW {
                // 有資料回來
                let cname = sqlite3_column_text(stmt, 1)
                let cphoto = sqlite3_column_text(stmt, 2)
                let cintro = sqlite3_column_text(stmt, 3)
                let name = String(cString: cname!)
                let photo = String(cString: cphoto!)
                let intro = String(cString: cintro!)
                
                return (name, photo, intro)
            }else{
                // 無資料
                let cerrmsg = sqlite3_errmsg(app.db)
                let errmsg = String(cString: cerrmsg!, encoding: String.Encoding.utf8 )
                print(errmsg)
                return ("error3","error3","")
            }
        }
        return ("","","")
    }
    
    

}
