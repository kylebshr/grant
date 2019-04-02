import AppKit

class GrantController {
    private let encoder = PropertyListEncoder()
    private let decoder = PropertyListDecoder()

    static let shared = GrantController()

    @objc dynamic var dynamicGrants = NSMutableArray(array: [Grant]())

    @objc dynamic var grants: [Grant] {
        return dynamicGrants.map { $0 as! Grant }
    }

    init() {
        if let data = UserDefaults.standard.value(forKey: "grants") as? Data,
            let grants = try? decoder.decode([Grant].self, from: data) {
            dynamicGrants = NSMutableArray(array: grants)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(save),
                                               name: NSApplication.willTerminateNotification, object: nil)
    }

    @objc func save() {
        let grants = dynamicGrants.map { $0 as! Grant }
        let encoded = try! encoder.encode(grants)
        UserDefaults.standard.setValue(encoded, forKey: "grants")
    }
}
