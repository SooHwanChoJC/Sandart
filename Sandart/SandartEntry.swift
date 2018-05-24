//
//  SandartEntry.swift
//  Sandart
//
//  Created by Soohwan.Cho on 2018. 3. 29..
//  Copyright © 2018년 Joshua. All rights reserved.
//

import Foundation
import Alamofire
enum MovieStatus:Int{
    case NotPurchased = 0
    case NotDownloaded = 1
    case Downloading = 2
    case Downloaded = 4
}

class SandartEntry:NSObject,NSCoding{
   
    var LangKey:String = ""
    var Title:String = ""
    var Price:String = ""
    var Status:MovieStatus = MovieStatus.NotDownloaded

    var _progress:Float = 0.0
    var progress:Float{
        get{
            return _progress
        }
        set{
            _progress = newValue
        }
    }
    override init(){
        LangKey = "Not Found"
        Status = MovieStatus.NotDownloaded
    }
    
    init(WithLangKey key:String)
    {
        LangKey = key
    }
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.LangKey, forKey: "LangKey")
        aCoder.encode(self.Title, forKey: "Title")
        aCoder.encode(self.Price, forKey: "Price")
        aCoder.encode(self.Status.rawValue, forKey: "Status")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        guard let LangKey = aDecoder.decodeObject(forKey: "LangKey") as? String,
        let Title = aDecoder.decodeObject(forKey: "Title") as? String,
        let Price = aDecoder.decodeObject(forKey: "Price") as? String,
        let Status = MovieStatus(rawValue:(aDecoder.decodeInteger(forKey: "Status")))
        else {
            return nil
        }
        self.LangKey = LangKey
        self.Title = Title
        self.Price = Price
        if(Status == MovieStatus.Downloading){//reset Download if previous download incomplete
            self.Status = MovieStatus.NotDownloaded
        }
        else{
        self.Status = Status
        }
    }
    
    func persistForKey(_ key:String){
        let EncodedObject = NSKeyedArchiver.archivedData(withRootObject: self)
      
        UserDefaults.standard.set(EncodedObject,forKey:key)
    }
    
    class func restoreForKey(_ key:String?) ->SandartEntry?
    {
        if (key==nil){
        return nil
        }
        let EncodedObject = UserDefaults.standard.data(forKey: key!)
        var entry:SandartEntry? = nil
        if(EncodedObject != nil)
        {
            entry = NSKeyedUnarchiver.unarchiveObject(with: EncodedObject!) as? SandartEntry
        }
        return entry
    }
    
}
