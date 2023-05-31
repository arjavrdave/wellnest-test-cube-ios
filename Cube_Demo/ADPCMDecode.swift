//
//  ADPCMDecode.swift
//  Wellnest One
//
//

import Foundation
class ADPCMDecode {
    let step_size = [ 16, 17, 19, 21, 23, 25, 28, 31, 34, 37, 41,
        45, 50, 55, 60, 66, 73, 80, 88, 97, 107, 118, 130, 143, 157, 173,
        190, 209, 230, 253, 279, 307, 337, 371, 408, 449, 494, 544, 598, 658,
        724, 796, 876, 963, 1060, 1166, 1282, 1411, 1552 ]
    
    var state = adpcm_status()
    func adpcm_decode(code: Int) -> Int {
        let SS: Int = step_size[state.step_index]
        var E: Int = SS/8
        if (( code & 1 ) != 0){
            E += SS/4
        }
                
        if (( code & 2 ) != 0) {
            E += SS/2
        }
               
        if (( code & 4 ) != 0){
            E += SS
        }
                
        let diff: Int = ((code & 8) != 0) ? -E : E
        var samp: Int = state.last + diff
        
        if( samp > 2047 ) {
            samp = 2047
        }
        if( samp < -2048 ) {
            samp = -2048
        }
        state.last = samp
        state.step_index += self.step_adjust(code: code)
        if( state.step_index < 0 ){
            state.step_index = 0
        }
        if( state.step_index > 48 ){
            state.step_index = 48
        }
        return samp
        
    }
    func decodedSample(data: Data) -> Data {
        var decoded = Data()
        for i in 0..<data.count {
            let byte = Int(data[i])
            let high_4_bit = (byte  & 0xf0) >> 4
            let low_4_bit = byte & 0x0f
            let des1 = self.adpcm_decode(code: high_4_bit)
            let byte1 = Int8.init(bitPattern: UInt8((des1 & 4080) >> 4))
            let lastFourBits = des1 & 15
            let des2 = self.adpcm_decode(code: low_4_bit)
            let firstFourBits = (des2 & 3840) >> 8
            let byte2 = Int8.init(bitPattern: UInt8(((lastFourBits << 4) | 15) & firstFourBits))
            let byte3 = Int8.init(bitPattern: UInt8(des2 & 255))
            
            let signedDataArray: [Int8] = [byte1, byte2, byte3]
            let unsignedDataArray = signedDataArray.map {
                UInt8.init(bitPattern: $0)
            }
            decoded.append(contentsOf: unsignedDataArray)
//            let des1 = withUnsafeBytes(of: self.adpcm_decode(code: high_4_bit)) { Data($0) }
//            let des2 = withUnsafeBytes(of: self.adpcm_decode(code: low_4_bit)) { Data($0) }
//            decoded.append(des1)
//            decoded.append(des2)
        }
        return decoded
    }
    func step_adjust(code: Int) -> Int {
        let c = code & 0x07
        return c<4 ? -1 : (c-3) * 2
//        switch code & 0x07 {
//        case 0x00:
//            return(-1)
//        case 0x01:
//            return(-1)
//        case 0x02:
//            return(-1)
//        case 0x03:
//            return(-1)
//        case 0x04:
//            return(2)
//        case 0x05:
//            return(4)//        case 0x06:
//            return(6)
//        case 0x07:
//            return(8)
//        default:
//            return 0
//        }
    }
}
class adpcm_status {
    var last: Int = 0
    var step_index: Int = 0
}
