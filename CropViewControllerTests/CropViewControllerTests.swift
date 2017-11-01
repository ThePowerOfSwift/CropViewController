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
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
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
