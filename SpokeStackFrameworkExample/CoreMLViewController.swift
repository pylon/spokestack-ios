//
//  CoreMLViewController.swift
//  SpokeStackFrameworkExample
//
//  Created by Noel Weichbrodt on 6/13/19.
//  Copyright © 2019 Pylon AI, Inc. All rights reserved.
//

import UIKit
import SpokeStack
import AVFoundation

class CoreMLViewController: UIViewController {
    
    lazy var startRecordingButton: UIButton = {
        
        let button: UIButton = UIButton(frame: .zero)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Start Recording", for: .normal)
        button.addTarget(self,
                         action: #selector(CoreMLViewController.startRecordingAction(_:)),
                         for: .touchUpInside)
        button.setTitleColor(.purple, for: .normal)
        
        return button
    }()
    
    var stopRecordingButton: UIButton = {
        
        let button: UIButton = UIButton(frame: .zero)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Stop Recording", for: .normal)
        button.addTarget(self,
                         action: #selector(CoreMLViewController.stopRecordingAction(_:)),
                         for: .touchUpInside)
        
        button.setTitleColor(.purple, for: .normal)
        
        
        return button
    }()
    
    lazy private var pipeline: SpeechPipeline = {
                
        return try! SpeechPipeline(.appleSpeech,
                                   speechConfiguration: RecognizerConfiguration(),
                                   speechDelegate: self,
                                   wakewordService: .coremlWakeword,
                                   wakewordConfiguration: WakewordConfiguration(),
                                   wakewordDelegate: self,
                                   pipelineDelegate: self)
    }()
    
    override func loadView() {
        
        super.loadView()
        self.view.backgroundColor = .white
        self.title = "CoreML"
        
        let doneBarButtonItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                                 target: self,
                                                                 action: #selector(CoreMLViewController.dismissViewController(_:)))
        self.navigationItem.rightBarButtonItem = doneBarButtonItem
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.startRecordingButton)
        self.view.addSubview(self.stopRecordingButton)
        
        self.startRecordingButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        self.startRecordingButton.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor).isActive = true
        self.startRecordingButton.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor).isActive = true
        
        self.stopRecordingButton.topAnchor.constraint(equalTo: self.startRecordingButton.bottomAnchor, constant: 50.0).isActive = true
        self.stopRecordingButton.leftAnchor.constraint(equalTo: self.startRecordingButton.leftAnchor).isActive = true
        self.stopRecordingButton.rightAnchor.constraint(equalTo: self.startRecordingButton.rightAnchor).isActive = true
    }
    
    @objc func startRecordingAction(_ sender: Any) {
        print("pipeline started")
        self.pipeline.start()
    }
    
    @objc func stopRecordingAction(_ sender: Any) {
        print("pipeline finished")
        self.pipeline.stop()
    }
    
    @objc func dismissViewController(_ sender: Any?) -> Void {
        self.dismiss(animated: true, completion: nil)
    }
    
    func toggleStartStop() {
        DispatchQueue.main.async {
            self.stopRecordingButton.isEnabled.toggle()
            self.startRecordingButton.isEnabled.toggle()
        }
    }
}

extension CoreMLViewController: SpeechRecognizer, WakewordRecognizer, PipelineDelegate {
    func setupFailed(_ error: String) {
        print("setupFailed: " + error)
    }
    
    func didInit() {
        print("didInit")
    }
    
    func didStop() {
        print("didStop")
    }
    
    func timeout() {
        print("timeout")
    }
    
    func activate() {
        print("activate")
        self.toggleStartStop()
        self.pipeline.activate()
    }
    
    func deactivate() {
        print("deactivate")
        self.toggleStartStop()
        self.pipeline.deactivate()
    }
    
    func didError(_ error: Error) {
        print("didError \(String(describing: error))")
    }
    
    func didRecognize(_ result: SpeechContext) {
        print("didRecognize transcript \(result.transcript)")
    }
    
    func didStart() {
        print("didStart")
        self.toggleStartStop()
    }
}