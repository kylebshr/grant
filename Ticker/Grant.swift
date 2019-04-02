import Foundation

class Grant: NSObject, Codable {
    @objc dynamic var shares: Int
    @objc dynamic var grantDate: Date
    @objc dynamic var cliff: Date?

    var vested: Int {
        let calendar = Calendar(identifier: .gregorian)

        var fourYears = DateComponents()
        fourYears.year = 4

        let endDate = calendar.date(byAdding: fourYears, to: grantDate)!

        let totalQuarters = grantDate.quarters(to: endDate)
        let elapsedQuarters = grantDate.quarters(to: Date())

        guard totalQuarters > 0 else {
            return 0
        }

        let percentVested = Double(elapsedQuarters) / Double(totalQuarters)
        var sharesVested = percentVested * Double(shares)
        elapsedQuarters.isEven ? sharesVested.round(.up) : sharesVested.round(.down)
        return Int(sharesVested)
    }

    init(shares: Int, grantDate: Date, cliff: Date? = nil) {
        self.shares = shares
        self.grantDate = grantDate
        self.cliff = cliff
    }
}

extension Int {
    var isEven: Bool {
        return self % 2 == 0
    }
}

extension Date {
    func quarters(to date: Date) -> Int {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.dateComponents([.month], from: self, to: date).month! / 3
    }
}
