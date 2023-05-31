//
//  OrgIdViewController.swift
//  Created by Dhruvi Prajapati on 16/05/23.
//  Copyright © 2023 Wellnest Inc. All rights reserved.
//

import UIKit

class OrgLoginViewController: UIParentViewController, UITextFieldDelegate {
    
    var organisationIdentifier = ""
    
    @IBOutlet weak var txtFOrgId: UITextField!
    @IBOutlet weak var constNextBottomSpace: NSLayoutConstraint!
    
    @IBOutlet weak var btnNext: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        txtFOrgId.textColor = .black
        if self.organisationIdentifier != ""{
            self.txtFOrgId.text = self.organisationIdentifier
        }
        self.txtFOrgId.delegate = self
        self.btnNext.layer.cornerRadius = self.btnNext.frame.height / 2
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.constNextBottomSpace.constant = 20
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.constNextBottomSpace.constant = 20
        // self.constButtonBottom = self.constNextBottomSpace
    }
    @IBAction func btnCancelTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 7
        let currentString: NSString = (textField.text ?? "") as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    
    @IBAction func btnNextTapped(_ sender: UIButton) {
        if let orgId = self.txtFOrgId.text {
            if orgId == "" {
                let alertController = UIAlertController(title:  "Error", message: "Please enter valid Organisation Identifier.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .default))
                self.present(alertController, animated: false)
            } else {
                DispatchQueue.main.async {
                    //                    UILoader.startAnimating()
                    self.view.endEditing(true)
                }
                if txtFOrgId.text == "WLN1234"{
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeRecordViewController") as! HomeRecordViewController
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else{
                    let alertController = UIAlertController(title:  "Error", message: "Please enter valid Organisation Identifier.", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: .default))
                    self.present(alertController, animated: false)
                }
            }
        }
        
        
    }
}
