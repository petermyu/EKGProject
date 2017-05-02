//
//  ArchivesViewController.swift
//  EKGShirt
//
//  Created by Solomon, Karl on 3/30/17.
//  Copyright © 2017 Solomon, Karl. All rights reserved.
//

import UIKit
import Foundation
import MessageUI

class ArchivesViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    
// MARK: Statics
    static var ArchiveList = [Archive]() // data source
    
// MARK: Properties
    @IBOutlet var archivesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        ArchivesViewController.ArchiveList = loadArchives()!
        self.archivesTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func addArchive(archive: Archive) {
        ArchivesViewController.ArchiveList.append(archive)
        let _ = NSKeyedArchiver.archiveRootObject(ArchivesViewController.ArchiveList, toFile: SymptomsViewController.ArchiveURL.path!)   // saves archive to documents directory (semi-permanent) memory
    }
    
    private func loadArchives() -> [Archive]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(SymptomsViewController.ArchiveURL.path!) as? [Archive] // loads all saved archives from memory
    }

// MARK: Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ArchivesViewController.ArchiveList.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ArchiveCell", forIndexPath: indexPath)
        let archive = ArchivesViewController.ArchiveList[indexPath.row]
        cell.textLabel?.text = archive.getDate() + " " + archive.getTime()
        cell.detailTextLabel?.text = archive.getSymptomsAbbreviations()
        return cell
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let archive = ArchivesViewController.ArchiveList[indexPath.row]
        
        let email = UITableViewRowAction(style: .Normal, title: "Email", handler: {_,_ in
            let mailComposeViewController = self.configuredMailComposeViewController(archive)
            if MFMailComposeViewController.canSendMail() {
                self.presentViewController(mailComposeViewController, animated: true, completion: nil)
            } else {
                self.showSendMailErrorAlert()
            }
            
        })
        
        let delete = UITableViewRowAction(style: .Default, title: "Delete", handler: {_,_ in 
            ArchivesViewController.ArchiveList.removeAtIndex(indexPath.row)
            self.archivesTableView.reloadData()
        })
        return [email, delete]
    }
    
    // Open Data Vis View of Archive Data
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        LiveFeedViewController.displayedArchive = ArchivesViewController.ArchiveList[indexPath.row]
        let destinationVC = self.storyboard?.instantiateViewControllerWithIdentifier("LiveFeedViewController") as! LiveFeedViewController
        self.showViewController(destinationVC, sender: self)
        destinationVC.updateChartWithData()
    }
    
    //Delete Archive From memory
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            archivesTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
// MARK: EMAIL VIEW DELEGATE
    func configuredMailComposeViewController(archive: Archive) -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setSubject("Patient EKG Record: " + archive.getDate() + " " + archive.getTime() )
        mailComposerVC.setMessageBody("Symptoms: \n" + archive.getSymptoms(), isHTML: false)
        if let fileData = NSData(contentsOfURL: archive.getPath()){
            mailComposerVC.addAttachmentData(fileData, mimeType: "text/plain", fileName: archive.getDate())
        } else {
            let alert = UIAlertController(title: "File Not Found", message: "The file for this archive could not be found", preferredStyle: .Alert)
            let cancel = UIAlertAction(title: "Cancel", style: .Default, handler: { action in
            })
            alert.addAction(cancel)
            presentViewController(alert, animated: true, completion: nil)
        }
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MFMailComposeViewControllerDelegate Method
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}
