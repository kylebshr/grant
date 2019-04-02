import Foundation

class TickerPriceProvider {
    typealias Update = (Quote) -> Void

    private let decoder = JSONDecoder()

    private let update: Update
    private let url: URL

    init(ticker: String, apiKey: String, update: @escaping Update) {
        self.update = update
        self.url = URL(string: "https://cloud.iexapis.com/beta/stock/\(ticker)/quote?token=\(apiKey)")!

        let timer = Timer.scheduledTimer(withTimeInterval: 6, repeats: true) { [weak self] _ in
            self?.refreshIfNeeded()
        }

        RunLoop.main.add(timer, forMode: .common)
        timer.fire()
    }

    private func refreshIfNeeded() {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            data.flatMap {
                try? self.decoder.decode(Quote.self, from: $0)
            } .flatMap { quote in
                DispatchQueue.main.async { self.update(quote) }
            }
        }.resume()
    }
}
