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
    private var movieDownloadLink:[String:String]? = [:]
    init(){
        Language = UserDefaults.standard.array(forKey: "Languages") as? [String]
        movieDownloadLink = UserDefaults.standard.dictionary(forKey: "movieDownloadLink") as? [String:String]
        if Language == nil || movieDownloadLink == nil{
            Language = ["English","Chinese","Chinese Traditional","Japanese","Russian","French","Spanish","Hindi","Mongolia","Polish",
            "Turkish","Nepali","Indonesia","Thai","Cambodian", "Filipino","Vietnamese","Arabic","Lao","Persian"]
            movieDownloadLink = ["Korean":"http://cccvlm6.myqnapcloud.com/sandartp4u/SandArtP4U_mobile_Korean.mp4" ,
                        "English":"http://cccvlm6.myqnapcloud.com/sandartp4u/SandArtP4U_mobile_English.mp4",
                        "Chinese":"http://cccvlm6.myqnapcloud.com/sandartp4u/SandArtP4U_mobile_Chinese.mp4",
                        "Chinese Traditional":"http://cccvlm6.myqnapcloud.com/sandartp4u/SandArtP4U_mobile_Chinese(Traditional).mp4",
                        "Japanese":"http://cccvlm6.myqnapcloud.com/sandartp4u/SandArtP4U_mobile_Chinese(Traditional).mp4",
                        "Russian":"http://cccvlm6.myqnapcloud.com/sandartp4u/SandArtP4U_mobile_Russian.mp4",
                        "French":"http://cccvlm6.myqnapcloud.com/sandartp4u/SandArtP4U_mobile_French.mp4",
                        "Spanish":"http://cccvlm6.myqnapcloud.com/sandartp4u/SandArtP4U_mobile_Spanish.mp4",
                        "Hindi":"http://cccvlm6.myqnapcloud.com/sandartp4u/SandArtP4U_mobile_Hindi.mp4",
                        "Mongolia":"http://cccvlm6.myqnapcloud.com/sandartp4u/SandArtP4U_mobile_Mongolia.mp4",
                        "Polish":"http://cccvlm6.myqnapcloud.com/sandartp4u/SandArtP4U_mobile_Polish.mp4",
                        "Turkish":"http://cccvlm6.myqnapcloud.com/sandartp4u/SandArtP4U_mobile_Turkish.mp4",
                        "Nepali":"http://cccvlm6.myqnapcloud.com/sandartp4u/SandArtP4U_mobile_Nepali.mp4",
                        "Indonesia":"http://cccvlm6.myqnapcloud.com/sandartp4u/SandArtP4U_mobile_Indonesian.mp4",
                        "Thai":"http://cccvlm6.myqnapcloud.com/sandartp4u/SandArtP4U_mobile_Thai.mp4",
                        "Cambodian":"http://cccvlm6.myqnapcloud.com/sandartp4u/SandArtP4U_mobile_Cambodian.mp4",
                        "Filipino":"http://cccvlm6.myqnapcloud.com/sandartp4u/SandArtP4U_mobile_Filipino.mp4",
                        "Vietnamese":"http://cccvlm6.myqnapcloud.com/sandartp4u/SandArtP4U_mobile_Vietnamese.mp4",
                        "Arabic":"http://cccvlm6.myqnapcloud.com/sandartp4u/SandArtP4U_mobile_Vietnamese.mp4",
                        "Lao":"http://cccvlm6.myqnapcloud.com/sandartp4u/SandArtP4U_mobile_Laos.mp4",
                        "Persian":"http://cccvlm6.myqnapcloud.com/sandartp4u/SandArtP4U_mobile_Persian.mp4"]
            Language!.sort()
            Language!.insert("Korean", at: 0)
            UserDefaults.standard.set(Language, forKey: "Languages")
            UserDefaults.standard.set(movieDownloadLink,forKey:"movieDownloadLink")
        }
        //JSON버젼을 체크하고, 최신 버젼이 있으면 업데이트 후 반영한다.(항목 개수를 체크해서 더 많으면 추가하는 방식)
        if(ConnectionChecker.isConnectedInternet()){
            let URL = "http://www.sandartp4u.com/"//JSON LINK
            
            Alamofire.request(URL, method: .get).validate().responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    let tempLanguage = json.dictionaryValue.map{
                        $0.key
                    }
                    
                    if(tempLanguage.count>self.Language!.count){
                        for i in 0..<tempLanguage.count{
                            if !(self.Language!.contains(tempLanguage[i])){
                                self.Language!.append(tempLanguage[i])
                                self.movieDownloadLink![tempLanguage[i]] = json.dictionaryValue[tempLanguage[i]]?.stringValue
                            }
                        }
                    }
                    UserDefaults.standard.set(self.Language, forKey: "Languages")
                    UserDefaults.standard.set(self.movieDownloadLink,forKey:"movieDownloadLink")//링크는 변하지 않기에, 여기서만 추가함
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
        return movieDownloadLink![key]!
    }
    func reorder(){
        Language!.removeAll{
            $0 == " Korean"
        }//Korean 삭제
        Language!.sort()
        Language!.insert("Korean", at: 0)
        UserDefaults.standard.set(Language,forKey:"Languages")
    }
}
