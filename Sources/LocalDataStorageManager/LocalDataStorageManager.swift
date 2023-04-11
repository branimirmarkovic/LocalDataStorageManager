

//
//  File.swift
//  
//
//  Created by Branimir Markovic on 7.4.23..

import Foundation

public class LocalDataStorageManager {
    
    enum SetupError: Swift.Error {
        case invalidDocumentsDirectory
        case noDatabaseFile
        case cantCreateDatabaseFile
    }
    
    enum LocalDataManagerError: Swift.Error {
        case invalidURL
        case fileNotFound
        case cantCreateDatabaseFile
    }
    
    static let userDefaultsFilePathKey = "main-file-path"
    
    private let fileManager: FileManager
    private var mainDirectoryUrl: URL
    
    public init(fileManager: FileManager = FileManager.default, rootDirectoryName: String = "RootDirectory") throws {
        self.fileManager = fileManager
        self.mainDirectoryUrl = try Self.setUp(fileManager: fileManager, rootDirectoryName: rootDirectoryName)
    }
    
    private static func setUp(fileManager: FileManager, rootDirectoryName: String) throws -> URL {
        if let url = UserDefaults.standard.url(forKey: Self.userDefaultsFilePathKey) {
            if validateMainDirectory(url, fileManager: fileManager) {
                return url
            }
        }
        return try createMainDirectory(fileManager: fileManager, directoryName: rootDirectoryName)
    }
    
    private static func validateMainDirectory(_ url: URL, fileManager: FileManager) -> Bool {
        return fileManager.fileExists(atPath: url.path)
    }
    
    private static func createMainDirectory(fileManager: FileManager, directoryName: String) throws -> URL {
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw SetupError.invalidDocumentsDirectory
        }
        let mainDirectory = documentsDirectory.appendingPathComponent(directoryName)
        if !fileManager.fileExists(atPath: mainDirectory.path) {
            try fileManager.createDirectory(at: mainDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        UserDefaults.standard.set(mainDirectory, forKey: Self.userDefaultsFilePathKey)
        return mainDirectory
    }
    
    public func cleanUp() {
        UserDefaults.standard.removeObject(forKey: Self.userDefaultsFilePathKey)
        try? fileManager.removeItem(at: mainDirectoryUrl)
    }
    
    
    public func read(from url: String, completion: @escaping (Result<Data, Error>) -> Void) {
        let finalPath = self.mainDirectoryUrl.absoluteString + "/" + url
        guard let url = URL(string: finalPath) else {
            completion(.failure(LocalDataManagerError.invalidURL))
            return
        }
        
        if fileManager.fileExists(atPath: url.path) {
            do {
                let data = try Data(contentsOf: url)
                completion(.success(data))
            } catch { completion(.failure(error)) }
        } else {
            completion(.failure(LocalDataManagerError.fileNotFound))
        }
        
    }
    
    public func write(data: Data, to url: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let finalPath = self.mainDirectoryUrl.path + "/" + url
         let url = URL(fileURLWithPath: finalPath)
        let directoryUrl = url.deletingLastPathComponent()
        if !fileManager.fileExists(atPath: directoryUrl.path) {
            do {
                try fileManager.createDirectory(at: directoryUrl, withIntermediateDirectories: true)
                if !fileManager.fileExists(atPath: url.absoluteString) {
                    let result = fileManager.createFile(atPath: url.path, contents: nil)
                    if result == false {
                        completion(.failure(LocalDataManagerError.cantCreateDatabaseFile))
                        return
                    }
                    
                    do {
                        try data.write(to: url)
                        completion(.success(()))
                    } catch let error {
                        completion(.failure(error)) }
                }
                
            } catch let error {
                completion(.failure(error))
                return
            }
        } else {
            let result = fileManager.createFile(atPath: url.path, contents: nil)
            if result == false {
                completion(.failure(SetupError.cantCreateDatabaseFile))
                return
            }
            
            do {
                try data.write(to: url)
                completion(.success(()))
            } catch let error {
                completion(.failure(error)) }
        }
        
    }
    
    public func delete(at url: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let finalPath = self.mainDirectoryUrl.path + "/" + url
        let fileUrl = URL(fileURLWithPath: finalPath)
        
        if fileManager.fileExists(atPath: fileUrl.path) {
            do {
                try fileManager.removeItem(at: fileUrl)
                completion(.success(()))
            } catch let error {
                completion(.failure(error))
            }
        } else {
            completion(.failure(LocalDataManagerError.fileNotFound))
        }
    }
    
}

