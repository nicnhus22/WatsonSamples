//
//  CreateProfileViewController.swift
//  BankEnroll
//
//  Created by Nicolas Husser on 21/11/2017.
//  Copyright © 2017 Wavestone. All rights reserved.
//

import UIKit
import SpeechToTextV1
import AVFoundation
import Cloudinary
import Gifu

class CreateProfileViewController: UIViewController {
    
    // ui buttons
    @IBOutlet weak var scanFaceButton: UIButton!
    
    // ui image
    @IBOutlet weak var scanFaceIcon: UIImageView!
    @IBOutlet weak var scanFaceGif: GIFImageView!
    
    // ui labels
    @IBOutlet weak var maleLabel: UILabel!
    @IBOutlet weak var femaleLabel: UILabel!
    
    var scanFaceCompleted: Bool = false {
        didSet {
            self.updateViewState()
        }
    }
    
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // setup view
        self.updateViewState()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func updateViewState() {
        scanFaceButton.layer.opacity      = (scanFaceCompleted ? 1 : 0.5)
        scanFaceButton.backgroundColor    = (scanFaceCompleted ? UIColor(netHex: CAColors.green) : UIColor(netHex: CAColors.orange))
        scanFaceIcon.image                = (scanFaceCompleted ? UIImage(named: CAIcons.icon_success) : UIImage(named: CAIcons.icon_error))
    }
}

extension CreateProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate  {
    
    /*
     *  UI Buttons
     */
    @IBAction func scanFaceButtonClicked(_ sender: Any) {
        // take picture = data
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    //MARK: - Done image capture here
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        startLoadingState()
        
        
        
        imagePicker.dismiss(animated: true, completion: nil)
        let image: UIImage = (info[UIImagePickerControllerOriginalImage] as? UIImage)!
        let imageData = UIImagePNGRepresentation(image)
        
        // setup cloudinary
        let config = CLDConfiguration(cloudName: UIApplication.valueForAPIKey(named: "CLOUDINARY_CLOUD_NAME"),
                                      apiKey: UIApplication.valueForAPIKey(named: "CLOUDINARY_API_KEY"))
        let cloudinary = CLDCloudinary(configuration: config)
        
        cloudinary.createUploader().upload(data: imageData!, uploadPreset: Cloudinary.UPLOAD_PRESET) {
            response, error in
            if let url = response?.url {
                // use cloudinary url transformations
                let urlTransformed = url.insertAt(string: Cloudinary.URL_TRANSFORMATION, ind: 49)
                VisualRecognitionMapper.recognizeImage(urlTransformed) {
                    maleOrFemale in
                    if maleOrFemale == Gender.MALE {
                        self.maleLabel.layer.opacity = 1
                        self.femaleLabel.layer.opacity = 0.5
                    } else {
                        self.maleLabel.layer.opacity = 0.5
                        self.femaleLabel.layer.opacity = 1
                    }
                    self.stopLoadingState()
                    self.scanFaceCompleted = true
                }
            } else { // error
                self.stopLoadingState()
                self.scanFaceCompleted = false
            }
        }
    }
    
    func startLoadingState() {
        // animate gif
        scanFaceGif.animate(withGIFNamed: "gif_loading")
        scanFaceGif.isHidden = false
        
        
        scanFaceIcon.image = UIImage(named: CAIcons.icon_upload)
        scanFaceButton.backgroundColor = UIColor(netHex: CAColors.green)
        scanFaceButton.isEnabled = false
        scanFaceButton.setTitle(NSLocalizedString("asking_ibm", comment: "").uppercased(), for: .normal)
    }
    
    func stopLoadingState() {
        scanFaceButton.isEnabled = true
        scanFaceGif.isHidden = true
    }
}




