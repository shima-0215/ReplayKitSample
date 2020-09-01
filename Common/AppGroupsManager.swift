//
//  AppGroupsManager.swift
//  ReplayKitSample
//
//  Created by jun shima on 2020/08/19.
//  Copyright © 2020 jun shima. All rights reserved.
//

import Foundation
import ReplayKit

protocol AppGroupsManagerDelegate {
    @available(iOS 10.0, *)
    func sampleBufferType(sampleBufferType: RPSampleBufferType)
    func changeState(state: AppGroupsManager.BroadcastState)
    func sampleBuffer(sampleBuffer: CMSampleBuffer)
}

class AppGroupsManager: NSObject {
    private let groupID = "group.com.jshima.ReplayKitSample"
    private let kState = "state"
    private let kSampleBuffer = "sampleBuffer"
    private let kType = "type"
    private let userDefaults: UserDefaults!
    private let delegate: AppGroupsManagerDelegate?
    
    public enum BroadcastState: Int {
        case started
        case paused
        case resumed
        case finished
        case error
    }
    
    override init() {
        self.delegate = nil
        userDefaults = UserDefaults(suiteName: groupID)
        super.init()
    }
    
    init(delegate: AppGroupsManagerDelegate?) {
        self.delegate = delegate
        userDefaults = UserDefaults(suiteName: groupID)
        
        super.init()
        userDefaults.addObserver(self, forKeyPath: kState, options: .new, context: nil)
        userDefaults.addObserver(self, forKeyPath: kSampleBuffer, options: .new, context: nil)
        userDefaults.addObserver(self, forKeyPath: kType, options: .new, context: nil)
    }
    
    deinit {
        userDefaults.removeObject(forKey: kState)
        userDefaults.removeObject(forKey: kSampleBuffer)
        userDefaults.removeObject(forKey: kType)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case kState:
            guard let value = change?[NSKeyValueChangeKey.newKey] as? Int else { return }
            delegate?.changeState(state: BroadcastState(rawValue: value)!)
        case kSampleBuffer:
            guard let value = change?[NSKeyValueChangeKey.newKey] as? Data else { return }
            delegate?.sampleBuffer(sampleBuffer: NSKeyedUnarchiver.unarchiveObject(with: value) as! CMSampleBuffer)
        case kType:
            if #available(iOS 10.0, *) {
                guard let value = change?[NSKeyValueChangeKey.newKey] as? Int else { return }
                delegate?.sampleBufferType(sampleBufferType: RPSampleBufferType(rawValue: value)!)
            }
        default:
            break
        }
    }
    
    @available(iOS 10, *)
    var type: RPSampleBufferType? {
        set {
            userDefaults.set(newValue?.rawValue, forKey: kType)
        }
        get {
            guard let value = userDefaults.object(forKey: kType) as? Int else { return nil }
            return RPSampleBufferType(rawValue: value)
        }
    }
    
    var state: BroadcastState? {
        set {
            userDefaults.set(newValue?.rawValue, forKey: kState)
        }
        get {
            guard let value = userDefaults.object(forKey: kState) as? Int else { return nil }
            return BroadcastState(rawValue: value)
        }
    }
    
    var sampleBuffer: CMSampleBuffer? {
        get {
//            if let value = userDefaults.object(forKey: kSampleBuffer) as? Data {
//                return NSKeyedUnarchiver.unarchiveObject(with: value) as! CMSampleBuffer
//            }
            return nil
        }
        set {
            let imageBuffer = CMSampleBufferGetImageBuffer(newValue!)
            CVPixelBufferLockBaseAddress(imageBuffer!, CVPixelBufferLockFlags(rawValue: 0))
            let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer!)
            let height = CVPixelBufferGetHeight(imageBuffer!)
            let src_buff = CVPixelBufferGetBaseAddress(imageBuffer!)
            let data = NSData(bytes: src_buff, length: bytesPerRow * height)
            CVPixelBufferUnlockBaseAddress(imageBuffer!, CVPixelBufferLockFlags(rawValue: 0))
            let archiveData = NSKeyedArchiver.archivedData(withRootObject: data)
            userDefaults.set(archiveData, forKey: kSampleBuffer)
        }
    }
}
