//
//  SandArtViewController.swift
//  Sandart
//
//  Created by Soohwan.Cho on 2018. 3. 24..
//  Copyright © 2018년 Joshua. All rights reserved.
//

import UIKit
import StoreKit
import Alamofire
import AVFoundation
import AVKit

let MaxConcurrentDownload = 3

class SandArtViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var ReorderButton: UIBarButtonItem!
    
    override var shouldAutorotate: Bool {
        return true
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }
    var table:SandartEntryTable?
    var playerView:LandscapeAVPlayerViewController?
    var requestDic:Dictionary<String,Alamofire.Request> = Dictionary<String,Alamofire.Request>()
    var downloadProgress:Dictionary<String,Float> = Dictionary<String,Float>()
    var downloadingPath = Array<IndexPath>()
    var timerSet = false
    var isEditMode = false//false : Normal Mode. true : EditMode
    let SandArtLanguages = LanguageData()
    let manager = Alamofire.SessionManager(configuration: URLSessionConfiguration.background(withIdentifier: "org.kccc.P4U.background"))
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        
        let tabbarHeight = self.tabBarController!.tabBar.frame.size.height
        self.tableView.contentInset = UIEdgeInsets.init(top: 0,left: 0,bottom: tabbarHeight,right: 0)
        if(table == nil)
        {
            table = SandartEntryTable(With: SandArtLanguages.getLanguages())
        }
        for identifier in SandArtLanguages.getLanguages(){
            downloadProgress[identifier] = 0.0
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.displayUI()
    }
    func getScreenFrameForCurrentOrientation() -> CGRect{
        return self.getScreenFrameForOrientation(orientation: UIApplication.shared.statusBarOrientation)
    }
    
    func getScreenFrameForOrientation(orientation:UIInterfaceOrientation)->CGRect{
        let screen = UIScreen.main
        var fullScreenRect = screen.bounds
        let statusBarHidden = UIApplication.shared.isStatusBarHidden
        
        if orientation == UIInterfaceOrientation.landscapeRight || orientation == UIInterfaceOrientation.landscapeLeft{
            var temp = CGRect.zero
            temp.size.width = fullScreenRect.size.height
            temp.size.height = fullScreenRect.size.width
            fullScreenRect = temp
        }
        if !statusBarHidden{
            let statusBarSize = UIApplication.shared.statusBarFrame.size
            let statusBarHeight = Swift.min(statusBarSize.width, statusBarSize.height)
            fullScreenRect.size.height -= CGFloat(statusBarHeight)
        }
        
        return fullScreenRect
    }
    //MARK: - event handlers
    
    @objc @IBAction func download(_ sender: Any) {
        let button = sender as! UIButton
        let langKey = button.title(for: UIControl.State.application)
        
        self.downloadWithLangKey(langkey: langKey!)
    }
    
    func downloadWithLangKey(langkey:String){
        if !ConnectionChecker.isConnectedInternet(){
            let title = "Download_Error"
            let message = "CheckInternet"
            let av = UIAlertController.init(title: NSLocalizedString(title, comment: title), message: NSLocalizedString(message, comment: message), preferredStyle:.alert)
            let cancel = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .cancel, handler: nil)
            av.addAction(cancel)
            self.present(av, animated: true, completion: nil)
            return
        }
        let entry = table!.entryWithLangKey(langkey)
        let indexPath = IndexPath.init(row: (table?.indexForLangKey(langkey))!, section: 1)
        if self.requestDic.count >= MaxConcurrentDownload{
            let title = "Download_Error"
            let message = "Max_DownloadError"
            let av = UIAlertController.init(title: NSLocalizedString(title, comment: title), message: NSLocalizedString(message, comment: message), preferredStyle:.alert)
            let cancel = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .cancel, handler: nil)
            av.addAction(cancel)
            self.present(av, animated: true, completion: nil)
            return
        }
        if entry?.Status == MovieStatus.NotDownloaded{
            let targetPath = SandArtLanguages.getMovieDownloadLink(langkey)
            let url = URL.init(string: targetPath)//download url
            //downloading with alamofire
            let destination:DownloadRequest.DownloadFileDestination = { _, _ in
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fileURL = documentsURL.appendingPathComponent("SandArt/" + langkey + ".mp4")
                
                return (fileURL,[.removePreviousFile, .createIntermediateDirectories])
            }
            
            self.update(indexPath: indexPath, withStatus: MovieStatus.Downloading)
            downloadingPath.append(indexPath)
            let request = manager.download(url!,method: .get, to: destination)
                .downloadProgress{progress in
                        self.downloadProgress[langkey] = Float(progress.fractionCompleted)
                    
                }
                .responseData{
                    response in
                    
                    if response.result.isFailure{
                        if response.error!.localizedDescription == "cancelled"{
                        }
                        else{
                            let title = "Download_Error"
                            let message = "Try again"
                            let av = UIAlertController.init(title: NSLocalizedString(title, comment: title), message: NSLocalizedString(message, comment: message), preferredStyle:.alert)
                            let cancel = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .cancel, handler: nil)
                            av.addAction(cancel)
                            self.present(av, animated: true, completion: nil)
                        }
                        self.update(indexPath: indexPath, withStatus: MovieStatus.NotDownloaded)
                    }
                    else{
                        self.addSkipBackupAttributeToItemAtURL(URL: response.destinationURL!)
                        self.update(indexPath: indexPath, withStatus: MovieStatus.Downloaded)
                    }
                    self.requestDic.removeValue(forKey: langkey)
                    self.downloadingPath.remove(at: self.downloadingPath.index(of: indexPath)!)
              
            }
            requestDic[langkey] = request
           if(!self.timerSet){
            Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updatePeriodically(timer:)), userInfo: nil, repeats: true)
                self.timerSet = true
            }
            request.resume()
        }
}
    
    func addSkipBackupAttributeToItemAtURL(URL:URL){
        
        assert(FileManager.default.fileExists(atPath: URL.path))
        
        var URL = URL
        
        do{
            var resourceValues = URLResourceValues()
            resourceValues.isExcludedFromBackup = true
            try URL.setResourceValues(resourceValues)
        }
        catch {
            NSLog("Error execluding %@ from backup", URL.lastPathComponent)
        }
}
    @objc @IBAction func cancelDownloading(_ sender:Any){
        let button = sender as! UIButton
        let langKey = button.title(for: UIControl.State.application)
        let indexPath = IndexPath.init(row: (table?.indexForLangKey(langKey!))!, section: 1)
        let download = requestDic[langKey!]
        
        if download != nil{
            download!.cancel()
        }
        
        self.update(indexPath: indexPath, withStatus: MovieStatus.NotDownloaded)
    }
    
    @objc @IBAction func play(_ sender:Any){
        let entry = self.entryForSender(sender)
        if(entry!.Status == MovieStatus.Downloaded){
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let url = documentsURL.appendingPathComponent("SandArt/" + entry!.LangKey + ".mp4")
            let player = AVPlayer(url: url)
            playerView = LandscapeAVPlayerViewController()
            playerView!.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            playerView!.player = player
           NotificationCenter.default.addObserver(self, selector: #selector(moviePlayerPlaybackDidFinish(notification:)), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: playerView!.player?.currentItem)
            playerView!.view.frame = self.view.frame
            self.present(playerView!, animated: true){
                UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue,forKey:"orientation")
                self.playerView!.player?.play()
            }
        }
        
    }
    //MARK: - event helpers
    @objc func moviePlayerPlaybackDidFinish(notification:Notification){
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue,forKey:"orientation")
        playerView?.dismiss(animated: true, completion: nil)
        
    }
    
    func entryForSender(_ sender:Any)->SandartEntry?{
        let button = sender as! UIButton
        let langkey = button.title(for: UIControl.State.application)
        let entry = table!.entryWithLangKey(langkey!)
        return entry
    }
    
    func reloadEntyTableWithLangKey(langkey:String){
        let entry = table?.entryWithLangKey(langkey)
        let new = SandartEntry.restoreForKey(langkey)
        entry?.Status=(new?.Status)!
    }
    
    func update(indexPath:IndexPath,withStatus status:MovieStatus){
        let cell = self.tableView(self.tableView, cellForRowAt: indexPath)
        let entry = table?.entryAtIndex(index: indexPath.row)
        entry!.Status = status
        entry!.persistForKey((entry!.LangKey))
        self.updateButton(cell:cell, withStatus: entry!.Status,indexPath: indexPath)
    }
    
    func updateButton(cell:UITableViewCell,withStatus status:MovieStatus,indexPath:IndexPath){
        let cell = cell as! LanguageTableViewCell
        let button = cell.viewWithTag(2) as! UIButton
        let progressBar = cell.viewWithTag(3) as! UIProgressView
        button.isHidden = false
        progressBar.isHidden = true
        switch(status){
        case MovieStatus.NotDownloaded:
            button.setImage(UIImage(named: "Download.png"), for: UIControl.State.normal)
            button.imageView!.contentMode = UIView.ContentMode.scaleAspectFill
            button.removeTarget(self, action: #selector(SandArtViewController.cancelDownloading(_:)), for: UIControl.Event.touchUpInside)
            button.removeTarget(self, action: #selector(SandArtViewController.play(_:)), for: UIControl.Event.touchUpInside)
            button.addTarget(self, action: #selector(SandArtViewController.download(_:)), for: UIControl.Event.touchUpInside)
        case MovieStatus.Downloading:
            progressBar.isHidden = false
            button.setImage(UIImage(named: "Stop.png"), for: UIControl.State.normal)
            button.imageView?.contentMode = UIView.ContentMode.scaleAspectFill
            button.removeTarget(self, action: #selector(SandArtViewController.play(_:)), for: UIControl.Event.touchUpInside)
            button.removeTarget(self, action: #selector(SandArtViewController.download(_:)), for: UIControl.Event.touchUpInside)
            button.addTarget(self, action: #selector(SandArtViewController.cancelDownloading(_:)), for: UIControl.Event.touchUpInside)
        case MovieStatus.Downloaded:
            button.setImage(UIImage(named: "Play.png"), for: UIControl.State.normal)
            button.imageView?.contentMode = UIView.ContentMode.scaleAspectFill
            button.removeTarget(self, action: #selector(SandArtViewController.download(_:)), for: UIControl.Event.touchUpInside)
            button.removeTarget(self, action: #selector(SandArtViewController.cancelDownloading(_:)), for: UIControl.Event.touchUpInside)
            button.addTarget(self, action: #selector(SandArtViewController.play(_:)), for: UIControl.Event.touchUpInside)
            break
        }
        
            self.tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    //MARK: - tableviewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }
        else{
        return self.SandArtLanguages.count()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let Identifier = (indexPath.section == 0) ? "ImageCell" : "LanguageCell"
        let Rawcell = tableView.dequeueReusableCell(withIdentifier: Identifier)
         if(indexPath.section == 0)
         {
            Rawcell?.selectionStyle = UITableViewCell.SelectionStyle.none

            return Rawcell!
         }
        else
        {
            let cell = Rawcell as! LanguageTableViewCell
            let languageLabel = cell.viewWithTag(1) as! UILabel
            let entry = table!.entryAtIndex(index: indexPath.row)
            
            
            if(entry!.Title != ""){
                languageLabel.text = entry!.Title
            }
            let actionButton = cell.contentView.viewWithTag(2) as! UIButton

            actionButton.setTitle(entry!.LangKey, for: UIControl.State.application)//set product identifier for purchase
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.Progress.setProgress(downloadProgress[entry!.LangKey]!, animated: false)
            self.updateButton(cell:cell, withStatus: entry!.Status,indexPath: indexPath)
            return cell
         
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {//notice if a cell is editable(insert,delete)
        if(table==nil)
        {
            return false
        }
        if(table?.entryAtIndex(index: indexPath.row)==nil)
        {
            return false
        }
        if(indexPath.section != 0)
        {
            return true
        }
        else
        {
            return false
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {//actions when you edited row(insert,delete)
        if(editingStyle == UITableViewCell.EditingStyle.delete)
        {
            let entry = table!.entryAtIndex(index: indexPath.row)
            do{
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let url = documentsURL.appendingPathComponent("SandArt/" + entry!.LangKey + ".mp4")
                try FileManager.default.removeItem(at: url)
            }
            catch _{
                NSLog("file delete error :")
            }
            self.update(indexPath: indexPath, withStatus: MovieStatus.NotDownloaded)
        }
        else if (editingStyle == UITableViewCell.EditingStyle.insert){
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {//notice editing style(insert, delete)
        if(indexPath.section != 0&&(table!.entryAtIndex(index: indexPath.row))!.Status == MovieStatus.Downloaded)//only for downloaded items
        {
            return .delete
        }
        else{//otherwise, nothing to do except reorder
            return .none
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {//notice a cell is reorderable
        if downloadingPath.count != 0{//while downloading something else, block reorder
            return false
        }
        else{
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {//actions when you reordered rows
                let temp = SandArtLanguages.getLanguage(sourceIndexPath.row)
                SandArtLanguages.setLanguage(sourceIndexPath.row, data: SandArtLanguages.getLanguage(destinationIndexPath.row))
                SandArtLanguages.setLanguage(destinationIndexPath.row, data: temp)
                table!.swapEntry(from:sourceIndexPath.row,to:destinationIndexPath.row)
    }
 
    //MARK: - Update UI
    func displayUI(){
        
        for langKey in self.SandArtLanguages.getLanguages(){
            let entry = table!.entryWithLangKey(langKey)
            entry!.Title = NSLocalizedString(langKey, comment: langKey)
            entry!.persistForKey(langKey)
        }
        self.tableView.reloadData()
    }
    
    func initIfAvailable(){
         var isLaunchedSuccesfullyBefore = UserDefaults.standard.object(forKey: "AlreadyLaunchedSuccessfullyBefore") as? Bool
        if(isLaunchedSuccesfullyBefore == nil){
            UserDefaults.standard.set(false, forKey: "AlreadyLaunchedSuccessfullyBefore")
            isLaunchedSuccesfullyBefore = false
        }
        
        if(!(isLaunchedSuccesfullyBefore!)){
            if !(ConnectionChecker.isConnectedInternet()){
            let title = "FirstLaunchError"
            let message = "CheckInternet"
            let av = UIAlertController.init(title: NSLocalizedString(title, comment: title), message: NSLocalizedString(message, comment: message), preferredStyle:.alert)
            let retry = UIAlertAction(title: NSLocalizedString("Retry", comment: "Retry"), style: .default){
                (action: UIAlertAction) in
                if(ConnectionChecker.isConnectedInternet()){
                    self.displayUI()
                    UserDefaults.standard.set(true, forKey: "AlreadyLaunchedSuccessfullyBefore")
                }
                else{
                    self.initIfAvailable()
                }
            }
            let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"),style: .cancel){
                (action: UIAlertAction) in
                exit(0)
            }
            
            av.addAction(retry)
            av.addAction(cancel)
            
            self.present(av, animated: true, completion: nil)
            }
            else{
                self.displayUI()
                UserDefaults.standard.set(true, forKey: "AlreadyLaunchedSuccessfullyBefore")
            }
        }
        else{
           self.displayUI()
        }
    }

    @objc func updatePeriodically(timer:Timer){
        if self.downloadingPath.count == 0{
            timer.invalidate()
            self.timerSet = false
            self.tableView.reloadData()//last reload
            return
        }
        else{
            self.tableView.reloadRows(at: self.downloadingPath, with: .none)
        }
    }
    //MARK:- BarButton's Action
    @IBAction func toggleEditMode(_ sender: Any) {

        if(self.isEditMode == false){
            self.navigationItem.rightBarButtonItem!.title = "Done"
            self.tableView.setEditing(true, animated: true)
            self.isEditMode = true
            self.ReorderButton.isEnabled = false
        }
        else{
            self.navigationItem.rightBarButtonItem!.title = "Edit"
            self.tableView.setEditing(false, animated: true)
            self.isEditMode = false
            SandArtLanguages.SaveLanguageData()//only affeted if press Done Button
            self.ReorderButton.isEnabled = true
        }
    }
    @IBAction func reorderTable(_ sender: Any) {
        let title = "Confirm"
        let message = "ReorderTable"
        let av = UIAlertController.init(title: NSLocalizedString(title, comment: title), message: NSLocalizedString(message, comment: message), preferredStyle:.alert)
        let ok = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default){
             (action: UIAlertAction)  in
                self.SandArtLanguages.reorder()
                self.table = SandartEntryTable(With: self.SandArtLanguages.getLanguages())
                self.tableView.reloadData()
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"),style: .cancel)
        
        av.addAction(ok)
        av.addAction(cancel)
        
        self.present(av, animated: true, completion: nil)
    }
    
}
