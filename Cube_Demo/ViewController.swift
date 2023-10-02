//
//  ViewController.swift
//  Created by Dhruvi Prajapati on 16/05/23.
//  Copyright © 2023 Wellnest Inc. All rights reserved.
//

import UIKit
import RangeSeekSlider
import CoreBluetooth
import DSWaveformImage
import AVFoundation
 

class ViewController: UIViewController,RangeSeekSliderDelegate {
    
    @IBOutlet weak var lblLowFrequency: UILabel!
    @IBOutlet weak var lblHighFrequency: UILabel!
    @IBOutlet weak var imgEcgGraph: UIImageView!
    @IBOutlet weak var graphView: UIImageView!
    @IBOutlet weak var waveFormView: UIView!
    @IBOutlet weak var rangeSlider: RangeSeekSlider!
    @IBOutlet weak var lblHeartRate: UILabel!

    var adpcmDecoder = ADPCMDecode()
    var toneGenerator = ToneGenerator()
    var circularQueue : Queue<Any>?
    var ringBuffer: RingBuffer<Data>?
    var transferCharacteristic: CBCharacteristic?
    var n: Int = 0
    var stethoData : [Int] = []
    var recordingData = [[Double]]()
    var waveData : Data!
    var helloData = Data()
    var rawData = Data()
    var timer = Timer()
    var currentDataCount = 0
    var ecgShapeLayer = CAShapeLayer()
    var phonogramShapeLayer = CAShapeLayer()
    var beziewPath  = UIBezierPath()
    var arrayBezierPath = [UIBezierPath]()
    var points = Array.init(repeating: CGPoint(), count: 1050)
    var byttes = [UInt8]()
    var pointsCount = 0
    var dataByteBuffer = RingBuffer<UInt8>(count: 350)
    // ECG
    let dataParserIIR = DataParser()
    var nForIIR: Int = 0
    var ecgValuesArrayToShare = [String]()
    var filteredValuesArrayToShare = [String]()
    var filteredValuesDouble = [Double]()
    let sampleRateForECG = 500.0

    
    //BPM Variables
    var arrayBPMDictionary = [[String: String]]()
    var bpmCalculations = BPMCalcaulations()
    var dateToCheck = Date()
    
    @IBOutlet var ecgGraphView: RealTimeVitalChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        initECGChart()
        
        
        if let filePath = Bundle.main.url(forResource: "StethoRawData", withExtension: nil) {
            if var stethoData = try? Data(contentsOf: filePath) {
                self.waveData = stethoData
                print(stethoData)
            }
        }
        
        self.rawData = try! Data(contentsOf: Bundle.main.url(forResource: "Pyaar Hota Kayi Baar Hai(PagalWorld.com.se)", withExtension: "mp3")!)
        

        toneGenerator.setupAudioUnit()
        toneGenerator.start()
        
        rangeSlider.delegate = self
        rangeSlider.minValue = 0
        rangeSlider.maxValue = 2000
        rangeSlider.colorBetweenHandles = .systemBlue
        rangeSlider.tintColor = .lightGray
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async {
            self.ecgGraphView.updateChartSize()
        }
    }

    @IBAction func btnBackTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    // Range Slider Delegate method
    
    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        lblLowFrequency.text =  "  \(Int(rangeSlider.selectedMinValue)) Hz"
        lblHighFrequency.text =  "\(Int(rangeSlider.selectedMaxValue)) Hz  "
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
//    func parseRecording(dataECG : Data) -> [[Double]] {
//        let arr = [UInt8](dataECG)
//        var finalArr = [[Double]]()
//        var innerArr = [Double]()
//        for a in arr {
//            innerArr.append(Double(a))
//            if(innerArr.count == 16) {
//                finalArr.append(innerArr)
//                innerArr = [Double]()
//            }
//        }
//        let chartsData = DataParser().setUpDataForRecording(finalArr)
//        var sublist = [[Double]]()
//        for j in 0..<12 {
//            sublist.append([Double]())
//            for i in 0..<chartsData.count{
//                sublist[j].append(chartsData[i][j])
//            }
//        }
//        return sublist;
//    }
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
        ecgShapeLayer.path = bezierPath.cgPath
        ecgShapeLayer.lineWidth = 1.0
        ecgShapeLayer.strokeColor = UIColor.black.cgColor
        ecgShapeLayer.fillColor = UIColor.clear.cgColor
        self.graphView.layer.addSublayer(self.ecgShapeLayer)
        self.currentDataCount += 1
    }
 
    // Phonogram (Stetho Graph)
   
    @objc func phonogramGraph(){
        
        let beat = UInt8(rawData[n])
        let bezierPath = UIBezierPath()
        var xOffset = waveFormView.frame.width / 350
        let multiplyingFactor = 0.3
        var yOffset = waveFormView.frame.height / 2
        if dataByteBuffer.isFull {
            dataByteBuffer.read()
        }
        dataByteBuffer.write(element: beat)
        for beat in dataByteBuffer.readIndex..<(dataByteBuffer.writeIndex){
            if dataByteBuffer.readIndex == beat {
                bezierPath.move(to: CGPoint(x: Double((beat - dataByteBuffer.readIndex)) * xOffset, y: yOffset - Double(dataByteBuffer.getQueueData[beat % dataByteBuffer.getQueueData.count]!) * multiplyingFactor))
                bezierPath.addLine(to: CGPoint(x: Double((beat - dataByteBuffer.readIndex)) * xOffset, y: yOffset + Double(dataByteBuffer.getQueueData[beat % dataByteBuffer.getQueueData.count]!) * multiplyingFactor))
                bezierPath.addLine(to: CGPoint(x: Double((beat - dataByteBuffer.readIndex)) * xOffset, y: yOffset))
            } else {
                bezierPath.addLine(to: CGPoint(x: Double((beat - dataByteBuffer.readIndex)) * xOffset, y: yOffset - Double(dataByteBuffer.getQueueData[beat % dataByteBuffer.getQueueData.count]!) * multiplyingFactor))
                bezierPath.addLine(to: CGPoint(x: Double((beat - dataByteBuffer.readIndex)) * xOffset, y: yOffset + Double(dataByteBuffer.getQueueData[beat % dataByteBuffer.getQueueData.count]!) * multiplyingFactor))
                bezierPath.addLine(to: CGPoint(x: Double((beat - dataByteBuffer.readIndex)) * xOffset, y: yOffset))
            }
        }
        n += 1
        phonogramShapeLayer.path = bezierPath.cgPath
        phonogramShapeLayer.strokeColor = UIColor.black.cgColor
        phonogramShapeLayer.lineWidth = 0.5
        phonogramShapeLayer.fillColor = UIColor.clear.cgColor
        waveFormView.layer.addSublayer(phonogramShapeLayer)
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
                peripheral.discoverCharacteristics([TransferService.characteristicUUID, TransferService.ecgCharacteristicUUID], for: service)
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
            for characteristic in serviceCharacteristics where (characteristic.uuid == TransferService.characteristicUUID || TransferService.ecgCharacteristicUUID == characteristic.uuid) {
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
            if let error = error {
                print(error)
                return
            }
            guard let value = characteristic.value else {
                return
            }
            if characteristic.uuid.uuidString == "6E400003-B5A3-F393-E0A9-E50E24DCCA9E" {
                /*
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
                                                                                         */
            }
            if characteristic.uuid.uuidString == TransferService.ecgCharacteristicUUID.uuidString {
//              print(value.count)
                for i in stride(from: 0, to: value.count, by: 2) {
                    let b1 = UInt16(value[i])
                    let b2 = UInt16(value[i+1])
                    let combined = b2 << 8 | b1
                    let filteredIIR = dataParserIIR.caluclateXY(index: 0, value: Double(combined), n: self.nForIIR)
                    self.nForIIR = (self.nForIIR + 1) % 10
                    ecgValuesArrayToShare.append("\(combined)")
                    filteredValuesArrayToShare.append("\(filteredIIR)")
                    filteredValuesDouble.append(filteredIIR)
                    
                    // Append dictionary
                    var dictionary = [String: String]()
                    dictionary["ecgData"] = "\(filteredIIR)"
                    dictionary["date"] = Date().getStringFromDate()
                    arrayBPMDictionary.append(dictionary)

                    // Plot the points in graph
                    ecgGraphView.dataHandler.enqueue(value: Double(filteredIIR))
                }
                
                if abs(dateToCheck.timeIntervalSinceNow) >= 1 {
                    calculatingBPM()
                    dateToCheck = Date()
                }
            } // ECG characteristics ends here
        } // Delegate function ends here
}


//MARK: Share File
extension ViewController {
    @IBAction func btnShareFileTapped(_ sender: UIButton) {
        let data = try! Data(contentsOf: Bundle.main.url(forResource: "Pyaar Hota Kayi Baar Hai(PagalWorld.com.se)", withExtension: "mp3")!)
        
        let originalECGFilePath = createFile(array: self.ecgValuesArrayToShare, fileName: "ECGFile")
        let filteredECGfilePath = createFile(array: self.filteredValuesArrayToShare, fileName: "Filtered")

        let controller = UIActivityViewController(activityItems: [originalECGFilePath, filteredECGfilePath], applicationActivities: nil)
        self.present(controller, animated: true) {
            //print("done")
        }
  

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
       // drawWaveForm()
        
      
//        self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(drawGraph), userInfo: nil, repeats: true)
//        self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(phonogramGraph), userInfo: nil, repeats: true)
    }

    
    
    func createFile(array: [String], fileName: String) -> URL {
        
        let date = Date()
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "dd-MM--HH:mm"
        
        let path = FileManager.default.urls(for: .documentDirectory,
                                            in: .userDomainMask)[0].appendingPathComponent("\(fileName)\(dateFormat.string(from: date)).txt")
        
        let ecgIntDataInComma = array.joined(separator: "\n")
        let ecgStrigData = ecgIntDataInComma.data(using: String.Encoding.utf8)!
        try? ecgStrigData.write(to: path)
        
        return path
        
    }
}

 //MARK: - ECG
extension ViewController {
    
    func initECGChart() {
        let spec = Spec(oneSecondDataCount: 500, //sample rate
                        visibleSecondRange: 2, // sec data in view at a time
                        refreshGraphInterval: 0.069, // refresh graph (ploat by 0.1 sec
                        vitalMaxValue: 2400,
                        vitalMinValue: 1800)
        ecgGraphView.lineColor = .black
        ecgGraphView.valueCircleIndicatorColor = .black
        self.ecgGraphView.setRealTimeSpec(spec: spec)
    }
    
    @objc func calculatingBPM() {
        //Sample rate - 500
        //In 1 second 500 points will come
        let dataToCalcuateBPM = arrayBPMDictionary.map {
            Double($0["ecgData"] ?? "0.0") ?? 0.0
        }
        let allData = dataToCalcuateBPM
        lblHeartRate.text = "\(bpmCalculations.calculateHeartRate(z: allData, samplingRate: sampleRateForECG))"
    }

    
    
}
