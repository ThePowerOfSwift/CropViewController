//
//  CropViewControllerTests.swift
//  CropViewControllerTests
//
//  Created by ST20591 on 2017/10/25.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import XCTest
@testable import CropViewController

private extension UIImage {
    func rotatedAndCropped(angle: CGFloat) -> UIImage? {
        guard let ciImage = safeCiImage else {
            return nil
        }
        let rotated = ciImage.applyingFilter("CIStraightenFilter", parameters: [kCIInputAngleKey: -angle])
        return UIImage(ciImage: rotated)
    }
}

class CropViewControllerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    private func assertConvertCGAffineTransform(_ state: TransformState) {
        let newState = TransformState.from(transform: state.asCGAffineTransform())
        // This possibly fails because of the float-value accuracy.
        // If it fails, use XCTAssertEqual(_, _, accuracy: _) or something else
        XCTAssertEqual(state, newState)
    }
    
    private static let statesForTest: [TransformState] = [
        TransformState.identity,
        TransformState(rotation: CGFloat.pi / 2, scale: 1.0, translation: CGPoint(x: 0, y: 0)),
        TransformState(rotation: 0, scale: 3.0, translation: CGPoint(x: 0, y: 0)),
        TransformState(rotation: 0, scale: 1.0, translation: CGPoint(x: 1, y: 2)),
        TransformState(rotation: CGFloat.pi / 2, scale: 3.0, translation: CGPoint(x: 0, y: 0)),
        TransformState(rotation: 0, scale: 3.0, translation: CGPoint(x: 1, y: 2)),
        TransformState(rotation: CGFloat.pi / 2, scale: 1.0, translation: CGPoint(x: 1, y: 2)),
        TransformState(rotation: CGFloat.pi / 2, scale: 3.0, translation: CGPoint(x: 1, y: 2))
    ]
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        CropViewControllerTests.statesForTest.forEach { state in
            assertConvertCGAffineTransform(state)
        }
    }
    
    func testCgImageWithGetter() {
        let image = #imageLiteral(resourceName: "sample.png")
        assert(image.cgImage != nil)
        self.measure {
            // Put the code you want to measure the time of here.
            for _ in 0..<100 {
                _ = image.safeCgImage!
            }
        }
    }
    
    func testCgImageWithBuild() {
        let image = #imageLiteral(resourceName: "sample.png").rotatedAndCropped(angle: 30)!
        assert(image.cgImage == nil)
        self.measure {
            // Put the code you want to measure the time of here.
            for _ in 0..<100 {
                _ = image.safeCgImage!
            }
        }
    }
    
}
