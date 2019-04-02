import AppKit

class ValueMenuItemView: NSStackView {
    private let titleLabel = NSTextField(labelWithString: "")
    private let valueLabel = NSTextField(labelWithString: "")

    var value: String? {
        didSet {
            valueLabel.stringValue = value ?? ""
            valueLabel.sizeToFit()
        }
    }

    init(title: String) {
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        edgeInsets = NSEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        alignment = .leading
        orientation = .vertical

        titleLabel.font = .systemFont(ofSize: 11, weight: .bold)
        titleLabel.textColor = .secondaryLabelColor
        titleLabel.stringValue = title
        titleLabel.sizeToFit()

        valueLabel.font = .systemFont(ofSize: 15, weight: .regular)
        valueLabel.textColor = .labelColor

        addArrangedSubview(titleLabel)
        addArrangedSubview(valueLabel)
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
