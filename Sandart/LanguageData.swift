//
//  LanguageData.swift
//  Sandart
//
//  Created by 조수환 on 2018. 9. 4..
//  Copyright © 2018년 Joshua. All rights reserved.
//

import Foundation

class LanguageData{
    private var Language:[String]? = []
    
    init(){
        Language = UserDefaults.standard.stringArray(forKey: "Languages")
        
        if Language == nil{
            Language = ["Korean" ,"English","Chinese","Chinese Traditional","Japanese", "Russian", "French", "Spanish", "Hindi","Mongolia", "Polish", "Turkish", "Nepali", "Indonesia","Thai", "Cambodian", "Filipino","Vietnamese","Arabic","Lao","Persian"]
            UserDefaults.standard.set(Language, forKey: "Languages")
        }
        //JSON버젼을 체크하고, 최신 버젼이 있으면 업데이트 후 반영한다.
    }
    
    func SaveLanguageData(){
        UserDefaults.standard.set(Language,forKey:"Languages")
    }
    
    func getLanguage(_ index:Int)->String{
        return Language![index]
    }
    
    func setLanguage(_ index:Int,data Data:String){
        Language![index] = Data
    }
    func count()->Int{
        return Language!.count
    }
    
    func getLanguages()->[String]{
        return Language!
    }
}
