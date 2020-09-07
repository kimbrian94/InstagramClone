//
//  ViewController.swift
//  Instagram
//
//  Created by Brian Kim on 2020-07-28.
//  Copyright © 2020 Brian Kim. All rights reserved.
//

// import Parse
import UIKit
import Parse

class ViewController: UIViewController {
    // Object initialization
    var signupModeActive = true
    
    // Outlet initialization
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var signupOrLoginButton: UIButton!
    @IBOutlet weak var switchLoginModeButton: UIButton!
    
    // This function displays alerts to user using UIAlertController
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // This IBAction function signs up or logs in a user depending on the mode
    @IBAction func signupOrLogin(_ sender: Any) {
        if email.text == "" || password.text == "" {
            displayAlert(title: "Error in form", message: "Please enter an email and password")
            
            email.text = nil
            password.text = nil
            // Signup Mode
        } else {
            // Set up activity indicator to run while the app signs in or logs in a user
            let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.style = UIActivityIndicatorView.Style.medium
            
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            self.view.isUserInteractionEnabled = false
            
            // If sign up mode is true, then create a new Parse Server user object and sign up user in the server
            if signupModeActive {
                let user = PFUser()
                user.username = email.text!
                user.password = password.text!
                user.email = email.text!

                user.signUpInBackground { (succeeded, error) in
                    activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    
                    // If user successfully signed up, then perform segue to UserTableViewController
                    if succeeded {
                        print("sign up was successful")
                        self.performSegue(withIdentifier: "showUserTable", sender: self)
                    } else {
                        self.displayAlert(title: "Could not sign you up", message: error!.localizedDescription)
                    }
                }
                
                email.text = nil
                password.text = nil
            // If sign up mode is false, then attempt to log the user into the app server
            } else {
                PFUser.logInWithUsername(inBackground: email.text!, password: password.text!) { (user, error) in
                    activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    
                    if user != nil {
                        // If successfully logged in, then perform segue to UserTableViewController
                        print("Login successful")
                        self.performSegue(withIdentifier: "showUserTable", sender: self)
                    } else {
                        // If not, display error alert
                        var errorText = "Unknown error: please try again"
                        
                        if let error = error {
                            errorText = error.localizedDescription
                        }
                        
                        self.displayAlert(title: "Could not log you in", message: errorText)
                    }
                }
                email.text = ""
                password.text = ""
            }
        }
    }
    
    // This IBAction function switches between sign up mode and log in mode
    @IBAction func switchLoginMode(_ sender: Any) {
        if signupModeActive {
            signupModeActive = false
            signupOrLoginButton.setTitle("Log In", for: [])
            switchLoginModeButton.setTitle("Sign Up", for: [])
        } else {
            signupModeActive = true
            signupOrLoginButton.setTitle("Sign Up", for: [])
            switchLoginModeButton.setTitle("Log In", for: [])
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // If view appear again while a user is still logged in, perform segue to the UserTableViewController
    override func viewDidAppear(_ animated: Bool) {
        if PFUser.current() != nil {
            performSegue(withIdentifier: "showUserTable", sender: self)
        }
        
        self.navigationController?.navigationBar.isHidden = true
    }


}

