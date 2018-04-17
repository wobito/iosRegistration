//
//  SignatureViewController.swift
//  Registration
//
//  Created by Adrian Wobito on 2018-01-09.
//  Copyright © 2018 Adrian Wobito. All rights reserved.
//

import UIKit
import SwiftyJSON
import T1Autograph
import SVProgressHUD
import Alamofire

class SignatureViewController: UIViewController {
    
    let checkURL = "https://core.craigproctor.com/ipad/attendees/checkin"
    let uploadURL = "https://core.craigproctor.com/ipad/attendees/upload"
    let printURL = "https://core.craigproctor.com/ipad/attendees/print"
    
    var attendee = Attendee()
    var autograph: T1Autograph = T1Autograph()
    var outputImage: UIImageView! = UIImageView()
    var t1Key:String = ""
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var programLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var seatLabel: UILabel!
    @IBOutlet weak var signatureView: UIView!
    @IBOutlet weak var resetBtn: UIButtonX!
    @IBOutlet weak var checkInBtn: UIButtonX!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setT1Key()
        nameLabel.text = attendee.name
        programLabel.text = "PROGRAM: \(attendee.label)"
        locationLabel.text = "LOCATION: \(attendee.city), \(attendee.state)"
        seatLabel.text = attendee.seatType
        statusLabel.text = (attendee.postStatus != "") ? "STATUS : Checked In" : "STATUS : Not Checked In"
        configureView()
    }
    
    func configureView() {
        signatureView.layer.cornerRadius = CGFloat(5)
        autograph = T1Autograph.autograph(withView: signatureView, delegate: self) as! T1Autograph
        autograph.licenseCode = t1Key
        autograph.showGuideline = false
        
        checkInBtn.alpha = 0
        resetBtn.alpha = 0
        signatureView.alpha = 1
    }
    
    func dismissModal() {
        SVProgressHUD.dismiss()
        autograph.reset(self)
        dismiss(animated: true, completion: nil)
    }
    
    func uploadSignature(signature: T1Signature, attendee: Attendee) {
        let imageName = "\(attendee.pivotId)-SIGNATURE.png"
        let image = UIImage(data: signature.imageData)
        let imageData = UIImagePNGRepresentation(image!)
        let pivotId = "\(attendee.pivotId)".data(using: String.Encoding.utf8)!
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imageData!, withName: "media", fileName: imageName, mimeType: "image/png")
            multipartFormData.append(pivotId, withName: "aid")
        },
             to: uploadURL,
             encodingCompletion: {  encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        self.changeAttendeeStatus()
                    }
                case .failure(_):
                    SVProgressHUD.setFadeOutAnimationDuration(1)
                    SVProgressHUD.showError(withStatus: "Signature Upload Failed")
                }
        })
    }
    
    func changeAttendeeStatus() {
        let params = [
            "contact_id" : attendee.contactId,
            "pivot_id" : attendee.pivotId,
            "event_id" : attendee.eventId,
        ]
        
        Alamofire.request(checkURL, method: .post, parameters: params).responseJSON { response in
            if response.result.isSuccess {
                let jsonResponse : JSON = JSON(response.result.value!)
                let pdf = jsonResponse["pdf"].stringValue
                self.printBadge(pdf: pdf)
            } else {
                SVProgressHUD.setFadeOutAnimationDuration(1)
                SVProgressHUD.showError(withStatus: "Check-In Failed")
            }
        }
    }
    
    func printBadge(pdf: String) {
        Alamofire.request(printURL, method: .post, parameters: ["pdf":pdf]).responseJSON { response in
            if response.result.isSuccess {
                SVProgressHUD.setFadeOutAnimationDuration(2)
                SVProgressHUD.showSuccess(withStatus: "Check-In Complete")
                self.dismissModal()
            } else {
                SVProgressHUD.setFadeOutAnimationDuration(1)
                SVProgressHUD.showError(withStatus: "Printing Failed")
            }
        }
    }
    
    func setT1Key() {
        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist") {
            let dictRoot = NSDictionary(contentsOfFile: path)
            if let dict = dictRoot {
                t1Key = dict["T1Key"] as! String
            }
        }
    }
    
    @IBAction func closeModal(_ sender: Any) {
        dismissModal()
    }
   
    @IBAction func resetBtnPressed(_ sender: Any) {
        autograph.reset(sender)
        UIView.animate(withDuration: 0.5, animations: {
            self.checkInBtn.alpha = 0
            self.resetBtn.alpha = 0
        })
    }
    
    @IBAction func checkInBtnPressed(_ sender: Any) {
        SVProgressHUD.show(withStatus: "Please Wait.. ")
        
        UIView.animate(withDuration: 0.5, animations: {
            self.checkInBtn.alpha = 0
            self.signatureView.alpha = 0
            self.resetBtn.alpha = 0
        })
        
        autograph.done(self)
    }
}



// MARK: Signature Delegate
extension SignatureViewController: T1AutographDelegate {
    func autograph(_ autograph: T1Autograph!, didCompleteWith signature: T1Signature!) {
        uploadSignature(signature: signature, attendee: attendee)
    }
    
    func autographDidCompleteWithNoSignature(_ autograph: T1Autograph!) {
        SVProgressHUD.setFadeOutAnimationDuration(1)
        SVProgressHUD.showError(withStatus: "Signature Required")
    }
    
    func autograph(_ autograph: T1Autograph!, didEndLineWithSignaturePointCount count: UInt) {
        NSLog("Line ended with total signature point count of %d", count)
        // Note: You can use the 'count' parameter to determine if the line is substantial enough to enable the done or clear button.
        UIView.animate(withDuration: 0.3, animations: {
            self.checkInBtn.alpha = 1
            self.resetBtn.alpha = 1
        })
    }
}
