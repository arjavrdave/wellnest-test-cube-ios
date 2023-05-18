//
//  SplashViewController.swift

//  Created by Dhruvi Prajapati on 16/05/23.
//  Copyright © 2023 Wellnest Inc. All rights reserved.
//

import UIKit

class SplashViewController: UIParentViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageWave: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let window = UIApplication.shared.windows.first
        let topPadding = window?.safeAreaInsets.top
        
        self.scrollView.setContentOffset(CGPoint.init(x: (self.imageWave.bounds.maxX - UIScreen.main.bounds.width), y:  -(topPadding ?? 0)), animated: false)
        
        UIView.animate(withDuration: 2, animations: {
            self.scrollView.scrollRectToVisible(self.imageWave.frame, animated: true)
            self.view.layoutIfNeeded()
        }) { (complete) in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "OrgLoginViewController") as! OrgLoginViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
      
    }
}
