//
//  PostTableViewCell.swift
//  Continuum
//
//  Created by Chris Anderson on 12/11/19.
//  Copyright © 2019 trevorAdcock. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    var post: Post? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var postPhotoImageView: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    
    // MARK: - Custom Methods
    
    func updateViews() {
        postPhotoImageView.image = post?.photo
        captionLabel.text = post?.caption
        commentCountLabel.text = "\(post?.commentCount ?? 0)"
    }
}
