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
import GooglePlaces

class ProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    //// Edit School pluggings
    @IBOutlet weak var universityBtn: UIButton!
    @IBOutlet weak var degreeSubjectBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var classRoomTableView: UITableView!
    @IBOutlet weak var myClassesTableView: UITableView!
    @IBOutlet weak var addClassBtn: UIButton!
    /// finish edit school pluggins
    
    // edit account pluggins
    @IBOutlet weak var editAcctView: UIView!
    @IBOutlet weak var fNameTxt: UITextField!
    @IBOutlet weak var lNameTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var schoolEmail: UITextField!
    @IBOutlet weak var major: UITextField!
    @IBOutlet weak var classification: UITextField!
    @IBOutlet weak var phoneNumberTxt: UITextField!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var editViewBtn: UIButton!
    @IBOutlet weak var changePicBtn: UIButton!
    @IBOutlet weak var displaySegControBtn: UISegmentedControl!
    @IBOutlet weak var classSearchView: UITableView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    @IBOutlet weak var schoolInstructionsLabel: UILabel!
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var scheduleTableView: UITableView!
    @IBOutlet weak var tutorEdit: UIView!
    @IBOutlet weak var addScheduleStackView: UIStackView!
    @IBOutlet weak var addPlaceStackView: UIStackView!
    // date picker
    @IBOutlet weak var dayPicker: UIPickerView!
    @IBOutlet weak var hourPicker: UIPickerView!
    @IBOutlet weak var minPicker: UIPickerView!
    @IBOutlet weak var amPickr: UIPickerView!
    
    @IBOutlet weak var meetUpLocationsTable: UITableView!
    @IBOutlet weak var tutorEditLbl: UILabel!
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
    var Id: String?
    var classView = Bool()
    var schedules = [String]()
    var schedule = String()
    var dayArray = [String](); var hourArr = [String](); var minArr = [String](); var amArr = [String]()
    var chosenLocationsArr = [String]() ; var day = "Sunday"; var hour = "12"; var min = "00"; var am = "Am"
    var place = Place()
    var placeArr = [Place](); var placeesDict = [String:[String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        picker.delegate = self
        let storage = Storage.storage().reference(forURL: "gs://hmwrkme.appspot.com")
        userStorage = storage.child("Students")
        
        // Show registration completion
        if classView {
            editView.isHidden = false
        } else {
            editView.isHidden = true
        }
        // setup date picker
        let currentDate: Date = Date()
        tutorEdit.isHidden = true
        setUpSchdArr()
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
        dismissKeyboard()
        
    }
 
     
    @IBAction func selectUniPrsd(_ sender: Any) {
        tableViewTitleCounter = 0
        headerTitle = "Select University"
        degreeSubjectBtn.isEnabled = false
        degreeSubjectBtn.setTitleColor(UIColor.gray, for: .normal); degreeSubjectBtn.setTitle("List Subject", for: .normal)
        universityBtn.isEnabled = false ; universityBtn.setTitleColor(UIColor.gray, for: .normal); universityBtn.setTitle("List University", for: .normal)
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
            userName.isHidden = false
            cancelBtn.isHidden = true
            if imageChangeCheck {
                saveImage()
            }
            editAcctView.isHidden = true
            setPersonalInfoChange()
            view.endEditing(true)
            addClassBtn.isHidden = true
        } else {
            /// second time pressed
            editViewBtn.setTitle("Save", for: .normal)
            changePicBtn.isHidden = false
            displaySegControBtn.isHidden = false
            classSearchView.isHidden = false
            userName.isHidden = true
            cancelBtn.isHidden = false
            cancelBtn.isHidden = false
            displaySegControBtn.selectedSegmentIndex = 0
            addClassBtn.isHidden = true
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
        userName.isHidden = false
        cancelBtn.isHidden = true
        view.endEditing(true)
        editAcctView.isHidden = true
        editIntChecker = 0
    }
    
    @IBAction func addClassPrsd(_ sender: Any) {
        editView.isHidden = false
    }
    
    @IBAction func tutorRegistration(_ sender: Any) {
        editView.isHidden = true
        tutorEdit.isHidden = false
    }
    
    // Done button for editView pressed
    @IBAction func signUpEditDone(_ sender: Any) {
        editView.isHidden = true
        tutorEdit.isHidden = true
    }
    
    @IBAction func backToEditView(_ sender: Any) {
        editView.isHidden = false
        tutorEdit.isHidden = true
    }
    
    @IBAction func nextToAddLoc(_ sender: Any) {
        tutorEditLbl.text = "Meet up locations"
        addScheduleStackView.isHidden = true
        addPlaceStackView.isHidden = false
    }
    
    @IBAction func backToSchdl(_ sender: Any) {
        tutorEditLbl.text = "My Weekly Schedule"
        addPlaceStackView.isHidden = true
        addScheduleStackView.isHidden = false
    }
    
    @IBAction func saveTutor(_ sender: Any) {
        
        if major.text != nil && classification.text != nil && schoolEmail.text != nil {
            let parameters = [
                "schedule": self.schedules,
                "meetUpLocations":placeesDict,
                "major":major.text ?? "",
                "classification":classification.text ?? "",
                "schoolEmail":schoolEmail.text ?? ""] as [String : Any]
            
            
            ref.child("Students").child((Auth.auth().currentUser?.uid)!).child("TutorProfile").updateChildValues(parameters)
            ref.child("Tutors").child((Auth.auth().currentUser?.uid)!).setValue(parameters)
        } else {
            // display warning
        }
        
        tutorEdit.isHidden = true
    }
    
    
    @IBAction func addPaymentMethod(_ sender: Any) {
        addCard()
    }
    
    @IBAction func setSchedulePrsd(_ sender: Any) {
        schedules.append(schedule)
        scheduleTableView.reloadData()
        schedule.removeAll()
    }
    
    
    @IBAction func autocompleteClicked(_ sender: UIButton) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    func logout() {
        if Auth.auth().currentUser != nil {
            do {
                try? Auth.auth().signOut()
            } catch  {
            }
        }
    }
    
    func setUpSchdArr(){
        schedule = "Sundays 12:00 am"
        dayArray = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
        hourArr = ["12","1","2","3","4","5","6","7","8","9","10","11"]
        minArr = ["00","01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43","44","45","46","47","48","49","50","51","52","53","54","55","56","57","58","59"]
        amArr = ["Am","Pm"]
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
    
    func addCard() {
        let addCardViewController = STPAddCardViewController()
        addCardViewController.delegate = self
        
        // Present add card view controller
        let navigationController = UINavigationController(rootViewController: addCardViewController)
        present(navigationController, animated: true)
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
                } //email
                if let email = myclass["email"] as? String {
                    UserDefaults.standard.set(email, forKey: "email")
                }
                if let lname = myclass["lName"] as? String {
                    UserDefaults.standard.set(lname, forKey: "lName")
                    self.lNameTxt.text = lname
                    self.emailTxt.text = (Auth.auth().currentUser?.email)!
                    name += " " + lname + "\n " + (Auth.auth().currentUser?.email)!
                }
                if let id = myclass["uid"] as? String {
                    UserDefaults.standard.set(id, forKey: "userId")
                    self.Id = id
                } //customerID
                
                if let customer = myclass["customerId"] as? String {
                    UserDefaults.standard.set(customer, forKey: "customerId")
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
        
        if tableView == scheduleTableView {
            if (editingStyle == UITableViewCellEditingStyle.delete) {
                schedules.remove(at: indexPath.row)
                scheduleTableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
        
        if tableView == meetUpLocationsTable {
            if (editingStyle == UITableViewCellEditingStyle.delete) {
                placeArr.remove(at: indexPath.row)
                meetUpLocationsTable.deleteRows(at: [indexPath], with: .fade)
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
        } else if tableView == scheduleTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleCell", for: indexPath)
            cell.textLabel!.text = schedules[indexPath.row]
            return cell
        } else if tableView == meetUpLocationsTable {
            let cell = tableView.dequeueReusableCell(withIdentifier: "meetUpLocation", for: indexPath)
            cell.textLabel!.text = placeArr[indexPath.row].name
            return cell
        }
        else {
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
        } else if tableView == scheduleTableView {
            return schedules.count
        } else if tableView == meetUpLocationsTable {
            return placeArr.count
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
        if tableView == scheduleTableView {
            return "My weekly schedul"
        }
        if tableView == meetUpLocationsTable {
            return "Meet up locations"
        }
        if tableView == myClassesTableView {
            return "My Classes"
        } else {
            return ""
        }
    }
    
    
}

extension ProfileVC: STPAddCardViewControllerDelegate {
    
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        dismiss(animated: true)
    }
    
    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateToken token: STPToken, completion: @escaping STPErrorBlock) {
        
        
        StripeClient.shared.addCard(with: token, amount: 000) { result in
            switch result {
            // 1
            case .success:
                completion(nil)
                
                self.dismiss(animated: true)
            // 2
            case .failure(let error):
                completion(error)
            }
        }
        
    }
}

extension ProfileVC: GMSAutocompleteViewControllerDelegate {
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        self.place.name = place.name
        self.place.coordinates = "\(place.coordinate)"
        self.placeArr.append(self.place)
        let arr = ["\(place.coordinate.latitude) * \(place.coordinate.longitude)", place.name]
        placeesDict["\(place.placeID)"] = arr
        meetUpLocationsTable.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }

}


extension ProfileVC:  UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView == dayPicker {
            return 1
        } else if pickerView == hourPicker {
            return 1
        } else if pickerView == minPicker {
            return 1
        } else if pickerView == amPickr {
            return 1
        } else {
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == dayPicker {
            return dayArray.count
        } else if pickerView == hourPicker {
            return hourArr.count
        } else if pickerView == minPicker {
            return minArr.count
        } else if pickerView == amPickr {
            return amArr.count
        } else {
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == dayPicker {
            return dayArray[row]
        } else if pickerView == hourPicker {
            return hourArr[row]
        } else if pickerView == minPicker {
            return minArr[row]
        } else if pickerView == amPickr {
            return amArr[row]
        } else {
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == dayPicker {
            day = dayArray[row]
            schedule = (day+"s "+hour+":"+min+" "+am)
        } else if pickerView == hourPicker {
            hour = hourArr[row]
            schedule = (day+"s "+hour+":"+min+" "+am)
        } else if pickerView == minPicker {
            min = minArr[row]
            schedule = (day+"s "+hour+":"+min+" "+am)
        } else if pickerView == amPickr {
            am = amArr[row]
            schedule = (day+"s "+hour+":"+min+" "+am)
        }
    }
}
