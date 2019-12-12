//
//  Post.swift
//  Continuum
//
//  Created by Chris Anderson on 12/10/19.
//  Copyright © 2019 trevorAdcock. All rights reserved.
//

import UIKit
import CloudKit

class Post {
    var photoData: Data?
    var timeStamp: Date
    var caption: String
    var comments: [Comment]
    var commentCount: Int
    let recordID: CKRecord.ID
    
    var photo: UIImage? {
        get {
            guard let photoData = photoData else { return nil }
            return UIImage(data: photoData)
        }
        set {
            photoData = newValue?.jpegData(compressionQuality: 0.5)
        }
    }
    
    var imageAsset: CKAsset? {
        get {
            let tempDirectory = NSTemporaryDirectory()
            let tempDirectoryURL = URL(fileURLWithPath: tempDirectory)
            let fileURL = tempDirectoryURL.appendingPathComponent(recordID.recordName).appendingPathExtension("jpg")
            do {
                try photoData?.write(to: fileURL)
            } catch let error {
                print("Error writing to temp url : \(error) \(error.localizedDescription)")
            }
            return CKAsset(fileURL: fileURL)
        }
    }
    
    init (caption: String, photo: UIImage, timeStamp: Date = Date(), comments: [Comment] = [], recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), commentCount: Int = 0) {
        
        self.caption = caption
        self.timeStamp = timeStamp
        self.comments = comments
        self.recordID = recordID
        self.commentCount = commentCount
        self.photo = photo
    }
    
    init?(ckRecord: CKRecord) {
        do {
            guard let caption = ckRecord[PostConstants.captionKey] as? String,
                let timeStamp = ckRecord[PostConstants.timeStampKey] as? Date,
                let photoAsset = ckRecord[PostConstants.photoKey] as? CKAsset,
                let commentCount = ckRecord[PostConstants.commentCountKey] as? Int
                else { return nil }
            
            let photoData = try Data(contentsOf: photoAsset.fileURL)
            self.caption = caption
            self.timeStamp = timeStamp
            self.photoData = photoData
            self.recordID = ckRecord.recordID
            self.commentCount = commentCount
            self.comments = []
        } catch {
            print("There was an error with photoData : \(error.localizedDescription)")
            return nil
        }
    }
}

extension CKRecord {
    convenience init(post: Post) {
        self.init(recordType: PostConstants.postKey, recordID: post.recordID)
        setValue(post.caption, forKey: PostConstants.captionKey)
        setValue(post.timeStamp, forKey: PostConstants.timeStampKey)
        setValue(post.imageAsset, forKey: PostConstants.photoKey)
        setValue(post.commentCount, forKey: PostConstants.commentCountKey)
    }
}

extension Post: SearchableRecord {
    func matches(searchTerm: String) -> Bool {
        if caption.lowercased().contains(searchTerm.lowercased()) {
            return true
        } else {
            for comment in comments {
                if comment.matches(searchTerm: searchTerm) {
                    return true
                }
            }
        }
        return false
    }
}

enum PostConstants {
    static let postKey = "Post"
    static let captionKey = "caption"
    static let timeStampKey = "timeStamp"
    static let commentsKey = "comments"
    static let photoKey = "photo"
    static let commentCountKey = "commentCount"
}
