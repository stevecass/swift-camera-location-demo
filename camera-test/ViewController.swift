//
//  ViewController.swift
//  camera-test
//
//  Created by Steven Cassidy on 11/20/15.
//  Copyright © 2015 Steven Cassidy. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate {

    var locationManager : CLLocationManager!
    var locations: [CLLocation] = []

    @IBOutlet var imageView : UIImageView!

    @IBAction func buttonClicked() {
        let picker = UIImagePickerController()
        picker.delegate = self
        if false && UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            picker.sourceType = UIImagePickerControllerSourceType.Camera
        } else {
            picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        }
        presentViewController(picker, animated: true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let temp = info[UIImagePickerControllerOriginalImage]
        imageView.image = temp as? UIImage
        dismissViewControllerAnimated(true, completion: nil)
    }

    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().UUIDString)"
    }

    func createRequestBody(imageData: NSData, boundary: String, parameters:[String:Any]) -> NSMutableData {
        let uuid = NSUUID().UUIDString
        let mimeType = "image/jpeg"
        let body = NSMutableData()

        for (key, value) in parameters {
            body.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            body.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            body.appendData("\(value)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        }
        // now the image data
        body.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("Content-Disposition: form-data; name=\"image\"; filename=\"\(uuid).jpg\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("Content-Type: \(mimeType)\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData(imageData)
        body.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("--\(boundary)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)

        return body
    }

    func createRequest(imageData:NSData, parameters:[String:Any]) -> NSMutableURLRequest {
        let url = NSURL(string: "http://192.168.1.10:9292/items")!
        let boundary = generateBoundaryString()
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = createRequestBody(imageData, boundary: boundary, parameters: parameters)
        return request

    }

    func uploadImage(imageData: NSData, parameters:[String: Any]) {

        let request = createRequest(imageData, parameters: parameters)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                print(error)
                return
            }

            do {
                if let dict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                    print("success == \(dict)")

                    // dispatch_async(dispatch_get_main_queue()) {
                    //     // update GUI and model objects here
                    // }

                }
            } catch {
                print(error)
                
                let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("responseString = \(responseString)")
            }
        }
        task.resume()
    }

    @IBAction func btnSendClicked() {
        if let image = imageView.image {
            var parameters:[String: Any] = [ "lat" : 40, "lng" : -71, "user_id" : 2 ]
            if let loc = locationManager.location {
                parameters["lat"] = loc.coordinate.latitude
                parameters["lng"] = loc.coordinate.longitude
            }

            if let imageData:NSData? = UIImageJPEGRepresentation(image, 1) {
                print(parameters)
                uploadImage(imageData!, parameters: parameters)
            }
        }
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
        self.locations = locations
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        print (CLLocationManager.authorizationStatus())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

