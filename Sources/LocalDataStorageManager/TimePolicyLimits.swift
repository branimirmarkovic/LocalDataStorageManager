//
//  File.swift
//  
//
//  Created by Branimir Markovic on 9.4.23..
//

import Foundation

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
