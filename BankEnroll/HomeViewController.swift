//
//  ViewController.swift
//  BankEnroll
//
//  Created by Nicolas Husser on 21/11/2017.
//  Copyright © 2017 Wavestone. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var createProfileButton: UIButton!
    @IBOutlet weak var alreadyClientButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationController?.navigationBar.tintColor = UIColor(netHex: CAColors.green)
        
        //
        self.createProfileButton.setTitle(NSLocalizedString("create_profile", comment: "").uppercased(), for: .normal)
        self.alreadyClientButton.setTitle(NSLocalizedString("already_client", comment: "").uppercased(), for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated);
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}

