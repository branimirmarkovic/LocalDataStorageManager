//
//  File.swift
//  
//
//  Created by Branimir Markovic on 9.4.23..
//

import Foundation


protocol DataCachePolicy {
    var timeLimit: TimeInterval { get set }
    func isDataValid(for object: TimeValidable) -> Bool
}

