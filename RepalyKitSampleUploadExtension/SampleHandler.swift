//
//  SampleHandler.swift
//  RepalyKitSampleUploadExtension
//
//  Created by shima on 2020/08/13.
//  Copyright © 2020 jun shima. All rights reserved.
//

import ReplayKit

enum BroadcastError: Error {
    case notMeeting
}

class SampleHandler: RPBroadcastSampleHandler {

    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.
        print("started")
        updateServiceInfo(["state": (0) as NSCoding & NSObjectProtocol])
        AppGroupsManager().state = .started
//        finishBroadcastWithError(BroadcastError.notMeeting)
    }
    
    override func broadcastPaused() {
        // User has requested to pause the broadcast. Samples will stop being delivered.
        print("paused")
        AppGroupsManager().state = .paused
    }
    
    override func broadcastResumed() {
        // User has requested to resume the broadcast. Samples delivery will resume.
        print("resumed")
        AppGroupsManager().state = .resumed
    }
    
    override func broadcastFinished() {
        // User has requested to finish the broadcast.
        print("finished")
        updateServiceInfo(["state": (1) as NSCoding & NSObjectProtocol])
        AppGroupsManager().state = .finished
    }
    
    override func finishBroadcastWithError(_ error: Error) {
        print("Error \(error)")
        AppGroupsManager().state = .error
        super.finishBroadcastWithError(error)
    }
    
    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        switch sampleBufferType {
        case RPSampleBufferType.video:
            // Handle video sample buffer
            print("video sample")
            AppGroupsManager().sampleBuffer = sampleBuffer
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
