import AppKit

protocol StatusItemDelegate: AnyObject {
    func openSettings()
}

class StatusItemController {
    private let provider: TickerPriceProvider
    private let item: NSStatusItem

    weak var delegate: StatusItemDelegate?

    init(ticker: String, token: String) {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_us")
        formatter.numberStyle = .currency

        let menu = NSMenu()

        menu.addItem(titleItem("VESTED"))
        let vestedStockItem = standardItem(nil)
        menu.addItem(vestedStockItem)
        let vestedMenuItem = standardItem(nil)
        menu.addItem(vestedMenuItem)

        menu.addItem(NSMenuItem.separator())
        menu.addItem(titleItem("VESTING NEXT"))
        let vestingNextStockItem = standardItem(nil)
        menu.addItem(vestingNextStockItem)
        let vestingNextMenuItem = standardItem(nil)
        menu.addItem(vestingNextMenuItem)

        menu.addItem(NSMenuItem.separator())
        menu.addItem(titleItem("UNVESTED"))
        let unvestedStockItem = standardItem(nil)
        menu.addItem(unvestedStockItem)
        let unvestedMenuItem = standardItem(nil)
        menu.addItem(unvestedMenuItem)

        menu.addItem(.separator())
        menu.addItem(titleItem("TOTAL"))
        let totalMenuItem = standardItem(nil)
        menu.addItem(totalMenuItem)

        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.font = .monospacedDigitSystemFont(ofSize: 14, weight: .regular)
        item.button?.title = "..."
        item.menu = menu
        item.isVisible = true

        let tax: Double = 0
        let percent = 1 - tax

        let provider = TickerPriceProvider(ticker: ticker, apiKey: token) { [weak item] quote in
            if let value = formatter.string(from: quote.latestPrice as NSNumber) {
                item?.button?.title = value
            }

            let grants = GrantController.shared.grants

            let vestedShares = grants.reduce(into: 0) { $0 += $1.vested() }
            let vestedSharesAfterTax = Int(Double(vestedShares) * percent)
            vestedStockItem.updateAttributedTitle("~\(vestedSharesAfterTax) Shares")

            if let value = formatter.string(from: Double(vestedShares) * quote.latestPrice * percent as NSNumber) {
                vestedMenuItem.updateAttributedTitle(value)
            }

            let oneQuarterFromNow = Calendar.current.date(byAdding: .month, value: 3, to: Date())!
            let vestingNextShares = grants.reduce(into: 0) { $0 += $1.vested(at: oneQuarterFromNow) } - vestedShares
            let nextVestingSharesAfterTax = Int(Double(vestingNextShares) * percent)
            vestingNextStockItem.updateAttributedTitle("~\(nextVestingSharesAfterTax) Shares")

            if let value = formatter.string(from: Double(vestingNextShares) * quote.latestPrice * percent as NSNumber) {
                vestingNextMenuItem.updateAttributedTitle(value)
            }

            let totalShares = grants.reduce(into: 0) { $0 += $1.shares }
            if let value = formatter.string(from: Double(totalShares) * quote.latestPrice * percent as NSNumber) {
                totalMenuItem.updateAttributedTitle(value)
            }

            let unvestedShares = totalShares - vestedShares

            let unvestedSharesAfterTax = Int(Double(unvestedShares) * percent)
            unvestedStockItem.updateAttributedTitle("~\(unvestedSharesAfterTax) Shares")

            if let value = formatter.string(from: Double(unvestedShares) * quote.latestPrice * percent as NSNumber) {
                unvestedMenuItem.updateAttributedTitle(value)
            }
        }

        self.provider = provider
        self.item = item

        menu.addItem(.separator())
        let addGrant = NSMenuItem(title: "Settings", action: #selector(self.addGrant), keyEquivalent: ",")
        addGrant.target = self
        menu.addItem(addGrant)
        menu.addItem(.init(title: "Quit", action: #selector(NSApplication.terminate), keyEquivalent: "q"))

    }

    @objc private func addGrant(_ sender: NSMenuItem) {
        delegate?.openSettings()
    }
}

private func titleItem(_ title: String) -> NSMenuItem {
    return menuItem(withTitle: title, font: .systemFont(ofSize: 12, weight: .bold), color: .secondaryLabelColor)
}

private func standardItem(_ title: String?) -> NSMenuItem {
    return menuItem(withTitle: title, font: .monospacedDigitSystemFont(ofSize: 15, weight: .regular), color: .labelColor)
}

private func menuItem(withTitle title: String?, font: NSFont, color: NSColor) -> NSMenuItem {
    let item = MenuItem(title: "", action: nil, keyEquivalent: "")

    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .right

    let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color, .paragraphStyle: paragraph]
    item.attributedTitle = .init(string: title ?? " ", attributes: attributes)

    return item
}

extension NSMenuItem {
    func updateAttributedTitle(_ title: String?) {
        let string = attributedTitle?.mutableCopy() as? NSMutableAttributedString ?? NSMutableAttributedString()
        string.mutableString.setString(title ?? " ")
        attributedTitle = string
    }
}

class MenuItem: NSMenuItem {
    override var isHighlighted: Bool {
        get { return false }
        set {}
    }
}
