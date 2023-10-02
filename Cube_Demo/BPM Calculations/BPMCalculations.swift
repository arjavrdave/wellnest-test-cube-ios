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
    
    //MARK: - R Peak Detection
    func calculateBPM(dataArray: [Double], sampleRate: Double) -> ([Double]){
        
        //1. Filtering the data with 1000 to 5000
        let filteredDataArray = dataArray.filter {
            $0 < 5000.0 && $0 > 1000.0
        }
        
        //2. Apply powerline filter
        let powerlineSignal = signalFilterPowerline(signal: filteredDataArray, samplingRate: sampleRate)

        //3. Find square of differences
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

        //4. Finding the threshold
        //TODO: Need to adjust
        let thresholdArray = squareOfDifferences.filter {
            $0 < 150.0
        }
        print("squareOfDifferences \(squareOfDifferences)")
        let maxAngleVal = thresholdArray.max() ?? 0.0
        let errorThreshold = 0.25 * maxAngleVal
        print("errorThreshold \(errorThreshold)")
        
        /* 5.
          Since the maximum duration of the QRS regions is 150 ms, to eliminate possibility of detection of several
         peaks in the same QRS region all the difference peaks within an interval of ±75 ms of each selected
         difference peaks are eliminated.
        */
        var qrsArray = [Int]()
        var newRPeaks = [Int]()
        
        var windowArray = Array(repeating: Array(repeating: 0.0, count: 150), count: thresholdArray.count)
        for i in 0..<thresholdArray.count {
            if thresholdArray[i] > errorThreshold && (qrsArray.isEmpty || (i - (qrsArray.last ?? 0)) > 75) {
                qrsArray.append(i)
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
                }
            }
        }
        let rPeakIndicies = newRPeaks.map {
            Double($0)
        }
//        print("Todal R Peaks count \(rPeakIndicies.count)")
        //6. Find the differences between the R Peaks
        let differences = zip(rPeakIndicies.dropFirst(), rPeakIndicies).map { $0 - $1 }

        return  processRRIntervals(differences)
    }
    
    //MARK: - R R Interval Processing
    
    func calculateAverageRRInterval(_ rrIntervals: [Double]) -> Double {
        return rrIntervals.reduce(0, +) / Double(rrIntervals.count)
    }

    func processRRIntervals(_ rrIntervals: [Double]) -> [Double] {
        // Calculate the average RR interval
        let averageRRInterval = calculateAverageRRInterval(rrIntervals)
        
        // Process RR intervals based on the provided cases
        var processedRRIntervals: [Double] = []
        for i in 0..<rrIntervals.count {
            if i == 0 || i == rrIntervals.count - 1 {
                // First and last RR intervals are not compared
                processedRRIntervals.append(rrIntervals[i])
            } else {
                // Compare with the average RR interval and apply the given cases
                if rrIntervals[i] < 0.7 * averageRRInterval {
                    // Case 1: Eliminate the 2nd peak
                    // Skip the 2nd peak
                    continue
                } else if rrIntervals[i] > 1.8 * averageRRInterval {
                    // Case 2: Search for another R peak in the interval
                    // Implement your logic for searching another R peak with a decreased threshold
                    // For now, we'll just skip this RR interval
//                    print("Search for another R peak in the interval")
                    continue
                } else {
                    processedRRIntervals.append(rrIntervals[i])
                }
            }
        }
        return processedRRIntervals
    }
}

//MARK: - Average BPM Calculations
extension BPMCalcaulations {
    func calculateHeartRate(z: [Double],
                            samplingRate: Double) -> Int {
        let differences = calculateBPM(dataArray: z, sampleRate: samplingRate)
        print("Processed differences \(differences.count)")
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



