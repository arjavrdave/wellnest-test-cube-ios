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
    
    func calculateBPM(dataArray: [Int]) {

        
        //1. Filtering the data with 1000 to 5000
        var filteredDataArray = dataArray.filter {
            $0 < 5000 && $0 > 1000
        }
        
        print("filteredDataArray \(filteredDataArray[(filteredDataArray.count-4)..<(filteredDataArray.count)])")
        
        //2. Apply powerline filter
        let signal: [Double] = filteredDataArray.map {
            Double($0)
        }
        // TODO: To determing sample rate correctly
        let samplingRate: Double = 100.0
        let powerlineSignal = signalFilterPowerline(signal: signal, samplingRate: samplingRate)
        print("powerlineSignal \(powerlineSignal[(powerlineSignal.count-4)..<(powerlineSignal.count)])")

        
        var squareOfDifferences = [Int]()
        var d1 = [Int]()

        //2. Filtered data array find the differences and append to d1
        for i in 0..<powerlineSignal.count {
            if i > 0 && i < powerlineSignal.count - 1 {
                let temp = powerlineSignal[i+1] - powerlineSignal[i]
                d1.append(Int(temp))
            }
        }
        
        print("d1 \(d1[(d1.count-4)..<(d1.count)])")
        //3. From the difference find the difference of d1 values. And square each value, and append to square of differences.

        for i in 0..<d1.count{
            if i > 0 && i < d1.count - 1{
                let temp = d1[i+1] - d1[i]
                squareOfDifferences.append(temp * temp)
            }
        }

        print("squareOfDifferences \(squareOfDifferences[(squareOfDifferences.count-4)..<(squareOfDifferences.count)])")
       
        //TODO: To apply error threshold
        // -----------------------------
        /*
             2. The difference array is sorted in descending order of magnitude and the difference peaks above a constant
             threshold value of 3% of the maximum are selected.
         */
        
//        print("squareOfDifferences \(squareOfDifferences)")
//        let maxAngleVal = Double(squareOfDifferences.max() ?? Int(0.0))
//        let errorThreshold = 0.25 * maxAngleVal
//        print("errorThreshold \(errorThreshold)")
        
        /*
         3. Since the maximum duration of the QRS regions is 150 ms, to eliminate possibility of detection of several
         peaks in the same QRS region all the difference peaks within an interval of ±75 ms of each selected
         difference peaks are eliminated.
        */
        var qrsArray = [Int]()
        var newRPeaks = [Int]()
        var windowArray = Array(repeating: Array(repeating: 0, count: 150), count: squareOfDifferences.count)
        for i in 0..<squareOfDifferences.count {
            if (qrsArray.isEmpty || i - Int((qrsArray.last ?? 0)) > 75) {
                qrsArray.append(i)
                if i > 75 && i + 75 < squareOfDifferences.count{
                    let startIdx = max(0, i - 75)
                    let endIdx = min(squareOfDifferences.count, i + 75)
                    let slice = Array(squareOfDifferences[startIdx..<endIdx])
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
        print("R Peaks \(newRPeaks[(newRPeaks.count-4)..<(newRPeaks.count)])")
        print("R Peaks count \(newRPeaks.count)")
        
        //TODO: To apply R Peaks correctness
        
    }
}
