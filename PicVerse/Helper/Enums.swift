//
//  Enum.swift
//  PicVerse
//
//  Created by Neel Kalariya on 08/11/25.
//

import Foundation

enum ByteFormat {
    static func friendly(bytes: Int64) -> String {
        let f = ByteCountFormatter()
        f.allowedUnits = [.useKB, .useMB, .useGB]
        f.countStyle = .file
        return f.string(fromByteCount: bytes)
    }
}

enum DateFormat {
    static func friendly(_ date: Date?) -> String {
        guard let d = date else { return "-" }
        let cal = Calendar.current
        let timeFmt = DateFormatter()
        timeFmt.dateFormat = "h:mm a"

        if cal.isDateInToday(d) {
            return "Today " + timeFmt.string(from: d)
        } else if cal.isDateInYesterday(d) {
            return "Yesterday " + timeFmt.string(from: d)
        } else {
            let fmt = DateFormatter()
            fmt.dateFormat = "MMM d, yyyy h:mm a"
            return fmt.string(from: d)
        }
    }
}
