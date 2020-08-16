//
//  SampleHandler.swift
//  RepalyKitSampleUploadExtension
//
//  Created by shima on 2020/08/13.
//  Copyright © 2020 jun shima. All rights reserved.
//

import ReplayKit

class SampleHandler: RPBroadcastSampleHandler {

    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.
        print("started")
        updateServiceInfo(["state": (0) as NSCoding & NSObjectProtocol])
    }
    
    override func broadcastPaused() {
        // User has requested to pause the broadcast. Samples will stop being delivered.
        print("paused")
    }
    
    override func broadcastResumed() {
        // User has requested to resume the broadcast. Samples delivery will resume.
        print("resumed")
    }
    
    override func broadcastFinished() {
        // User has requested to finish the broadcast.
        print("finished")
        updateServiceInfo(["state": (1) as NSCoding & NSObjectProtocol])
    }
    
    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        switch sampleBufferType {
        case RPSampleBufferType.video:
            // Handle video sample buffer
            print("video sample")
            break
        case RPSampleBufferType.audioApp:
            // Handle audio sample buffer for app audio
            break
        case RPSampleBufferType.audioMic:
            // Handle audio sample buffer for mic audio
            break
        @unknown default:
            // Handle other sample buffer types
            fatalError("Unknown type of sample buffer")
        }
        
    }
}
