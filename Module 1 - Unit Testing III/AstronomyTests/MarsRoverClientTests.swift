//
//  MarsRoverClientTests.swift
//  AstronomyTests
//
//  Created by Andrew R Madsen on 9/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import XCTest
@testable import Astronomy

struct MockLoader: NetworkDataLoader {
    
    func loadData(from request: URLRequest, completion: @escaping (Data?, Error?) -> Void) {
        loadData(from: request.url!, completion: completion)
    }
    
    func loadData(from url: URL, completion: @escaping (Data?, Error?) -> Void) {
        DispatchQueue.global().async { completion(self.data, self.error) }
    }
    
    let data: Data?
    let error: Error?
}

class MarsRoverClientTests: XCTestCase {
    
    enum TestError : Error { case unknownError }
    
    func testFetchingMarsRover() {
        let mock = MockLoader(data: validRoverJSON, error: nil)
        let client = MarsRoverClient(networkLoader: mock)
        
        let expectation = self.expectation(description: "Mars Rover Fetch Expectation")
        client.fetchMarsRover(named: "curiosity") { (rover, error) in
            defer { expectation.fulfill() }
            XCTAssertNotNil(rover)
            XCTAssertNil(error)
            
            XCTAssertEqual(rover?.name, "Curiosity")
            XCTAssertEqual(rover?.numberOfPhotos, 4156)
            XCTAssertEqual(rover?.solDescriptions.count, 5)
        }
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testFetchingMarsRoverError() {
        let mock = MockLoader(data: nil, error: TestError.unknownError)
        let client = MarsRoverClient(networkLoader: mock)
        
        let expectation = self.expectation(description: "Mars Rover Fetch Expectation")
        client.fetchMarsRover(named: "curiosity") { (rover, error) in
            defer { expectation.fulfill() }
            XCTAssertNotNil(error)
            XCTAssertNil(rover)
        }
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testFetchingPhotos() {
        let mock = MockLoader(data: validSol1JSON, error: nil)
        let client = MarsRoverClient(networkLoader: mock)
        
        let expectation = self.expectation(description: "Photo Fetch Expectation")
        let jsonDecoder = MarsPhotoReference.jsonDecoder
        let rover = (try! jsonDecoder.decode([String : MarsRover].self, from: validRoverJSON))["photoManifest"]!
        client.fetchPhotos(from: rover, onSol: 1) { (photos, error) in
            defer { expectation.fulfill() }
            XCTAssertNotNil(photos)
            XCTAssertNil(error)
            
            XCTAssertEqual(photos?.count, 16)
            let firstPhoto = photos![0]
            XCTAssertEqual(firstPhoto.sol, 1)
            XCTAssertEqual(firstPhoto.camera.name, "MAST")
            XCTAssertNotNil(firstPhoto.imageURL)
        }
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testFetchingPhotosError() {
        let mock = MockLoader(data: nil, error: TestError.unknownError)
        let client = MarsRoverClient(networkLoader: mock)
        
        let expectation = self.expectation(description: "Photo Fetch Expectation")
        let jsonDecoder = MarsPhotoReference.jsonDecoder
        let rover = (try! jsonDecoder.decode([String : MarsRover].self, from: validRoverJSON))["photoManifest"]!
        client.fetchPhotos(from: rover, onSol: 1) { (photos, error) in
            defer { expectation.fulfill() }
            XCTAssertNotNil(error)
            XCTAssertNil(photos)
        }
        waitForExpectations(timeout: 10.0, handler: nil)
    }
}

