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
    
    func calculateBPM(dataArray: [Int], sampleRate: Int) -> ([Double]){
        //1. Filtering the data with 1000 to 5000
        let filteredDataArray = dataArray.filter {
            $0 < 5000 && $0 > 1000
        }
        
        //2. Apply powerline filter
        let signal: [Double] = filteredDataArray.map {
            Double($0)
        }

        //3. Powerline filter
        let samplingRate: Double = Double(sampleRate)
        let powerlineSignal = signalFilterPowerline(signal: signal, samplingRate: samplingRate)
        
        //4. Square of differences
        var squareOfDifferences = [Int]()
        var d1 = [Int]()

        for i in 0..<powerlineSignal.count {
            if i > 0 && i < powerlineSignal.count - 1 {
                let temp = powerlineSignal[i+1] - powerlineSignal[i]
                d1.append(Int(temp))
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
        print("squareOfDifferences \(squareOfDifferences)")
        let thresholdArray = squareOfDifferences.filter {
            $0 < 10000
        }
        
        print("squareOfDifferences.count \(squareOfDifferences.count)")
        print("thresholdFilteredDataArray.count \(thresholdArray.count)")

        
//        print("squareOfDifferences \(squareOfDifferences)")
        let maxAngleVal = Double(thresholdArray.max() ?? Int(0.0))
        let errorThreshold = 0.3 * maxAngleVal
        print("errorThreshold \(errorThreshold)")
        
        /*
         3. Since the maximum duration of the QRS regions is 150 ms, to eliminate possibility of detection of several
         peaks in the same QRS region all the difference peaks within an interval of ±75 ms of each selected
         difference peaks are eliminated.
        */
        var qrsArray = [Int]()
        var newRPeaks = [Int]()
        
        var windowArray = Array(repeating: Array(repeating: 0, count: 150), count: squareOfDifferences.count)
        for i in 0..<thresholdArray.count {
            if Double(thresholdArray[i]) > errorThreshold && (qrsArray.isEmpty || i - Int((qrsArray.last ?? 0)) > 75) {
                qrsArray.append(i)
                if i > 75 && i + 75 < thresholdArray.count{
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
                }
            }
        }
                
        let rPeakIndicies = newRPeaks.map {
            Double($0)
        }
        
        return rPeakIndicies
    }
}


extension BPMCalcaulations {

    func ecgPeaks(signal: [Double], samplingRate: Double) -> ([Double]) {
        return calculateBPM(dataArray: signal.map {
            Int($0)
        },sampleRate: Int(samplingRate))
    }

    func calculateHeartRate(z: [Double], samplingRate: Double,howManySecondsToFindBPM: Double) -> Int {
        // Perform ECG peak detection
        let rpeaks = ecgPeaks(signal: z, samplingRate: samplingRate)
        
        // Convert R peaks to a list of doubles`
        let r = rpeaks
        
        print("R Peaks count \(rpeaks.count)")
        
        // Calculate average R-R interval
        let differences = zip(r.dropFirst(), r).map { $0 - $1 }
        let avg = differences.reduce(0.0, +) / Double(differences.count)
        print("avg \(avg), differences \(differences)")
        let bpm = samplingRate * howManySecondsToFindBPM / avg
        print("Heart rate is \(bpm) bpm")

        if bpm.isNaN || bpm.isInfinite {
            return 0
        }
        else {
            return Int(round(bpm))
        }
    }
}



