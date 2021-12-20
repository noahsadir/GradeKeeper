//
//  LoginViewController.swift
//  GradeKeeper
//
//  Created by Noah Sadir on 10/28/21.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        activityIndicator.isHidden = true

        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        self.activityIndicator.isHidden = false
        self.loginButton.isHidden = true
        
        GradeKeeper.user().authenticate(email: emailTextField.text!, password: passwordTextField.text!) { (success, error) in
            if success {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "loginToCoursesUnwindSegue", sender: nil)
                }
            } else {
                GradeKeeper().errorAlert(self, error: error!)
                
                DispatchQueue.main.async {
                    self.activityIndicator.isHidden = true
                    self.loginButton.isHidden = false
                }
            }
        }
    }
    
    @IBAction func signUpButtonClicked(_ sender: Any) {
        
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
