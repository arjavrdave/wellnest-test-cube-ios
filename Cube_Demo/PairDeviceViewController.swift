//
//  PairDeviceViewController.swift
//  Created by Dhruvi Prajapati on 16/05/23.
//  Copyright © 2023 Wellnest Inc. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol ProtoDeviceConnected {
    func isDeviceConnected(connected: Bool)
}
protocol ProtoBBSConnected {
    func bbsConnected(peripheral: CBPeripheral, centralManager: CBCentralManager)
}

class PairDeviceViewController: UIParentViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral!
    var connectedPeripheral: CBPeripheral?
    var peripherals = Array<CBPeripheral>()
    var advertisementData = [String]()
    var discoveredPeripheral: CBPeripheral?
    var transferCharacteristic: CBCharacteristic?

    var deviceceConnected = false
    var previousScreenAuscultation = false
    
    var delegate : ProtoDeviceConnected? = nil
    var delegate2 : ProtoBBSConnected? = nil
    var helloData = Data()
    
    var writeIterationsComplete = 0
    var connectionIterationsComplete = 0
    let defaultIterations = 5
    var data = Data()
    var previousTimeInterval = Date()
    
    @IBOutlet weak var lblConnectMsg: UILabel!
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnProceed: UIButton!
    @IBOutlet weak var constBottomMessage: NSLayoutConstraint!
    @IBOutlet weak var btnCancel: UIButton!
    
    var isFromSplash = false
   
    var isReRecordFlow = false
    var recordingID : Int?
    var recordingName : String?
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        self.lblConnectMsg.text = "Press & hold power button until you see blinking lights on Wellnest 12L®"
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main, options: [CBCentralManagerOptionShowPowerAlertKey: true])
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.peripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String.init(describing: "BluetoothPairTableViewCell")) as! BluetoothPairTableViewCell
        cell.lblBluetoothName.text = self.peripherals[indexPath.row].name
        print("name",self.peripherals[indexPath.row].name)
        cell.delegate = self
        cell.index = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        if self.lblConnectMsg.text == "Select Wellnest 12L® from the list to connect" {
            self.lblConnectMsg.text = "Press & hold power button until you see blinking lights on Wellnest 12L®"
            self.tableView.isHidden = true
            self.btnProceed.isHidden = false
            //self.viewBottom.isHidden = false
            self.btnProceed.setTitle("NEXT", for: .normal)
            self.constBottomMessage.constant = 65
            self.view.layoutIfNeeded()
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnCancelTapped(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    private func retrievePeripheral() {
        
        let connectedPeripherals: [CBPeripheral] = (centralManager.retrieveConnectedPeripherals(withServices: [TransferService.serviceUUID]))
        
        print("Found connected Peripherals with transfer service: %@", connectedPeripherals)
        
        if let connectedPeripheral = connectedPeripherals.last {
            print("Connecting to peripheral %@", connectedPeripheral)
            centralManager.connect(connectedPeripheral, options: nil)
        } else {
            // We were not connected to our counterpart, so start scanning
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    private func cleanup() {
        // Don't do anything if we're not connected
        guard let discoveredPeripheral = discoveredPeripheral,
              case .connected = discoveredPeripheral.state else { return }
        
        for service in (discoveredPeripheral.services ?? [] as [CBService]) {
            for characteristic in (service.characteristics ?? [] as [CBCharacteristic]) {
                if characteristic.uuid == TransferService.characteristicUUID && characteristic.isNotifying {
                    // It is notifying, so unsubscribe
                    self.discoveredPeripheral?.setNotifyValue(true, for: characteristic)
                }
            }
        }
    }
}
    
    
extension PairDeviceViewController: CBCentralManagerDelegate {
        
        internal func centralManagerDidUpdateState(_ central: CBCentralManager) {
            
            switch central.state {
            case .poweredOn:
                // ... so start working with the peripheral
                print("CBManager is powered on")
                retrievePeripheral()
            case .poweredOff:
                print("CBManager is not powered on")
                // In a real app, you'd deal with all the states accordingly
                return
            case .resetting:
                print("CBManager is resetting")
                // In a real app, you'd deal with all the states accordingly
                return
            case .unauthorized:
                // In a real app, you'd deal with all the states accordingly
                if #available(iOS 13.0, *) {
                    switch central.authorization {
                    case .denied:
                        print("You are not authorized to use Bluetooth")
                    case .restricted:
                        print("Bluetooth is restricted")
                    default:
                        print("Unexpected authorization")
                    }
                } else {
                    // Fallback on earlier versions
                }
                return
            case .unknown:
                print("CBManager state is unknown")
                // In a real app, you'd deal with all the states accordingly
                return
            case .unsupported:
                print("Bluetooth is not supported on this device")
                // In a real app, you'd deal with all the states accordingly
                return
            @unknown default:
                print("A previously unknown central manager state occurred")
                // In a real app, you'd deal with yet unknown cases that might occur in the future
                return
            }
        }
        
        
        func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                            advertisementData: [String: Any], rssi RSSI: NSNumber) {
            
            // Reject if the signal strength is too low to attempt data transfer.
            // Change the minimum RSSI value depending on your app’s use case.
            
            print("Discovered %s at %d", String(describing: peripheral.name), RSSI.intValue)
            
            if peripheral.name?.hasPrefix("BB") == true{
                if let localName = advertisementData[CBAdvertisementDataLocalNameKey], !self.peripherals.contains(peripheral) {
                    self.advertisementData.append(String(describing: localName))
                    self.peripherals.append(peripheral)
                    self.tableView.reloadData()
                }
            }
        }
        
        /*
         *  If the connection fails for whatever reason, we need to deal with it.
         */
        func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
            print("Failed to connect to %@. %s", peripheral, String(describing: error))
            cleanup()
        }
        
        /*
         *  We've connected to the peripheral, now we need to discover the services and characteristics to find the 'transfer' characteristic.
         */
        func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
            print("Peripheral Connected")
            centralManager.stopScan()
            self.discoveredPeripheral = peripheral
            let alertController = UIAlertController(title: "Connected", message: "Device Connected Successfully", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {_ in
                //  self.afterConnectionView.isHidden = false
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                self.navigationController?.pushViewController(vc, animated: true)
                
                self.data.removeAll(keepingCapacity: false)
                
                // Make sure we get the discovery callbacks
                peripheral.delegate = vc
                
                // Search only for services that match our UUID
                peripheral.discoverServices(nil)
            }))
            self.present(alertController, animated: false)
            
        }
        
        /*
         *  Once the disconnection happens, we need to clean up our local copy of the peripheral
         */
        func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
            let alertController = UIAlertController(title: "Disconnected", message: "Device Disconnected", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "ok", style: .default){_ in
               // self.navigationController?.popToRootViewController(animated: true)
            })
            self.present(alertController, animated: false)
            print("Perhiperal Disconnected")
            discoveredPeripheral = nil
            
            // We're disconnected, so start scanning again
            if connectionIterationsComplete < defaultIterations {
                retrievePeripheral()
            } else {
                print("Connection iterations completed")
            }
        }
        
}
extension PairDeviceViewController : ConnectBTDeviceHandle {
    func handleConnectBTDevice(index: Int) {
        centralManager.connect(self.peripherals[index])
    }
}
