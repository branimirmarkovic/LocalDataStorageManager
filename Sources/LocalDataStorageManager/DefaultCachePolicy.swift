//
//  File.swift
//  
//
//  Created by Branimir Markovic on 9.4.23..
//

import Foundation

class DefaultCachePolicy: DataCachePolicy {
    
    var timeLimit: TimeInterval

    init(_ timeLimit: TimePolicyLimits) {
        self.timeLimit = timeLimit.rawValue
    }
    
    init(customTimeLimit: TimeInterval) {
        self.timeLimit = customTimeLimit
    }


    func isDataValid(for object: TimeValidable) -> Bool {
        let maximumDate = object.timeStamp.addingTimeInterval(timeLimit)
        let referenceDate = Date()
        return referenceDate <= maximumDate
    }
}

struct TimeValidableDataWrapper: TimeValidable, Codable {
    var timeStamp: Date
    var data: Data
}
