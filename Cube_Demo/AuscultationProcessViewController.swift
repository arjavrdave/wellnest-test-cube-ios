//
//  AuscultationProcessViewController.swift
//  Created by Dhruvi Prajapati on 16/05/23.
//  Copyright © 2023 Wellnest Inc. All rights reserved.
//

import Foundation
import UIKit
//import DSWaveformImage
//import Combine
//import Charts
//import Lottie
//import TinyConstraints
//import CoreBluetooth
class AuscultationProcessViewController: UIParentViewController {
    
//
//    let user: User
//    let userService : IUserService
//    let recording : Recording
//    let recordingService : IRecordingService
//    var subscriptions : [AnyCancellable] = []
//    var audioPlayer = AVAudioPlayer()
//    var yValues : [ChartDataEntry] = []
//    var counter = 0
//    var isAuscultationCompleted = false
//
//    @IBOutlet weak var lblMessage: UILabel!
//    @IBOutlet weak var lblValueAuscultation: UILabel!
//    @IBOutlet weak var lblBPMTitle: UILabel!
//
//    @IBOutlet weak var btnBluetooth: UIButton!
//    @IBOutlet weak var btnBattery: UIButton!
//
//    @IBOutlet weak var btnDone: UIButton!
//
//    @IBOutlet weak var viewHeader: UIView!
//    @IBOutlet weak var constViewTopHeight: NSLayoutConstraint!
//
//    @IBOutlet weak var btnBackward: UIButton!
//    @IBOutlet weak var btnPlay: UIButton!
//    @IBOutlet weak var btnForward: UIButton!
//    @IBOutlet weak var viewDrawECG: UIView!
//    @IBOutlet weak var viewRetake: UIView!
//    @IBOutlet weak var viewShare: UIView!
//    @IBOutlet weak var middleStaticWave: WaveformImageView!
//    @IBOutlet weak var viewAuscultationAudio: WaveformLiveView!
//    var selectedViews = [RecordType]()
//    var actualValues = [RecordType]()
//    var isViewHeader = true
//    var byteArray = Array<UInt8>()
//    var ECGArray = Array<UInt8>()
//    var peripheral : CBPeripheral!
//    var centralManager = CBCentralManager()
//    private let waveformImageDrawer = WaveformImageDrawer()
//    private let audioManager: SCAudioManager!
//    private let imageDrawer: WaveformImageDrawer!
//    var a = IosAudioController()
//    var decoder = ADPCMDecode()
//    var helloData = Data()
//    lazy var lineChartView : LineChartView  = {
//        let chartView = LineChartView()
//        chartView.rightAxis.enabled = false
//        chartView.rightAxis.labelTextColor = .clear
//        chartView.rightAxis.axisLineColor = .clear
//        chartView.doubleTapToZoomEnabled = false
//        chartView.setScaleMinima(5, scaleY: 1)
//        chartView.scaleXEnabled = false
//        chartView.scaleYEnabled = false
//        chartView.dragEnabled = false//To Zoom or slice the data x: Zoom y: view (1 = fit screen)
//        chartView.pinchZoomEnabled = false
//        chartView.doubleTapToZoomEnabled = false
//        chartView.legend.enabled = false
//
//        let yAxis = chartView.leftAxis
//        yAxis.labelTextColor = .clear
//        yAxis.drawGridLinesEnabled = false
//        yAxis.axisLineColor = .clear
//        yAxis.setLabelCount(10, force: false)
//        yAxis.axisMinimum = -50
//        yAxis.axisMaximum = 85
//        yAxis.drawLabelsEnabled = false
//
//        chartView.xAxis.drawGridLinesEnabled = false
//        chartView.xAxis.labelTextColor = .clear
//        chartView.xAxis.axisLineColor = .clear
//        //        chartView.animate(xAxisDuration: 30.5)
//        //        chartView.xAxis.axisMinimum =  // To show the graph from x-axis
//        //        chartView.xAxis.axisMaximum = 2000  // To show the graph till x-axis
//
//
//        return chartView
//    }()
//
//    init?(coder: NSCoder, user: User) {
//        audioManager = SCAudioManager()
//        imageDrawer = WaveformImageDrawer()
//        self.userService = DIContainer.shared.resolve(type: IUserService.self)!
//        self.user = user
//        self.recordingService = DIContainer.shared.resolve(type: IRecordingService.self)!
//        self.recording = Recording()
//        super.init(coder: coder)
//        audioManager.recordingDelegate = self
//
//    }
//
//    required init?(coder: NSCoder) {
//        audioManager = SCAudioManager()
//        imageDrawer = WaveformImageDrawer()
//        self.userService = DIContainer.shared.resolve(type: IUserService.self)!
//        self.user = User()
//        self.recordingService = DIContainer.shared.resolve(type: IRecordingService.self)!
//        self.recording = Recording()
//        super.init(coder: coder)
//        audioManager.recordingDelegate = self
//        a.start()
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
//        if let parent = (self.navigationController?.parent as? RecordingMultiViewController){
//            parent.viewAllRecordings.isHidden = true
//            parent.viewAllRecordingsHeightConstraint.constant = 0
//        }
//        if isViewHeader{
//            self.viewHeader.isHidden = false
//        }
//        else{
//            self.viewHeader.isHidden = true
//            self.constViewTopHeight.constant = 0
//        }
//        self.btnDone.layer.cornerRadius = self.btnDone.frame.height / 2
//        self.centralManager.delegate = self
//        self.peripheral.delegate = self
//        self.peripheral.discoverServices(nil)
//
//        self.viewDrawECG.addSubview(lineChartView)
//        self.lineChartView.delegate = self
//        self.lineChartView.centerInSuperview()
//        self.lineChartView.width(to: self.viewDrawECG)
//        self.lineChartView.heightToWidth(of: self.viewDrawECG)
//        self.lineChartView.center.x = self.viewDrawECG.center.x
//        self.lineChartView.center.y = self.viewDrawECG.center.y
//
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        //        viewAuscultationAudio.configuration = viewAuscultationAudio.configuration.with(
//        //            style: .striped(.init(color: .black, width: 3, spacing:3)))
//        //        audioManager.prepareAudioRecording()
//        //
//        //        if audioManager.recording() {
//        //            audioManager.stopRecording()
//        //        } else {
//        //            self.viewAuscultationAudio.reset()
//        //            audioManager.startRecording()
//        //        }
//
//    }
//
//    func audioManager(_ manager: SCAudioManager!, didAllowRecording flag: Bool) {
//        //        if !flag {
//        //            preconditionFailure("Recording must be allowed in Settings to work.")
//        //        }
//    }
//
//    func audioManager(_ manager: SCAudioManager!, didFinishRecordingSuccessfully flag: Bool) {
//        //        print("did finish recording with success=\(flag)")
//    }
//
//    func audioManager(_ manager: SCAudioManager!, didUpdateRecordProgress progress: CGFloat) {
//        //        print("current power: \(manager.lastAveragePower()) dB")
//        //        let linear = 1 - pow(10, manager.lastAveragePower() / 20)
//        //
//        //        self.viewAuscultationAudio.add(samples: [linear, linear, linear])
//    }
//
//    private func updateWaveformImages() {
//        let fileManager = FileManager.default
//        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
//        let documentDirectory = urls[0] as NSURL
//        let soundURL = documentDirectory.appendingPathComponent("Record.wav")
//        guard let url = soundURL     else { return }
//        // always uses background thread rendering
//        //        waveformImageDrawer.waveformImage(
//        //            fromAudioAt: audioURL, with: .init(
//        //                size: topWaveformView.bounds.size,
//        //                style: .gradient(
//        //                    [
//        //                        UIColor(red: 255/255.0, green: 159/255.0, blue: 28/255.0, alpha: 1),
//        //                        UIColor(red: 255/255.0, green: 191/255.0, blue: 105/255.0, alpha: 1),
//        //                        UIColor.red
//        //                    ]
//        //                ),
//        //                dampening: .init(percentage: 0.2, sides: .right, easing: { x in pow(x, 4) }),
//        //                position: .top,
//        //                verticalScalingFactor: 2)
//        //        ) { image in
//        //            // need to jump back to main queue
//        //            DispatchQueue.main.async {
//        //                self.topWaveformView.image = image
//        //            }
//        //        }
//
//        self.middleStaticWave.configuration = Waveform.Configuration(
//            backgroundColor: .white,
//            style: .striped(.init(color: .black, width: 2, spacing: 5)),
//            verticalScalingFactor: 0.5
//        )
//        self.middleStaticWave.waveformAudioURL = url
//
//        //        waveformImageDrawer.waveformImage(fromAudioAt: audioURL, with: bottomWaveformConfiguration) { image in
//        //            DispatchQueue.main.async {
//        //                self.bottomWaveformView.image = image
//        //            }
//        //        }
//    }
//
//
//    func setData() {
//        //Line Settings
//        let set1 = LineChartDataSet(entries: self.yValues)
//        set1.drawCirclesEnabled = false
//        set1.lineWidth = 2
//        set1.setColor(UIColor(named: "ColorGreenTheme00B97F") ?? .black)
//
//        let data = LineChartData(dataSet: set1 )
//
//        data.setDrawValues(false)
//        lineChartView.data = data
//    }
//
//    func readValue(characteristic: CBCharacteristic) {
//        self.peripheral.readValue(for: characteristic)
//    }
//
//
//    @IBAction func btnBackTapped(_ sender: UIButton) {
//        UIAlertUtil.alertWith(title: "Discard Process", message: "Your previous steps will be lost. Would you like to discard the Process?", OkTitle: "Discard", cancelTitle: "Cancel", viewController: self) { (index) in
//            if index == 1
//            {
//                self.navigationController?.popViewController(animated: true)
//            }
//        }
//    }
//    @IBAction func btnBackwardTapped(_ sender: UIButton) {
//    }
//    @IBAction func btnPlayTapped(_ sender: UIButton) {
//        let fileManager = FileManager.default
//        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
//        let documentDirectory = urls[0] as NSURL
//        let soundURL = documentDirectory.appendingPathComponent("Record.wav")
//        guard let url = soundURL     else { return }
//
//        do {
//            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
//            try AVAudioSession.sharedInstance().setActive(true)
//
//            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
//            audioPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.wav.rawValue)
//
//            /* iOS 10 and earlier require the following line:
//             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
//
//
//            audioPlayer.play()
//
//        } catch let error {
//            print(error.localizedDescription)
//        }
//    }
//    @IBAction func btnForwardTapped(_ sender: UIButton) {
//    }
//    @IBAction func btnRetakeTapped(_ sender: UIButton) {
//        UIAlertUtil.alertWith(title: "Retake", message: "This data will not be saved.\n Do you want to retake?", OkTitle: "Retake", cancelTitle: "Cancel", viewController: self) { (index) in
//            if index == 0
//            {
//
//            }
//        }
//    }
//    @IBAction func btnDoneTapped(_ sender: UIButton) {
//        DispatchQueue.main.async {
//            UILoader.startAnimating()
//        }
//        self.user.auscultation = Int(self.lblValueAuscultation.text ?? "")
//        if self.actualValues.count > 1{
//            self.recordingService.recording(user: self.user)        //API
//                .sink(receiveCompletion: { (completion) in
//                    switch completion {
//                    case .finished :
//                        DispatchQueue.main.async {
//                            UILoader.stopAnimating()
//                        }
//                        break
//                    case .failure(let error) :
//                        DispatchQueue.main.async {
//                            UILoader.stopAnimating()
//                        }
//                        UIAlertUtil.alertWith(title: "Error !", message: "\(error.localizedDescription)", OkTitle: "Okay", viewController: self) { (_) in
//                        }
//
//                        break
//                    }
//                }, receiveValue: { (_) in
//                    let storyboard = UIStoryboard.init(name: StoryBoard.Recording.rawValue, bundle: Bundle.main)
//                    let vc = storyboard.instantiateViewController(identifier: String.init(describing: ReviewReportViewController.self)) { coder in
//                        return ReviewReportViewController(coder: coder, user: self.user)
//                    }
//                    vc.selectedViews = self.actualValues
//                    self.parent?.navigationController?.pushViewController(vc, animated: true)
//                })
//                .store(in: &subscriptions)
//        } else {
//            self.recordingService.recording(user: self.user)        //API
//                .sink(receiveCompletion: { (completion) in
//                    switch completion {
//                    case .finished :
//                        DispatchQueue.main.async {
//                            UILoader.stopAnimating()
//                        }
//                        break
//                    case .failure(let error) :
//                        DispatchQueue.main.async {
//                            UILoader.stopAnimating()
//                        }
//                        UIAlertUtil.alertWith(title: "Error !", message: "\(error.localizedDescription)", OkTitle: "Okay", viewController: self) { (_) in
//                        }
//
//                        break
//                    }
//                }, receiveValue: { (_) in
//                    let storyboard = UIStoryboard.init(name: StoryBoard.Landing.rawValue, bundle: Bundle.main)
//                    let vc = storyboard.instantiateViewController(withIdentifier: String.init(describing: TabBarViewController.self)) as! TabBarViewController
//                    self.navigationController?.pushViewController(vc, animated: true)
//                })
//                .store(in: &subscriptions)
//        }
//        NotificationCenter.default.removeObserver(self, name: Notification.Name("Auscultation"), object: nil)
//        NotificationCenter.default.removeObserver(self, name: Notification.Name("AuscultationStart"), object: nil)
//        //        let storyboard = UIStoryboard.init(name: StoryBoard.Landing.rawValue, bundle: Bundle.main)
//        //        let vc = storyboard.instantiateViewController(withIdentifier: String.init(describing: TabBarViewController.self)) as! TabBarViewController
//        self.parent?.navigationController?.popToRootViewController(animated: true)
//    }
//    @IBAction func btnShareTapped(_ sender: UIButton) {
//    }
//    @IBAction func btnShareFile(_ sender: UIButton) {
//        let path = FileManager.default.urls(for: .documentDirectory,
//                                            in: .userDomainMask)[0].appendingPathComponent("kevu gayu ")
//
//
//        try? self.helloData.write(to: path)
//        let controller = UIActivityViewController(activityItems: [path], applicationActivities: nil)
//        self.present(controller, animated: true) {
//            print("done")
//        }
//
//    }
//}
//
//// MARK: CBCentralManagerDelegate
//extension AuscultationProcessViewController: CBCentralManagerDelegate{
//    func centralManagerDidUpdateState(_ central: CBCentralManager) {
//        if central.state == .poweredOn {
//            print("Powered on")
//        }
//    }
//    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
//        self.btnDone.isHidden = false
//        self.btnPlay.isHidden = false
//        self.isAuscultationCompleted = true
//        print("Audio Data")
//        print(self.byteArray)
//        print("ECG Data")
//        print(self.ECGArray)
//
//        let data = NSData(bytes: self.byteArray, length: self.byteArray.count)
//        let base64Data = data.base64EncodedData(options: NSData.Base64EncodingOptions.endLineWithLineFeed)
//        //        let newData = NSData(base64Encoded: base64Data, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)!
//        //        let newNSString = NSString(data: base64Data as Data, encoding: String.Encoding.utf8.rawValue)!
//        let arFileManager = ARFileManager()
//        do{
//            let file = try arFileManager.createWavFile(using: base64Data)
//            print(file)
//        }
//        catch{
//            print("An Error has occured to create a wav file")
//        }
//        let fileManager = FileManager.default
//        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
//        let documentDirectory = urls[0] as NSURL
//        let soundURL = documentDirectory.appendingPathComponent("Record.wav")
//        guard let url = soundURL     else { return }
//
//        updateWaveformImages()
//
//        // get access to the raw, normalized amplitude samples
//        let waveformAnalyzer = WaveformAnalyzer(audioAssetURL: url)
//        waveformAnalyzer?.samples(count: 10) { samples in
//            print("sampled down to 10, results are \(samples ?? [])")
//        }
//
//    }
//
//}
//
//// MARK: CBPeripheralDelegate
//extension AuscultationProcessViewController : CBPeripheralDelegate{
//
//    func discoverCharacteristics(peripheral: CBPeripheral) {
//        guard let services = peripheral.services else {
//            return
//        }
//        for service in services {
//            peripheral.discoverCharacteristics(nil, for: service)
//        }
//    }
//
//    func discoverDescriptors(peripheral: CBPeripheral, characteristic: CBCharacteristic) {
//        peripheral.discoverDescriptors(for: characteristic)
//    }
//
//    func subscribeToNotifications(peripheral: CBPeripheral, characteristic: CBCharacteristic) {
//        peripheral.setNotifyValue(true, for: characteristic)
//    }
//
//
//
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
//        guard let services = peripheral.services else {
//            return
//        }
//        print(services)
//        discoverCharacteristics(peripheral: peripheral)
//    }
//
//    //READ WRITE
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
//        guard let characteristics = service.characteristics else {
//            return
//        }
//        for characteristic in characteristics {
//            print(characteristic)
//            peripheral.discoverDescriptors(for: characteristic)
//            subscribeToNotifications(peripheral: peripheral, characteristic: characteristic)
//        }
//        // Consider storing important characteristics internally for easy access and equivalency checks later.
//        // From here, can read/write to characteristics or subscribe to notifications as desired.
//    }
//
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
//        guard let descriptors = characteristic.descriptors else { return }
//
//        if let userDescriptionDescriptor = descriptors.first(where: {
//            return $0.uuid.uuidString == CBUUIDCharacteristicUserDescriptionString
//        }) {
//            peripheral.readValue(for: userDescriptionDescriptor)
//        }
//    }
//
//    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
//        if descriptor.uuid.uuidString == CBUUIDCharacteristicUserDescriptionString,
//           let userDescription = descriptor.value as? String {
//            print("Characterstic \(String(describing: descriptor.characteristic?.uuid.uuidString)) is also known as \(userDescription)")
//        }
//    }
//
//    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
//        if let error = error {
//            print(error)
//            return
//        }
//        subscribeToNotifications(peripheral: peripheral, characteristic: characteristic)
//        // Successfully subscribed to or unsubscribed from notifications/indications on a characteristic
//    }
//
//    // ------------------------------------------ Getting bytes value for Auscultation
//    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//        if let error = error {
//            // Handle error
//            print(error)
//            return
//        }
//        guard let value = characteristic.value else {
//            return
//        }
//        if characteristic.uuid.uuidString == "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"{
//            helloData.append(value)
//            //let decodedData = self.decoder.decodedSample(data: value)
////            helloData.append(decodedData)
//
////            var list2 = [Int]()
////            for i in 0..<a.count {
////                list2.append(Int(a[i]))
////            }
////            print(list2)
////            value.withUnsafeBytes { pointer in
////                var b = a.tempBuffer.object(at: 1)
////
////                for _ in 0..<a.tempBuffer.mDataByteSize {
////                    print(b!.load(as: UInt8.self) , terminator: ", ")
////                    b = b?.advanced(by: MemoryLayout<UInt8>.stride)
////
////                }
////                print("\n Origninal data \([UInt8](value))")
////                memcpy(a.tempBuffer.mData, pointer.baseAddress, pointer.count)
////            }
////
////            if let byte = value.first{
////                self.byteArray.append(byte)
////                DispatchQueue.global(qos: .background).async {
////                    if self.isAuscultationCompleted == false{
////                        let data = NSData(bytes: self.byteArray, length: self.byteArray.count)
////                        let base64Data = data.base64EncodedData(options: NSData.Base64EncodingOptions.endLineWithLineFeed)
////                        //        let newData = NSData(base64Encoded: base64Data, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)!
////                        //        let newNSString = NSString(data: base64Data as Data, encoding: String.Encoding.utf8.rawValue)!
////                        let arFileManager = ARFileManager()
////                        do{
////                            let file = try arFileManager.createWavFile(using: base64Data)
////                            print(file)
////                        }
////                        catch{
////                            print("An Error has occured to create a wav file")
////                        }
////                        DispatchQueue.main.async {
////                            let fileManager = FileManager.default
////                            let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
////                            let documentDirectory = urls[0] as NSURL
////                            let soundURL = documentDirectory.appendingPathComponent("Record.wav")
////                            guard let url = soundURL     else { return }
////
////                            self.updateWaveformImages()
////
////                            // get access to the raw, normalized amplitude samples
////                            let waveformAnalyzer = WaveformAnalyzer(audioAssetURL: url)
////                            waveformAnalyzer?.samples(count: 10) { samples in
////                                print("sampled down to 10, results are \(samples ?? [])")
////                            }
////                        }
////                    }
////                }
////            }
//        } else if characteristic.uuid.uuidString == "6E40196A-B5A3-F393-E0A9-E50E24DCCA9E"{
//            if let byte = value.first{
//                DispatchQueue.global(qos: .background).sync {
//                    if self.isAuscultationCompleted == false{
//                        let value = Double(byte)
//                        self.yValues.append(ChartDataEntry(x: Double(self.counter), y: value))
//                        DispatchQueue.main.async {
//                            self.setData()
//                            self.lineChartView.setVisibleXRangeMaximum(200)
//                            self.lineChartView.moveViewToX(Double(self.counter))
//                        }
//                    }
//                }
//                self.counter += 1
//                self.ECGArray.append(byte)
//            }
//        }
//    }
}
