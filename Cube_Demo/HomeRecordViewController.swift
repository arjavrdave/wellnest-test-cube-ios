//
//  HomeRecordViewController.swift

//  Created by Dhruvi Prajapati on 16/05/23.
//  Copyright © 2023 Wellnest Inc. All rights reserved.
//

import UIKit

protocol RecordingUploadDelegate :NSObject {
    func offlineRecordingUplaodedSuccessfully()
}

class HomeRecordViewController: UIParentViewController, UITextFieldDelegate {
    
    @IBOutlet weak var viewLineHeader: UIView!
    @IBOutlet weak var btnNewRecording: UIButton!

    var searchText = String()
    var isSearchOpen = false
    var resultAwaited = false
    var refreshControl = UIRefreshControl()
    
    var loadMoreData = false
    var isLoading = false
    var skip = 0
    var take = 30
    let delegate = (UIApplication.shared.delegate as! AppDelegate)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
    }
    
   
    override func viewDidDisappear(_ animated: Bool) {
    }
    
    
    @IBAction func btnReadingTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title:  "", message: "Please pair your device to start Auscultation reading.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
        alertController.addAction(UIAlertAction(title: "Pair Now", style: .default))
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PairDeviceViewController") as! PairDeviceViewController

        self.navigationController?.pushViewController(vc, animated: true)
        self.present(alertController, animated: false)

    }
    
    
}
