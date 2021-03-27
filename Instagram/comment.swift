//
//  comment.swift
//  Instagram
//
//  Created by 徳富博 on 2021/03/26.
//

import Foundation
import Firebase

class Comment: NSObject {
    var id: String
    var name: String?
    var postData_id: String?
    var comment: String?
    
   

    init(document: QueryDocumentSnapshot) {
        self.id = document.documentID

        let postDic = document.data()

        self.name = postDic["name"] as? String

        self.postData_id = postDic["postData_id"] as? String

        self.comment = postDic["comment"] as? String
        
    }
}



