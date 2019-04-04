import AppKit

protocol SettingsDelegate: AnyObject {
    func set(token: String)
    func set(ticker: String)
}

class SettingsWindowController: NSWindowController, NSWindowDelegate {
    @IBOutlet var grantsController: NSArrayController!
    @IBOutlet var tableView: NSTableView!
    @IBOutlet var addRemoveSegment: NSSegmentedControl!

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
        addRemoveSegment.setEnabled(sender.selectedRow != -1, forSegment: 0)
    }

    @IBAction func addOrRemoveGrant(_ sender: NSSegmentedCell) {
        if sender.isSelected(forSegment: 0) {
            deleteSelectedRow()
        } else {
            addGrant()
        }
    }


    @IBAction func updateToken(_ sender: NSTextField) {
        delegate?.set(token: sender.stringValue)
    }

    @IBAction func updateTicker(_ sender: NSTextField) {
        delegate?.set(ticker: sender.stringValue)
    }

    private func deleteSelectedRow() {
        grantsController.remove(atArrangedObjectIndex: tableView.selectedRow)
        if GrantController.shared.grants.count > 0 {
            tableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
        } else {
            addRemoveSegment.setEnabled(false, forSegment: 0)
        }
    }

    private func addGrant() {
        grantsController.addObject(Grant(shares: 0, grantDate: Date()))
    }

    func windowWillClose(_ notification: Notification) {
        GrantController.shared.save()
    }
}
