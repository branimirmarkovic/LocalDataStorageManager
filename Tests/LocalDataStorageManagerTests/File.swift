//
//  File.swift
//  
//
//  Created by Branimir Markovic on 10.4.23..
//


import XCTest
@testable import LocalDataStorageManager

class LocalDataStorageManagerWithDataValidationPolicyDecoratorTests: XCTestCase {
    private var localDataStorageManager: LocalDataStorageManager!
    private var dataCachePolicy: DataCachePolicy!
    private var decoratedManager: LocalDataStorageManagerWithDataValidationPolicyDecorator!
    
    override func setUpWithError() throws {
        localDataStorageManager = try LocalDataStorageManager()
        dataCachePolicy = AlwaysValidDataCachePolicy(timeLimit: 0.0)
        decoratedManager = LocalDataStorageManagerWithDataValidationPolicyDecorator(dataCachePolicy: dataCachePolicy, dataStorageManager: localDataStorageManager)
    }
    
    override func tearDownWithError() throws {
        localDataStorageManager.cleanUp()
        localDataStorageManager = nil
        dataCachePolicy = nil
        decoratedManager = nil
    }
    
    func testWriteAndReadData() {
        let data = "Test data".data(using: .utf8)!
        let url = "test_file.txt"
        
        let writeExpectation = expectation(description: "Write data expectation")
        decoratedManager.write(data: data, to: url) { result in
            switch result {
            case .success:
                writeExpectation.fulfill()
            case .failure(let error):
                XCTFail("Write data failed with error: \(error)")
            }
        }
        waitForExpectations(timeout: 5)
        
        let readExpectation = expectation(description: "Read data expectation")
        decoratedManager.read(from: url) { result in
            switch result {
            case .success(let retrievedData):
                XCTAssertEqual(data, retrievedData)
                readExpectation.fulfill()
            case .failure(let error):
                XCTFail("Read data failed with error: \(error)")
            }
        }
        waitForExpectations(timeout: 5)
    }
    
    func testDeleteData() {
        let data = "Test data".data(using: .utf8)!
        let url = "test_file.txt"
        
        let writeExpectation = expectation(description: "Write data expectation")
        decoratedManager.write(data: data, to: url) { result in
            switch result {
            case .success:
                writeExpectation.fulfill()
            case .failure(let error):
                XCTFail("Write data failed with error: \(error)")
            }
        }
        waitForExpectations(timeout: 5)
        
        let deleteExpectation = expectation(description: "Delete data expectation")
        decoratedManager.delete(at: url) { result in
            switch result {
            case .success:
                deleteExpectation.fulfill()
            case .failure(let error):
                XCTFail("Delete data failed with error: \(error)")
            }
        }
        waitForExpectations(timeout: 5)
        
        let readExpectation = expectation(description: "Read data expectation")
        decoratedManager.read(from: url) { result in
            switch result {
            case .success:
                XCTFail("Data should have been deleted")
            case .failure(let error):
                if case LocalDataStorageManagerWithDataValidationPolicyDecorator.ManagerError.noData = error {
                    readExpectation.fulfill()
                } else {
                    XCTFail("Read data failed with unexpected error: \(error)")
                }
            }
        }
        waitForExpectations(timeout: 5)
    }
    
    func testInvalidData() {
        let data = "Test data".data(using: .utf8)!
        let url = "test_file.txt"
        let neverValidDataCachePolicy = NeverValidDataCachePolicy(timeLimit: 0.0)
        
        let decoratedManager = LocalDataStorageManagerWithDataValidationPolicyDecorator(dataCachePolicy: neverValidDataCachePolicy, dataStorageManager: localDataStorageManager)
        let writeExpectation = expectation(description: "Write data expectation")
        decoratedManager.write(data: data, to: url) { result in
            switch result {
            case .success:
                writeExpectation.fulfill()
            case .failure(let error):
                XCTFail("Write data failed with error: \(error)")
            }
        }
        waitForExpectations(timeout: 5)
        
        let readExpectation = expectation(description: "Read data expectation")
        decoratedManager.read(from: url) { result in
            switch result {
            case .success:
                XCTFail("Data should have been invalid")
            case .failure(let error):
                if case LocalDataStorageManagerWithDataValidationPolicyDecorator.ManagerError.dataNoLongerValid = error {
                    readExpectation.fulfill()
                } else {
                    XCTFail("Read data failed with unexpected error: \(error)")
                }
            }
        }
        waitForExpectations(timeout: 5)
    }
}


struct AlwaysValidDataCachePolicy: DataCachePolicy {
    
    init(timeLimit: TimeInterval) {}
    
    func isDataValid(for timeValidableData: TimeValidable) -> Bool {
        return true
    }
}

struct NeverValidDataCachePolicy: DataCachePolicy {
    
    init(timeLimit: TimeInterval) {}
    
    func isDataValid(for timeValidableData: TimeValidable) -> Bool {
        return false
    }
}
