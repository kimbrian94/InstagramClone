//
//  FeedTableViewCell.swift
//  Instagram
//
//  Created by Brian Kim on 2020-08-03.
//  Copyright © 2020 Brian Kim. All rights reserved.
//

import UIKit

class FeedTableViewCell: UITableViewCell {
    
    // Outlet initialization
    @IBOutlet weak var postedImage: UIImageView!
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var userInfo: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
