//
//  Objects.swift
//  HomeworkMe
//
//  Created by Radiance Okuzor on 8/1/18.
//  Copyright © 2018 RayCo. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseDatabase

class Student {
    var fName: String?
    var lName: String?
    var email: String?
    var password: String?
    var confPassword: String? 
    var school: [String]?
    var classroom: [Classroom]?
    var posts: [Post]?
    var profilepic: Data?
    var billing: Billing?
    var postedPosts: [Post]?
    var uid: String?
}

class Classroom {
    var university: String?
    var subject: Subject?
    var students: [Student]?
    var teacher: String?
    var title: String?
    var createdBy: String?
    var uid: String?
}

class Post {
    var classs: Classroom?
    var publisher: Student?
    var subject: Subject?
    var title: String?
    var seller: Student?
    var buyer: Student?
    var file: File?
    var date: Date?
    var uid: String?
    
}


struct File {
    var title: String?
    var data: Data?
    var post: Post?
    
}

struct Billing {
    var creditCardNumber: Int?
    var creditCardExpr: Date?
    var creditCardPin: Int?
    var nameOnCreditCard: String?
    var zip: Int?
    var cash_zelle: String?
}

struct Subject {
    var title:String? 
    var classrooms: [Classroom]?
    var uid: String?
}

struct University {
    var title:String?
    var subjects: [Subject]?
    var uid: String?
}

struct fetchObject {
    var title: String?
    var uid: String?
    var dict: [String:AnyObject]?
}

struct Reciept {
    var post: Post?
    var billing: Billing?
    var date: Date?
    var uid: String?
    var buyer: Student?
    var seller: Student?
    var zelle_cash: String?
}

class CommonFunctions {
    var ref: DatabaseReference?
    var handle: DatabaseHandle?
    var handle2: DatabaseHandle?
    
    func alertWithOk(errorMessagTitle:String, errorMessage:String) ->UIAlertController {
        let alert = UIAlertController(title: errorMessagTitle, message: errorMessage, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        return alert
    }
    
    func addToDirecotory(key:String, title:String, message:String, paramKey:String, paramName:String, foldername:String, universityKey:String = " ", subjectKey:String = " " ) -> UIAlertController {
        let ref = Database.database().reference()
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter name here"
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let post = UIAlertAction(title: "Create", style: .default) { _ in
            guard let text = alert.textFields?.first?.text else { return }
            if text != "" {
                print(text)
                
                if foldername == "Universities" {
                let parameters = [paramKey : key,
                                  paramName : text]
                
                let university = ["\(key)" : parameters]
                ref.child(foldername).updateChildValues(university)
                }
                if foldername == "Subjects" {
                    let parameters = [paramKey: key,
                                      paramName : text]
                    let subject = ["\(key)": parameters]
                    let uniSection = [key:key]
                    ref.child(foldername).updateChildValues(subject)
                    ref.child("Universities").child(universityKey).child("Subjects").updateChildValues(uniSection)
                }
                if foldername == "Classes" {
                    let parameters = [paramKey: key,
                                      paramName: text]
                    let classs = [key:parameters]
                    let subFldr = [key:key]
                    
                    ref.child("Classes").updateChildValues(classs)
                    ref.child("Subjects").child(subjectKey).child("Classes").updateChildValues(subFldr)
                    ref.child("Universities").child(universityKey).child("Classes").updateChildValues(subFldr)
                
                }
            }
        }
        alert.addAction(cancel)
        alert.addAction(post)
        return alert
    }
    
    func fetch(folderName:String, success successBlock: @escaping () -> ([University])) {
        var universitiesArray  = [University]() 
        let ref = Database.database().reference()
        ref.child(folderName).queryOrderedByKey().observeSingleEvent(of: .value, with: { response in
            if response.value is NSNull {
                
                /// dont do anything
            } else {
                let universities = response.value as! [String:AnyObject]
                for (_,b) in universities {
                    var university = University()
                    if let uid = b["uid"] {
                        university.uid = uid as? String
                    }
                    if let title = b["name"] {
                        university.title = title as? String
                    }
                    universitiesArray.append(university)
                }
            }
        })
    }
}

extension UIImageView {
    
    func downloadImage(from imgURL: String!) {
        
        let url = URLRequest(url: URL(string: imgURL)!)
        
        let task = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                self.image = UIImage(data: data!)
            }
            
        }
        
        task.resume()
    }
}

