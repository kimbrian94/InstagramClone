//
//  UserTableViewController.swift
//  Instagram
//
//  Created by Brian Kim on 2020-07-30.
//  Copyright © 2020 Brian Kim. All rights reserved.
//

import UIKit
import Parse

class UserTableViewController: UITableViewController {
    
    // Object initialization
    var usernames = [""]
    var objectIds = [""]
    var isFollowing = ["" : false]
    
    var refresher: UIRefreshControl = UIRefreshControl()
    
    // This IBAction function logs the user out when log out button is tapped
    @IBAction func logoutUser(_ sender: Any) {
        PFUser.logOut()
        
        performSegue(withIdentifier: "logoutSegue", sender: self)
    }
    
    // This function updates the main user table with the current updated list of total users and whether they are followed or not
    // Query through the server and find all users except current user and update the usernames, objectIds, isFollowing arrays
    @objc func updateTable() {
        let query = PFUser.query()
        
        query?.whereKey("username", notEqualTo: PFUser.current()?.username)
        
        query?.findObjectsInBackground(block: { (users, error) in
            
            if error != nil {
                print(error!)
            } else if let users = users {
                self.usernames.removeAll()
                self.objectIds.removeAll()
                self.isFollowing.removeAll()
                
                for object in users {
                    if let user = object as? PFUser {
                        if let username = user.username {
                            if let objectId = user.objectId {
                                let arr = username.components(separatedBy: "@")
                                self.usernames.append(arr[0])
                                self.objectIds.append(objectId)
                                
                                let query = PFQuery(className: "Following")
                                
                                query.whereKey("follower", equalTo: PFUser.current()?.objectId)
                                query.whereKey("following", equalTo: objectId)
                                
                                query.findObjectsInBackground { (objects, error) in
                                    if let objects = objects {
                                        if objects.count > 0 {
                                            self.isFollowing[objectId] = true
                                        } else {
                                            self.isFollowing[objectId] = false
                                        }
                                        
                                        if self.usernames.count == self.isFollowing.count {
                                            self.tableView.reloadData()
                                            
                                            self.refresher.endRefreshing()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // First update table when view is loaded
        updateTable()
        
        // Set up refresher and set action to run the updateTable function when pulled
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(UserTableViewController.updateTable), for: UIControl.Event.valueChanged)
        
        // Add the refresher
        tableView.addSubview(refresher)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernames.count
    }
    
    // Set up the content of each cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        cell.textLabel?.text = usernames[indexPath.row]
        
        // If a user from the list is followed by the current user, then put a checkmark
        if let followsBoolean = isFollowing[objectIds[indexPath.row]] {
            if followsBoolean {
                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
            }
        }
        
        return cell
    }
    
    // This function runs when a cell is selected/tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        if let followsBoolean = isFollowing[objectIds[indexPath.row]] {
            // If selected user cell is followed by the current user, then unfollow it by deleting from the isFollowing array and from the parse database
            if followsBoolean {
                isFollowing[objectIds[indexPath.row]] = false
                
                // Uncheck the cell
                cell?.accessoryType = UITableViewCell.AccessoryType.none
                
                let query = PFQuery(className: "Following")
                
                query.whereKey("follower", equalTo: PFUser.current()?.objectId)
                query.whereKey("following", equalTo: objectIds[indexPath.row])
                
                query.findObjectsInBackground { (objects, error) in
                    if let objects = objects {
                        for object in objects {
                            object.deleteInBackground()
                        }
                    }
                }
            // If selected user cell is not followed by the current user, then follow it by adding follow object to the array and to the database
            } else {
                isFollowing[objectIds[indexPath.row]] = true
                cell?.accessoryType = UITableViewCell.AccessoryType.checkmark
                
                let following = PFObject(className: "Following")
                
                following["follower"] = PFUser.current()?.objectId
                
                following["following"] = objectIds[indexPath.row]
                
                following.saveInBackground()
            }
        }
    }
}
