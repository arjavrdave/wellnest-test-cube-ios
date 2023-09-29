//
//  CalcaulateRPeaks.swift
//  Cube_Demo
//
//  Created by Nihar Jagad on 19/09/23.
//

import Foundation


class BPMCalcaulations: NSObject {
    
    override init() {
    }
    
    func calculateBPM(dataArray: [Double], sampleRate: Double) -> ([Double]){
        
        //1. Filtering the data with 1000 to 5000
        let filteredDataArray = dataArray.filter {
            $0 < 5000.0 && $0 > 1000.0
        }
//        print("filteredDataArray \(filteredDataArray[0..<min(0,4)])")
        
        //2. Apply powerline filter
        let powerlineSignal = signalFilterPowerline(signal: filteredDataArray, samplingRate: sampleRate)
//        print("powerlineSignal \(powerlineSignal[0..<4])")

        //3. Square of differences
        var squareOfDifferences = [Double]()
        var d1 = [Double]()
        for i in 0..<powerlineSignal.count {
            if i > 0 && i < powerlineSignal.count - 1 {
                let temp = powerlineSignal[i+1] - powerlineSignal[i]
                d1.append(temp)
            }
        }
        
        for i in 0..<d1.count {
            if i > 0 && i < d1.count - 1 {
                let temp = d1[i+1] - d1[i]
                squareOfDifferences.append(temp * temp)
            }
        }


        // -----------------------------
        /*
             2. The difference array is sorted in descending order of magnitude and the difference peaks above a constant
             threshold value of 3% of the maximum are selected.
         */
        //3. Finding the threshold
        let thresholdArray = squareOfDifferences.filter {
            $0 < 500.0
        }
        print("squareOfDifferences \(squareOfDifferences)")
        print("thresholdArray \(thresholdArray)")

        let maxAngleVal = thresholdArray.max() ?? 0.0
        print("maxAngleVal \(maxAngleVal)")
        let errorThreshold = 0.25 * maxAngleVal
        print("errorThreshold \(errorThreshold)")
        
        /*
         3. Since the maximum duration of the QRS regions is 150 ms, to eliminate possibility of detection of several
         peaks in the same QRS region all the difference peaks within an interval of ±75 ms of each selected
         difference peaks are eliminated.
        */
        var qrsArray = [Int]()
        var newRPeaks = [Int]()
        
        var windowArray = Array(repeating: Array(repeating: 0.0, count: 150), count: thresholdArray.count)
        for i in 0..<thresholdArray.count {
            if thresholdArray[i] > errorThreshold && (qrsArray.isEmpty || (i - (qrsArray.last ?? 0)) > 75) {
                qrsArray.append(i)
                print("qrsArray \(i)")
                if i > 75 && i + 75 < thresholdArray.count {
                    let startIdx = max(0, i - 75)
                    let endIdx = min(thresholdArray.count, i + 75)
                    let slice = Array(thresholdArray[startIdx..<endIdx])
                    windowArray[qrsArray.count - 1] = slice
                }
                let maxValue = windowArray[qrsArray.count - 1].max() ?? 0
                let minValue = windowArray[qrsArray.count - 1].min() ?? 0
                let avg = (maxValue + minValue) / 2

                windowArray[qrsArray.count - 1] = windowArray[qrsArray.count - 1].map { $0 - avg }
                
                if let index = windowArray[qrsArray.count - 1].firstIndex(of: windowArray[qrsArray.count - 1].max() ?? 0) {
                    newRPeaks.append(qrsArray.last! + (index - 75))
                    print("newRPeaks \(newRPeaks.count)")
                }
            }
        }
                
        let rPeakIndicies = newRPeaks.map {
            Double($0)
        }
        print("rPeakIndicies \(rPeakIndicies[0..<min(4,0)])")
        return rPeakIndicies
    }
}


extension BPMCalcaulations {


    func calculateHeartRate(z: [Double],
                            samplingRate: Double) -> Int {
        let rpeaks = calculateBPM(dataArray: z, sampleRate: samplingRate)
        let r = rpeaks
        print("R Peaks count \(rpeaks.count)")
        let differences = zip(r.dropFirst(), r).map { $0 - $1 }
        let avg = differences.reduce(0.0, +) / Double(differences.count)
//        print("avg \(avg), differences \(differences)")
        let bpm = samplingRate * 60 / avg

        if bpm.isNaN || bpm.isInfinite {
            return 0
        }
        else {
            return Int(round(bpm))
        }
    }
}



