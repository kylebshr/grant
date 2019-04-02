import AppKit

protocol SettingsDelegate: AnyObject {
    func set(token: String)
    func set(ticker: String)
}

class SettingsWindowController: NSWindowController, NSWindowDelegate {
    @IBOutlet var grantsController: NSArrayController!
    @IBOutlet var tableView: NSTableView!
    @IBOutlet var addButton: NSButton!
    @IBOutlet var deleteButton: NSButton!

    weak var delegate: SettingsDelegate?

    override var windowNibName: NSNib.Name? {
        return "SettingsWindow"
    }

    init() {
        super.init(window: nil)
    }

    override func windowDidLoad() {
        window?.titlebarAppearsTransparent = true
        window?.standardWindowButton(.miniaturizeButton)?.isEnabled = false
        window?.standardWindowButton(.zoomButton)?.isEnabled = false

        grantsController.content = GrantController.shared.dynamicGrants
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @IBAction private func tableViewClicked(_ sender: NSTableView) {
        deleteButton.isEnabled = sender.selectedRow != -1
    }

    @IBAction private func deleteSelectedRow(_ sender: NSButton) {
        grantsController.remove(atArrangedObjectIndex: tableView.selectedRow)
        if GrantController.shared.grants.count > 0 {
            tableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
        } else {
            deleteButton.isEnabled = false
        }
    }

    @IBAction func addGrant(_ sender: NSButton) {
        grantsController.addObject(Grant(shares: 0, grantDate: Date()))
    }

    @IBAction func updateToken(_ sender: NSTextField) {
        delegate?.set(token: sender.stringValue)
    }

    @IBAction func updateTicker(_ sender: NSTextField) {
        delegate?.set(ticker: sender.stringValue)
    }

    func windowWillClose(_ notification: Notification) {
        GrantController.shared.save()
    }
}
