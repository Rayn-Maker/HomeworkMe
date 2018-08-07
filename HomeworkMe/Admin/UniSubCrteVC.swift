//
//  UniSubCrteVC.swift
//  HomeworkMe
//
//  Created by Radiance Okuzor on 8/2/18.
//  Copyright © 2018 RayCo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class UniSubCrteVC: UIViewController {
    
    @IBOutlet weak var uniTxt: UITextField!
    @IBOutlet weak var degre_subTxt: UITextField!
    @IBOutlet weak var uniTableView: UITableView!
    var commonFunctions = CommonFunctions()
    var universities = [University]()
    var universityID: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    @IBAction func addUniBtn(_ sender: Any) {
        let ref = Database.database().reference()
        let key = ref.child("Universities").childByAutoId().key
        
        present(commonFunctions.addToDirecotory(key: key, title: "Add Uni", message: "add new University", paramKey: "uid", paramName: "name", foldername: "Universities", universityKey: ""), animated: true, completion: nil)
        fetchUni()
    }
    
    @IBAction func addSubBtn(_ sender: Any) {
        let ref = Database.database().reference()
        let key = ref.child("Subjects").childByAutoId().key
       
        present(commonFunctions.addToDirecotory(key: key, title: "Add Subject/Degree", message: "add new Subjecct/Degree", paramKey: "uid", paramName: "name", foldername: "Subjects", universityKey: self.universityID), animated: true, completion: nil)
    }
    
    func fetchUni() {
        let ref = Database.database().reference()
        ref.child("Universities").queryOrderedByKey().observeSingleEvent(of: .value, with: { response in
            if response.value is NSNull {
                
                /// dont do anything
            } else {
                self.universities.removeAll()
                let universitiesDict = response.value as! [String:AnyObject]
                for (_,b) in universitiesDict {
                    var university = University()
                    if let uid = b["uid"] {
                        university.uid = uid as? String
                    }
                    if let title = b["name"] {
                        university.title = title as? String
                    }
                    self.universities.append(university)
                }
                self.uniTableView.reloadData()
            }
        })
        ref.removeAllObservers()
    }
    
}

extension UniSubCrteVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.universityID = universities[indexPath.row].uid
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "uniTable", for: indexPath)
        cell.textLabel!.text = universities[indexPath.row].title
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return universities.count
    }
}
