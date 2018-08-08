//
//  MyClassRoomVC.swift
//  HomeworkMe
//
//  Created by Radiance Okuzor on 8/7/18.
//  Copyright © 2018 RayCo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class MyClassRoomVC: UIViewController {

    @IBOutlet weak var addPostBtn: UIButton!
    @IBOutlet weak var classRoomLbl: UILabel!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var categoryBtn: UISegmentedControl!
    @IBOutlet weak var postsTableView: UITableView!
    
    var fetchObject = FetchObject()
    var postTitle = String()
    var handle: DatabaseHandle?; var handle2: DatabaseHandle?
    var myPostArr = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        postsTableView.estimatedRowHeight = 35
        postsTableView.rowHeight = UITableViewAutomaticDimension
        classRoomLbl.text = fetchObject.title
        fetchMyPostsKey()
    }
    
    @IBAction func addPostPrsd(_ sender: Any) {
        popupView.isHidden = false
        categoryBtn.isHidden = false
    }
    
    
    @IBAction func backPrsd(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func categoryPrsd(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            postTitle = fetchObject.title! + " Homework #() (Insert Teacher Name)"
            creatPost(cat: "Homework")
            self.categoryBtn.isHidden = true
        }
        if sender.selectedSegmentIndex == 1 {
            postTitle = fetchObject.title! + " Test (Insert Teacher Name)"
            creatPost(cat: "Test")
            self.categoryBtn.isHidden = true
        }
        if sender.selectedSegmentIndex == 2 {
            postTitle = fetchObject.title! + " Notes (Insert Teacher Name)" // put date here for the future
            creatPost(cat: "Notes")
            self.categoryBtn.isHidden = true
        }
        if sender.selectedSegmentIndex == 3 {
            postTitle = fetchObject.title! + " Tutoring (Insert Teacher Name)"
            creatPost(cat: "Tutoring")
            self.categoryBtn.isHidden = true
        }
        if sender.selectedSegmentIndex == 4 {
            postTitle = fetchObject.title! + " Other (Insert Teacher Name)"
            creatPost(cat: "Other")
            self.categoryBtn.isHidden = true
        }
    }
    
    func creatPost(cat:String){
        let ref = Database.database().reference()
        let authrName = Auth.auth().currentUser?.email
        let postKey = ref.child("Posts").childByAutoId().key
        let alert = UIAlertController(title: "New \(cat) Post", message: "", preferredStyle: .alert)
        alert.addTextField { (text) in
            text.text = self.postTitle
        }
        let post = UIAlertAction(title: "Post", style: .default) { (_) in
            guard let text = alert.textFields?.first?.text else { return }
            let dateString = String(describing: Date())
            let newTxt = text.replacingOccurrences(of: "(Insert Teacher Name)", with: "")
            let parameters = ["uid":postKey,
                              "name":newTxt,
                              "authorID":Auth.auth().currentUser?.uid,
                              "authorEmail": authrName,
                              "timeStamp":dateString,
                              "category":cat]
            let postParam = [postKey : parameters]
            let postParam2 = [postKey:postKey]
            ref.child("Posts").updateChildValues(postParam)
            ref.child("Classes").child(self.fetchObject.uid!).child("Posts").updateChildValues(postParam2)
            ref.child("Students").child((Auth.auth().currentUser?.uid)!).child("Posts").updateChildValues(postParam2)
            
            self.popupView.isHidden = true
            
            
        }
        let cancel = UIAlertAction(title: "Cancel", style: .destructive) { (_) in
            self.popupView.isHidden = true
        }
        alert.addAction(post); alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
        categoryBtn.isSelected = false 
    }
    
    func fetchMyPostsKey() {
        let ref = Database.database().reference()
        handle = ref.child("Classes").child(fetchObject.uid!).queryOrderedByKey().observe( .value, with: { response in
            if response.value is NSNull {
                /// dont do anything
            } else {
                let posts = response.value as! [String:AnyObject]
                if let dict = posts["Posts"] as? [String : AnyObject] {
                    self.fetchMyClass(dictCheck: dict)
                }
            }
        })
    }
    
    func fetchMyClass(dictCheck: [String:AnyObject]){
        let ref = Database.database().reference()
        handle2 = ref.child("Posts").queryOrderedByKey().observe( .value, with: { response in
            if response.value is NSNull {
                /// dont do anything \\\
            } else {
                self.myPostArr.removeAll()
                let posts = response.value as! [String:AnyObject]
                for (a,_) in dictCheck {
                    for (c,b) in posts {
                        if a == c {
                            let postss = Post()
                            if let uid = b["uid"] {
                                postss.uid = uid as? String
                            }
                            if let title = b["name"] {
                                postss.title = title as? String
                            }
                            if let authId = b["authorID"] {
                                postss.authorID = authId as? String
                            }
                            if let authEmal = b["authorEmail"] {
                                postss.author = authEmal as? String
                            }
                            if let tmStmp = b["timeStamp"] {
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss +zzzz"
                                let dat = dateFormatter.date(from: tmStmp as! String)
                                postss.timeStamp = dat
                            }
                            if let catgry = b["category"] {
                                postss.category = catgry as? String
                            }
                            self.myPostArr.append(postss)
                        }
                    }
                }
                self.postsTableView.reloadData()
            }
        })
    }
    
    func imageWithImage(image:UIImage,scaledToSize newSize:CGSize)-> UIImage {
        
        UIGraphicsBeginImageContext( newSize )
        image.draw(in: CGRect(x: 0,y: 0,width: newSize.width,height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!.withRenderingMode(.alwaysTemplate)
    }
    
}

extension MyClassRoomVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myPostArr.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postsCell", for: indexPath)
        let cellTxt = myPostArr[indexPath.row].title! + "\n~" + myPostArr[indexPath.row].author! + "  || \(myPostArr[indexPath.row].timeStamp!)"
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = cellTxt
//        cell.imageView?.image = #imageLiteral(resourceName: "manInWater")
        cell.imageView?.image = imageWithImage(image: UIImage(named: "manInWater")!, scaledToSize: CGSize(width: 20, height: 20))

        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
    }
}
