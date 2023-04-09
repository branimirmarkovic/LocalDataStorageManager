//
//  File.swift
//  
//
//  Created by Branimir Markovic on 9.4.23..
//

import Foundation

class LocalDataStorageManagerWithDataValidationPolicyDecorator: DataStorageManager {
    
    enum ManagerError: Error {
        case dataNoLongerValid
        case decodingError
        case encodingError
        case noData
    }
    
    private let dataCachePolicy: DataCachePolicy
    private let dataStorageManager: DataStorageManager
    
    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder
    
    init(dataCachePolicy: DataCachePolicy, dataStorageManager: DataStorageManager) {
        self.dataCachePolicy = dataCachePolicy
        self.dataStorageManager = dataStorageManager
        self.jsonDecoder = JSONDecoder()
        self.jsonEncoder = JSONEncoder()
    }
    
    func read(from url: String, completion: @escaping (Result<Data, Error>) -> Void) {
        dataStorageManager.read(from: url) {[weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let data):
                do {
                    let object = try self.jsonDecoder.decode(TimeValidableDataWrapper.self, from: data)
                    if dataCachePolicy.isDataValid(for: object) {
                        completion(.success(object.data))
                    } else {
                        completion(.failure(ManagerError.dataNoLongerValid))
                        self.dataStorageManager.delete(at: url, completion: {_ in })
                    }
                } catch {completion(.failure(ManagerError.decodingError))}
            case .failure(_):
                completion(.failure(ManagerError.noData))
            }
        }
    }
    
    func write(data: Data, to url: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let objectWrapper = TimeValidableDataWrapper(timeStamp: Date(), data: data)
        guard let writeData = try? jsonEncoder.encode(objectWrapper) else {
            completion(.failure(ManagerError.encodingError))
            return
        }
        dataStorageManager.write(data: writeData, to: url, completion: completion)
    }
    
    func delete(at url: String, completion: @escaping (Result<Void, Error>) -> Void) {
        dataStorageManager.delete(at: url, completion: completion)
    }
}
