//
//  LoginVC.swift
//  htchhkr-development
//
//  Created by Caleb Stultz on 4/29/17.
//  Copyright © 2017 Caleb Stultz. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController, UITextFieldDelegate, Alertable {

    @IBOutlet weak var emailField: RoundedCornerTextField!
    @IBOutlet weak var passwordField: RoundedCornerTextField!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var authBtn: RoundedShadowButton!
    @IBOutlet weak var closeBtn: UIButton!
    
    var flagCloseBtn = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.closeBtn.isHidden = flagCloseBtn
        self.emailField.delegate = self
        self.passwordField.delegate = self
        view.bindtoKeyboard()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleScreenTap(sender:)))
        self.view.addGestureRecognizer(tap)
    }
    
    func handleScreenTap(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    @IBAction func cancelBtnWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func authBtnWasPressed(_ sender: Any) {
        if emailField.text != nil && passwordField.text != nil {
            authBtn.animateButton(shouldLoad: true, withMessage: nil)
            self.view.endEditing(true)
            
            if let email = emailField.text, let password = passwordField.text {
                FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                    if error == nil {
                        if let user = user {
                            print("user ===> \(user) + \(user.displayName) + \(user.email))")
                            if self.segmentedControl.selectedSegmentIndex == 0 {
                                let userData = ["provider": user.providerID] as [String: Any]
                                DataService.instance.createFirebaseDBUser(uid: user.uid, userData: userData, isDriver: false)
                            } else {
                                let userData = ["provider": user.providerID, USER_IS_DRIVER: true, ACCOUNT_PICKUP_MODE_ENABLED: false, DRIVER_IS_ON_TRIP: false] as [String: Any]
                                DataService.instance.createFirebaseDBUser(uid: user.uid, userData: userData, isDriver: true)
                            }
                        }
                        //self.dismiss(animated: true, completion: nil)
                        self.moveToHome()
                    } else {
                        if let errorCode = FIRAuthErrorCode(rawValue: error!._code) {
                            switch errorCode {
                            case .errorCodeWrongPassword:
                                self.showAlert(ERROR_MSG_WRONG_PASSWORD)
                            default:
                                self.showAlert(ERROR_MSG_UNEXPECTED_ERROR)
                            }
                        }
                        
                        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                            if error != nil {
                                if let errorCode = FIRAuthErrorCode(rawValue: error!._code) {
                                    switch errorCode {
                                    case .errorCodeInvalidEmail:
                                        self.showAlert(ERROR_MSG_INVALID_EMAIL)
                                    default:
                                        self.showAlert(ERROR_MSG_UNEXPECTED_ERROR)
                                    }
                                }
                            } else {
                                if let user = user {
                                    print("user ===> \(user) + \(user.displayName) + \(user.email))")
                                    if self.segmentedControl.selectedSegmentIndex == 0 {
                                        let userData = ["provider": user.providerID] as [String: Any]
                                        DataService.instance.createFirebaseDBUser(uid: user.uid, userData: userData, isDriver: false)
                                    } else {
                                        let userData = ["provider": user.providerID, USER_IS_DRIVER: true, ACCOUNT_PICKUP_MODE_ENABLED: false, DRIVER_IS_ON_TRIP: false] as [String: Any]
                                        DataService.instance.createFirebaseDBUser(uid: user.uid, userData: userData, isDriver: true)
                                    }
                                }
                                //self.dismiss(animated: true, completion: nil)
                                self.moveToHome()
                            }
                        }) 
                    }
                })
            }
        }
    }
    
    func moveToHome() {
        let containerVc = ContainerVC()
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeVC")
        self.navigationController?.pushViewController(containerVc, animated: true)
    }
}
