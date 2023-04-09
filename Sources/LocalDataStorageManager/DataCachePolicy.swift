//
//  File.swift
//  
//
//  Created by Branimir Markovic on 7.4.23..
//

import Foundation

// Create an enum to represent different time limits for a caching policy.
enum TimePolicyLimits: TimeInterval {
    case seconds30 = 30
    case oneMinute = 60
    case twoMinutes = 120
    case fiveMinutes = 300
    case tenMinutes = 600
    case thirtyMinutes = 1800
    case oneHour = 3600
    case twoHours = 7200
    case sixHours = 21600
    case twelveHours = 43200
    case oneDay = 86400
}

// Define a protocol for objects that have a timestamp.
protocol TimeValidable {
    var timeStamp: Date { get set }
}

// Define a protocol for a data cache policy with a time limit and a method to check data validity.
protocol DataCachePolicy {
    var timeLimit: TimeInterval { get set }
    func isDataValid(for object: TimeValidable) -> Bool
}

// Implement the default cache policy with a specified time limit.
class DefaultCachePolicy: DataCachePolicy {
    var timeLimit: TimeInterval

    // Initialize the cache policy with a time limit from the TimePolicyLimits enum.
    init(_ timeLimit: TimePolicyLimits) {
        self.timeLimit = timeLimit.rawValue
    }
    
    init(customTimeLimit: TimeInterval) {
        self.timeLimit = customTimeLimit
    }

    // Check if the data associated with a TimeValidable object is still valid based on the time limit.
    func isDataValid(for object: TimeValidable) -> Bool {
        let maximumDate = object.timeStamp.addingTimeInterval(timeLimit)
        let referenceDate = Date()
        return referenceDate <= maximumDate
    }
}
