import Foundation

class TickerPriceProvider {
    typealias Update = (Quote) -> Void

    private let decoder = JSONDecoder()

    private let update: Update
    private let url: URL

    private var cached: Quote?

    init(ticker: String, apiKey: String, update: @escaping Update) {
        self.update = update
        self.url = URL(string: "https://cloud.iexapis.com/beta/stock/\(ticker)/quote?token=\(apiKey)")!

        let timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            self?.refreshIfNeeded()
        }

        RunLoop.main.add(timer, forMode: .common)
        timer.fire()
    }

    private func refreshIfNeeded() {
        guard Date().isTradingHours || cached == nil else {
            cached.flatMap(update)
            return
        }

        URLSession.shared.dataTask(with: url) { (data, response, error) in
            data.flatMap {
                try? self.decoder.decode(Quote.self, from: $0)
            } .flatMap { quote in
                DispatchQueue.main.async {
                    self.cached = quote
                    self.update(quote)
                }
            }
        }.resume()
    }
}

extension Date {
    var isTradingHours: Bool {
        let calendar = Calendar.current
        let est = convertedToEST()

        guard !calendar.isDateInWeekend(est) else {
            return false
        }

        let minutesBuffer = 15
        let open = calendar.date(bySettingHour: 9, minute: 30 - minutesBuffer, second: 0, of: est)!
        let close = calendar.date(bySettingHour: 16, minute: 0 + minutesBuffer, second: 0, of: est)!

        return est >= open && est <= close
    }

    func convertedToEST() -> Date {
        let timeZone = TimeZone(abbreviation: "EST")!
        let targetOffset = TimeInterval(timeZone.secondsFromGMT())
        let localOffset = TimeInterval(TimeZone.autoupdatingCurrent.secondsFromGMT(for: self))
        return addingTimeInterval(targetOffset - localOffset)
    }
}
