//
//  UploadViewController.swift
//  HealthyLiving
//
//  Created by J-Ro on 7/26/20.
//  Copyright © 2020 HobbyHacksHackathon. All rights reserved.
//

import UIKit
import Firebase

class UploadViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(chooseImage))
        imageView.addGestureRecognizer(gestureRecognizer)
    }
    
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var uploadButtonClicked: UIButton!
    
    func makeAlert(titleInput:String, messageInput:String) {
        let alert = UIAlertController(title: "Error", message: "Username/Password Missing", preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func chooseImage() {
       
       let pickerController = UIImagePickerController()
       pickerController.delegate = self
       pickerController.sourceType = .photoLibrary
       present(pickerController, animated: true, completion: nil)

   }

   func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
       imageView.image = info[.originalImage] as? UIImage
       self.dismiss(animated: true, completion: nil)
   }
    
    @IBAction func uploadButtonClicked(_ sender: Any) {
       let storage = Storage.storage()
       let storageReference = storage.reference()
   
       let mediaFolder = storageReference.child("media") //creates a folder inside of media folder

       // converting images to a datatype, can't be directly uploaded as a image
        if let data = imageView.image?.jpegData(compressionQuality: 0.5) {
           let uuid = UUID().uuidString // creates random text
            
            
            
           let imageReference = mediaFolder.child("\(uuid).jpg")
           imageReference.putData(data, metadata:nil) { (metadata, error) in
               if error != nil {
                    self.makeAlert(titleInput: "Error", messageInput: error?.localizedDescription ?? "Error")
               } else {
                   // get URL of upload image, to save it to database along with other information, eg date
                   imageReference.downloadURL { (url, error) in
                       if error == nil {
                           let imageUrl = url?.absoluteString
                           
                        
        // DATABASE
        
        let firestoreDatabase = Firestore.firestore()
        
        var firestoreReference : DocumentReference? = nil

                        var firestorePost = ["imageUrl" : imageUrl!, "postedBy" : Auth.auth().currentUser!.email, "postComment" : self.commentTextField.text!, "date" : FieldValue.serverTimestamp(), "likes" : 0 ] as [String: Any]
            
        firestoreReference = firestoreDatabase.collection("Posts").addDocument(data: firestorePost, completion: { (error) in
                           if error != nil {
                               self.makeAlert(titleInput: "Error", messageInput: error?.localizedDescription ?? "Error")
                           } else {
                            self.imageView.image = UIImage(named: "tapToSelect.png")
                            self.commentTextField.text = ""
                            self.tabBarController?.selectedIndex = 3
                            }
            
                        })
                   }
               }
           }
        }
    }
}
}
