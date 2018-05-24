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
    case NotDownloaded = 0
    case Downloading = 1
    case Downloaded = 2
}

class SandartEntry:NSObject,NSCoding{
   
    var LangKey:String = ""
    var Title:String = ""
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
        aCoder.encode(self.Status.rawValue, forKey: "Status")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        guard let LangKey = aDecoder.decodeObject(forKey: "LangKey") as? String,
        let Title = aDecoder.decodeObject(forKey: "Title") as? String,
        let Status = MovieStatus(rawValue:(aDecoder.decodeInteger(forKey: "Status")))
        else {
            return nil
        }
        self.LangKey = LangKey
        self.Title = Title
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
