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
    
    init(onComplete c:@escaping ()->()){
        self.loadData()//JSON으로 부터 데이터를 가져옴
        self.CheckUpdate(onComplete: c)//온라인에서 JSON을 가져옴
    }
    //MARK: - Member Method
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
            $0 == "Korean"
        }//Korean 삭제
        Language!.sort()
        Language!.insert("Korean", at: 0)
        UserDefaults.standard.set(Language,forKey:"Languages")
    }
    func getDisplayText(_ key:String)->String{
        return DisplayText![key]!
    }
    func CheckUpdate(onComplete c: @escaping ()->()){
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent("SandartLanguages.json")
        if(ConnectionChecker.isConnectedInternet()){
            let URL = "http://cccvlm6.myqnapcloud.com/SandartLanguages.json"//JSON LINK
            
            Alamofire.request(URL, method: .get).validate().responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    let tempVersion = json["Version"].intValue
                    if(self.Version!<tempVersion)
                    {
                        let fileManager = FileManager.default
                        try? fileManager.removeItem(at: fileURL)
                        fileManager.createFile(atPath: fileURL.relativePath, contents: try? json.rawData())
                        self.reloadData()
                    }
                    c()
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    //MARK: - Private Method
    private func loadData(){
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent("SandartLanguages.json")
        
        if !FileManager.default.fileExists(atPath: fileURL.relativePath){//앱의 사용자 데이터 폴더 안에 json이 없으면 프로젝트 안의 json을 가져옴.
            let LocalJSONPath = Bundle.main.path(forResource: "SandartLanguages", ofType: "json")
            let LocalJSONURL = URL(fileURLWithPath: LocalJSONPath!)
            if let data = try? String(contentsOf: LocalJSONURL){
                let json = JSON(parseJSON: data)
                Version = json["Version"].intValue
                Language = json["Data"].dictionaryValue.map{
                    $0.key
                }
                //키가 원하는 순서대로 나오지 않기 때문에, 재정렬을 수행
                Language!.removeAll{
                    $0 == "Korean"
                }//Korean 삭제
                Language!.sort()
                Language!.insert("Korean", at: 0)
                UserDefaults.standard.set(Language,forKey:"Languages")//순서는 Userdefaults로 따로 관리
                
                MovieDownloadLink = json["Data"].dictionaryValue.mapValues{
                    $0["Link"].stringValue
                }
                DisplayText = json["Data"].dictionaryValue.mapValues{
                    $0["Text"].stringValue
                }
                
                FileManager.default.createFile(atPath: fileURL.relativePath, contents:try? json.rawData())
            }
        } else{
            Language = UserDefaults.standard.stringArray(forKey: "Languages")
            if let data = try? String(contentsOf: fileURL){
                let json = JSON(parseJSON: data)
                Version = json["Version"].intValue
                MovieDownloadLink = json["Data"].dictionaryValue.mapValues{
                    $0["Link"].stringValue
                }
                DisplayText = json["Data"].dictionaryValue.mapValues{
                    $0["Text"].stringValue
                }
            }
            
        }
    }
    private func reloadData(){//데이터를 다시 로드한다. 파일의 존재 여부를 검사하지 않고, 새로운 언어가 추가되었는지 여부를 체크하고 있으면 추가한다.
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent("SandartLanguages.json")
        
        Language = UserDefaults.standard.stringArray(forKey: "Languages")
        if let data = try? String(contentsOf: fileURL){
            let json = JSON(parseJSON: data)
            Version = json["Version"].intValue
            MovieDownloadLink = json["Data"].dictionaryValue.mapValues{
                $0["Link"].stringValue
            }
            DisplayText = json["Data"].dictionaryValue.mapValues{
                $0["Text"].stringValue
            }
            let tempLanguage = json["Data"].dictionaryValue.map{
                    $0.key
                }
            let addedLanguage = tempLanguage.filter{
                    !(Language!.contains($0))
            }.sorted()//새로 추가된 언어를 체크,정렬 후 넣기
            
            let deletedLanguage = Language!.filter{
                !(tempLanguage.contains($0))
            }//삭제된 언어를 체크
            Language! += addedLanguage//추가된 언어를 뒤에 붙임
            Language = Language!.filter{
                !(deletedLanguage.contains($0))
            }//삭제된 언어를 지움
            
            UserDefaults.standard.set(Language,forKey:"Languages")
        }
    }
    //MARK: - Static Method
    static func productIdentifiers()->Array<String>{
        return UserDefaults.standard.stringArray(forKey: "Languages")!
    }
}
