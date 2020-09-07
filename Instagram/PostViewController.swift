//
//  PostViewController.swift
//  Instagram
//
//  Created by Brian Kim on 2020-08-03.
//  Copyright © 2020 Brian Kim. All rights reserved.
//

import UIKit
import Parse

class PostViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // Outlets initialization
    @IBOutlet weak var imageToPost: UIImageView!
    @IBOutlet weak var comment: UITextField!
    
    // This function displays alert to user using UIAlertController
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // This IBAction runs when choose image button is  tapped
    // Chooses image from the photo library to post
    @IBAction func chooseImage(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = false
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    // This function runs when the image is successfully selected from the library, points the image to the imageToPost object and dismisses the imagePicker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageToPost.image = image
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // Posts image by making a Parse server object of class "Post" with their attributes properly set and save it to the database
    @IBAction func postImage(_ sender: Any) {
        if let image = imageToPost.image {
            let post = PFObject(className: "Post")
            
            post["message"] = comment.text!
            post["userid"] = PFUser.current()?.objectId
            
            if let imageData = image.pngData() {
                let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
                activityIndicator.center = self.view.center
                activityIndicator.hidesWhenStopped = true
                activityIndicator.style = UIActivityIndicatorView.Style.medium
                
                view.addSubview(activityIndicator)
                activityIndicator.startAnimating()
                self.view.isUserInteractionEnabled = false
                
                let imageFile = PFFileObject(name: "image.png", data: imageData)
                post["imageFile"] = imageFile
                
                post.saveInBackground { (success, error) in
                    activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    
                    if success {
                        self.displayAlert(title: "Image Posted!", message: "Your image has been posted successfully")
                        self.comment.text = ""
                        self.imageToPost.image = nil
                    } else {
                        self.displayAlert(title: "Image Could Not Be Posted", message: "Please try again later")
                    }
                }
            }
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
