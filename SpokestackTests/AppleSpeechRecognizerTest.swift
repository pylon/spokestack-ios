//
//  AppleSpeechRecognizerTest.swift
//  SpokestackTests
//
//  Created by Noel Weichbrodt on 9/16/19.
//  Copyright © 2020 Spokestack, Inc. All rights reserved.
//

import Foundation
import XCTest
import Spokestack
import AVFoundation

class AppleSpeechRecognizerTest: XCTestCase {

    /// startStreaming
    func testStartStopStreaming() {
        let delegate = AppleSpeechRecognizerTestDelegate()
        let asr = AppleSpeechRecognizer.sharedInstance
        let context = SpeechContext()
        asr.configuration = SpeechConfiguration()
        asr.delegate = delegate
        asr.startStreaming(context: context)
        XCTAssert(context.isActive)
        asr.stopStreaming(context: context)
        XCTAssert(!context.isActive)
    }
}

class AppleSpeechRecognizerTestDelegate: PipelineDelegate, SpeechEventListener {
    /// Spy pattern for the system under test.
    /// asyncExpectation lets the caller's test know when the delegate has been called.
    var didError: Bool = false
    var didDidTimeout: Bool = false
    var didDeactivate: Bool = false
    var didRecognize: Bool = false
    var asyncExpectation: XCTestExpectation?
    
    func reset() {
        self.didError = false
        self.didDidTimeout = false
        self.didDeactivate = false
        self.didRecognize = false
        self.didRecognize = false
        asyncExpectation = .none
    }
    
    func didRecognize(_ result: SpeechContext) {
        print(result)
        self.didRecognize = true
    }
    
    func didError(_ error: Error) {
        print(error)
        guard let _ = asyncExpectation else {
            XCTFail("AppleSpeechRecognizerTestDelegate was not setup correctly. Missing XCTExpectation reference")
            return
        }
        self.didError = true
        self.asyncExpectation?.fulfill()
    }
    
    func didTimeout() {
        self.didDidTimeout = true
    }
    
    func activate() {}

    func deactivate() {
        self.didDeactivate = true
    }
    
    func didStop() {}
    
    func didStart() {}
    
    func didInit() {}
    
    func setupFailed(_ error: String) {}
    
    func didTrace(_ trace: String) {
        print(trace)
    }
}
