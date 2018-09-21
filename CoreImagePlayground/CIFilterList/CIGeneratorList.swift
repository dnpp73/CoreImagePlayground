import UIKit
import CIFilterExtension

protocol CIGeneratorListTableViewDelegate: class {
    func imageDidUpdate(tableView: CIGeneratorListTableView)
}

final class CIGeneratorListTableView: UITableView, UITableViewDelegate, UITableViewDataSource, CIFilterCellDelegate {

    private var data: [FilterCellData] = [
        (name: "", key: "", defaultValue: 0.0, value: 0.0, min: 0.0, max: 0.0, isOn: false),

        // 6. Generator
        (name: "Checkerboard", key: "centerX", defaultValue: 150.0, value: 150.0, min: -100.0, max: 500.0, isOn: false),
        (name: "Checkerboard", key: "centerY", defaultValue: 150.0, value: 150.0, min: -100.0, max: 500.0, isOn: false),
        (name: "Checkerboard", key: "color0R", defaultValue: 1.0, value: 1.0, min: 0.0, max: 1.0, isOn: false),
        (name: "Checkerboard", key: "color0G", defaultValue: 1.0, value: 1.0, min: 0.0, max: 1.0, isOn: false),
        (name: "Checkerboard", key: "color0B", defaultValue: 1.0, value: 1.0, min: 0.0, max: 1.0, isOn: false),
        (name: "Checkerboard", key: "color0A", defaultValue: 1.0, value: 1.0, min: 0.0, max: 1.0, isOn: false),
        (name: "Checkerboard", key: "color1R", defaultValue: 0.0, value: 0.0, min: 0.0, max: 1.0, isOn: false),
        (name: "Checkerboard", key: "color1G", defaultValue: 0.0, value: 0.0, min: 0.0, max: 1.0, isOn: false),
        (name: "Checkerboard", key: "color1B", defaultValue: 0.0, value: 0.0, min: 0.0, max: 1.0, isOn: false),
        (name: "Checkerboard", key: "color1A", defaultValue: 1.0, value: 1.0, min: 0.0, max: 1.0, isOn: false),
        (name: "Checkerboard", key: "width", defaultValue: 80.0, value: 80.0, min: -10.0, max: 300.0, isOn: false),
        (name: "Checkerboard", key: "sharpness", defaultValue: 1.0, value: 1.0, min: -1.0, max: 2.0, isOn: false),

        (name: "Code128Barcode", key: "quietSpace", defaultValue: 7.0, value: 7.0, min: -1.0, max: 21.0, isOn: false),

        (name: "ConstantColor", key: "colorR", defaultValue: 0.5, value: 0.5, min: 0.0, max: 1.0, isOn: false),
        (name: "ConstantColor", key: "colorG", defaultValue: 0.5, value: 0.5, min: 0.0, max: 1.0, isOn: false),
        (name: "ConstantColor", key: "colorB", defaultValue: 0.5, value: 0.5, min: 0.0, max: 1.0, isOn: false),
        (name: "ConstantColor", key: "colorA", defaultValue: 0.5, value: 0.5, min: 0.0, max: 1.0, isOn: false),

        (name: "QRCode", key: "correctionLevel", defaultValue: 1.0, value: 1.0, min: 0.0, max: 3.0, isOn: false),

        (name: "Random", key: "", defaultValue: 0.0, value: 0.0, min: 0.0, max: 0.0, isOn: false),

        (name: "Stripes", key: "centerX", defaultValue: 150.0, value: 150.0, min: -100.0, max: 500.0, isOn: false),
        (name: "Stripes", key: "centerY", defaultValue: 150.0, value: 150.0, min: -100.0, max: 500.0, isOn: false),
        (name: "Stripes", key: "color0R", defaultValue: 1.0, value: 1.0, min: 0.0, max: 1.0, isOn: false),
        (name: "Stripes", key: "color0G", defaultValue: 1.0, value: 1.0, min: 0.0, max: 1.0, isOn: false),
        (name: "Stripes", key: "color0B", defaultValue: 1.0, value: 1.0, min: 0.0, max: 1.0, isOn: false),
        (name: "Stripes", key: "color0A", defaultValue: 1.0, value: 1.0, min: 0.0, max: 1.0, isOn: false),
        (name: "Stripes", key: "color1R", defaultValue: 0.0, value: 0.0, min: 0.0, max: 1.0, isOn: false),
        (name: "Stripes", key: "color1G", defaultValue: 0.0, value: 0.0, min: 0.0, max: 1.0, isOn: false),
        (name: "Stripes", key: "color1B", defaultValue: 0.0, value: 0.0, min: 0.0, max: 1.0, isOn: false),
        (name: "Stripes", key: "color1A", defaultValue: 1.0, value: 1.0, min: 0.0, max: 1.0, isOn: false),
        (name: "Stripes", key: "width", defaultValue: 80.0, value: 80.0, min: -10.0, max: 300.0, isOn: false),
        (name: "Stripes", key: "sharpness", defaultValue: 1.0, value: 1.0, min: -1.0, max: 2.0, isOn: false),

        // 8. Gradient
        (name: "GaussianGradient", key: "centerX", defaultValue: 150.0, value: 150.0, min: -100.0, max: 500.0, isOn: false),
        (name: "GaussianGradient", key: "centerY", defaultValue: 150.0, value: 150.0, min: -100.0, max: 500.0, isOn: false),
        (name: "GaussianGradient", key: "color0R", defaultValue: 1.0, value: 1.0, min: 0.0, max: 1.0, isOn: false),
        (name: "GaussianGradient", key: "color0G", defaultValue: 1.0, value: 1.0, min: 0.0, max: 1.0, isOn: false),
        (name: "GaussianGradient", key: "color0B", defaultValue: 1.0, value: 1.0, min: 0.0, max: 1.0, isOn: false),
        (name: "GaussianGradient", key: "color0A", defaultValue: 1.0, value: 1.0, min: 0.0, max: 1.0, isOn: false),
        (name: "GaussianGradient", key: "color1R", defaultValue: 0.0, value: 0.0, min: 0.0, max: 1.0, isOn: false),
        (name: "GaussianGradient", key: "color1G", defaultValue: 0.0, value: 0.0, min: 0.0, max: 1.0, isOn: false),
        (name: "GaussianGradient", key: "color1B", defaultValue: 0.0, value: 0.0, min: 0.0, max: 1.0, isOn: false),
        (name: "GaussianGradient", key: "color1A", defaultValue: 1.0, value: 1.0, min: 0.0, max: 1.0, isOn: false),
        (name: "GaussianGradient", key: "radius", defaultValue: 300.0, value: 300.0, min: -100.0, max: 1000.0, isOn: false),

        (name: "LinearGradient", key: "point0X", defaultValue: 0.0, value: 0.0, min: -100.0, max: 500.0, isOn: false),
        (name: "LinearGradient", key: "point0Y", defaultValue: 0.0, value: 0.0, min: -100.0, max: 500.0, isOn: false),
        (name: "LinearGradient", key: "point1X", defaultValue: 200.0, value: 200.0, min: -100.0, max: 500.0, isOn: false),
        (name: "LinearGradient", key: "point1Y", defaultValue: 200.0, value: 200.0, min: -100.0, max: 500.0, isOn: false),
        (name: "LinearGradient", key: "color0R", defaultValue: 1.0, value: 1.0, min: 0.0, max: 1.0, isOn: false),
        (name: "LinearGradient", key: "color0G", defaultValue: 1.0, value: 1.0, min: 0.0, max: 1.0, isOn: false),
        (name: "LinearGradient", key: "color0B", defaultValue: 1.0, value: 1.0, min: 0.0, max: 1.0, isOn: false),
        (name: "LinearGradient", key: "color0A", defaultValue: 1.0, value: 1.0, min: 0.0, max: 1.0, isOn: false),
        (name: "LinearGradient", key: "color1R", defaultValue: 0.0, value: 0.0, min: 0.0, max: 1.0, isOn: false),
        (name: "LinearGradient", key: "color1G", defaultValue: 0.0, value: 0.0, min: 0.0, max: 1.0, isOn: false),
        (name: "LinearGradient", key: "color1B", defaultValue: 0.0, value: 0.0, min: 0.0, max: 1.0, isOn: false),
        (name: "LinearGradient", key: "color1A", defaultValue: 1.0, value: 1.0, min: 0.0, max: 1.0, isOn: false),

        (name: "RadialGradient", key: "centerX", defaultValue: 150.0, value: 150.0, min: -100.0, max: 500.0, isOn: false),
        (name: "RadialGradient", key: "centerY", defaultValue: 150.0, value: 150.0, min: -100.0, max: 500.0, isOn: false),
        (name: "RadialGradient", key: "radius0", defaultValue: 5.0, value: 5.0, min: -100.0, max: 1000.0, isOn: false),
        (name: "RadialGradient", key: "radius1", defaultValue: 100.0, value: 100.0, min: -100.0, max: 1000.0, isOn: false),
        (name: "RadialGradient", key: "color0R", defaultValue: 1.0, value: 1.0, min: 0.0, max: 1.0, isOn: false),
        (name: "RadialGradient", key: "color0G", defaultValue: 1.0, value: 1.0, min: 0.0, max: 1.0, isOn: false),
        (name: "RadialGradient", key: "color0B", defaultValue: 1.0, value: 1.0, min: 0.0, max: 1.0, isOn: false),
        (name: "RadialGradient", key: "color0A", defaultValue: 1.0, value: 1.0, min: 0.0, max: 1.0, isOn: false),
        (name: "RadialGradient", key: "color1R", defaultValue: 0.0, value: 0.0, min: 0.0, max: 1.0, isOn: false),
        (name: "RadialGradient", key: "color1G", defaultValue: 0.0, value: 0.0, min: 0.0, max: 1.0, isOn: false),
        (name: "RadialGradient", key: "color1B", defaultValue: 0.0, value: 0.0, min: 0.0, max: 1.0, isOn: false),
        (name: "RadialGradient", key: "color1A", defaultValue: 1.0, value: 1.0, min: 0.0, max: 1.0, isOn: false),

        (name: "SmoothLinearGradient", key: "point0X", defaultValue: 0.0, value: 0.0, min: -100.0, max: 500.0, isOn: false),
        (name: "SmoothLinearGradient", key: "point0Y", defaultValue: 0.0, value: 0.0, min: -100.0, max: 500.0, isOn: false),
        (name: "SmoothLinearGradient", key: "point1X", defaultValue: 200.0, value: 200.0, min: -100.0, max: 500.0, isOn: false),
        (name: "SmoothLinearGradient", key: "point1Y", defaultValue: 200.0, value: 200.0, min: -100.0, max: 500.0, isOn: false),
        (name: "SmoothLinearGradient", key: "color0R", defaultValue: 1.0, value: 1.0, min: 0.0, max: 1.0, isOn: false),
        (name: "SmoothLinearGradient", key: "color0G", defaultValue: 1.0, value: 1.0, min: 0.0, max: 1.0, isOn: false),
        (name: "SmoothLinearGradient", key: "color0B", defaultValue: 1.0, value: 1.0, min: 0.0, max: 1.0, isOn: false),
        (name: "SmoothLinearGradient", key: "color0A", defaultValue: 1.0, value: 1.0, min: 0.0, max: 1.0, isOn: false),
        (name: "SmoothLinearGradient", key: "color1R", defaultValue: 0.0, value: 0.0, min: 0.0, max: 1.0, isOn: false),
        (name: "SmoothLinearGradient", key: "color1G", defaultValue: 0.0, value: 0.0, min: 0.0, max: 1.0, isOn: false),
        (name: "SmoothLinearGradient", key: "color1B", defaultValue: 0.0, value: 0.0, min: 0.0, max: 1.0, isOn: false),
        (name: "SmoothLinearGradient", key: "color1A", defaultValue: 1.0, value: 1.0, min: 0.0, max: 1.0, isOn: false),

        // 余白
        (name: "???", key: "alpha", defaultValue: 1.0, value: 1.0, min: 0.0, max: 1.0, isOn: false)
    ]

    var image: CIImage? {
        var formatted: [(name: String, option: [String: CGFloat])] = []
        data.filter { d in d.isOn }.forEach { d in
            var f: (name: String, option: [String: CGFloat]) = (name: d.name, option: [d.key: CGFloat(d.value)])
            if let last = formatted.last, last.name == f.name {
                last.option.forEach { f.option[$0.0] = $0.1 }
                formatted[formatted.count - 1] = f
            } else {
                formatted.append(f)
            }
        }

        let barcodeData: Data = "Sample Text Data".data(using: .ascii)!

        var image: CIImage? = nil
        formatted.forEach { d in
            switch d.name {
            case "Checkerboard":
                let centerX: CGFloat = d.option["centerX"] ?? CheckerboardGenerator.defaultInputCenter.x
                let centerY: CGFloat = d.option["centerY"] ?? CheckerboardGenerator.defaultInputCenter.y
                let center = XYPosition(x: centerX, y: centerY)

                let color0R: CGFloat = d.option["color0R"] ?? 1.0
                let color0G: CGFloat = d.option["color0G"] ?? 1.0
                let color0B: CGFloat = d.option["color0B"] ?? 1.0
                let color0A: CGFloat = d.option["color0A"] ?? 1.0
                let color1R: CGFloat = d.option["color1R"] ?? 0.0
                let color1G: CGFloat = d.option["color1G"] ?? 0.0
                let color1B: CGFloat = d.option["color1B"] ?? 0.0
                let color1A: CGFloat = d.option["color1A"] ?? 1.0
                let color0 = CIColor(red: color0R, green: color0G, blue: color0B, alpha: color0A)
                let color1 = CIColor(red: color1R, green: color1G, blue: color1B, alpha: color1A)

                let width: CGFloat = d.option["width"] ?? CheckerboardGenerator.defaultInputWidth
                let sharpness: CGFloat = d.option["sharpness"] ?? CheckerboardGenerator.defaultInputSharpness

                image = CheckerboardGenerator.image(inputCenter: center, inputColor0: color0, inputColor1: color1, inputWidth: width, inputSharpness: sharpness)
            case "Code128Barcode":
                let quietSpace: CGFloat = d.option["quietSpace"] ?? 7.0
                image = Code128BarcodeGenerator.image(inputMessage: barcodeData, inputQuietSpace: quietSpace)
            case "ConstantColor":
                let colorR: CGFloat = d.option["colorR"] ?? 0.5
                let colorG: CGFloat = d.option["colorG"] ?? 0.5
                let colorB: CGFloat = d.option["colorB"] ?? 0.5
                let colorA: CGFloat = d.option["colorA"] ?? 0.5
                let color = CIColor(red: colorR, green: colorG, blue: colorB, alpha: colorA)
                image = ConstantColorGenerator.image(inputColor: color)
            case "QRCode":
                let correctionLevelValue: Int = Int(round(d.option["correctionLevel"] ?? 1.0))
                let correctionLevel: QRCodeGenerator.ErrorCorrectionLevel
                switch correctionLevelValue {
                case 0:  correctionLevel = .L
                case 1:  correctionLevel = .M
                case 2:  correctionLevel = .Q
                case 3:  correctionLevel = .H
                default: correctionLevel = .M
                }
                image = QRCodeGenerator.image(inputMessage: barcodeData, inputCorrectionLevel: correctionLevel)
            case "Random":
                image = RandomGenerator.image
            case "Stripes":
                let centerX: CGFloat = d.option["centerX"] ?? StripesGenerator.defaultInputCenter.x
                let centerY: CGFloat = d.option["centerY"] ?? StripesGenerator.defaultInputCenter.y
                let center = XYPosition(x: centerX, y: centerY)

                let color0R: CGFloat = d.option["color0R"] ?? 1.0
                let color0G: CGFloat = d.option["color0G"] ?? 1.0
                let color0B: CGFloat = d.option["color0B"] ?? 1.0
                let color0A: CGFloat = d.option["color0A"] ?? 1.0
                let color1R: CGFloat = d.option["color1R"] ?? 0.0
                let color1G: CGFloat = d.option["color1G"] ?? 0.0
                let color1B: CGFloat = d.option["color1B"] ?? 0.0
                let color1A: CGFloat = d.option["color1A"] ?? 1.0
                let color0 = CIColor(red: color0R, green: color0G, blue: color0B, alpha: color0A)
                let color1 = CIColor(red: color1R, green: color1G, blue: color1B, alpha: color1A)

                let width: CGFloat = d.option["width"] ?? StripesGenerator.defaultInputWidth
                let sharpness: CGFloat = d.option["sharpness"] ?? StripesGenerator.defaultInputSharpness

                image = StripesGenerator.image(inputCenter: center, inputColor0: color0, inputColor1: color1, inputWidth: width, inputSharpness: sharpness)
            case "GaussianGradient":
                let centerX: CGFloat = d.option["centerX"] ?? GaussianGradient.defaultInputCenter.x
                let centerY: CGFloat = d.option["centerY"] ?? GaussianGradient.defaultInputCenter.y
                let center = XYPosition(x: centerX, y: centerY)

                let color0R: CGFloat = d.option["color0R"] ?? 1.0
                let color0G: CGFloat = d.option["color0G"] ?? 1.0
                let color0B: CGFloat = d.option["color0B"] ?? 1.0
                let color0A: CGFloat = d.option["color0A"] ?? 1.0
                let color1R: CGFloat = d.option["color1R"] ?? 0.0
                let color1G: CGFloat = d.option["color1G"] ?? 0.0
                let color1B: CGFloat = d.option["color1B"] ?? 0.0
                let color1A: CGFloat = d.option["color1A"] ?? 1.0
                let color0 = CIColor(red: color0R, green: color0G, blue: color0B, alpha: color0A)
                let color1 = CIColor(red: color1R, green: color1G, blue: color1B, alpha: color1A)

                let radius: CGFloat = d.option["radius"] ?? GaussianGradient.defaultInputRadius
                image = GaussianGradient.image(inputCenter: center, inputColor0: color0, inputColor1: color1, inputRadius: radius)
            case "LinearGradient":
                let point0X: CGFloat = d.option["point0X"] ?? LinearGradient.defaultInputPoint0.x
                let point0Y: CGFloat = d.option["point0Y"] ?? LinearGradient.defaultInputPoint0.y
                let point0 = XYPosition(x: point0X, y: point0Y)

                let point1X: CGFloat = d.option["point1X"] ?? LinearGradient.defaultInputPoint1.x
                let point1Y: CGFloat = d.option["point1Y"] ?? LinearGradient.defaultInputPoint1.y
                let point1 = XYPosition(x: point1X, y: point1Y)

                let color0R: CGFloat = d.option["color0R"] ?? 1.0
                let color0G: CGFloat = d.option["color0G"] ?? 1.0
                let color0B: CGFloat = d.option["color0B"] ?? 1.0
                let color0A: CGFloat = d.option["color0A"] ?? 1.0
                let color1R: CGFloat = d.option["color1R"] ?? 0.0
                let color1G: CGFloat = d.option["color1G"] ?? 0.0
                let color1B: CGFloat = d.option["color1B"] ?? 0.0
                let color1A: CGFloat = d.option["color1A"] ?? 1.0
                let color0 = CIColor(red: color0R, green: color0G, blue: color0B, alpha: color0A)
                let color1 = CIColor(red: color1R, green: color1G, blue: color1B, alpha: color1A)
                image = LinearGradient.image(inputPoint0: point0, inputPoint1: point1, inputColor0: color0, inputColor1: color1)
            case "RadialGradient":
                let centerX: CGFloat = d.option["centerX"] ?? RadialGradient.defaultInputCenter.x
                let centerY: CGFloat = d.option["centerY"] ?? RadialGradient.defaultInputCenter.y
                let center = XYPosition(x: centerX, y: centerY)

                let radius0: CGFloat = d.option["radius0"] ?? RadialGradient.defaultInputRadius0
                let radius1: CGFloat = d.option["radius1"] ?? RadialGradient.defaultInputRadius1

                let color0R: CGFloat = d.option["color0R"] ?? 1.0
                let color0G: CGFloat = d.option["color0G"] ?? 1.0
                let color0B: CGFloat = d.option["color0B"] ?? 1.0
                let color0A: CGFloat = d.option["color0A"] ?? 1.0
                let color1R: CGFloat = d.option["color1R"] ?? 0.0
                let color1G: CGFloat = d.option["color1G"] ?? 0.0
                let color1B: CGFloat = d.option["color1B"] ?? 0.0
                let color1A: CGFloat = d.option["color1A"] ?? 1.0
                let color0 = CIColor(red: color0R, green: color0G, blue: color0B, alpha: color0A)
                let color1 = CIColor(red: color1R, green: color1G, blue: color1B, alpha: color1A)

                image = RadialGradient.image(inputCenter: center, inputRadius0: radius0, inputRadius1: radius1, inputColor0: color0, inputColor1: color1)
            case "SmoothLinearGradient":
                let point0X: CGFloat = d.option["point0X"] ?? SmoothLinearGradient.defaultInputPoint0.x
                let point0Y: CGFloat = d.option["point0Y"] ?? SmoothLinearGradient.defaultInputPoint0.y
                let point0 = XYPosition(x: point0X, y: point0Y)

                let point1X: CGFloat = d.option["point1X"] ?? SmoothLinearGradient.defaultInputPoint1.x
                let point1Y: CGFloat = d.option["point1Y"] ?? SmoothLinearGradient.defaultInputPoint1.y
                let point1 = XYPosition(x: point1X, y: point1Y)

                let color0R: CGFloat = d.option["color0R"] ?? 1.0
                let color0G: CGFloat = d.option["color0G"] ?? 1.0
                let color0B: CGFloat = d.option["color0B"] ?? 1.0
                let color0A: CGFloat = d.option["color0A"] ?? 1.0
                let color1R: CGFloat = d.option["color1R"] ?? 0.0
                let color1G: CGFloat = d.option["color1G"] ?? 0.0
                let color1B: CGFloat = d.option["color1B"] ?? 0.0
                let color1A: CGFloat = d.option["color1A"] ?? 1.0
                let color0 = CIColor(red: color0R, green: color0G, blue: color0B, alpha: color0A)
                let color1 = CIColor(red: color1R, green: color1G, blue: color1B, alpha: color1A)
                image = SmoothLinearGradient.image(inputPoint0: point0, inputPoint1: point1, inputColor0: color0, inputColor1: color1)
            default:
                break
            }
        }
        return image
    }

    weak var generatorListTableViewDelegate: CIGeneratorListTableViewDelegate?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        commonInit()
    }

    private func commonInit() {
        register(CIFilterCell.nibForRegisterTableView(), forCellReuseIdentifier: CIFilterCell.defaultReuseIdentifier)
        delegate = self
        dataSource = self
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CIFilterCell.defaultReuseIdentifier) as? CIFilterCell else {
            fatalError()
        }
        cell.delegate = self
        cell.set(data: data[indexPath.row])
        return cell
    }

    // MARK:- CIFilterCellDelegate

    func touchUpInsideDefaultButton(cell: CIFilterCell) {
        guard let index = indexPath(for: cell)?.row else { return }
        print(index)
    }

    func valueChangedSlider(cell: CIFilterCell, value: Float) {
        guard let index = indexPath(for: cell)?.row else { return }
        data[index].value = value
        generatorListTableViewDelegate?.imageDidUpdate(tableView: self)
    }

    func valueChangedSwitch(cell: CIFilterCell, isOn: Bool) {
        guard let index = indexPath(for: cell)?.row else { return }
        data[index].isOn = isOn
        generatorListTableViewDelegate?.imageDidUpdate(tableView: self)
    }

}
