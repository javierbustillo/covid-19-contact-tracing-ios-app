//
//  GetStatusViewController.swift
//  COVID19CT
//
//  Created by Javier Bustillo on 4/24/20.
//  Copyright © 2020 Javier Bustillo. All rights reserved.
//

import UIKit
import AVFoundation
import QRCodeReader
import Hash
import PMSuperButton
import SCLAlertView
import Alamofire
import MBProgressHUD

class GetStatusViewController: UIViewController, QRCodeReaderViewControllerDelegate{
   
    @IBOutlet weak var getStatus: PMSuperButton!
    @IBOutlet weak var selfReport: PMSuperButton!
    @IBOutlet weak var registerLicense: PMSuperButton!
    @IBOutlet weak var userInfo: PMSuperButton!

    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.pdf417], captureDevicePosition: .back)
            
            $0.showTorchButton        = false
            $0.showSwitchCameraButton = false
            $0.showCancelButton       = true
            $0.showOverlayView        = true
            $0.rectOfInterest         = CGRect(x: 0.2, y: 0.2, width: 0.6, height: 0.6)
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        softEdgeButton(button: getStatus)
        softEdgeButton(button: selfReport)
        softEdgeButton(button: registerLicense)
        softEdgeButton(button: userInfo)
        
        touchGetStatus()
        touchSelfReport()
        touchRegister()
        touchUserInfo()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func getStatusAction(_ sender: Any) {
                
       
    }
    
    func softEdgeButton(button: PMSuperButton){
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 0
        button.layer.borderColor = UIColor.black.cgColor
    }
    
    func touchUserInfo() {
        userInfo.touchUpInside(){
            if let hashValue = UserDefaults.standard.string(forKey: "registeredLicense"){
                self.performSegue(withIdentifier: "userInfo", sender: nil)
            } else{
                SCLAlertView().showError("Missing License", subTitle: "Register license first")
            }
        }
    }
    
    func touchRegister() {
        registerLicense.touchUpInside() {
            self.readerVC.delegate = self
            self.readerVC.completionBlock = { (result: QRCodeReaderResult?) in
                UserDefaults.standard.set(Hash(message: result!.value, algorithm: .sha256)?.description, forKey: "registeredLicense")
                print(UserDefaults.standard.string(forKey: "registeredLicense")!)
                SCLAlertView().showSuccess("Success", subTitle: "License has been registered in the application")
            }
            self.readerVC.modalPresentationStyle = .formSheet
            self.present(self.readerVC, animated: true, completion: nil)
        }
    }
    
    func touchGetStatus(){
        getStatus.touchUpInside(){
            if UserDefaults.standard.string(forKey: "registeredLicense") != nil{
                self.readerVC.delegate = self

                    // Or by using the closure pattern
                self.readerVC.completionBlock = { (result: QRCodeReaderResult?) in
                    print(result!)
                    let hashValue = Hash(message: result!.value, algorithm: .sha256)?.description
                    
                    let parameters = [
                    "scanner_secure_id": hashValue!,
                    "scanned_secure_id": UserDefaults.standard.string(forKey: "registeredLicense")!
                    ]
                    MBProgressHUD.showAdded(to: self.view, animated: true)
                    AF.request("https://covid-contact-tracing.herokuapp.com/contact/", method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder.default, headers: ["application-type": "JSON"]).responseJSON { (response) in
                        switch response.result {
                        case .success(let value):
                            if let JSON = value as? [String: Any] {
                                let status = JSON["result"] as! Int
                                let message = JSON["message"] as! String
                                MBProgressHUD.hide(for: self.view, animated: true)
                                if status == 0 {
                                    SCLAlertView().showSuccess("Clear!", subTitle: message)
                                }
                                else{
                                    SCLAlertView().showWarning("Known Risk", subTitle: message)
                                }
                            }
                        case .failure(let error):
                            MBProgressHUD.hide(for: self.view, animated: true)
                            SCLAlertView().showError("Error", subTitle: "Try again")
                            print(error.localizedDescription)
                        }
                        
                    }
                    
                    
                    
                }
                self.readerVC.modalPresentationStyle = .formSheet
                   
                self.present(self.readerVC, animated: true, completion: nil)
            }
            else{
                SCLAlertView().showError("Missing License", subTitle: "Register License first")
            }
            
        }
    }
    
    func touchSelfReport(){
        selfReport.touchUpInside(){
            self.readerVC.delegate = self
            self.readerVC.completionBlock = {(result: QRCodeReaderResult?) in
                   //hash and maybe coords to server to report that the person is infected
                let hashValue = Hash(message: result!.value, algorithm: .sha256)?.description
                let parameter = ["scanned_secure_id": hashValue!]
                MBProgressHUD.showAdded(to: self.view, animated: true)
                AF.request("https://covid-contact-tracing.herokuapp.com/infection/", method: .post, parameters: parameter, headers: ["application-type": "JSON"]).response { (response) in
                    switch response.result {
                    case .success(let value):
                        MBProgressHUD.hide(for: self.view, animated: true)
                        SCLAlertView().showSuccess("Reported", subTitle:"Infection has been reported and people at risk have been notified")
                    case .failure(let error): print(error.errorDescription)
                    }
                    
                }
            }
            self.readerVC.modalPresentationStyle = .formSheet
                   
            self.present(self.readerVC, animated: true, completion: nil)
        }
    }
    
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        
        //Here we send it to the server
        
        dismiss(animated: true, completion: nil)
    }

    func readerDidCancel(_ reader: QRCodeReaderViewController) {
      reader.stopScanning()

      dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
