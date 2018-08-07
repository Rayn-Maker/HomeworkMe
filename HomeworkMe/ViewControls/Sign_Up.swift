//
//  Sign_Up.swift
//  HomeworkMe
//
//  Created by Radiance Okuzor on 8/1/18.
//  Copyright © 2018 RayCo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class Sign_Up: UIViewController {
    
    @IBOutlet weak var fNameTxt: UITextField!
    @IBOutlet weak var lNameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var conPaswordTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    var ref: DatabaseReference!
    var alert: CommonFunctions!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
    }
 

    @IBAction func registerPrsd(_ sender: Any) {
        ref = Database.database().reference()
        if passwordTxt.text != conPaswordTxt.text {
            let alert = self.alert.alertWithOk(errorMessagTitle: "Password error", errorMessage: "Please make sure your passwords match")
            self.present(alert, animated: true, completion: nil)
        }
        if fNameTxt.text != nil && lNameTxt.text != nil && passwordTxt.text != nil && conPaswordTxt.text != nil && emailTxt.text != nil && fNameTxt.text != " " && lNameTxt.text != " " && passwordTxt.text != " " && conPaswordTxt.text != " " && emailTxt.text != " " {
            Auth.auth().createUser(withEmail: self.emailTxt.text!, password: self.passwordTxt.text!) { (user, error) in
                if error != nil {
                    let alert = self.alert.alertWithOk(errorMessagTitle: "Something went wrong", errorMessage: (error?.localizedDescription)!)
                    self.present(alert, animated: true, completion: nil)
                }  /// Catch any errors and present it to the screen.
                
                if let user = user {
                    let userInfo: [String: Any] = ["uid": user.user.uid,
                                                   "fName": self.fNameTxt.text ?? " ",
                                                   "lName": self.lNameTxt.text ?? " ",
                                                   "email": self.emailTxt.text ?? " ",
                                                   "password": self.passwordTxt.text ?? " "]
                    
                    self.ref.child("Students").child(user.user.uid).setValue(userInfo)
                }
            }
            
        } else {
            // post error message here to fill up all fields
            let alert = self.alert.alertWithOk(errorMessagTitle: "Missing Fields", errorMessage: "Please make sure all fields are filled")
            self.present(alert, animated: true, completion: nil)
        }
        
    }
}


