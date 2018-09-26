//
//  MyClassMates.swift
//  HomeworkMe
//
//  Created by Radiance Okuzor on 8/13/18.
//  Copyright © 2018 RayCo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import MessageUI
import GoogleMaps
import GooglePlaces
import Alamofire


class MyRequests: UIViewController, MFMessageComposeViewControllerDelegate  {

    @IBOutlet weak var navBat: UINavigationBar!
    @IBOutlet weak var requestersView: UIView!
    @IBOutlet weak var myRequestsTable: UITableView!
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var callBtn: UIButton!
    @IBOutlet weak var timeSincePstLable: UILabel!
    @IBOutlet weak var bioLable: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    @IBOutlet weak var meetUpLocation: UITextView!
    @IBOutlet weak var switchView: UIBarButtonItem!
    @IBOutlet weak var tutorReqView: UIView!
    @IBOutlet weak var tutorReqTable: UITableView!
    @IBOutlet weak var googleMaps: GMSMapView!
    
    var tutor = Student()
    var student = Student()
    var functions = CommonFunctions()
    var userStorage: StorageReference!
    var request: Request!
    let ref = Database.database().reference()
    var displayingTutReqview = true
    var handle: DatabaseHandle?
    var handle2: DatabaseHandle?
    var isTutor = true
    var place = Place()
    var locationManager = CLLocationManager()
    var locationSelected = Location.startLocation
    var locationStart = CLLocation()
    var locationEnd = CLLocation()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let istutor = UserDefaults.standard.bool(forKey: "isTutorApproved") as? Bool {
            isTutor = istutor
        } else {
            isTutor = false
        }
        if isTutor {
            displayingTutReqview = false
            tutorReqView.isHidden = true
        }
        tutorReqTable.estimatedRowHeight = 45
        tutorReqTable.rowHeight = UITableViewAutomaticDimension
        myRequestsTable.estimatedRowHeight = 45
        myRequestsTable.rowHeight = UITableViewAutomaticDimension
        let storage = Storage.storage().reference(forURL: "gs://hmwrkme.appspot.com")
        userStorage = storage.child("Students")
        googleMapsetup()
        fetchTutor()
        fetchSent()
        editImage()
    }
    
    @IBAction func rejectReq(_ sender: Any) {
        let dateString = String(describing: Date())
        
        let par = ["time": dateString as AnyObject,
                   "status":"rejected"] as! [String: Any]
        self.ref.child("Students").child(request.authorId ?? "").child("sentReqs").child(request.reqID).updateChildValues(par) //"status":"pending"
        self.ref.child("Tutors").child(Auth.auth().currentUser?.uid ?? "").child("requests").child(request.reqID).updateChildValues(par)
        requestersView.isHidden = true
       
    }
    
    @IBAction func switchView(_ sender: Any) {
        if displayingTutReqview {
            tutorReqView.isHidden = true
            displayingTutReqview = false
//            navBat.topItem?.title = "Sent"
            switchView.title = "View Sent"
        } else {
            tutorReqView.isHidden = false
            displayingTutReqview = true
            switchView.title = "View Received"
        }
    }
    
    @IBAction func acceptReq(_ sender: Any) {
        // remove profile from request cup and put it jobs cup
        // start timer for 20 mins
        let dateString = String(describing: Date())

        let par = ["time": dateString as AnyObject,
                   "status":"approved"] as! [String: Any]
        self.ref.child("Students").child(request.authorId ?? "").child("sentReqs").child(request.reqID).updateChildValues(par)
        self.ref.child("Tutors").child(Auth.auth().currentUser?.uid ?? "").child("requests").child(request.reqID).updateChildValues(par)
        requestersView.isHidden = true
    }
    
    
    @IBAction func callPrsd(_ sender: Any) {
        
        self.request.phoneNumber = self.request.phoneNumber.replacingOccurrences(of: "-", with: "")
        self.request.phoneNumber = self.request.phoneNumber.replacingOccurrences(of: " ", with: "")
        self.request.phoneNumber = self.request.phoneNumber.replacingOccurrences(of: ")", with: "")
       self.request.phoneNumber = self.request.phoneNumber.replacingOccurrences(of: "(", with: "")
       self.request.phoneNumber = self.request.phoneNumber.replacingOccurrences(of: "+", with: "")
        
        if self.request.phoneNumber.count > 10 {
            self.request.phoneNumber.remove(at: self.request.phoneNumber.startIndex)
        }
        if self.request.phoneNumber.count > 10 {
           self.request.phoneNumber.remove(at: self.request.phoneNumber.startIndex)
        }
        
        if self.request.phoneNumber.count > 10 {
            String(self.request.phoneNumber.characters.dropLast())
        }
        let dd =  (self.request.phoneNumber as NSString).integerValue
        
        guard let number = URL(string: "tel://" + "\(dd ?? 8888888888)") else {
            
        
            return }
        UIApplication.shared.open(number)
    }
    
    @IBAction func txtMsg(_ sender: Any) {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = ""
            controller.recipients = [self.request.phoneNumber]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //... handle sms screen actions
        self.dismiss(animated: true, completion: nil)
    }
    
    var storageRef: Storage {
        return Storage.storage()
    }
    
    func fetchTutor(){
        let ref = Database.database().reference()
          handle = ref.child("Tutors").child(Auth.auth().currentUser?.uid ?? " ").queryOrderedByKey().observe( .value, with: { response in
            if response.value is NSNull {
            } else {
                let tutDict = response.value as! [String:AnyObject]

                if let json = tutDict["requests"] as? [String:AnyObject] {
                    self.student.requestsObject = json
                    self.tutor.requestsArrAccepted.removeAll()
                    self.tutor.requestsArrRejected.removeAll()
                    self.tutor.requestsArrPending.removeAll()
                    self.tutor = self.setUpReqArr(tableArr: self.tutor, object: json, table: self.myRequestsTable)
                    //                    self.getLocations()
                }
                if let scdul = tutDict["appointMents"] as? [String] {
                    self.tutor.schedule = scdul
                }
                if let posts = tutDict["Posts"] as? [String:AnyObject] {
                    self.tutor.posts2 = posts
                }
                if let studentProf = tutDict["StudentProfile"] as? [String:AnyObject] {
                    self.tutor.studentProfile = studentProf
                    self.tutor.customerId = studentProf["customerId"] as? String
                    self.tutor.phoneNumebr = studentProf["phoneNumber"] as? String
                    self.tutor.full_name = studentProf["full_name"] as? String
                    self.tutor.email = studentProf["email"] as? String
                }
                if let status = tutDict["status"] as? String {
                    self.tutor.tutorStatus = status
                    
                }
            }
        })
    }
    
    func fetchSent(){
        let ref = Database.database().reference()
        handle2 = ref.child("Students").child(Auth.auth().currentUser?.uid ?? " ").queryOrderedByKey().observe( .value, with: { response in
            if response.value is NSNull {
            } else {
                let tutDict = response.value as! [String:AnyObject]
                
                if let json = tutDict["sentReqs"] as? [String:AnyObject] {
                    self.student.requestsArrAccepted.removeAll()
                    self.student.requestsArrRejected.removeAll()
                    self.student.requestsArrPending.removeAll()
                    self.student = self.setUpReqArr(tableArr: self.student, object: json, table: self.tutorReqTable)
                }
            }
        })
    }
    
    func connectProfile(req: Request) {
        downlaodPic(url: req.picUrl)
        postTitle.text = req.postTite
        timeSincePstLable.text = req.timeString
        bioLable.text = req.author
        meetUpLocation.text = req.place.name
    }
    
    func editImage(){
        image.layer.borderWidth = 1
        image.layer.masksToBounds = false
        image.layer.borderColor = UIColor.black.cgColor
        image.layer.cornerRadius = image.frame.height/2
        image.clipsToBounds = true
    }
    
    func setUpReqArr (tableArr: Student, object:[String : AnyObject], table:UITableView) -> Student {
        var req = Request()
        tableArr.requestsArrRejected.removeAll()
        tableArr.requestsArrAccepted.removeAll()
        tableArr.requestsArrPending.removeAll()
        for (_,b) in object {
            req.author = b["author"] as? String
            req.authorId = b["senderId"] as? String
            let ts = b["time"] as? String
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss +zzzz"
            let dat = dateFormatter.date(from: ts as! String)
            req.timeString = functions.getTimeSince(date: dat ?? Date())
            req.reqID = b["reqId"] as? String
            req.postTite = b["postTitle"] as? String
            req.phoneNumber = b["phoneNumber"] as? String
            req.picUrl = b["picUrl"] as? String
            req.reqStatus = b["status"] as? String
            if let place = b["place"] as? [String:AnyObject] {
                 req.place.address = place["address"] as? String
                req.place.lat = place["lat"] as? String
                req.place.long = place["long"] as? String
                req.place.name = place["name"] as? String
            }
            if req.reqStatus == "pending" {
                tableArr.requestsArrPending.append(req)
            } else if req.reqStatus == "approved" {
                tableArr.requestsArrAccepted.append(req)
            } else if req.reqStatus == "rejected"{
                tableArr.requestsArrRejected.append(req)
            }
            
        }
        table.reloadData()
        return tableArr
    }
    
    func downlaodPic(url:String) {
        self.storageRef.reference(forURL:url).getData(maxSize: 1 * 1024 * 1024, completion: { (imgData, error) in
            if error == nil {
                if let data = imgData{
                    self.image.image = UIImage(data: data)
                    self.activitySpinner.stopAnimating()
                }
            }
            else {
                print(error?.localizedDescription)
                self.activitySpinner.stopAnimating()
            }
        })
    }
    
    /// Google maps implementation
    func googleMapsetup() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()
        
        //Your map initiation code
        let camera = GMSCameraPosition.camera(withLatitude: -7.9293122, longitude: 112.5879156, zoom: 15.0)
        
        self.googleMaps.camera = camera
        self.googleMaps.delegate = self
        self.googleMaps?.isMyLocationEnabled = true
        self.googleMaps.settings.myLocationButton = true
        self.googleMaps.settings.compassButton = true
        self.googleMaps.settings.zoomGestures = true
    }
    
    func drawPath(startLocation: CLLocation, endLocation: CLLocation)
    {
        let origin = "\(startLocation.coordinate.latitude),\(startLocation.coordinate.longitude)"
        let destination = "\(place.lat),\(place.long)"
        
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving"
        
        Alamofire.request(url).responseJSON { response in
            
            print(response.request as Any)  // original URL request
            print(response.response as Any) // HTTP URL response
            print(response.data as Any)     // server data
            print(response.result as Any)   // result of response serialization
            
//            let json = JSON(data: response.data!)
//            let routes = json["routes"].arrayValue
//
//            // print route using Polyline
//            for route in routes
//            {
//                let routeOverviewPolyline = route["overview_polyline"].dictionary
//                let points = routeOverviewPolyline?["points"]?.stringValue
//                let path = GMSPath.init(fromEncodedPath: points!)
//                let polyline = GMSPolyline.init(path: path)
//                polyline.strokeWidth = 4
//                polyline.strokeColor = UIColor.red
//                polyline.map = self.googleMaps
//            }
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRequester" {
            let vc = segue.destination as? Request
            
        }
    }
}


extension MyRequests: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == myRequestsTable {
            let cell = tableView.dequeueReusableCell(withIdentifier: "myRequests", for: indexPath)
            if indexPath.section == 0 {
                cell.textLabel?.text = "\( tutor.requestsArrPending[indexPath.row].author ?? "")\n\(tutor.requestsArrPending[indexPath.row].postTite ?? "")"
                cell.detailTextLabel?.text = tutor.requestsArrPending[indexPath.row].postTite
                return cell
            } else if indexPath.section == 1 {
                cell.textLabel?.text = "\( tutor.requestsArrAccepted[indexPath.row].author ?? "")\n\(tutor.requestsArrAccepted[indexPath.row].postTite ?? "")"
                cell.detailTextLabel?.text = tutor.requestsArrAccepted[indexPath.row].postTite
                return cell
            } else if indexPath.section == 2 {
                cell.textLabel?.text = "\( tutor.requestsArrRejected[indexPath.row].author ?? "")\n\(tutor.requestsArrRejected[indexPath.row].postTite ?? "")"
                cell.detailTextLabel?.text = tutor.requestsArrRejected[indexPath.row].postTite
                return cell
            }
        } else if tableView == tutorReqTable {
            let cell = tableView.dequeueReusableCell(withIdentifier: "myTutorRequests", for: indexPath)
            if indexPath.section == 0 {
                cell.textLabel?.text = "\( student.requestsArrPending[indexPath.row].author ?? "")\n\(student.requestsArrPending[indexPath.row].postTite ?? "")"
                cell.detailTextLabel?.text = student.requestsArrPending[indexPath.row].postTite
                return cell
            } else if indexPath.section == 1 {
                cell.textLabel?.text = "\( student.requestsArrAccepted[indexPath.row].author ?? "")\n\(student.requestsArrAccepted[indexPath.row].postTite ?? "")"
                cell.detailTextLabel?.text = student.requestsArrAccepted[indexPath.row].postTite
                return cell
            } else if indexPath.section == 2 {
                cell.textLabel?.text = "\( student.requestsArrRejected[indexPath.row].author ?? "")\n\(student.requestsArrRejected[indexPath.row].postTite ?? "")"
                cell.detailTextLabel?.text = student.requestsArrRejected[indexPath.row].postTite
                return cell
            }

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "myRequests", for: indexPath)
            cell.textLabel?.text = "\( tutor.requestsArrRejected[indexPath.row].author ?? "")\n\(tutor.requestsArrRejected[indexPath.row].postTite ?? "")"
            cell.detailTextLabel?.text = tutor.requestsArrRejected[indexPath.row].postTite
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "myRequests", for: indexPath)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Pending Requests"
        } else if section == 1 {
            return "Accepted Requests"
        } else if section == 2 {
            return "Rejected Requests"
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == myRequestsTable {
            switch (section) { //["All","Homework", "Test","Notes","Tutoring","Other"]
            case 0:
                return tutor.requestsArrPending.count
            case 1:
                return tutor.requestsArrAccepted.count
            case 2:
                return tutor.requestsArrRejected.count
            default:
                return 0
            }
        } else if tableView == tutorReqTable {
            switch (section) { //["All","Homework", "Test","Notes","Tutoring","Other"]
            case 0:
                return student.requestsArrPending.count
            case 1:
                return student.requestsArrAccepted.count
            case 2:
                return student.requestsArrRejected.count
            default:
                return 0
            }
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        activitySpinner.startAnimating()
        requestersView.isHidden = false
        if tableView == tutorReqTable {
            if indexPath.section == 0 {
                request = student.requestsArrPending[indexPath.row]
                connectProfile(req: student.requestsArrPending[indexPath.row])
            } else if indexPath.section == 1 {
                request = student.requestsArrAccepted[indexPath.row]
                connectProfile(req: student.requestsArrAccepted[indexPath.row])
                self.place = student.requestsArrAccepted[indexPath.row].place
            } else if indexPath.section == 2 {
                request = student.requestsArrRejected[indexPath.row]
                connectProfile(req: student.requestsArrRejected[indexPath.row])
            }
        } else if tableView == myRequestsTable {
            if indexPath.section == 0 {
                request = tutor.requestsArrPending[indexPath.row]
                connectProfile(req: tutor.requestsArrPending[indexPath.row])
            } else if indexPath.section == 1 {
                request = tutor.requestsArrAccepted[indexPath.row]
                connectProfile(req: tutor.requestsArrAccepted[indexPath.row])
            } else if indexPath.section == 2 {
                request = tutor.requestsArrRejected[indexPath.row]
                connectProfile(req: tutor.requestsArrRejected[indexPath.row])
            }
        }
    }
}

extension MyRequests: GMSMapViewDelegate ,  CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error to get location : \(error)")
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
