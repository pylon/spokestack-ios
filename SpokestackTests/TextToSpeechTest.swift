//
//  TTSManagerTest.swift
//  SpokestackTests
//
//  Created by Noel Weichbrodt on 11/15/19.
//  Copyright © 2020 Spokestack, Inc. All rights reserved.
//

import Foundation
import XCTest
import Spokestack

@available(iOS 13, *)
class TextToSpeechTest: XCTestCase {
    
    /// MARK: Synthesize
    func testSynthesize() {
        let delegate = TestTextToSpeechDelegate()
        let input = TextToSpeechInput()

        // bad config results in a failed request that calls failure
        let badConfig = SpeechConfiguration()
        let didFailConfigExpectation = expectation(description: "bad config results in a failed request that calls TestTextToSpeechDelegate.failure")
        badConfig.apiId = "BADBADNOTGOOD"
        let badTTS = TextToSpeech(delegate, configuration: badConfig)
        delegate.asyncExpectation = didFailConfigExpectation
        badTTS.synthesize(input)
        wait(for: [didFailConfigExpectation], timeout: 5)
        XCTAssert(delegate.didFail)
        XCTAssertFalse(delegate.didSucceed)
        
        let config = SpeechConfiguration()
        let tts = TextToSpeech(delegate, configuration: config)
        
        // successful request calls success
        delegate.reset()
        let didSucceedExpectation = expectation(description: "successful request calls TestTextToSpeechDelegate.success")
        delegate.asyncExpectation = didSucceedExpectation
        tts.synthesize(input)
        wait(for: [didSucceedExpectation], timeout: 5)
        XCTAssert(delegate.didSucceed)
        XCTAssertFalse(delegate.didFail)
    }
    
    func testSynthesizeSSML() {
        let delegate = TestTextToSpeechDelegate()
        let config = SpeechConfiguration()
        let tts = TextToSpeech(delegate, configuration: config)
        
        // successful request with ssml formatting
        let didSucceedExpectation2 = expectation(description: "successful request calls TestTextToSpeechDelegate.success")
        delegate.asyncExpectation = didSucceedExpectation2
        let ssmlInput = TextToSpeechInput("<speak>Yet right now the average age of this 52nd Parliament is 49 years old, <break time='500ms'/> OK Boomer.</speak>", voice: .demoMale, inputFormat: .ssml)
        tts.synthesize(ssmlInput)
        wait(for: [didSucceedExpectation2], timeout: 5)
        XCTAssert(delegate.didSucceed)
        XCTAssertFalse(delegate.didFail)
    }
        
    func testSynthesizeMarkdown() {
        let delegate = TestTextToSpeechDelegate()
        let config = SpeechConfiguration()
        let tts = TextToSpeech(delegate, configuration: config)
        
        // successful request with markdown formatting
        delegate.reset()
        let didSucceedExpectation3 = expectation(description: "successful request calls TestTextToSpeechDelegate.success")
        delegate.asyncExpectation = didSucceedExpectation3
        let markdownInput = TextToSpeechInput("Yet right now the average age of this (50)[number] second Parliament is (49)[number] years old, [1s] OK Boomer.", voice: .demoMale, inputFormat: .markdown)
        tts.synthesize(markdownInput)
        wait(for: [didSucceedExpectation3], timeout: 5)
        XCTAssert(delegate.didSucceed)
        XCTAssertFalse(delegate.didFail)
    }
    
    func testSynthesizePublisher() {
        let config = SpeechConfiguration()
        guard let tts = try? TextToSpeech(configuration: config) else {
            XCTFail("could not initialize TextToSpeech class")
            return
        }
        let input = TextToSpeechInput()

        // successful request
        let didCompleteExpectation = expectation(description: "successful request publishes completion")
        let publisher = tts.synthesize([input])
            .sink(
                receiveCompletion: {completion in
                    switch completion {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                        break
                    case .finished:
                        didCompleteExpectation.fulfill()
                        break
                    }
            },
                receiveValue: {result in
                    XCTAssertTrue(result.count > 0)
                    XCTAssertNotNil(result.first?.url)
            })
        XCTAssertNotNil(publisher)
        wait(for: [didCompleteExpectation], timeout: 5)
    }
    
    /// MARK:  Speak
    func testSpeak() {
        
        // speak() calls didBeginSpeaking and didFinishSpeaking
        let didBeginExpectation = expectation(description: "successful request calls TestTextToSpeechDelegate.didBeginSpeaking")
        let didFinishExpectation = expectation(description: "successful request calls TestTextToSpeechDelegate.didFinishSpeaking")
        let delegate = TestTextToSpeechDelegate()
        delegate.asyncExpectation = didBeginExpectation
        delegate.didFinishExpectation = didFinishExpectation
        let input = TextToSpeechInput()
        let config = SpeechConfiguration()
        let tts = TextToSpeech(delegate, configuration: config)
        tts.speak(input)
        wait(for: [didBeginExpectation, didFinishExpectation], timeout: 10)
        XCTAssert(delegate.didBegin)
        XCTAssert(delegate.didFinish)
    }
}

class TestTextToSpeechDelegate: TextToSpeechDelegate {
    /// Spy pattern for the system under test.
    /// asyncExpectation lets the caller's test know when the delegate has been called.
    var didSucceed: Bool = false
    var didFail: Bool = false
    var didBegin: Bool = false
    var didFinish: Bool = false
    var asyncExpectation: XCTestExpectation?
    var didFinishExpectation: XCTestExpectation?
    
    func reset() {
        didSucceed = false
        didFail = false
        didBegin = false
        didFinish = false
        asyncExpectation = .none
    }
    
    func success(result: TextToSpeechResult) {
        asyncExpectation?.fulfill()
        didSucceed = true
    }
    
    func failure(ttsError error: Error) {
        asyncExpectation?.fulfill()
        didFail = true
    }
    
    func didBeginSpeaking() {
        asyncExpectation?.fulfill()
        didBegin = true
    }
    
    func didFinishSpeaking() {
        didFinishExpectation?.fulfill()
        didFinish = true
    }
    
    func didTrace(_ trace: String) -> Void {
        print(trace)
    }
}
