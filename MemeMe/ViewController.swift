//
//  ViewController.swift
//  MemeMe
//
//  Created by Hari Prasad on 1/14/20.
//  Copyright © 2020 Hari Prasad. All rights reserved.
//

import UIKit

class ViewController: UIViewController,  UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var imagePicker: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var topNavigationBar: UIToolbar!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    
    // MARK: MemeMe Text Attributes
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40),
        NSAttributedString.Key.strokeWidth: -3.0
        
    ]
    
    struct Meme {
        let topText: String
        let bottomText: String
        let originialImage: UIImage
        let memedImage: UIImage
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextField(textField: topTextField, defaultText: "TOP")
        configureTextField(textField: bottomTextField, defaultText: "BOTTOM")
        
    }
    
    func configureTextField(textField: UITextField, defaultText: String) {
        textField.delegate = self
        textField.text = defaultText
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
        shareButton.isEnabled = false
    }
    
    //MARK: Setting the textfield to blank when it is clicked
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
        
    }
    
    //MARK: textFieldShouldReturn function implementation
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    // MARK: Picking an Image from Album
    @IBAction func pickImageFromAlbum(_ sender: Any) {
        presentImagePickerWith(sourceType: .photoLibrary)
        
    }
    
    // MARK: Capture image from camera
    @IBAction func pickImageFromCamera(_ sender: Any) {
        presentImagePickerWith(sourceType: .camera)
    }
    
    // MARK: Navigating to the respective screen based on source type
    func presentImagePickerWith(sourceType: UIImagePickerController.SourceType) {
        let memeImagePickerController = UIImagePickerController()
        memeImagePickerController.delegate = self
        memeImagePickerController.sourceType = sourceType
        present(memeImagePickerController, animated: true, completion: nil)
        shareButton.isEnabled = true
    }
    
    // MARK: Action taking when Share icon pressed
    @IBAction func actionButtonPressed(_ sender: Any) {
        
        let image = generateMemedImage()
        let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
        
        activityController.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?, completed:
        Bool, arrayReturnedItems: [Any]?, error: Error?) in
            if completed {
                print("share completed")
                self.save()
                return
            } else {
                print("cancel")
            }
            if let shareError = error {
                print("error while sharing: \(shareError.localizedDescription)")
            }
        }
        //dismiss(animated: true, completion: nil)

    }
    
    // MARK: Cancel button implementation
    @IBAction func cancelButtonPressed(_ sender: Any) {
         self.topTextField.text = "TOP"
        self.bottomTextField.text = "BOTTOM"
         shareButton.isEnabled = false
        imagePicker.image = nil
    }
    
    // MARK: imagePickerController implementation
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imageName = info[.originalImage] as? UIImage {
              imagePicker.image = imageName
          }
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: imagePickerControllerDidCancel
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Swiping the view when Keyboard appears
    @objc func keyboardWillShow(_ notification: Notification) {
        if bottomTextField.isEditing {
            view.frame.origin.y -= getKeyBoardHeight(notification)
        }
        
    }
    
    // MARK: Swiping back the view when Keyboard dissapears
    @objc func keyboardWillHide(_ notification: Notification) {
        
        view.frame.origin.y = 0
    }

    //MARK: Subscribe Keyboard notifications
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    //MARK: Subscribe notifications when keyboard is hiding
    func subscribeToKeyboardHideNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        subscribeToKeyboardHideNotifications()
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unSubscribeToKeyboardNotifications()
        unSubscribeToKeyboardHideNotifications()
    }

    //MARK: Getting Keyboard size
    func getKeyBoardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height

    }
    
    //MARK: Unsubscribe to Keyboard notifications
    func unSubscribeToKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }

    //MARK: Unsubscribe the notifications for Keyboard hide
    func unSubscribeToKeyboardHideNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: Save function
    func save() {
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originialImage: imagePicker.image!, memedImage: generateMemedImage())
       
    }
    
    //MARK: Generating the Memed image
    func generateMemedImage() -> UIImage {
        
        configureToolBars(status: true)
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        configureToolBars(status: false)
        
        return memedImage
    }
    
    // MARK: Configure Tool Bars based on need
    func configureToolBars(status: Bool) {
        topNavigationBar.isHidden = status
        bottomToolBar.isHidden = status
    }

   
}

