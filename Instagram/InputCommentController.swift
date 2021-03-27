//
//  InputCommentController.swift
//  Instagram
//
//  Created by 徳富博 on 2021/03/24.
//

import UIKit
import Firebase

class InputCommentController: UIViewController {
    var postData: PostData!
    
    @IBOutlet weak var inputCommentText: UITextField!
    @IBAction func CommentUpButton(_ sender: Any) {
        if let commentText = inputCommentText.text, !commentText.isEmpty {
        // コメントを保存するを更新する
        if let myid = Auth.auth().currentUser?.uid {
            // 更新データを作成する
                var updateValue: FieldValue
                let name = Auth.auth().currentUser!.displayName!
                let commentText = inputCommentText.text!
                let comment = "\(name): \(commentText)"
                let commentDic = [comment] as [String]
//                postData.comment += commentDic
                updateValue = FieldValue.arrayUnion(commentDic)
                // likesに更新データを書き込む
                let postRef = Firestore.firestore().collection(Const.PostPath).document(postData.id)
                postRef.updateData(["comment": updateValue])
        
            self.dismiss(animated: true, completion: nil)
        }
        }else{
            return
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
