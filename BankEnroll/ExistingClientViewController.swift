//
//  ExistingClientViewController.swift
//  BankEnroll
//
//  Created by Nicolas Husser on 21/11/2017.
//  Copyright © 2017 Wavestone. All rights reserved.
//


import UIKit
import SpeechToTextV1
import AVFoundation
import Gifu

class ExistingClientViewController: UIViewController {
    
    
    
    // buttons
    @IBOutlet weak var scanCardButton: UIButton!
    @IBOutlet weak var dictateInformationButton: UIButton!
    
    // images
    @IBOutlet weak var scanCardIcon: UIImageView!
    @IBOutlet weak var dictateInformationIcon: UIImageView!
    
    // gifs
    @IBOutlet weak var dictateInformationGIF: GIFImageView!
    
    // labels
    @IBOutlet weak var debugLabel: UILabel!
    
    // fields
    @IBOutlet weak var creditCardNumberTextFieldScan: CATextField!
    @IBOutlet weak var creditCardExpiryTextFieldScan: CATextField!
    @IBOutlet weak var creditCardNumberTextFieldDict: CATextField!
    @IBOutlet weak var creditCardExpiryTextFieldDict: CATextField!
    
    var speechToText: SpeechToText!
    
    var scanCardCompleted: Bool = false {
        didSet {
            self.updateViewState()
        }
    }
    
    var dictateInformationCompleted: Bool = false {
        didSet {
            self.updateViewState()
        }
    }
    
    var activeRecordingState: Bool = false {
        didSet {
            if activeRecordingState {
                self.startActiveRecordingState()
            } else {
                self.stopActiveRecordingState()
            }
        }
    }
    
    var activeTextField: CATextField? {
        didSet {
            if activeTextField == nil {
                self.creditCardNumberTextFieldDict.unHighlightField()
                self.creditCardExpiryTextFieldDict.unHighlightField()
            } else if activeTextField == self.creditCardExpiryTextFieldDict {
                self.creditCardNumberTextFieldDict.unHighlightField()
                self.creditCardExpiryTextFieldDict.highlightField()
            } else if activeTextField == self.creditCardNumberTextFieldDict {
                self.creditCardExpiryTextFieldDict.unHighlightField()
                self.creditCardNumberTextFieldDict.highlightField()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // initialize IBM Speech To Text
        speechToText = SpeechToText(username: UIApplication.valueForAPIKey(named: "SPEECH_TO_TEXT_USERNAME"), password: UIApplication.valueForAPIKey(named: "SPEECH_TO_TEXT_PASSWORD"))
        initializeView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func initializeView() {
        dictateInformationButton.setTitle(NSLocalizedString("we_re_listening", comment: "").uppercased(), for: .normal)
        scanCardButton.setTitle(NSLocalizedString("scan_my_credit_card", comment: "").uppercased(), for: .normal)
        dictateInformationButton.setTitle(NSLocalizedString("we_re_listening", comment: "").uppercased(), for: .normal)
        creditCardNumberTextFieldScan.placeholder = NSLocalizedString("credit_card_number", comment: "")
        creditCardExpiryTextFieldScan.placeholder = NSLocalizedString("expires_on", comment: "")
        creditCardNumberTextFieldDict.placeholder = NSLocalizedString("credit_card_number", comment: "")
        creditCardExpiryTextFieldDict.placeholder = NSLocalizedString("expires_on", comment: "")
    }
}

/*
 *  IBM Watson
 */
extension ExistingClientViewController {
    
    //
    @IBAction func dictateInformation(_ sender: Any) {
        if !activeRecordingState {
            startStreaming()
        } else {
            stopStreaming()
        }
    }
    
    func startStreaming() {
        self.activeRecordingState = true
        
        var settings = RecognitionSettings(contentType: .oggOpus)
        settings.interimResults = true
        settings.smartFormatting = true
        let failure = { (error: Error) in print(error) }
        speechToText.recognizeMicrophone(settings: settings, model: "en-US_BroadbandModel", failure: failure) { results in
            let onlyDigits = results.bestTranscript.replacingOccurrences(of: " ", with: "").digits
            self.debugLabel.text = onlyDigits
            self.selectTextField(string: String(results.bestTranscript.suffix(40)))
            if self.activeTextField != nil {
                self.writeOnTextField(textField: self.activeTextField!, withText: onlyDigits)
            }
        }
    }
    
    func stopStreaming() {
        speechToText.stopRecognizeMicrophone()
        self.activeRecordingState = false
        self.dictateInformationCompleted = true
        self.activeTextField = nil
    }
    
    func startActiveRecordingState() {
        // animate gif
        dictateInformationGIF.animate(withGIFNamed: "gif_loading")
        dictateInformationGIF.isHidden = false
        
        self.dictateInformationIcon.image = UIImage(named: CAIcons.icon_microphone)
        dictateInformationButton.setTitle(NSLocalizedString("we_re_listening", comment: "").uppercased(), for: .normal)
        dictateInformationButton.backgroundColor = UIColor(netHex: CAColors.green)
    }
    
    func stopActiveRecordingState() {
        // hide gif
        dictateInformationGIF.isHidden = true
    }
    
    func selectTextField(string: String) {

        var startPosCCN:Int = -1
        var startPosED:Int  = -1
        
        if let range =  string.range(of: "card number") {
            startPosCCN = string.distance(from: string.startIndex, to: range.upperBound)
        }
        if let range =  string.range(of: "expires on") {
            startPosED = string.distance(from: string.startIndex, to: range.upperBound)
        }
        
        // cvc
        if (startPosCCN != -1) && (startPosCCN == [startPosCCN, startPosED].max()!) {
            self.activeTextField = self.creditCardNumberTextFieldDict
        } else if (startPosED != -1) && (startPosED == [startPosCCN, startPosED].max()!) {
            self.activeTextField = self.creditCardExpiryTextFieldDict
        }
        
        if string.range(of: "stop") != nil {
            self.stopStreaming()
        }
    }
    
    func writeOnTextField(textField: CATextField, withText: String) {
        print(textField)
        print(withText)
        if textField == self.creditCardExpiryTextFieldDict && withText.count == 4 {
            let expiryDate = String(withText.suffix(4)).insertAt(string: " / ", ind: 2)
            self.creditCardExpiryTextFieldDict.text = expiryDate
            self.flushBuffer()
        } else if textField == self.creditCardNumberTextFieldDict && withText.count > 16 {
            let cardNumber = String(withText.suffix(16))
            self.creditCardNumberTextFieldDict.text = cardNumber.inserting(separator: " ", every: 4)
            self.flushBuffer()
        }
    }
    
    func flushBuffer() {
        speechToText.stopRecognizeMicrophone()
        startStreaming()
    }
}

/*
 *  Stripe
 */
extension ExistingClientViewController:CardIOPaymentViewControllerDelegate {
    
    @IBAction func scanCard(sender: AnyObject) {
        let cardIOVC = CardIOPaymentViewController(paymentDelegate: self)
        cardIOVC?.collectCardholderName = true
        cardIOVC?.scannedImageDuration = 0.0
        cardIOVC?.suppressScanConfirmation = true
        cardIOVC?.modalPresentationStyle = .fullScreen
        present(cardIOVC!, animated: true, completion: nil)
    }
    
    func userDidCancel(_ paymentViewController: CardIOPaymentViewController!) {
        paymentViewController?.dismiss(animated: true, completion: nil)
    }
    
    func userDidProvide(_ cardInfo: CardIOCreditCardInfo!, in paymentViewController: CardIOPaymentViewController!) {
        if let info = cardInfo {
            creditCardNumberTextFieldScan.text = info.cardNumber.inserting(separator: " ", every: 4)
            creditCardExpiryTextFieldScan.text = "\(info.expiryMonth)/\(info.expiryYear)"
            scanCardCompleted = true
        }
        paymentViewController?.dismiss(animated: true, completion: nil)
    }
}

/**
 *  View
 */
extension ExistingClientViewController {
    
    func updateViewState() {
        scanCardButton.setTitle((scanCardCompleted ? NSLocalizedString("credit_card_scanned", comment: "").uppercased() : NSLocalizedString("scan_my_credit_card", comment: "").uppercased() ), for: .normal)
        scanCardButton.layer.opacity      = (scanCardCompleted ? 1 : 0.5)
        scanCardButton.backgroundColor    = (scanCardCompleted ? UIColor(netHex: CAColors.green) : UIColor(netHex: CAColors.orange))
        scanCardIcon.image                = (scanCardCompleted ? UIImage(named: CAIcons.icon_success) : UIImage(named: CAIcons.icon_error))
        
        dictateInformationButton.setTitle((dictateInformationCompleted ? NSLocalizedString("information_collected", comment: "").uppercased() : NSLocalizedString("dictate_information", comment: "").uppercased()), for: .normal)
        dictateInformationButton.layer.opacity   = (dictateInformationCompleted ? 1 : 0.5)
        dictateInformationButton.backgroundColor = (dictateInformationCompleted ? UIColor(netHex: CAColors.green) : UIColor(netHex: CAColors.orange))
        dictateInformationIcon.image             = (dictateInformationCompleted ? UIImage(named: CAIcons.icon_success) : UIImage(named: CAIcons.icon_error))
    }
    
}
