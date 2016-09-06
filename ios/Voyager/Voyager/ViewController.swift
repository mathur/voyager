//
//  ViewController.swift
//  Voyager
//
//  Created by Tommy Yu on 6/18/16.
//  Copyright © 2016 BattleOfHacks. All rights reserved.
//

import UIKit
import Alamofire
import Toast_Swift

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var emailInput: UITextField!
    
    var pickerData = [String]()
    var imagePicker: UIImagePickerController!
    var image: UIImage!
    var imageString: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.picker.delegate = self
        self.picker.dataSource = self
        
        pickerData = ["Van Gogh", "HackIllinois", "Colorful"]
        
        
        emailInput.keyboardType = UIKeyboardType.EmailAddress
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }

    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 75
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        image = (info[UIImagePickerControllerOriginalImage] as? UIImage)!
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        let imageData = UIImagePNGRepresentation(image)!
        let strBase64:String = imageData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        imageString = strBase64
        
        //let decodedData = NSData(base64EncodedString: imageString, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
        //let decodedImage = UIImage(data: decodedData!)!
        //imageView.image = decodedImage as UIImage
    }
    
    @IBAction func openCamera(sender: UIButton) {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .Camera
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func selectFromGallery(sender: UIButton) {
        imagePicker = UIImagePickerController()
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.delegate = self
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func processPhoto(sender: UIButton) {
        let index = picker.selectedRowInComponent(0)
        let email = self.emailInput.text as String!
        print(email)
        if(email != nil && email != ""){
            Alamofire.request(.GET, "http://jsonplaceholder.typicode.com/users", parameters: ["image": "imageString", "style":index, "email":email])
                .response { request, response, data, error in
                    print(request)
                    print(response)
                    print(error)
            }
            
            self.view.makeToast("Processing photo. Expect an email soon :)")
        }else{
            self.view.makeToast("Please enter a valid email")
        }
       
    }
    
}

