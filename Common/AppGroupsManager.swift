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
    func changeState(state: AppGroupsManager.BroadcastState)
    func sampleBuffer(sampleBuffer: CMSampleBuffer)
    @available(iOS 10.0, *)
    func sampleBufferType(sampleBufferType: RPSampleBufferType)
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
            guard let value = change?[NSKeyValueChangeKey.newKey] as? Int else { return }
            if #available(iOS 10.0, *) {
                delegate?.sampleBufferType(sampleBufferType: RPSampleBufferType(rawValue: value)!)
            } else {
                // Fallback on earlier versions
            }
        default:
            break
        }
    }
    
    var state: BroadcastState? {
        get {
            return userDefaults?.object(forKey: kState) as? BroadcastState
        }
        set {
            userDefaults?.set(newValue?.rawValue, forKey: kState)
        }
    }
    
    var sampleBuffer: CMSampleBuffer? {
        get {
            if let value = userDefaults.object(forKey: kSampleBuffer) as? Data {
                return NSKeyedUnarchiver.unarchiveObject(with: value) as! CMSampleBuffer
            }
            return nil
        }
        set {
            let data = NSKeyedArchiver.archivedData(withRootObject: newValue)
            userDefaults.set(data, forKey: kSampleBuffer)
        }
    }
    
    @available(iOS 10, *)
    var type: RPSampleBufferType? {
        set {
            userDefaults.set(newValue?.rawValue, forKey: kType)
        }
        get {
            return userDefaults.object(forKey: kType) as? RPSampleBufferType
        }
    }
}
