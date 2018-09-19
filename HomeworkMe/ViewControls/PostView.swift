//
//  PosView.swift
//  HomeworkMe
//
//  Created by Radiance Okuzor on 8/13/18.
//  Copyright © 2018 RayCo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import Stripe
import SquarePointOfSaleSDK


class PostView: UIViewController {
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var firstAndLastName: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var classAndRatingsLable: UILabel!
    @IBOutlet weak var dislikeBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var purchaseBtn: UIButton!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var leaveAcommentBtn: UIButton!
    @IBOutlet weak var viewCmntsBtn: UIButton!
    @IBOutlet weak var scheduleTableView: UITableView! //notesTableView
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    @IBOutlet weak var notesTableView: UITableView!
    var postObject = Post()
    var functions = CommonFunctions() 
    var userStorage: StorageReference!
    var studentInClass: Bool!
    var schedules = [String](); var selectSchedule = [String]()
    var disLikers = [String](); var likers = [String]()
    var authorFname = "" ; var authorLname = " " 
    let ref = Database.database().reference()
    lazy var functions2 = Functions.functions()
    
    // stripe payment setup
     

    override func viewDidLoad() {
        super.viewDidLoad()
        let storage = Storage.storage().reference(forURL: "gs://hmwrkme.appspot.com")
        userStorage = storage.child("Students")
        fetchBio()
        editImage()
    }
 
    @IBAction func backPrsd(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func viewComments(_ sender: Any) {
        if viewCmntsBtn.currentTitle == "📃" {
            notesTableView.isHidden = false
            scheduleTableView.isHidden = true
            viewCmntsBtn.setTitle("Schedule", for: .normal)
        } else {
            notesTableView.isHidden = true
            scheduleTableView.isHidden = false
            viewCmntsBtn.setTitle("📃", for: .normal)
        }
    }
    
    @IBAction func leavACommentPrsd(_ sender: Any) {
        let userId = Auth.auth().currentUser?.uid
        let ref = Database.database().reference()
        let dateString = String(describing: Date())
        if let fname = UserDefaults.standard.object(forKey: "fName") as? String {
            authorFname = fname
        }
        if let lname = UserDefaults.standard.object(forKey: "lName") as? String {
            authorLname = lname
        }
        let alert = UIAlertController(title: "Comment", message: "leave a comment", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter comment here..."
        }
        let ok = UIAlertAction(title: "Ok", style: .default) { (resp) in
            let name = self.authorFname + " " + self.authorLname
            let tt = alert.textFields?.first?.text
            let parameters: [String:String] = ["note":tt!,
                                               "time":dateString,
                                               "author":name,
                                               "key":userId!]
            
            ref.child("Posts").child(self.postObject.uid!).child("comments").child(userId!).updateChildValues(parameters)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(ok); alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func likers(_ sender: Any) {
        let userId = Auth.auth().currentUser?.uid
        let ref = Database.database().reference()
        if likers.contains(userId!) {
            print("Already liked")
        } else {
            let parameters: [String:String] = [userId! : userId!]
            
            ref.child("Posts").child(postObject.uid!).child("likers").updateChildValues(parameters)
            likers.append(userId!)
            self.likeBtn.setTitle("\(likers.count) Likes", for: .normal)
        }
        if disLikers.contains(userId!) {
            ref.child("Posts").child(postObject.uid!).child("disLikers").child(userId!).removeValue()
            let indx = self.disLikers.index(of: userId!)
            disLikers.remove(at: indx!)
            likers.append(userId!)
            self.likeBtn.setTitle("\(likers.count) Likes", for: .normal)
        }
    }
    
    @IBAction func purchesPrsd(_ sender: Any) {
        addCard()
        /*
        if !selectSchedule.isEmpty {
            if selectSchedule.count > 0 {
                let alert2 = UIAlertController(title: "Pay with", message: "", preferredStyle: .alert)
                let square = UIAlertAction(title: "Cash", style: .default) { (response) in
                    self.addCard()
                }
                alert2.addAction(square)
                present(alert2, animated: true, completion: nil)
                
            }
        } else {
            let alert = UIAlertController(title: "Missing Schedule", message: "Please select a date to meet up", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true , completion: nil)
        }
         */
    }
    
    @IBAction func disLikers(_ sender: Any) {
        let userId = Auth.auth().currentUser?.uid
        let ref = Database.database().reference()
        if disLikers.contains(userId!) {
            print("already disliked")
        } else {
            let parameters: [String:String] = [userId! : userId!]
            
            ref.child("Posts").child(postObject.uid!).child("disLikers").updateChildValues(parameters)
            self.disLikers.append(userId!)
            self.dislikeBtn.setTitle("\(disLikers.count) Dislike", for: .normal)
        }
        if likers.contains(userId!) {
            ref.child("Posts").child(postObject.uid!).child("likers").child(userId!).removeValue()
            let indx = self.likers.index(of: userId!)
            likers.remove(at: indx!)
            self.disLikers.append(userId!)
            self.dislikeBtn.setTitle("\(disLikers.count) Dislike", for: .normal)
        }
    }
    
    var storageRef: Storage {
        return Storage.storage()
    }
    
 // stripe implementation functions
    func addCard() {
        let addCardViewController = STPAddCardViewController()
        addCardViewController.delegate = self
        
        // Present add card view controller
        let navigationController = UINavigationController(rootViewController: addCardViewController)
        present(navigationController, animated: true)
    }
 
    
    // end of stripe payment implementation 
    func editImage(){
        profilePic.layer.borderWidth = 1
        profilePic.layer.masksToBounds = false
        profilePic.layer.borderColor = UIColor.black.cgColor
        profilePic.layer.cornerRadius = profilePic.frame.height/2
        profilePic.clipsToBounds = true
    }
 
    
    func fetchBio() {
        postTitle.text = postObject.title! + "\n" + functions.getTimeSince(date: postObject.timeStamp!)
        postTitle.numberOfLines = 0
        self.likeBtn.setTitle("\(postObject.likers.count)👍🏾", for: .normal)
        self.dislikeBtn.setTitle("\(postObject.disLikers.count)👎🏾", for: .normal)
        if postObject.studentInClas{
            self.classAndRatingsLable.text = "Student in class"
        } else {
            self.classAndRatingsLable.text = "Tutor of class"
        }
        self.storageRef.reference(forURL: postObject.postPic).getData(maxSize: 1 * 1024 * 1024, completion: { (imgData, error) in
            if error == nil {
                if let data = imgData{
                    self.profilePic.image = UIImage(data: data)
                    self.activitySpinner.stopAnimating()
                }
            }
            else {
                print(error?.localizedDescription)
                self.activitySpinner.stopAnimating()
            }
        })
    }
}

extension PostView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == scheduleTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "selecScheduleCell", for: indexPath)
            if selectSchedule.contains(postObject.schedule[indexPath.row]) {
                let indx = selectSchedule.index(of: postObject.schedule[indexPath.row])
                selectSchedule.remove(at: indx!)
                cell.accessoryType = .none
            } else {
                cell.accessoryType = .checkmark
                selectSchedule.append(postObject.schedule[indexPath.row])
            }
        }
        if tableView == notesTableView {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "notesCell", for: indexPath)
        }
    }
 
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == scheduleTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "selecScheduleCell", for: indexPath)
            cell.textLabel!.text = postObject.schedule[indexPath.row]
            cell.textLabel?.numberOfLines = 0
            return cell
        }
        if tableView == notesTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "notesCell", for: indexPath)
            cell.textLabel?.text = postObject.notes[indexPath.row].note + "\n" + postObject.notes[indexPath.row].author
            cell.textLabel?.numberOfLines = 0
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "notesCell", for: indexPath)
            cell.textLabel?.text = postObject.notes[indexPath.row].note + "\n" + postObject.notes[indexPath.row].author
            cell.textLabel?.numberOfLines = 0
            return cell
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == scheduleTableView{
            return postObject.schedule.count
        }
        if tableView == notesTableView {
            return postObject.notes.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == scheduleTableView{
            return "Select Schedule"
        }
        else {
            return "Notes"
        }
    }
 
}

extension PostView: STPAddCardViewControllerDelegate {
    
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateToken token: STPToken, completion: @escaping STPErrorBlock) {
//        functions2.httpsCallable("charge").call { (<#HTTPSCallableResult?#>, <#Error?#>) in
//            <#code#>
//        }
        StripeClient.shared.completeCharge(with: token, amount: 200) { result in
            switch result {
            // 1
            case .success:
                completion(nil)
                
                let alertController = UIAlertController(title: "Congrats", message: "Your payment was successful!", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
                    self.navigationController?.popViewController(animated: true)
                })
                alertController.addAction(alertAction)
                self.present(alertController, animated: true)
            // 2
            case .failure(let error):
                completion(error)
            }
        }
    }
}


