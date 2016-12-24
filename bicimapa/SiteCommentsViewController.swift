//
//  SiteCommentsViewController.swift
//  bicimapa
//
//  Created by Yoann Lecuyer on 10/10/15.
//  Copyright © 2015 Bicimapa. All rights reserved.
//

import UIKit
import CocoaLumberjack
import Alamofire
import SwiftyJSON
import DZNEmptyDataSet
import KeyboardWrapper
import SDWebImage

class SiteCommentsViewController : UITableViewController {
    
    var siteId : Int? = nil
    var comments : JSON = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadComments()
    }
    
    override func viewWillAppear(animated: Bool) {
        let comment = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Compose, target: self, action: "composeComment")
        self.tabBarController?.navigationItem.setRightBarButtonItem(comment, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.tabBarController?.navigationItem.setRightBarButtonItem(nil, animated: true)
    }
    
    func loadComments() {
        
        DDLogInfo("Show comments for site with id= \(self.siteId)")
        
        
        Alamofire.request(.GET, "\(Constants.Bicimapa.APIRootURL)/sites/\(self.siteId!)/comments.json")
            .responseJSON { _, _, result in
                
                let json = JSON(result.value!)
                
                self.comments = json["comments"]
                
                if (self.comments.count > 0) {
                    self.tabBarItem.badgeValue = "\(self.comments.count)"
                }
                self.tableView.reloadData()
                
                // must be called ios bug : http://stackoverflow.com/questions/27842764/uitableviewautomaticdimension-not-working-until-scroll
                self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    func composeComment() {
        let alertController = UIAlertController(title: "Enter your comment", message: nil, preferredStyle: .Alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: {
                (alert: UIAlertAction!) in
            
                let tf = alertController.textFields![0] as UITextField
                let comment = tf.text!
            
                DDLogInfo("Comment : \(comment)")
            
                let parameters = [
                    "comment": comment,
                    "token" : "" //TODO: add token
                ]
            
                Alamofire.request(.POST, "\(Constants.Bicimapa.APIRootURL)/sites/\(self.siteId!)/comment", parameters: parameters)
                    .responseJSON { _, _, result in
                        self.loadComments()
                    }
            }
        )
        let cancelAction = UIAlertAction(title: "Cancel", style: .Destructive, handler: nil)
        
        alertController.addTextFieldWithConfigurationHandler {
            (txtComment) -> Void in
            txtComment.placeholder = "<Your comment here>"
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(defaultAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell")!
        
        cell.textLabel!.text = comments[indexPath.item]["comment"].string!
        cell.detailTextLabel!.text = comments[indexPath.item]["added_by"].string!
        
        if let url = comments[indexPath.item]["avatar_url"].string {
            DDLogDebug(url)
            cell.imageView?.sd_setImageWithURL(NSURL(string: url), placeholderImage: UIImage(named: "anonymous50"))
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

}