//
//  ViewController.swift
//  Created by Dhruvi Prajapati on 16/05/23.
//  Copyright © 2023 Wellnest Inc. All rights reserved.
//

import UIKit
import RangeSeekSlider
import CoreBluetooth
import DSWaveformImage

class ViewController: UIViewController,RangeSeekSliderDelegate {
    
    @IBOutlet weak var lblLowFrequency: UILabel!
    @IBOutlet weak var lblHighFrequency: UILabel!
    @IBOutlet weak var imgWaveForm: UIImageView!
    @IBOutlet weak var imgEcgGraph: UIImageView!
    @IBOutlet weak var graphView: UIImageView!
  //  @IBOutlet weak var waveFormView: WaveformLiveView!
    @IBOutlet weak var rangeSlider: RangeSeekSlider!
    var adpcmDecoder = ADPCMDecode()
    var toneGenerator = ToneGenerator()
    var helloData = Data()
    var rawData = Data()
    var ringBuffer: RingBuffer<Data>?
    var transferCharacteristic: CBCharacteristic?
    
    var recordingData = [[Double]]()
    // var recordingData = [Double]()
    
    var timer = Timer()
    var currentDataCount = 0
    var shapeLayer = CAShapeLayer()
    var beziewPath  = UIBezierPath()
    var arrayBezierPath = [UIBezierPath]()
    var points = [CGPoint]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let filePath = Bundle.main.url(forResource: "correctRecoedingThreshold", withExtension: nil) {
            if var ecgData = try? Data(contentsOf: filePath) {
                self.recordingData = self.parseRecording(dataECG: ecgData)
            }
        }
        self.graphView.layer.addSublayer(self.shapeLayer)
        
        
        toneGenerator.setupAudioUnit()
        toneGenerator.start()
        
        rangeSlider.delegate = self
        rangeSlider.minValue = 0
        rangeSlider.maxValue = 2000
        rangeSlider.colorBetweenHandles = .systemBlue
        rangeSlider.tintColor = .lightGray
        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnBackTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    // Range Slider Delegate method
    
    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        lblLowFrequency.text =  "  \(Int(rangeSlider.selectedMinValue)) Hz"
        lblHighFrequency.text =  "\(Int(rangeSlider.selectedMaxValue)) Hz  "
    }
    @IBAction func btnShareFileTapped(_ sender: UIButton) {
        // Decode data
        //        let path = FileManager.default.urls(for: .documentDirectory,
        //                                            in: .userDomainMask)[0].appendingPathComponent("DhruviMadam")
        //
        //
        //        try? self.helloData.write(to: path)
        //        let path1 = FileManager.default.urls(for: .documentDirectory,
        //                                             in: .userDomainMask)[0].appendingPathComponent("DhruviMadamRaw")
        //        try? self.rawData.write(to: path1)
        
        // Draw graph
        self.timer = Timer.scheduledTimer(timeInterval: 0.002, target: self, selector: #selector(drawGraph), userInfo: nil, repeats: true)
    }
    @IBAction func filterHeartTapped(_ sender: Any) {
        rangeSlider.selectedMinValue = 20
        rangeSlider.selectedMaxValue = 200
        rangeSlider.colorBetweenHandles = .systemBlue
        rangeSlider.tintColor = .lightGray
        lblLowFrequency.text = "  20 Hz"
        lblHighFrequency.text = "200 Hz  "
    }
    @IBAction func filterLungsTapped(_ sender: Any) {
        rangeSlider.selectedMinValue = 100
        rangeSlider.selectedMaxValue = 2000
        rangeSlider.colorBetweenHandles = .systemBlue
        rangeSlider.tintColor = .lightGray
        lblLowFrequency.text = "  100 Hz"
        lblHighFrequency.text = "2000 Hz  "
    }
    @IBAction func filterBowelTapped(_ sender: Any) {
        rangeSlider.selectedMinValue = 5
        rangeSlider.selectedMaxValue = 30
        rangeSlider.colorBetweenHandles = .systemBlue
        rangeSlider.tintColor = .lightGray
        lblLowFrequency.text = "  5 Hz"
        lblHighFrequency.text = "30 Hz  "
    }
    @IBAction func btnNoFilterTapped(_ sender: Any) {
        rangeSlider.selectedMinValue = 0
        rangeSlider.selectedMaxValue = 2000
        rangeSlider.colorBetweenHandles = .systemBlue
        rangeSlider.tintColor = .lightGray
        lblLowFrequency.text = "  0 Hz"
        lblHighFrequency.text = "2000 Hz  "
    }
    
    // Parsing Data
    func parseRecording(dataECG : Data) -> [[Double]] {
        let arr = [UInt8](dataECG)
        var finalArr = [[Double]]()
        var innerArr = [Double]()
        for a in arr {
            innerArr.append(Double(a))
            if(innerArr.count == 16) {
                finalArr.append(innerArr)
                innerArr = [Double]()
            }
        }
        let chartsData = DataParser().setUpDataForRecording(finalArr)
        var sublist = [[Double]]()
        for j in 0..<12 {
            sublist.append([Double]())
            for i in 0..<chartsData.count{
                sublist[j].append(chartsData[i][j])
            }
        }
        return sublist;
    }
    // Draw ECG graph
    @objc func drawGraph() {
        guard currentDataCount != self.recordingData[1].count else {
            self.timer.invalidate()
            return
        }
        let leadData = recordingData[1][currentDataCount]
        let baseLine = graphView.frame.height * 0.5
        let width = graphView.frame.width / 1300
        let bezierPath = UIBezierPath()
        if self.currentDataCount < 1300 {
            self.points.append(CGPoint(x: CGFloat(self.currentDataCount % 1300) * width, y: baseLine - leadData * 7))
            for i in 0..<self.points.count {
                if i == 0 {
                    bezierPath.move(to: self.points[i])
                } else {
                    bezierPath.addLine(to: self.points[i])
                }
            }
        } else {
            self.points[self.currentDataCount % 1300] = CGPoint(x: CGFloat(self.currentDataCount % 1300) * width, y: baseLine - leadData * 7)
            var i = 0
            while i < self.points.count {
                
                if i == 0 || i == (self.currentDataCount % 1300) + 130 {
                    bezierPath.move(to: self.points[i])
                } else {
                    bezierPath.addLine(to: self.points[i])
                }
                if i == self.currentDataCount % 1300 {
                    i += 130
                } else {
                    i += 1
                }
                
            }
        }
        shapeLayer.path = bezierPath.cgPath
        shapeLayer.lineWidth = 1.0
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        
        self.currentDataCount += 1
    }
    
    
    // Phonogram (Stetho Graph)
    func drawWaveForm(){
        
    }
    
}
extension ViewController: CBPeripheralDelegate {
        // implementations of the CBPeripheralDelegate methods
        
        /*
         *  The peripheral letting us know when services have been invalidated.
         */
        func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
            
            for service in invalidatedServices where service.uuid == TransferService.serviceUUID {
                print("Transfer service is invalidated - rediscover services")
                peripheral.discoverServices([TransferService.serviceUUID])
            }
        }
        
        /*
         *  The Transfer Service was discovered
         */
        func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
            if let error = error {
                print("Error discovering services: %s", error.localizedDescription)
                //cleanup()
                return
            }
            
            // Discover the characteristic we want...
            
            // Loop through the newly filled peripheral.services array, just in case there's more than one.
            guard let peripheralServices = peripheral.services else { return }
            for service in peripheralServices {
                peripheral.discoverCharacteristics([TransferService.characteristicUUID], for: service)
            }
        }
        
        /*
         *  The Transfer characteristic was discovered.
         *  Once this has been found, we want to subscribe to it, which lets the peripheral know we want the data it contains
         */
        func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
            // Deal with errors (if any).
            if let error = error {
                print("Error discovering characteristics: %s", error.localizedDescription)
                //cleanup()
                return
            }
            
            // Again, we loop through the array, just in case and check if it's the right one
            guard let serviceCharacteristics = service.characteristics else { return }
            for characteristic in serviceCharacteristics where characteristic.uuid == TransferService.characteristicUUID {
                // If it is, subscribe to it
                transferCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
            }
            
            // Once this is complete, we just need to wait for the data to come in.
        }
        
        /*
         *   This callback lets us know more data has arrived via notification on the characteristic
         */
        func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
            // Deal with errors (if any)
//            if characteristic.uuid.uuidString == "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"{
//                guard let value = characteristic.value else {return}
//                print(Date().timeIntervalSince(previousTimeInterval))
//                previousTimeInterval = Date()
//                self.data.append(value)
//            }
            if let error = error {
                // Handle error
                print(error)
                return
            }
            guard let value = characteristic.value else {
                return
            }
            if characteristic.uuid.uuidString == "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"{
                rawData.append(value)
                if ringBuffer == nil{
                    ringBuffer = RingBuffer<Data>(count: rawData.count)
                }
                //recordingData.append(value)
                
                ringBuffer?.write(element: rawData)
                let decoder = adpcmDecoder.decodedSample(data: value)
                helloData.append(decoder)
                print(decoder.count)
                for byte in decoder {
                    print("Byte = ", byte)
//                    adpcmDecoder.adpcm_decode(code: Int(byte))
//                    print("Decoding", adpcmDecoder.adpcm_decode(code: Int(byte)))
                }
            }
            if characteristic.uuid.uuidString == "6E40196A-B5A3-F393-E0A9-E50E24DCCA9E"{
                for byte in value {
                    print("ECGByte = ", byte)
                }
            }
        }
}

