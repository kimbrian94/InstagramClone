//
//  FeedTableViewController.swift
//  Instagram
//
//  Created by Brian Kim on 2020-08-03.
//  Copyright © 2020 Brian Kim. All rights reserved.

import UIKit
import Parse

class FeedTableViewController: UITableViewController {
    // Object initialization
    var users = [String: String]()
    var comments = [String]()
    var usernames = [String]()
    var imageFiles = [PFFileObject]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Query through the PFUser for all the users who are being followed by the current user
        // If those queried users have posts, then append the post attributes to each array
        let query = PFUser.query()
        query?.whereKey("username", notEqualTo: PFUser.current()?.username)
        
        query?.findObjectsInBackground(block: { (objects, error) in
            if let users = objects {
                for object in users {
                    if let user = object as? PFUser {
                        self.users[user.objectId!] = user.username!
                    }
                }
            }
            
            let getFollowedUserQuery = PFQuery(className: "Following")
            getFollowedUserQuery.whereKey("follower", equalTo: PFUser.current()?.objectId)
            
            getFollowedUserQuery.findObjectsInBackground { (objects, error) in
                if let followers = objects {
                    for follower in followers {
                        if let followedUser = follower["following"] {
                            let query = PFQuery(className: "Post")
                            query.whereKey("userid", equalTo: followedUser)
                            
                            query.findObjectsInBackground { (objects, error) in
                                if let posts = objects {
                                    for post in posts {
                                        self.comments.append(post["message"] as! String)
                                        self.usernames.append(self.users[post["userid"] as! String]!)
                                        self.imageFiles.append(post["imageFile"] as! PFFileObject)
                                        
                                        self.tableView.reloadData()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return comments.count
    }

    // This runs everytime a table is reloaded. Configures each cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FeedTableViewCell
        
        // Set up cells attributes (image, comment, userInfo) from the arrays
        imageFiles[indexPath.row].getDataInBackground { (data, error) in
            if let imageData = data {
                if let imageToDisplay = UIImage(data: imageData) {
                    cell.postedImage.image = imageToDisplay
                }
            }
        }
        
        cell.comment.text = comments[indexPath.row]
        cell.userInfo.text = usernames[indexPath.row]
        
        return cell
    }

}
