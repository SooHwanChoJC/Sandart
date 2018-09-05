//
//  SandartEntryTable.swift
//  Sandart
//
//  Created by Soohwan.Cho on 2018. 3. 29..
//  Copyright © 2018년 Joshua. All rights reserved.
//

import Foundation

class SandartEntryTable{
    var Entries = [SandartEntry]()
    init(With LangKeys:Array<String?>){
        for key in LangKeys
        {
            var Entry = SandartEntry.restoreForKey(key)
            if(Entry == nil)
            {
                Entry = SandartEntry(WithLangKey: key!)
            }
            Entries.append(Entry!)
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
    static func productIdentifiers()->Array<String>{
        let paths = Bundle.main.infoDictionary!["Download Paths"] as! Dictionary<String,String>
        return Array(paths.keys)
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
