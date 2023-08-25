//
//  TransferServices.swift
//  Created by Dhruvi Prajapati on 16/05/23.
//  Copyright © 2023 Wellnest Inc. All rights reserved.
//

import Foundation
import CoreBluetooth
struct TransferService {
    static let serviceUUID = CBUUID(string: "1802")
    static let characteristicUUID = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")
    static let ecgCharacteristicUUID = CBUUID(string: "6E40196A-B5A3-F393-E0A9-E50E24DCCA9E")
}
