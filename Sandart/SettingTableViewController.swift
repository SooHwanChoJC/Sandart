//
//  SettingTableViewController.swift
//  Sandart
//
//  Created by Soohwan.Cho on 2018. 4. 6..
//  Copyright © 2018년 Joshua. All rights reserved.
//

import UIKit
import StoreKit
import os

class SettingTableViewController: UITableViewController{
    @IBOutlet var settingTable: UITableView!
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3;
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        var n:Int=0
        if(section == 1){
            n = 2
        }
        else{
            n = 1
        }
        return n;
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch(indexPath.section){
        case 0:
            switch(indexPath.row){
            case 0:
                showAllRemoveConfirmAlertView(Withtitle: NSLocalizedString("Confirm", comment: "Confirm"), WithMessage: NSLocalizedString("Remove_All_Files", comment: "Are you Sure?"))
                self.tableView.deselectRow(at: indexPath, animated: true)
                break;
            default:
                break;
            }
        case 1:
            switch(indexPath.row){
            case 0:
                UIApplication.shared.open(URL(string: "http://everykoreanstudent.com")!, options: [:] , completionHandler: nil)
                self.tableView.deselectRow(at: indexPath, animated: true)
                break;
            case 1:
                UIApplication.shared.open(URL(string: "http://sandartp4u.com")!, options: [:] , completionHandler: nil)
                self.tableView.deselectRow(at: indexPath, animated: true)
                break;
            default:
                break;
            }
        case 2:
             tableView.deselectRow(at: indexPath, animated: true)
        default:
            break;
        }
    }
 
   // MARK: - Delete file
    func removeAllFiles()
    {
        let productIdentifiers = LanguageData.productIdentifiers()
        
        for identifier in productIdentifiers
        {
            let entry = SandartEntry.restoreForKey(identifier)
            if(entry?.Status == MovieStatus.Downloaded)
            {
                do{
                    try removeStoredFileWithLangKey(langkey: identifier)
                    entry?.Status = MovieStatus.NotDownloaded
                    entry?.persistForKey(identifier)
                }
                catch{
                    os_log("file delete Error")
                }

                let nvc = self.tabBarController?.viewControllers![0] as! UINavigationController
                let tvc = nvc.viewControllers[0] as! SandArtViewController
                tvc.reloadEntyTableWithLangKey(langkey: identifier)
                tvc.tableView.reloadData()
            }
        }
    }
    func removeStoredFileWithLangKey(langkey key:String) throws {
        let fm = FileManager.default
        let StorePath = SandartEntryTable.storePath()
        let filePath = StorePath.appendingPathComponent(key + ".mp4")
        do{
        try fm.removeItem(atPath: filePath.relativePath)
        }
        catch (let error){
            print("\(error)\n");
            throw error
        }
    }
    //MARK: - Alert View
    func showAllRemoveConfirmAlertView(Withtitle title:String,WithMessage message:String)
    {
        let av = UIAlertController.init(title: NSLocalizedString(title, comment: title), message: NSLocalizedString(message, comment: message), preferredStyle:.alert)
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil)
        let ok = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"),style: .destructive){
            (action: UIAlertAction) in
            self.removeAllFiles()
        }
        
        av.addAction(cancel)
        av.addAction(ok)
        
        self.present(av, animated: true, completion: nil)
        
    }

}
