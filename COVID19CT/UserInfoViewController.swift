//
//  UserInfoViewController.swift
//  COVID19CT
//
//  Created by Javier Bustillo on 4/25/20.
//  Copyright © 2020 Javier Bustillo. All rights reserved.
//

import UIKit
import Alamofire
import MBProgressHUD

class UserInfoViewController: UIViewController {

    @IBOutlet weak var currentStatus: UILabel!
    @IBOutlet weak var lastKnownInteraction: UILabel!
    @IBOutlet weak var lastKnownRiskyInteraction: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        let parameters = ["secure_id": UserDefaults.standard.string(forKey: "registeredLicense")!]
        MBProgressHUD.showAdded(to: self.view, animated: true)
        AF.request("https://covid-contact-tracing.herokuapp.com/stats/", method: .post, parameters: parameters, headers: ["application-type": "JSON"]).responseJSON { (response) in
            switch response.result {
            case .success(let value):
                if let JSON = value as? [String: Any] {
                    let daysSinceLastContact = JSON["days_since_last_contact"] as! Int
                    let status = JSON["status"] as! Int
                    let daysSinceLastRiskyContact = JSON["days_since_last_risky_contact"] as! Int
                    
                    var statusString = "Current status: "
                    if status == 0{
                        statusString += "Infected"
                    }
                    else if status == 1 {
                        statusString += "Risk at infection"
                    }
                    else{
                        statusString += "No known risk"
                    }
                    self.currentStatus.text = statusString
                    if daysSinceLastContact != -1 {
                        self.lastKnownInteraction.text = "Last known interaction: \(daysSinceLastContact)"
                    }
                    else{
                        self.lastKnownInteraction.text = "No recent interactions"
                    }
                    if daysSinceLastRiskyContact != -1 {
                        self.lastKnownRiskyInteraction.text = "Last known risky interaction: \(daysSinceLastRiskyContact)"
                    }
                    else{
                        self.lastKnownRiskyInteraction.text = "No recent risky interactions"
                    }
                    MBProgressHUD.hide(for: self.view, animated: true)
                    
                }
            case .failure(let error):
                MBProgressHUD.hide(for: self.view, animated: true)
                print(error.localizedDescription)
            }
        }
        // Do any additional setup after loading the view.
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
