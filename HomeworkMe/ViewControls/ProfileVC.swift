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

class ProfileVC: UIViewController {
    
    @IBOutlet weak var universityBtn: UIButton!
    @IBOutlet weak var degreeSubjectBtn: UIButton!
    @IBOutlet weak var classRoomBtn: UIButton!
    @IBOutlet weak var classRoomTableView: UITableView!
    @IBOutlet weak var myClassesTableView: UITableView!
    var handle: DatabaseHandle?; var handle2: DatabaseHandle?
    var commonFunctions = CommonFunctions()
    var uni_sub_array = [fetchObject](); var subjectArray = [fetchObject](); var classArray = [fetchObject](); var myClassesArr = [fetchObject]()
    var subjectID: String?; var uniID: String?
    var uniBtnOn = false; var subBtnOn = false; var classBtnOn = false;
    var subjectsDict: [String: AnyObject]?; var classeDict: [String: AnyObject]?
     
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        fetchMyClassKey()
    }
    

    // Student Info
    @IBAction func addClassRoomPrsd(_ sender: Any) {
        let ref = Database.database().reference()
        let key = ref.child("Classes").childByAutoId().key
        
        present(commonFunctions.addToDirecotory(key: key, title: "New", message: "add classroom", paramKey: "uid", paramName: "name", foldername: "Classes", universityKey: uniID!, subjectKey:subjectID! ), animated: true, completion: nil)
    }
    
    @IBAction func selectUniPrsd(_ sender: Any) {
        fetch(folderName: "Universities")
        uniBtnOn = true ; subBtnOn = false
    }
    
    @IBAction func selectSubPrsd(_ sender: Any) {
        fetch(folderName: "Subjects")
        uniBtnOn = false ; subBtnOn = true
    }
    
    @IBAction func selectClass(_ sender: Any) {
        fetch(folderName: "Classes")
        uniBtnOn = true ; subBtnOn = false; classBtnOn = false
    }
    /// finish Student info
   
 
    
    func fetch(folderName:String) { 
        let ref = Database.database().reference()
        ref.child(folderName).queryOrderedByKey().observeSingleEvent(of: .value, with: { response in
            if response.value is NSNull {
                /// dont do anything
            } else {
                self.uni_sub_array.removeAll()
                let universities = response.value as! [String:AnyObject]
                for (_,b) in universities {
                    var university = fetchObject()
                    if let uid = b["uid"] {
                        university.uid = uid as? String
                    }
                    if let title = b["name"] {
                        university.title = title as? String
                    }
                    if let subDict = b["Subjects"]  {
                        university.dict = subDict as? [String : AnyObject]
                        self.subjectsDict = subDict as? [String : AnyObject]
                    }
                    if let classDict = b["Classes"] {
                        university.dict = classDict as? [String : AnyObject]
                        self.classeDict = classDict as? [String : AnyObject]
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
                self.uni_sub_array.removeAll()
                let universities = response.value as! [String:AnyObject]
                self.fetchSub(uniKey: self.subjectID!, dictCheck: universities["Classes"] as! [String : AnyObject])
                self.classeDict = universities
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
                if let dict = myclass["Classes"] as? [String : AnyObject] {
                    self.fetchMyClass(dictCheck: dict)
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
                            var classe = fetchObject()
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
                            var subject = fetchObject()
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
                                var subject = fetchObject()
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
                    self.uniBtnOn = false; self.subBtnOn = false; self.classBtnOn = true
                    self.classRoomTableView.reloadData()
                }
            })
        }
    }
}

extension ProfileVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == classRoomTableView {
        if uniBtnOn {
            uniID = uni_sub_array[indexPath.row].uid
            self.fetchSub(uniKey: uniID!, dictCheck: subjectsDict!)
            uniBtnOn = false ; subBtnOn = true ; classBtnOn = false
        } else if subBtnOn {
            subjectID = uni_sub_array[indexPath.row].uid
            subjectArray = uni_sub_array
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
                // print a statement saying class already added
            } else {
                ref.child("Students").child(uid!).child("Classes").updateChildValues(parameters)
                ref.child("Classes").child(key!).child("Students").updateChildValues(parameters2)
            }
            // delete it from the class array
                
        }
        } else if tableView == myClassesTableView{
            // delete class or go to class with a popup
            let ref = Database.database().reference()
            let key = myClassesArr[indexPath.row].uid
            let uid = Auth.auth().currentUser?.uid
            let alert = UIAlertController(title: "\(myClassesArr[indexPath.row].title ?? "")", message: "Perform action", preferredStyle: .alert)
            let delete = UIAlertAction(title: "Delete", style: .destructive) { (_) in
                // delete class from student and student from class
                ref.child("Students").child(uid!).child("Classes").child(key!).removeValue()
                ref.child("Classes").child(key!).child("Students").child(uid!).removeValue()
                
            }
            let view = UIAlertAction(title: "View", style: .default) { (_) in
                // view the class room Segue to the classroom.
            }
            alert.addAction(delete);  alert.addAction(view); present(alert, animated: true, completion: nil)
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == classRoomTableView {
             let cell = tableView.dequeueReusableCell(withIdentifier: "classRoomCells", for: indexPath)
             cell.textLabel!.text = uni_sub_array[indexPath.row].title
            return cell
        } else if tableView == myClassesTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "myClasses", for: indexPath)
            cell.textLabel!.text = myClassesArr[indexPath.row].title
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
           return "Search Result"
        }
        if tableView == myClassesTableView {
            return "My Classes"
        } else {
            return ""
        }
    }
    // change header color hear if necessary
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        //
//    }
}
