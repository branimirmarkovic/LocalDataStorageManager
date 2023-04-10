//
//  File.swift
//  
//
//  Created by Branimir Markovic on 7.4.23..
//


import XCTest
@testable import LocalDataStorageManager



class LocalDataStorageManagerTests: XCTestCase {

    var localDataStorageManager: LocalDataStorageManager!

    override func setUpWithError() throws {
        localDataStorageManager = try LocalDataStorageManager()
    }

    override func tearDownWithError() throws {
        localDataStorageManager = nil
         clearTestDirectoriesAndFiles()
    }
    
    func test_Init_DefaultDirectoryName_ShouldCreateDirectory() {
         clearTestDirectoriesAndFiles()
        let defaultDirectoryName = "RootDirectory"
        
        XCTAssertNoThrow(try LocalDataStorageManager())
        let localDataStorageManager = try! LocalDataStorageManager()
        let mainDirectoryUrl = UserDefaults.standard.url(forKey: LocalDataStorageManager.userDefaultsFilePathKey)!
        
        let lastPathComponent = mainDirectoryUrl.lastPathComponent
        XCTAssertEqual(lastPathComponent, defaultDirectoryName)
        
        let fileManager = FileManager.default
        XCTAssertTrue(fileManager.fileExists(atPath: mainDirectoryUrl.path))
        clearTestDirectoriesAndFilesFor(url: defaultDirectoryName)
    }

        func test_Init_CustomDirectoryName_ShouldCreateDirectory() {
            clearTestDirectoriesAndFiles()
            let customDirectoryName = "CustomRootDirectory"

            XCTAssertNoThrow(try LocalDataStorageManager(rootDirectoryName: customDirectoryName))
            _ = try! LocalDataStorageManager(rootDirectoryName: customDirectoryName)
            let mainDirectoryUrl = UserDefaults.standard.url(forKey: LocalDataStorageManager.userDefaultsFilePathKey)!

            let lastPathComponent = mainDirectoryUrl.lastPathComponent
            XCTAssertEqual(lastPathComponent, customDirectoryName)

            let fileManager = FileManager.default
            XCTAssertTrue(fileManager.fileExists(atPath: mainDirectoryUrl.path))
           clearTestDirectoriesAndFilesFor(url: customDirectoryName)
        }

        func test_Init_DuplicateDirectoryName_ShouldUseExistingDirectory() {
            let customDirectoryName = "DuplicateRootDirectory"

            XCTAssertNoThrow(try LocalDataStorageManager(rootDirectoryName: customDirectoryName))

            let firstManager = try! LocalDataStorageManager(rootDirectoryName: customDirectoryName)
            let firstDirectoryUrl = UserDefaults.standard.url(forKey: LocalDataStorageManager.userDefaultsFilePathKey)!

            let secondManager = try! LocalDataStorageManager(rootDirectoryName: customDirectoryName)
            let secondDirectoryUrl = UserDefaults.standard.url(forKey: LocalDataStorageManager.userDefaultsFilePathKey)!

            XCTAssertEqual(firstDirectoryUrl, secondDirectoryUrl)
            clearTestDirectoriesAndFilesFor(url: customDirectoryName)
        }


    func test_ReadFrom_InvalidURL_ShouldFail()  {
        let invalidURL = "234234%%%$^^##@@"
        localDataStorageManager.read(from: invalidURL) { result in
            switch result {
            case .success(_):
                XCTFail("Read from an invalid URL should not succeed.")
            case .failure(let error):
                XCTAssertEqual(error as? LocalDataStorageManager.LocalDataManagerError, .invalidURL)
            }
        }
    }

    func test_ReadFrom_NonexistentFile_ShouldFail() {
        let nonexistentFile = "NonexistentFile.txt"
        localDataStorageManager.read(from: nonexistentFile) { result in
            switch result {
            case .success(_):
                XCTFail("Read from a nonexistent file should not succeed.")
            case .failure(let error):
                XCTAssertEqual(error as? LocalDataStorageManager.LocalDataManagerError, .fileNotFound)
            }
        }
    }

    func test_ReadFrom_ValidFile_ShouldSucceed() {
        let validFile = "ValidFile.txt"
        let testData = "Test data".data(using: .utf8)!

        localDataStorageManager.write(data: testData, to: validFile) { writeResult in
            switch writeResult {
            case .success(_):
                break
            case .failure(let failure):
                XCTFail("Read from a valid file should not fail. error: \(failure.localizedDescription)")
            }
        }

        localDataStorageManager.read(from: validFile) { readResult in
            switch readResult {
            case .success(let data):
                XCTAssertEqual(data, testData)
            case .failure(_):
                XCTFail("Read from a valid file should not fail.")
            }
        }
    }

    func test_WriteTo_NonexistentDirectory_ShouldCreateDirectoryAndWrite() {
        let validFile = "NonexistentDirectory/ValidFile.txt"
        let testData = "Test data".data(using: .utf8)!

        localDataStorageManager.write(data: testData, to: validFile) { result in
            switch result {
            case .success:
                break
            case .failure(let failure):
                XCTFail("Write should not fail. error: \(failure.localizedDescription)")
            }
            
        }
    }

    func test_WriteTo_ExistingDirectory_ShouldWrite() {
        let validFile = "ExistingDirectory/ValidFile.txt"
        let testData = "Test data".data(using: .utf8)!

        localDataStorageManager.write(data: testData, to: validFile) { result in
            switch result {
            case .success:
                break
            case .failure(let failure):
                XCTFail("Write should not fail. error: \(failure.localizedDescription)")
            }
        }
    }

    func test_Delete_NonexistentFile_ShouldFail() {
        let nonexistentFile = "NonexistentFile.txt"
        localDataStorageManager.delete(at: nonexistentFile) { result in
            switch result {
            case .success(_):
                XCTFail("Delete operation on a nonexistent file should not succeed.")
            case .failure(let error):
                XCTAssertEqual(error as? LocalDataStorageManager.LocalDataManagerError, .fileNotFound)
            }
        }
    }

    func test_Delete_ValidFile_ShouldSucceed() {
        let validFile = "ValidFileToDelete.txt"
        let testData = "Test data".data(using: .utf8)!
        
        localDataStorageManager.write(data: testData, to: validFile) { writeResult in
            switch writeResult {
            case .success:
                break
            case .failure(let failure):
                XCTFail("Write should not fail. error: \(failure.localizedDescription)")
            }
        }
        
        localDataStorageManager.delete(at: validFile) { deleteResult in
            switch deleteResult {
            case .success(_):
                // Successfully deleted the file
                XCTAssert(true)
            case .failure(_):
                XCTFail("Delete operation on a valid file should not fail.")
            }
        }
    }
    
    private func clearTestDirectoriesAndFiles()  {
           let fileManager = FileManager.default
           let mainDirectoryUrl = UserDefaults.standard.url(forKey: LocalDataStorageManager.userDefaultsFilePathKey)

           if let url = mainDirectoryUrl {
                   try? fileManager.removeItem(at: url)
           }
       }
    
    private func clearTestDirectoriesAndFilesFor(url: String)  {
        
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        let finalUrl = documentsDirectory.appendingPathComponent(url) 
        
            try? fileManager.removeItem(at: finalUrl)
        
        
    }
}






