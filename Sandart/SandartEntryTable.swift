//
//  SandartEntryTable.swift - 샌드아트 영상 테이블 전체를 나타내는 Model
//  Sandart
//
//  Created by Soohwan.Cho on 2018. 3. 29..
//  Copyright © 2018년 Joshua. All rights reserved.
//

import Foundation

class SandartEntryTable{
    var Entries = [SandartEntry]()
     var downloadProgress:Dictionary<String,Float> = Dictionary<String,Float>()
    init(With LangKeys:Array<String?>){
        for key in LangKeys
        {
            var Entry = SandartEntry.restoreForKey(key)
            if(Entry == nil)
            {
                Entry = SandartEntry(WithLangKey: key!)
            }
            Entries.append(Entry!)
            downloadProgress[key!] = 0.0
        }
    }
    func count() -> Int{
        return self.Entries.count
    }
    
    func entryAtIndex(index:Int) ->SandartEntry?{
        if index >= Entries.count
        {
            return nil
        }
        else
        {
        let Entry = self.Entries[index]
        return Entry
        }
    }
    
    func entryWithLangKey(_ key:String)->SandartEntry?
    {
        for entry in self.Entries
        {
            if(entry.LangKey == key)
            {
                return entry
            }
        }
        return nil
    }
    
    func indexForLangKey(_ key:String) ->Int{
        for i in 0...(self.count())
        {
            if(self.Entries[i].LangKey == key)
            {
                return i
            }
        }
        return -1
    }
    static func storePath() ->URL
    {
        let Paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let StorePath = Paths.appendingPathComponent("SandArt/")
        
        return StorePath
    }
    func swapEntry(from sourceIndex:Int,to destinationIndex:Int){
        let temp = Entries[sourceIndex]
        Entries[sourceIndex] = Entries[destinationIndex]
        Entries[destinationIndex] = temp
    }
}
