//
//  HomeViewController.swift
//  Instagram
//
//  Created by 徳富博 on 2021/02/20.
//

import UIKit
import Firebase

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    // 投稿データを格納する配列
    var postArray: [PostData] = []
    //コメント用配列
//    var commentArray: [Comment] = []
    // Firestoreのリスナー
    var listener: ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // カスタムセルを登録する
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")
        // ログイン済みか確認
        if Auth.auth().currentUser != nil {
            // listenerを登録して投稿データの更新を監視する
            let postsRef = Firestore.firestore().collection(Const.PostPath).order(by: "date", descending: true)
            listener = postsRef.addSnapshotListener() { (querySnapshot, error) in
                if let error = error {
                    print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                    return
                }
                // 取得したdocumentをもとにPostDataを作成し、postArrayの配列にする。
                self.postArray = querySnapshot!.documents.map { document in
                    print("DEBUG_PRINT: document取得 \(document.documentID)")
                    let postData = PostData(document: document)
                    return postData
                }
                // TableViewの表示を更新する
                print("road")
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("DEBUG_PRINT: viewWillDisappear")
        // listenerを削除して監視を停止する
        listener?.remove()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        cell.setPostData(postArray[indexPath.row])
        // セル内のボタンのアクションをソースコードで設定する
        cell.likeButton.addTarget(self, action:#selector(handleButton(_:forEvent:)), for: .touchUpInside)
        cell.commentUpButton.addTarget(self, action:#selector(handlecommentUpButton(_:forEvent:)), for: .touchUpInside)
        
        return cell
    }
    // セル内のボタンがタップされた時に呼ばれるメソッド
        @objc func handleButton(_ sender: UIButton, forEvent event: UIEvent) {
            print("DEBUG_PRINT: likeボタンがタップされました。")

            // タップされたセルのインデックスを求める
            let touch = event.allTouches?.first
            let point = touch!.location(in: self.tableView)
            let indexPath = tableView.indexPathForRow(at: point)

            // 配列からタップされたインデックスのデータを取り出す
            let postData = postArray[indexPath!.row]

            // likesを更新する
            if let myid = Auth.auth().currentUser?.uid {
                // 更新データを作成する
                var updateValue: FieldValue
                if postData.isLiked {
                    // すでにいいねをしている場合は、いいね解除のためmyidを取り除く更新データを作成
                    updateValue = FieldValue.arrayRemove([myid])
                } else {
                    // 今回新たにいいねを押した場合は、myidを追加する更新データを作成
                    updateValue = FieldValue.arrayUnion([myid])
                }
                // likesに更新データを書き込む
                let postRef = Firestore.firestore().collection(Const.PostPath).document(postData.id)
                postRef.updateData(["likes": updateValue])
            }
        }
   
    
    @objc func handlecommentUpButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: likeボタンがタップされました。")

        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)

        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        
        //画面をコメント入力欄にとばす
        let inputCommentController = self.storyboard?.instantiateViewController(withIdentifier: "toInputComment") as! InputCommentController
        print(inputCommentController)
        inputCommentController.postData = postData
        present(inputCommentController, animated: true)
       

    }
}
