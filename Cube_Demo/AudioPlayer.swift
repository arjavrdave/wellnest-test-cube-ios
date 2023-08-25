//
//  AudioPlayer.swift
//  Cube_Demo
//
//  Created by Nihar Jagad on 02/06/23.
//

import Foundation
import AVFoundation

class VoicePlayer {
    
    var engine: AVAudioEngine
    
    let format = AVAudioFormat(commonFormat: AVAudioCommonFormat.pcmFormatInt16, sampleRate: 48000.0, channels: 2, interleaved: true)!
    let playerNode: AVAudioPlayerNode!
    var audioSession: AVCaptureSession = AVCaptureSession()
    
    init() {
        
        self.audioSession = AVCaptureSession()
        
        self.engine = AVAudioEngine()
        self.playerNode = AVAudioPlayerNode()
        
        self.engine.attach(self.playerNode)
        //engine.connect(self.playerNode, to: engine.mainMixerNode, format:AVAudioFormat.init(standardFormatWithSampleRate: 48000, channels: 2))
        /* If I set my custom format here, AVFoundation complains about the format not being available */
        engine.connect(self.playerNode, to: engine.outputNode, format:AVAudioFormat.init(standardFormatWithSampleRate: 48000, channels: 2))
        engine.prepare()
        try! engine.start()
        self.playerNode.play()
        
    }
    
    
    
    
    func play(buffer: [Int16]) {
        let interleavedChannelCount = 2
        let frameLength = buffer.count / interleavedChannelCount
        let audioBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(frameLength))!
        print("audio buffer size in frames is \(AVAudioFrameCount(frameLength))")
        // buffer contains 2 channel interleaved data
        // audioBuffer contains 2 channel interleaved data
        var buf = buffer
        let size = MemoryLayout<Int16>.stride * interleavedChannelCount * frameLength
        
        
        memcpy(audioBuffer.mutableAudioBufferList.pointee.mBuffers.mData, &buf, size)
        audioBuffer.frameLength = AVAudioFrameCount(frameLength)
        
        /* Implemented an AVAudioConverter for testing
         Input: 16 bit PCM 48kHz stereo interleaved
         Output: whatever the standard format for the system is
         
         Maybe this is somehow needed as my audio interface doesn't directly support 16 bit audio and can only run at 24 bit?
         */
         let normalBuffer = AVAudioPCMBuffer(pcmFormat: AVAudioFormat.init(standardFormatWithSampleRate: 48000, channels: 2)!, frameCapacity: AVAudioFrameCount(frameLength))
         normalBuffer?.frameLength = AVAudioFrameCount(frameLength)
         let converter = AVAudioConverter(from: format, to: AVAudioFormat.init(standardFormatWithSampleRate: 48000, channels: 2)!)
         var gotData = false
         
         let inputBlock: AVAudioConverterInputBlock = { inNumPackets, outStatus in
         
         if gotData {
         outStatus.pointee = .noDataNow
         return nil
         }
         gotData = true
         outStatus.pointee = .haveData
         return audioBuffer
         }
         
         var error: NSError? = nil
         let status: AVAudioConverterOutputStatus = converter!.convert(to: normalBuffer!, error: &error, withInputFrom: inputBlock);
         
        // Play the output buffer, in this case the audioBuffer, otherwise the normalBuffer
        // Playing the raw audio buffer causes an EXEC_BAD_ACCESS on playback, playing back the buffer from the converter doesn't, but it still doesn't sound anything like a human voice
        self.playerNode.scheduleBuffer(audioBuffer) {
        print("Played")
        }
        
        
    }
    
    
}
