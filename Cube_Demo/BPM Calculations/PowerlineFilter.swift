//
//  PowerlineFilter.swift
//  Cube_Demo
//
//  Created by Nihar Jagad on 25/09/23.
//

import Foundation

func signalFilterPowerline(signal: [Double], samplingRate: Double, powerline: Double = 50.0) -> [Double] {
    var b: [Double]
    if samplingRate >= 100 {
        b = [Double](repeating: 1.0, count: Int(samplingRate / powerline))
    } else {
        b = [1.0, 1.0]
    }
    
    let a = [1.0]  // Assuming len(b) is intended for 'a' in Python code
    let y = filter(b: b, a: a, x: signal)
    return y
}

func filter(b: [Double], a: [Double], x: [Double]) -> [Double] {
    var y = [Double](repeating: 0.0, count: x.count)
    
    for i in 0..<x.count {
        y[i] = b.enumerated().reduce(0.0) { (result, pair) in
            let (index, value) = pair
            let k = i - index
            if k >= 0 {
                return result + (value * x[k])
            } else {
                return result
            }
        }
        
        if a.count > 1 {
            for j in 1..<a.count {
                y[i] -= a[j] * y[i - j]
            }
        }
    }
    
    return y
}

