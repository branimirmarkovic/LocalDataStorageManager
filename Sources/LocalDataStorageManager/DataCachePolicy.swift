//
//  File.swift
//  
//
//  Created by Branimir Markovic on 9.4.23..
//

import Foundation


public protocol DataCachePolicy {
    func isDataValid(for object: TimeValidable) -> Bool
    init(timeLimit: TimeInterval)
}

