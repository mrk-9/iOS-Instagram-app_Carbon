//
//  NSDate+Extension.swift
//  Carbon
//
//  Created by Mobile on 9/19/16.
//  Copyright © 2016 Robert. All rights reserved.
//

import Foundation

func NSDateTimeAgoLocalizedStrings(key: String) -> String {
    return key
}

extension Date {
    func isGreaterThanDate(dateToCompare: Date) -> Bool {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedDescending {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    func isLessThanDate(dateToCompare: Date) -> Bool {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedAscending {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
    
    func equalToDate(dateToCompare: Date) -> Bool {
        //Declare Variables
        var isEqualTo = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedSame {
            isEqualTo = true
        }
        
        //Return Result
        return isEqualTo
    }
    
    func addDays(daysToAdd: Int) -> Date {
        let secondsInDays: TimeInterval = Double(daysToAdd) * 60 * 60 * 24
        let dateWithDaysAdded: Date = self.addingTimeInterval(secondsInDays)
        
        //Return Result
        return dateWithDaysAdded
    }
    
    func addHours(hoursToAdd: Int) -> Date {
        let secondsInHours: TimeInterval = Double(hoursToAdd) * 60 * 60
        let dateWithHoursAdded: Date = self.addingTimeInterval(secondsInHours)
        
        //Return Result
        return dateWithHoursAdded
    }
    
    // shows 1 or two letter abbreviation for units.
    // does not include 'ago' text ... just {value}{unit-abbreviation}
    // does not include interim summary options such as 'Just now'
    public var timeAgoSimple: String {
        let components = self.dateComponents()
        
        if components.year! > 0 {
            return stringFromFormat(format: "%%d%@yr", withValue: components.year!)
        }
        
        if components.month! > 0 {
            return stringFromFormat(format: "%%d%@mo", withValue: components.month!)
        }
        
        // TODO: localize for other calanders
        if components.day! >= 7 {
            let value = components.day!/7
            return stringFromFormat(format: "%%d%@w", withValue: value)
        }
        
        if components.day! > 0 {
            return stringFromFormat(format: "%%d%@d", withValue: components.day!)
        }
        
        if components.hour! > 0 {
            return stringFromFormat(format: "%%d%@h", withValue: components.hour!)
        }
        
        if components.minute! > 0 {
            return stringFromFormat(format: "%%d%@m", withValue: components.minute!)
        }
        
        if components.second! > 0 {
            return stringFromFormat(format: "%%d%@s", withValue: components.second! )
        }
        
        return ""
    }
    
    public var timeAgo: String {
        let components = self.dateComponents()
        
        if components.year! > 0 {
            if components.year! < 2 {
                return NSDateTimeAgoLocalizedStrings(key: "Last year")
            } else {
                return stringFromFormat(format: "%%d %@years ago", withValue: components.year!)
            }
        }
        
        if components.month! > 0 {
            if components.month! < 2 {
                return NSDateTimeAgoLocalizedStrings(key: "Last month")
            } else {
                return stringFromFormat(format: "%%d %@months ago", withValue: components.month!)
            }
        }
        
        // TODO: localize for other calanders
        if components.day! >= 7 {
            let week = components.day!/7
            if week < 2 {
                return NSDateTimeAgoLocalizedStrings(key: "Last week")
            } else {
                return stringFromFormat(format: "%%d %@weeks ago", withValue: week)
            }
        }
        
        if components.day! > 0 {
            if components.day! < 2 {
                return NSDateTimeAgoLocalizedStrings(key: "Yesterday")
            } else  {
                return stringFromFormat(format: "%%d %@days ago", withValue: components.day!)
            }
        }
        
        if components.hour! > 0 {
            if components.hour! < 2 {
                return NSDateTimeAgoLocalizedStrings(key: "An hour ago")
            } else  {
                return stringFromFormat(format: "%%d %@hours ago", withValue: components.hour!)
            }
        }
        
        if components.minute! > 0 {
            if components.minute! < 2 {
                return NSDateTimeAgoLocalizedStrings(key: "A minute ago")
            } else {
                return stringFromFormat(format: "%%d %@minutes ago", withValue: components.minute!)
            }
        }
        
        if components.second! > 0 {
            if components.second! < 5 {
                return NSDateTimeAgoLocalizedStrings(key: "Just now")
            } else {
                return stringFromFormat(format: "%%d %@seconds ago", withValue: components.second!)
            }
        }
        
        return ""
    }
    
    public var timeString: String {
        let dateFormatter = DateFormatter()
        
        let dateShortStr = self.timeShort
        if (dateShortStr == NSLocalizedString("Tomorrow", comment: "") || dateShortStr == NSLocalizedString("Yesterday", comment: "") || dateShortStr == NSLocalizedString("Today", comment: "")) {
            dateFormatter.dateFormat = "h:mm a"
            return String(format: "%@, %@", dateShortStr, dateFormatter.string(from: self))
        }
        
        dateFormatter.dateFormat = "d/M/yyyy h:mm a"
        return dateFormatter.string(from: self)
    }
    
    public var timeShort: String {
        let cal = Calendar.current
        
        
        // get today midnight
        let currentDate = Date()
        var components = cal.dateComponents([.day, .month, .year], from: currentDate)
        let todayMidnight = cal.date(from: components)
        
        components = cal.dateComponents([.day, .weekOfYear, .month, .year], from: self, to: todayMidnight!)
        
        if (components.year! < 0) {
            return String(format: NSLocalizedString("%ld years later", comment: ""), labs(components.year!))
        } else if (components.month! < 0) {
            return String(format: NSLocalizedString("%ld months later", comment: ""), labs(components.month!))
        } else if (components.weekOfYear! < 0) {
            return String(format: NSLocalizedString("%ld weeks later", comment: ""), labs(components.weekOfYear!))
        } else if (components.day! < 0) {
            if (components.day! < -1) {
                return String(format: NSLocalizedString("%ld days later", comment: ""), labs(components.day!))
            } else {
                return NSLocalizedString("Tomorrow", comment: "");
            }
        }
        else if (components.year! > 0) {
            return String(format: NSLocalizedString("%ld years ago", comment: ""), components.year!)
        } else if (components.month! > 0) {
            return String(format: NSLocalizedString("%ld months ago", comment: ""), components.month!)
        } else if (components.weekOfYear! > 0) {
            return String(format: NSLocalizedString("%ld weeks ago", comment: ""), components.weekOfYear!)
        } else if (components.day! > 0) {
            if (components.day! > 1) {
                return String(format: NSLocalizedString("%ld days ago", comment: ""), components.day!)
            } else {
                return NSLocalizedString("Yesterday", comment: "");
            }
        } else {
            return NSLocalizedString("Today", comment: "");
        }
        
    }
    
    private func dateComponents() -> DateComponents {
        let calander = Calendar.current
        
        return calander.dateComponents([.second, .minute, .hour, .day, .month, .year], from: self, to: Date())
    }
    
    private func stringFromFormat(format: String, withValue value: Int) -> String {
        let localeFormat = String(format: format, getLocaleFormatUnderscoresWithValue(value: Double(value)))
        return String(format: NSDateTimeAgoLocalizedStrings(key: localeFormat), value)
    }
    
    private func getLocaleFormatUnderscoresWithValue(value: Double) -> String {
        guard let localeCode = NSLocale.preferredLanguages.first else {
            return ""
        }
        
        // Russian (ru) and Ukrainian (uk)
        if localeCode.hasPrefix("ru") || localeCode.hasPrefix("uk") {
            let XY = Int(floor(value)) % 100
            let Y = Int(floor(value)) % 10
            
            if Y == 0 || Y > 4 || (XY > 10 && XY < 15) {
                return ""
            }
            
            if Y > 1 && Y < 5 && (XY < 10 || XY > 20) {
                return "_"
            }
            
            if Y == 1 && XY != 11 {
                return "__"
            }
        }
        
        return ""
    }
    
}
