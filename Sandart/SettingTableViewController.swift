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

class SettingTableViewController: UITableViewController,SKPaymentTransactionObserver{
    @IBOutlet var settingTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        SKPaymentQueue.default().add(self)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        /*
        let creditTag = cell?.viewWithTag(333) as! UILabel
        creditTag.frame = CGRect.init(x: cell!.frame.size.width-196, y: 12, width: 180, height: 20)
 */
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4;
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        var n:Int=0
        if(section == 2){
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
                //restore purchases
                self.restoreCompletedTransactions()
            default:
                break
            }
        case 1:
            switch(indexPath.row){
            case 0:
                showAllRemoveConfirmAlertView(Withtitle: NSLocalizedString("Confirm", comment: "Confirm"), WithMessage: NSLocalizedString("Remove_All_Files", comment: "Are you Sure?"))
                self.tableView.deselectRow(at: indexPath, animated: true)
                break;
            default:
                break;
            }
        case 2:
            switch(indexPath.row){
            case 0:
                UIApplication.shared.open(URL(string: "http://everykoreanstudent.com")!, options: [:], completionHandler: nil)
                self.tableView.deselectRow(at: indexPath, animated: true)
                break;
            case 1:
                UIApplication.shared.open(URL(string: "http://sandartp4u.com")!, options: [:], completionHandler: nil)
                self.tableView.deselectRow(at: indexPath, animated: true)
                break;
            default:
                break;
            }
        case 3:
             tableView.deselectRow(at: indexPath, animated: true)
        default:
            break;
        }
    }
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
   // MARK: - Delete file
    func removeAllFiles()
    {
        let productIdentifiers = SandartEntryTable.productIdentifiers()
        
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

                let tvc = self.tabBarController?.viewControllers![0] as! SandArtViewController
                tvc.reloadEntyTableWithLangKey(langkey: identifier)
                tvc.tableView.reloadData()
            }
        }
    }
    //MARK: - IN-App Purchase Restoration
    
    
    func restoreCompletedTransactions(){
        //It will be handled by the delegate. SandArtViewController
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        self.tableView.deselectRow(at: self.tableView.indexPathForSelectedRow!, animated:true)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        self.tableView.deselectRow(at: self.tableView.indexPathForSelectedRow!, animated: true)
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
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for t in transactions
        {
            switch(t.transactionState)
            {
            case SKPaymentTransactionState.restored:
                self.restoreTransaction(transaction: t)
            default:
                break;
            }
        }
    }
    func restoreTransaction(transaction:SKPaymentTransaction){
        let langkey = transaction.payment.productIdentifier;
        let entry = SandartEntry.restoreForKey(langkey)
        if(entry?.Status == MovieStatus.NotPurchased){
            entry?.Status = MovieStatus.NotDownloaded
            entry?.persistForKey(langkey)
        }
        //remove finished transaction from queue
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    //MARK: - Alert View
    func showAllRemoveConfirmAlertView(Withtitle title:String,WithMessage message:String)
    {
        //let uikitBundle = Bundle.init(for: type(of: UIButton.init()))
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
