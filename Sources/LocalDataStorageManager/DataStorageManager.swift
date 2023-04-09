//
//  File.swift
//  
//
//  Created by Branimir Markovic on 9.4.23..
//

import Foundation

protocol DataStorageManager {
    func read(from url: String, completion: @escaping (Result<Data, Error>) -> Void)
    func write(data: Data, to url: String, completion: @escaping (Result<Void, Error>) -> Void)
    func delete(at url: String, completion: @escaping (Result<Void, Error>) -> Void)
}

extension LocalDataStorageManager: DataStorageManager {}
