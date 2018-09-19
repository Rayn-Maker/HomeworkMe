//
//  ProfileVC.swift
//  HomeworkMe
//
//  Created by Radiance Okuzor on 8/2/18.
//  Copyright © 2018 RayCo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import Stripe

class ProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    //// Edit School pluggings
    @IBOutlet weak var universityBtn: UIButton!
    @IBOutlet weak var degreeSubjectBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var classRoomTableView: UITableView!
    @IBOutlet weak var myClassesTableView: UITableView!
    /// finish edit school pluggins
    
    // edit account pluggins
    @IBOutlet weak var editAcctView: UIView!
    @IBOutlet weak var fNameTxt: UITextField!
    @IBOutlet weak var lNameTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var phoneNumberTxt: UITextField!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var editViewBtn: UIButton!
    @IBOutlet weak var changePicBtn: UIButton!
    @IBOutlet weak var displaySegControBtn: UISegmentedControl!
    @IBOutlet weak var classSearchView: UITableView!
    @IBOutlet weak var classChoiceBtnView: UIStackView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    
    // finish edit account pluggins
    
    // edit school var
    var handle: DatabaseHandle?; var handle2: DatabaseHandle?
    var commonFunctions = CommonFunctions()
    var uni_sub_array = [FetchObject](); var subjectArray = [FetchObject](); var classArray = [FetchObject](); var myClassesArr = [FetchObject](); var uniArray = [FetchObject]()
    var subjectID: String?; var uniID: String?
    var uniBtnOn = true; var subBtnOn = false; var classBtnOn = false;
    var subjectsDict: [String: AnyObject]?; var classeDict: [String: AnyObject]?
    var tableViewTitleCounter: Int = 0 // helps track where the search is
    var headerTitle: String = "Select School"
    var editIntChecker = 0
    let picker = UIImagePickerController()
    var userStorage: StorageReference!
    var functions = CommonFunctions()
    var ref: DatabaseReference!
    var imageChangeCheck = false
    // finish edit school variable
    
    // edit account variables
    
    // finish edit account variables
     
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        picker.delegate = self
        let storage = Storage.storage().reference(forURL: "gs://hmwrkme.appspot.com")
        userStorage = storage.child("Students")
        dismissKeyboard()
        ref = Database.database().reference()
        myClassesTableView.estimatedRowHeight = 35
        myClassesTableView.rowHeight = UITableViewAutomaticDimension
        classRoomTableView.estimatedRowHeight = 35
        classRoomTableView.rowHeight = UITableViewAutomaticDimension
        degreeSubjectBtn.isEnabled = false
        degreeSubjectBtn.setTitleColor(UIColor.gray, for: .normal)
        activitySpinner.startAnimating()
        universityBtn.isEnabled = false ; universityBtn.setTitleColor(UIColor.gray, for: .normal)
        fetchMyClassKey()
        fetchUni()
        if let pictureDat = UserDefaults.standard.object(forKey: "pictureData") as? Data {
            profilePic.image = UIImage(data: pictureDat)
        }
        editImage()
    }
 
     
    @IBAction func selectUniPrsd(_ sender: Any) {
        tableViewTitleCounter = 0
        headerTitle = "Select University"
        degreeSubjectBtn.isEnabled = false
        degreeSubjectBtn.setTitleColor(UIColor.gray, for: .normal); degreeSubjectBtn.setTitle("Subject", for: .normal)
        universityBtn.isEnabled = false ; universityBtn.setTitleColor(UIColor.gray, for: .normal); universityBtn.setTitle("University", for: .normal)
        uni_sub_array = uniArray
        classRoomTableView.reloadData()
        uniBtnOn = true; subBtnOn = false
    }
    
    @IBAction func selectSubPrsd(_ sender: Any) {
        headerTitle = "Select Subject"
        tableViewTitleCounter = 1
        degreeSubjectBtn.setTitleColor(UIColor.gray, for: .normal); degreeSubjectBtn.setTitle("Subject", for: .normal); degreeSubjectBtn.isEnabled = false
        uni_sub_array = subjectArray
        classRoomTableView.reloadData()
        uniBtnOn = false; subBtnOn = true
    }
    
    @IBAction func displayViewChanger(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            editAcctView.isHidden = true
        }
        if sender.selectedSegmentIndex == 1{
            editAcctView.isHidden = false
        }
    }
    
    @IBAction func editViewPrsd(_ sender: Any) {
        // first time pressed
        editIntChecker += 1
        if editIntChecker % 2 == 0 {
            editViewBtn.setTitle("Edit", for: .normal)
            changePicBtn.isHidden = true
            displaySegControBtn.isHidden = true
            classSearchView.isHidden = true
            classChoiceBtnView.isHidden = true
            userName.isHidden = false
            cancelBtn.isHidden = true
            if imageChangeCheck {
                saveImage()
            }
            editAcctView.isHidden = true
            setPersonalInfoChange()
            view.endEditing(true)
        } else {
            /// second time pressed
            editViewBtn.setTitle("Save", for: .normal)
            changePicBtn.isHidden = false
            displaySegControBtn.isHidden = false
            classSearchView.isHidden = false
            classChoiceBtnView.isHidden = false
            userName.isHidden = true
            cancelBtn.isHidden = false
            cancelBtn.isHidden = false
            displaySegControBtn.selectedSegmentIndex = 0
        }
    }
    
    @IBAction func changePicPrsd(_ sender: Any) {
        changePicBtn.setTitle("Change", for: .normal)
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
        imageChangeCheck = true
    }
    
    @IBAction func signOutPressed(_ sender: Any) {
        logout()
        performSegue(withIdentifier: "logout", sender: self)
    }
    
    @IBAction func cancelSavePrsd(_ sender: Any) {
        editViewBtn.setTitle("Edit", for: .normal)
        changePicBtn.isHidden = true
        displaySegControBtn.isHidden = true
        classSearchView.isHidden = true
        classChoiceBtnView.isHidden = true
        userName.isHidden = false
        cancelBtn.isHidden = true
        view.endEditing(true)
        editAcctView.isHidden = true
        editIntChecker = 0
    }
    
    @IBAction func editPayment(_ sender: Any) {
        // Setup customer context
//        let customerContext = STPCustomerContext(keyProvider: MyKeyProvider().shared())
//
//        // Setup payment methods view controller
//        let paymentMethodsViewController = STPPaymentMethodsViewController(configuration: STPPaymentConfiguration.shared(), theme: STPTheme.default(), customerContext: customerContext, delegate: self)
//
//        // Present payment methods view controller
//        let navigationController = UINavigationController(rootViewController: paymentMethodsViewController)
//        present(navigationController, animated: true)
    }
    
    func logout() {
        if Auth.auth().currentUser != nil {
            do {
                try? Auth.auth().signOut()
            } catch  {
            }
        }
    }
        
    func dismissKeyboard() { 
        let tap = UITapGestureRecognizer(target: self.view, action: Selector("endEditing:"))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.profilePic.image = image
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    var storageRef: Storage {
        return Storage.storage()
    }
    
    func setPersonalInfoChange(){
        let user = Auth.auth().currentUser
        if fNameTxt.text != nil || fNameTxt.text == "" {
            self.ref.child("Students").child(user!.uid).child("fName").setValue(fNameTxt.text)
        }
        if lNameTxt.text != nil || lNameTxt.text == "" {
            self.ref.child("Students").child(user!.uid).child("lName").setValue(lNameTxt.text)
        }
        if emailTxt.text != nil || emailTxt.text == "" {
            self.ref.child("Students").child(user!.uid).child("email").setValue(emailTxt.text)
        }
        if phoneNumberTxt.text != nil || phoneNumberTxt.text == "" {
            self.ref.child("Students").child(user!.uid).child("phoneNumber").setValue(phoneNumberTxt.text)
        }
    }
    
    func editImage(){
        profilePic.layer.borderWidth = 1
        profilePic.layer.masksToBounds = false
        profilePic.layer.borderColor = UIColor.black.cgColor
        profilePic.layer.cornerRadius = profilePic.frame.height/2
        profilePic.clipsToBounds = true
    }
    
    func deletValue(indexPathRow:Int) {
        let ref = Database.database().reference()
        let key = myClassesArr[indexPathRow].uid
        let uid = Auth.auth().currentUser?.uid
            // delete class from student and student from class
        ref.child("Students").child(uid!).child("Classes").child(key!).removeValue()
        ref.child("Classes").child(key!).child("Students").child(uid!).removeValue()
    }
    
    func saveImage() {
        let user = Auth.auth().currentUser
        let imageRef = self.userStorage.child("\(user?.uid ?? "").jpg")
        let data = UIImageJPEGRepresentation(self.profilePic.image!, 0.5)
        
        let uploadTask = imageRef.putData(data!, metadata: nil, completion: { (metadata, err) in
            if err != nil {
                print(err!.localizedDescription)
                self.present(self.functions.alertWithOk(errorMessagTitle: "Save Failed", errorMessage: err!.localizedDescription), animated: true, completion: nil)
                return
            } else {
                UserDefaults.standard.set(data, forKey: "pictureData")
            }
            
            imageRef.downloadURL(completion: { (url, er) in
                if er != nil {
                    print(er!.localizedDescription)
                }
                if let url = url {
                    self.ref.child("Students").child(user!.uid).child("pictureUrl").setValue(url.absoluteString)

                    
                }
            })
        })
        uploadTask.resume()
    }
   
    func fetchUni() {
        let ref = Database.database().reference()
        ref.child("Universities").queryOrderedByKey().observeSingleEvent(of: .value, with: { response in
            if response.value is NSNull {
                /// dont do anything
            } else {
                self.uni_sub_array.removeAll()
                let universities = response.value as! [String:AnyObject]
                for (_,b) in universities {
                    var university = FetchObject()
                    if let uid = b["uid"] {
                        university.uid = uid as? String
                    }
                    if let title = b["name"] {
                        university.title = title as? String
                    }
                    if let subDict = b["Subjects"]  {
                        university.dict = subDict as? [String : AnyObject]
                       
                    }
                    self.uni_sub_array.append(university)
                }
                self.classRoomTableView.reloadData()
            }
        })
    }
    
    func fetchClass(subKey:String) {
        let ref = Database.database().reference()
        ref.child("Subjects").child(subKey).queryOrderedByKey().observeSingleEvent(of: .value, with: { response in
            if response.value is NSNull {
                /// dont do anything
            } else {
//                self.uni_sub_array.removeAll()
                let universities = response.value as! [String:AnyObject]
                if let dict =  universities["Classes"] as? [String : AnyObject] {
                    self.fetchSub(uniKey: self.subjectID!,dictCheck: dict)
                    self.classeDict = universities
                }
            }
        })
    }
    
    func fetchMyClassKey() {
        let ref = Database.database().reference()
        let uid = Auth.auth().currentUser?.uid
        handle2 = ref.child("Students").child(uid!).queryOrderedByKey().observe( .value, with: { response in
            if response.value is NSNull {
                /// dont do anything
            } else {
                self.myClassesArr.removeAll()
                let myclass = response.value as! [String:AnyObject]
                var name = " "
                if let dict = myclass["Classes"] as? [String : AnyObject] {
                    self.fetchMyClass(dictCheck: dict)
                }
                if let fname = myclass["fName"] as? String {
                    UserDefaults.standard.set(fname, forKey: "fName")
                    name = fname
                    self.fNameTxt.text = fname
                }
                if let phone = myclass["phoneNumber"] as? String {
                    UserDefaults.standard.set(phone, forKey: "phoneNumber")
                    self.phoneNumberTxt.text = phone
                }
                if let lname = myclass["lName"] as? String {
                    UserDefaults.standard.set(lname, forKey: "lName")
                    self.lNameTxt.text = lname
                    self.emailTxt.text = (Auth.auth().currentUser?.email)!
                    name += " " + lname + "\n " + (Auth.auth().currentUser?.email)!
                }
                self.userName.text = name
                if let pictureURl = myclass["pictureUrl"] as? String {
                    UserDefaults.standard.set(pictureURl, forKey: "pictureUrl")
                    self.storageRef.reference(forURL: pictureURl).getData(maxSize: 1 * 1024 * 1024, completion: { (imgData, error) in
                    if error == nil {
                        if let data = imgData{
                            UserDefaults.standard.set(data, forKey: "pictureData")
                            self.profilePic.image = UIImage(data: data)
                        }
                    }
                    else {
                        print(error?.localizedDescription)
                    }
                })
              }
            }
        })
    }
    
    func fetchMyClass(dictCheck: [String:AnyObject]){
        let ref = Database.database().reference()
        handle = ref.child("Classes").queryOrderedByKey().observe( .value, with: { response in
            if response.value is NSNull {
                /// dont do anything \\\
            } else {
                self.myClassesArr.removeAll()
                let classes = response.value as! [String:AnyObject]
                for (a,_) in dictCheck {
                    for (c,b) in classes {
                        if a == c {
                            var classe = FetchObject()
                            if let uid = b["uid"] {
                                classe.uid = uid as? String
                            }
                            if let title = b["name"] {
                                classe.title = title as? String
                            }
                            self.myClassesArr.append(classe)
                        }
                    }
                }
                self.activitySpinner.stopAnimating()
                self.activitySpinner.isHidden = true 
                self.myClassesTableView.reloadData()
            }
        })
    }
    
    func fetchSub(uniKey:String, dictCheck: [String:AnyObject]) {
        let ref = Database.database().reference()
        if uniBtnOn {
        ref.child("Subjects").queryOrderedByKey().observeSingleEvent(of: .value, with: { response in
            if response.value is NSNull {
                /// dont do anything \\\
            } else {
                self.uni_sub_array.removeAll()
                let subjects = response.value as! [String:AnyObject]
                for (a,_) in dictCheck {
                    for (c,b) in subjects {
                        if a == c {
                            var subject = FetchObject()
                            if let uid = b["uid"] {
                                subject.uid = uid as? String
                            }
                            if let title = b["name"] {
                                subject.title = title as? String
                            }
                            self.uni_sub_array.append(subject)
                        }
                    }
                }
                self.classRoomTableView.reloadData()
            }
        })
        } else if subBtnOn {
            ref.child("Classes").queryOrderedByKey().observeSingleEvent(of: .value, with: { response in
                if response.value is NSNull {
                    /// dont do anything \\\
                } else {
                    self.uni_sub_array.removeAll()
                    let subjects = response.value as! [String:AnyObject]
                    for (a,_) in dictCheck {
                        for (c,b) in subjects {
                            if a == c {
                                var subject = FetchObject()
                                if let uid = b["uid"] {
                                    subject.uid = uid as? String
                                }
                                if let title = b["name"] {
                                    subject.title = title as? String
                                }
                                if let title = b["subjectID"] {
                                    subject.subjectID = title as? String
                                } //uniId
                                if let title = b["uniId"] {
                                    subject.uniID = title as? String
                                }
                                self.uni_sub_array.append(subject)
                            }
                        }
                    }
                    self.uniBtnOn = false; self.subBtnOn = false; self.classBtnOn = true
                    self.classRoomTableView.reloadData()
                }
            })
        }
    }
    
    ///////////////////////////////////////// edit Account \\\\\\\\\\\\\\\\\\\\\\

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "profileToClasses" {
            let vc = segue.destination as? MyClassRoomVC
            let indexPath = myClassesTableView.indexPathForSelectedRow
            vc?.fetchObject = myClassesArr[(indexPath?.row)!]
        }
    }
}

extension ProfileVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == classRoomTableView {
        if uniBtnOn {
            tableViewTitleCounter = 1
            uniID = uni_sub_array[indexPath.row].uid
            uniArray = uni_sub_array
            self.fetchSub(uniKey: uniID!, dictCheck: uni_sub_array[indexPath.row].dict!)
            uniBtnOn = false ; subBtnOn = true; classBtnOn = false
            headerTitle = uni_sub_array[indexPath.row].title!
            universityBtn.isEnabled = true ; universityBtn.setTitleColor(UIColor.black, for: .normal)
        } else if subBtnOn {
            tableViewTitleCounter = 2
            subjectID = uni_sub_array[indexPath.row].uid
            headerTitle = uni_sub_array[indexPath.row].title!
            subjectArray = uni_sub_array
            degreeSubjectBtn.isEnabled = true
            degreeSubjectBtn.setTitleColor(UIColor.black, for: .normal)
            self.fetchClass(subKey: subjectID!)
        } else if classBtnOn {
            // here add classes to the user and user to the class
            classArray = uni_sub_array
            let ref = Database.database().reference()
            let key = uni_sub_array[indexPath.row].uid
            let uid = Auth.auth().currentUser?.uid
            let parameters: [String:String] = [key! : key!]
            let parameters2: [String:String] = [uid! : uid!]
            if myClassesArr.contains(where: { $0.uid == key }) {
            } else {
                ref.child("Students").child(uid!).child("Classes").updateChildValues(parameters)
                ref.child("Classes").child(key!).child("Students").updateChildValues(parameters2)
            }
            // delete it from the class array
         }
        } else if tableView == myClassesTableView{
                self.performSegue(withIdentifier: "profileToClasses", sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if tableView == myClassesTableView {
            if (editingStyle == UITableViewCellEditingStyle.delete) {
                deletValue(indexPathRow: indexPath.row)
                myClassesArr.remove(at: indexPath.row)
                myClassesTableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == classRoomTableView {
             let cell = tableView.dequeueReusableCell(withIdentifier: "classRoomCells", for: indexPath)
             cell.textLabel!.text = uni_sub_array[indexPath.row].title
            cell.textLabel?.numberOfLines = 0
            if myClassesArr.contains(where: { $0.uid == uni_sub_array[indexPath.row].uid }) {
                // print a statement saying class already added
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            return cell
        } else if tableView == myClassesTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "myClasses", for: indexPath)
            cell.textLabel!.text = myClassesArr[indexPath.row].title
            cell.textLabel?.numberOfLines = 0
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "myClasses", for: indexPath)
            cell.textLabel!.text = myClassesArr[indexPath.row].title
            return cell
        }
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == classRoomTableView {
            return uni_sub_array.count
        } else if tableView == myClassesTableView {
            return myClassesArr.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == classRoomTableView {
            if tableViewTitleCounter == 0 {
                return headerTitle
            }
            if tableViewTitleCounter == 1 {
                return headerTitle
            }
            if tableViewTitleCounter == 2 {
                return headerTitle
            }
           
        }
        if tableView == myClassesTableView {
            return "My Classes"
        } else {
            return ""
        }
    }
}
