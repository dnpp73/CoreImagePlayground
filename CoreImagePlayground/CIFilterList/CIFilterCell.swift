import UIKit

typealias FilterCellData = (name: String, key: String, defaultValue: Float, value: Float, min: Float, max: Float, isOn: Bool)

protocol CIFilterCellDelegate: AnyObject {
    func touchUpInsideDefaultButton(cell: CIFilterCell)
    func valueChangedSlider(cell: CIFilterCell, value: Float)
    func valueChangedSwitch(cell: CIFilterCell, isOn: Bool)
}

final class CIFilterCell: UITableViewCell {

    weak var delegate: CIFilterCellDelegate?

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var defaultButton: UIButton!
    @IBOutlet private weak var slider: UISlider!
    @IBOutlet private weak var valueLabel: UILabel!
    @IBOutlet private weak var `switch`: UISwitch!
    private var defaultValue: Float = 0.0

    @IBAction private func touchUpInsideDefaultButton(_ sender: UIButton) {
        slider.value = Float(defaultValue)
        valueLabel.text = String(format: "%.2f", defaultValue)
        delegate?.touchUpInsideDefaultButton(cell: self)
        delegate?.valueChangedSlider(cell: self, value: defaultValue)
    }

    @IBAction private func valueChangedSlider(_ sender: UISlider) {
        valueLabel.text = String(format: "%.2f", sender.value)
        delegate?.valueChangedSlider(cell: self, value: sender.value)
    }

    @IBAction private func valueChangedSwitch(_ sender: UISwitch) {
        // defaultButton.isEnabled = sender.isOn
        slider.isEnabled = sender.isOn
        delegate?.valueChangedSwitch(cell: self, isOn: sender.isOn)
    }

    func set(data: FilterCellData) {
        nameLabel.text = String(format: "\(data.name).\(data.key)")
        defaultValue = data.defaultValue
        // defaultButton.isEnabled = data.isOn
        slider.value = data.value
        slider.minimumValue = data.min
        slider.maximumValue = data.max
        slider.isEnabled = data.isOn
        valueLabel.text = String(format: "%.2f", data.value)
        `switch`.isOn = data.isOn
    }

}
