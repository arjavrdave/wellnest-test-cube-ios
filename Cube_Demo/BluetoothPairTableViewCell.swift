//
//  BluetoothPairTableViewCell.swift
//  Created by Dhruvi Prajapati on 16/05/23.
//  Copyright © 2023 Wellnest Inc. All rights reserved.
//

import UIKit

protocol ConnectBTDeviceHandle {
    func handleConnectBTDevice(index : Int)
}
class BluetoothPairTableViewCell: UITableViewCell {

    @IBOutlet weak var lblBluetoothName: UILabel!
    @IBOutlet weak var btnPair: UIButton!
    
  //  var peripheral: WellnestPeripheral?
    
 //   weak var delegate: DeviceSelectProtocol?
    
    
    var delegate : ConnectBTDeviceHandle? = nil
    var index = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.btnPair.layer.cornerRadius = self.btnPair.frame.height / 2
    }

    @IBAction func btnPairTapped(_ sender: UIButton) {
        self.delegate?.handleConnectBTDevice(index: self.index)
        self.layoutIfNeeded()
       // self.btnPair.isEnabled = false;
//        if let d = self.delegate {
//            d.didSelectPeripheral(peripheral: self.peripheral)
//        }
    }
}



    
   
    
