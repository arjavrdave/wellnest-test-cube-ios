//
//  DataParser.swift
//  Cube_Demo
//
//  Created by Dhruvi Prajapati on 30/05/23.


import UIKit

open class DataParser: NSObject {
    
    private var x: [[Double]]? = [];
    private var y: [[Double]]? = [];
    private var n: Int = 0;
    private var i: Int = 0;
    private let a: [Double] = [1.0
    ,-1.5789478550001697
    ,1.0120725453024577
    ,-0.22712139734776327];

    private let b: [Double] = [0.025750411619315607
    ,0.07725123485794683
    ,0.07725123485794683
    ,0.025750411619315607];
    public override init() {
        x = Array(repeating: Array(repeating: 0.0, count: 10), count: 9)
        y = Array(repeating: Array(repeating: 0.0, count: 10), count: 9)
    }

    func caluclateXY(index: Int, value: Double, n: Int) -> Double {
        x![index][n] = value;
        let m: Int = 10;
        var val: Double = b[0] * x![index][n] + b[1] * x![index][(n-1+m)%m] + b[2] * x![index][(n-2+m)%m] + b[3] * x![index][(n-3+m)%m] - a[1] * y![index][(n-1+m)%m] - a[2] * y![index][(n-2+m)%m] - a[3] * y![index][(n-3+m)%m];
        y![index][n] = val;
        val.round()
        if val > 32767.0 {
            val = 32767.0
        }
        if val < -32768.0 {
            val = -32768.0
        }
        
        let signedInt = Int16(val)

        let result = Double(UInt16.init(bitPattern: Int16(signedInt)))

        return result
    }
    
}

