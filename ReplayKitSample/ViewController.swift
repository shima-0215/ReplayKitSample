//
//  ViewController.swift
//  ReplayKitSample
//
//  Created by shima on 2020/08/13.
//  Copyright © 2020 jun shima. All rights reserved.
//

import UIKit
import ReplayKit

class ViewController: UIViewController {
    
    // In-App Capture
    @IBOutlet private var recordingButton: UIButton!
    @IBOutlet private var captureButton: UIButton!
    
    // Live Broadcast
    @IBOutlet private var broadcastButton: UIButton!
    @IBOutlet private var pairingButton: UIButton!
    @IBOutlet private var broadcastView: UIView!
    
    private var recorder = RPScreenRecorder.shared()
    
    private var controller: Any?
    @available(iOS 10.0, *)
    var broadcastController: RPBroadcastController? {
        get {
            return controller as? RPBroadcastController
        }
        set(new) {
            controller = new as Any
        }
    }
    private var _observers = [NSKeyValueObservation]()
    
    private let kUploadExtension = "com.jshima.ReplayKitSample.RepalyKitSampleUploadExtension"
    private let kSetupExtension = "com.jshima.ReplayKitSample.RepalyKitSampleUploadExtensionSetupUI"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupRecorder()
        setupBroadcastPickerView()
        setupKVO()
    }
    
    func setupUI() {
        if #available(iOS 10, *) {
            recordingButton.isEnabled = true
            broadcastButton.isEnabled = true
        }
        if #available(iOS 11, *) {
            captureButton.isEnabled = true
            pairingButton.isEnabled = true
        }
    }
    
    func setupRecorder() {
        recorder.isMicrophoneEnabled = true
        recorder.delegate = self
    }
    
    func setupKVO() {
        if #available(iOS 10.0, *) {
            broadcastController = RPBroadcastController()
            broadcastController?.delegate = self
            broadcastController?.addObserver(self, forKeyPath: "serviceInfo", options: .new, context: nil)
//            _observers.append((broadcastController?.observe(\.serviceInfo, options: .new) { (controller, change) in
//                print("\(#function) \(change)")
//                })!)
        }
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case "serviceInfo":
            print("\(#function)")
        default:
            print("")
        }
    }
    
    // MARK: - Recording
    @IBAction func recording() {
        if recorder.isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    func startRecording() {
        if #available(iOS 10.0, *) {
            recorder.startRecording { (error) in
                if let error = error {
                    print("\(#function) \(error)")
                    return
                }
            }
        }
    }
    
    func stopRecording() {
        recorder.stopRecording { (preview, error) in
            if let error = error {
                print("\(#function) \(error)")
                return
            }
            if let preview = preview {
                preview.previewControllerDelegate = self
                self.present(preview, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Capture
    @IBAction func capture() {
        if recorder.isRecording {
            stopCapture()
        } else {
            startCapture()
        }
    }

    func startCapture() {
        if #available(iOS 11.0, *) {
            recorder.startCapture(handler: { (cmSampleBuffer, sampleBufferType, error) in
                switch sampleBufferType {
                case .audioApp:
                    print("audioApp")
                case .audioMic:
                    print("audioMic")
                case .video:
                    print("video")
                @unknown default:
                    fatalError()
                }
            }) { (error) in
                if let error = error {
                    print("\(#function) \(error)")
                    return
                }
            }
        }
    }
    
    func stopCapture() {
        if #available(iOS 11.0, *) {
            recorder.stopCapture { (error) in
                if let error = error {
                    print("\(#function) \(error)")
                    return
                }
            }
        }
    }
    
    // MARK: - Broadcast
    @IBAction func broadcast() {
        if #available(iOS 10.0, *) {
            if broadcastController?.isBroadcasting ?? false {
                stopBroadcasst()
            } else {
                startBroadcast()
            }
        }
    }
    
    func startBroadcast() {
        if #available(iOS 10.0, *) {
            RPBroadcastActivityViewController.load { (broadcastAVC, error) in
                if let error = error {
                    print("\(#function) \(error)")
                    return
                }
                if let broadcastAVC = broadcastAVC {
                    broadcastAVC.delegate = self
                    self.present(broadcastAVC, animated: true, completion: nil)
                }
            }
        }
    }
    
    func stopBroadcasst() {
        if #available(iOS 10.0, *) {
            broadcastController?.finishBroadcast { (error) in
                if let error = error {
                    print("\(#function) \(error)")
                    return
                }
            }
        }
    }
    
    // MARK: - Broadcast Pairing
    @IBAction func broadcastPairing() {
        if #available(iOS 10.0, *) {
            if broadcastController?.isBroadcasting ?? false {
                stopBroadcasst()
            } else {
                startBroadcastPairing()
            }
        }
    }
    
    func startBroadcastPairing() {
        if #available(iOS 11.0, *) {
            RPBroadcastActivityViewController.load(withPreferredExtension: kSetupExtension) { (broadcastAVC, error) in
                if let error = error {
                    print("\(#function) \(error)")
                    return
                }
                if let broadcastAVC = broadcastAVC {
                    broadcastAVC.delegate = self
                    self.present(broadcastAVC, animated: true, completion: nil)
                }
            }
        }
    }
    
    // MARK: - BroadcastPickerView
    func setupBroadcastPickerView() {
        if #available(iOS 12, *) {
            let broadcastPicker = RPSystemBroadcastPickerView(frame: broadcastView.bounds)
            
            broadcastPicker.preferredExtension = kUploadExtension
            broadcastPicker.showsMicrophoneButton = true
            broadcastPicker.backgroundColor = .clear
            
            for subview  in broadcastPicker.subviews {
                let b = subview as! UIButton
                    b.setImage(nil, for: .normal)
                    b.setTitle("画面共有", for: .normal)
                    b.setTitleColor(.black, for: .normal)
            }
            self.broadcastView.addSubview(broadcastPicker)
        }
    }
}

// MARK: - RPScreenRecorderDelegate
extension ViewController: RPScreenRecorderDelegate {
    func screenRecorderDidChangeAvailability(_ screenRecorder: RPScreenRecorder) {
        print("\(#function) isAvailable:\(screenRecorder.isAvailable)")
        print("\(#function) isRecording:\(screenRecorder.isRecording)")
    }
}

// MARK: - RPPreviewViewControllerDelegate
extension ViewController: RPPreviewViewControllerDelegate {
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - RPBroadcastActivityViewControllerDelegate
@available(iOS 10.0, *)
extension ViewController: RPBroadcastActivityViewControllerDelegate {
    func broadcastActivityViewController(_ broadcastActivityViewController: RPBroadcastActivityViewController, didFinishWith broadcastController: RPBroadcastController?, error: Error?) {
        if let error = error {
            print("\(#function) \(error)")
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
            return
        }
        if let broadcastController = broadcastController {
            self.broadcastController = broadcastController
            self.broadcastController?.delegate = self
            DispatchQueue.main.async {
                self.dismiss(animated: true) {
                    self.broadcastController?.startBroadcast(handler: { (error) in
                        if let error = error {
                            print("\(#function) \(error)")
                            return
                        }
                    })
                }
            }
        }
    }
}

// MARK: - RPBroadcastControllerDelegate
@available(iOS 10.0, *)
extension ViewController: RPBroadcastControllerDelegate {
    func broadcastController(_ broadcastController: RPBroadcastController, didFinishWithError error: Error?) {
        if let error = error {
            print("\(#function) \(error)")
            return
        }
    }
    
    func broadcastController(_ broadcastController: RPBroadcastController, didUpdateServiceInfo serviceInfo: [String : NSCoding & NSObjectProtocol]) {
        print("\(#function) \(serviceInfo)")
    }
}
