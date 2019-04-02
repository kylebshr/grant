import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    private var itemController: StatusItemController?
    private let settingsWindowController = SettingsWindowController()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        UserDefaults.standard.register(defaults: [
            "ticker": "LYFT"
        ])

        settingsWindowController.delegate = self
        updateItem()

        if UserDefaults.standard.string(forKey: "token") == nil {
            openSettings()
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {}

    func updateItem() {
        let ticker = UserDefaults.standard.string(forKey: "ticker") ?? ""
        let token = UserDefaults.standard.string(forKey: "token") ?? ""
        itemController = StatusItemController(ticker: ticker, token: token)
        itemController?.delegate = self
    }
}

extension AppDelegate: StatusItemDelegate {
    func openSettings() {
        settingsWindowController.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

extension AppDelegate: SettingsDelegate {
    func set(token: String) {
        UserDefaults.standard.set(token, forKey: "token")
        updateItem()
    }

    func set(ticker: String) {
        UserDefaults.standard.set(ticker, forKey: "ticker")
        updateItem()
    }
}
