//
//  Comment.swift
//  Continuum
//
//  Created by Chris Anderson on 12/11/19.
//  Copyright © 2019 trevorAdcock. All rights reserved.
//

import Foundation
import CloudKit

class Comment {
    let text: String
    let timeStamp: Date
    
    weak var post: Post?
    
    let recordID: CKRecord.ID
    
    var postReference: CKRecord.Reference? {
        guard let post = post else { return nil }
        return CKRecord.Reference(recordID: post.recordID, action: .deleteSelf)
    }
    
    init(text: String, post: Post, timeStamp: Date = Date(), recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.text = text
        self.post = post
        self.timeStamp = timeStamp
        self.recordID = recordID
    }
    
    convenience init?(ckRecord: CKRecord, post: Post) {
        guard let text = ckRecord[CommentConstants.textKey] as? String,
            let timeStamp = ckRecord[CommentConstants.timeStampKey] as? Date
            else { return nil }
        
        self.init(text: text, post: post, timeStamp: timeStamp, recordID: ckRecord.recordID)
    }
}

extension CKRecord {
    convenience init? (comment: Comment) {
        self.init(recordType: CommentConstants.commentKey, recordID: comment.recordID)
        self.setValue(comment.postReference, forKey: CommentConstants.postReferenceKey)
        self.setValue(comment.text, forKey: CommentConstants.textKey)
        self.setValue(comment.timeStamp, forKey: CommentConstants.timeStampKey)
    }
}

extension Comment: SearchableRecord {
    func matches(searchTerm: String) -> Bool {
        return text.lowercased().contains(searchTerm.lowercased())
    }
}

enum CommentConstants {
    static let commentKey = "Comment"
    static let textKey = "text"
    static let timeStampKey = "timeStamp"
    static let postReferenceKey = "post"
}
