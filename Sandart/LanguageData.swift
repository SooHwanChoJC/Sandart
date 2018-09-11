//
//  LanguageData.swift
//  Sandart
//
//  Created by 조수환 on 2018. 9. 4..
//  Copyright © 2018년 Joshua. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class LanguageData{
    private var Language:[String]? = []
    private var MovieDownloadLink:[String:String]? = [:]
    private var DisplayText:[String:String]? = [:]
    private var Version:Int?
    init(){
        
        let LocalJSONPath = Bundle.main.path(forResource: "SandartLanguages", ofType: "json")
        let LocalJSONURL = URL(fileURLWithPath: LocalJSONPath!)
        if let data = try? String(contentsOf: LocalJSONURL){
            let json = JSON(parseJSON: data)
            Version = json["Version"].intValue
            Language = json["Data"].dictionaryValue.map{
                $0.key
            }
            MovieDownloadLink = json["Data"].dictionaryValue.mapValues{
                $0["Link"].stringValue
            }
            DisplayText = json["Data"].dictionaryValue.mapValues{
                $0["Text"].stringValue
            }
        }
      
        //JSON버젼을 체크하고, 최신 버젼이 있으면 업데이트 후 반영한다.(버젼을 체크)
        if(ConnectionChecker.isConnectedInternet()){
            let URL = "http://www.sandartp4u.com/"//JSON LINK
            
            Alamofire.request(URL, method: .get).validate().responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    let tempVersion = json["Version"].intValue
              
                    if(tempVersion != self.Version){//버전이 다르면 파일을 지우고 새로운 데이터를 넣어서 다시 만든다.
                        let fileManager = FileManager.default
                        try? fileManager.removeItem(at: LocalJSONURL)
                        fileManager.createFile(atPath: LocalJSONPath!, contents: try? json.rawData())
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
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
    
    func getMovieDownloadLink(_ key:String)->String{
        return MovieDownloadLink![key]!
    }
    func reorder(){
        Language!.removeAll{
            $0 == " Korean"
        }//Korean 삭제
        Language!.sort()
        Language!.insert("Korean", at: 0)
        UserDefaults.standard.set(Language,forKey:"Languages")
    }
    func getDisplayText(_ key:String)->String{
        return DisplayText![key]!
    }
}
