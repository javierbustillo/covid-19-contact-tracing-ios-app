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

class GetStatusViewController: UIViewController, QRCodeReaderViewControllerDelegate {
    
    @IBOutlet weak var getStatus: PMSuperButton!
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.pdf417], captureDevicePosition: .back)
            
            // Configure the view controller (optional)
            $0.showTorchButton        = false
            $0.showSwitchCameraButton = false
            $0.showCancelButton       = false
            $0.showOverlayView        = true
            $0.rectOfInterest         = CGRect(x: 0.2, y: 0.2, width: 0.6, height: 0.6)
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        getStatus.touchUpInside(){
            print("poke")

            self.readerVC.delegate = self

                // Or by using the closure pattern
            self.readerVC.completionBlock = { (result: QRCodeReaderResult?) in
                print(result!)
            }

                // Presents the readerVC as modal form sheet
            self.readerVC.modalPresentationStyle = .formSheet
               
            self.present(self.readerVC, animated: true, completion: nil)
            
        }
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func getStatusAction(_ sender: Any) {
                
       
    }
    
    
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        let hash = Hash(message: result.value, algorithm: .sha256)
        
        //Here we send it to the server
        
        print(hash!)
        dismiss(animated: true, completion: nil)
        SCLAlertView().showSuccess("Clear!", subTitle: "The person is clear to enter")
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
