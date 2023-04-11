//
//  File.swift
//  
//
//  Created by Branimir Markovic on 9.4.23..
//

import Foundation

class DefaultCachePolicy: DataCachePolicy {
    
   private let timeLimit: TimeInterval

   convenience init(_ timeLimit: TimePolicyLimits) {
       self.init(timeLimit: timeLimit.rawValue)
    }
    
    required init(timeLimit: TimeInterval) {
        self.timeLimit = timeLimit
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
