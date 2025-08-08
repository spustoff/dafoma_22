import Foundation
import SwiftUI

extension Color {
    init(hex: String) {
        let r, g, b, a: CGFloat

        var cleaned = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if cleaned.hasPrefix("#") { cleaned.removeFirst() }

        var hexNumber: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&hexNumber)

        switch cleaned.count {
        case 6:
            r = CGFloat((hexNumber & 0xFF0000) >> 16) / 255
            g = CGFloat((hexNumber & 0x00FF00) >> 8) / 255
            b = CGFloat(hexNumber & 0x0000FF) / 255
            a = 1.0
        case 8:
            r = CGFloat((hexNumber & 0xFF000000) >> 24) / 255
            g = CGFloat((hexNumber & 0x00FF0000) >> 16) / 255
            b = CGFloat((hexNumber & 0x0000FF00) >> 8) / 255
            a = CGFloat(hexNumber & 0x000000FF) / 255
        default:
            r = 0; g = 0; b = 0; a = 1
        }

        self.init(red: r, green: g, blue: b, opacity: a)
    }
}

extension FileManager {
    static var appSupportDirectory: URL {
        let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let appUrl = url.appendingPathComponent(AppStrings.appName, isDirectory: true)
        if !FileManager.default.fileExists(atPath: appUrl.path) {
            try? FileManager.default.createDirectory(at: appUrl, withIntermediateDirectories: true)
        }
        return appUrl
    }
}

extension Date {
    func days(until endDate: Date) -> Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: self)
        let end = calendar.startOfDay(for: endDate)
        let components = calendar.dateComponents([.day], from: start, to: end)
        return max(components.day ?? 0, 0)
    }

    func clamped(to range: ClosedRange<Date>) -> Date {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}

extension Collection {
    var isNotEmpty: Bool { !isEmpty }
}
