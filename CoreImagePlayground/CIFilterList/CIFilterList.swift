import UIKit
import CIFilterExtension

protocol CIFilterListTableViewDelegate: class {
    func filterDidUpdate(tableView: CIFilterListTableView)
}

final class CIFilterListTableView: UITableView, UITableViewDelegate, UITableViewDataSource, CIFilterCellDelegate {
    
    private var data: [FilterCellData] = [
        (name: "", key: "", defaultValue: 0.0, value: 0.0, min: 0.0, max: 0.0, isOn: false),
        
        (name: "TiltShiftLine", key: "blurRadius", defaultValue: 20.0, value: 20.0, min: -10.0, max: 100.0, isOn: false),
        (name: "TiltShiftLine", key: "centerX", defaultValue: 150.0, value: 150.0, min: -10.0, max: 500.0, isOn: false),
        (name: "TiltShiftLine", key: "centerY", defaultValue: 150.0, value: 150.0, min: -10.0, max: 500.0, isOn: false),
        
        (name: "TiltShiftCircle", key: "gaussian", defaultValue: 0.0, value: 0.0, min: 0.0, max: 0.0, isOn: false),
        (name: "TiltShiftCircle", key: "box", defaultValue: 0.0, value: 0.0, min: 0.0, max: 0.0, isOn: false),
        (name: "TiltShiftCircle", key: "disc", defaultValue: 0.0, value: 0.0, min: 0.0, max: 0.0, isOn: false),
        (name: "TiltShiftCircle", key: "motion", defaultValue: 0.0, value: 0.0, min: 0.0, max: 0.0, isOn: false),
        (name: "TiltShiftCircle", key: "zoom", defaultValue: 0.0, value: 0.0, min: 0.0, max: 0.0, isOn: false),
        (name: "TiltShiftCircle", key: "blurRadius", defaultValue: 20.0, value: 20.0, min: -10.0, max: 100.0, isOn: false),
        (name: "TiltShiftCircle", key: "centerX", defaultValue: 150.0, value: 150.0, min: -10.0, max: 500.0, isOn: false),
        (name: "TiltShiftCircle", key: "centerY", defaultValue: 150.0, value: 150.0, min: -10.0, max: 500.0, isOn: false),
        (name: "TiltShiftCircle", key: "radius0", defaultValue: 5.0, value: 5.0, min: 0.0, max: 300.0, isOn: false),
        (name: "TiltShiftCircle", key: "radius1", defaultValue: 100.0, value: 100.0, min: 0.0, max: 300.0, isOn: false),
        
        (name: "Crystallize", key: "radius", defaultValue: 20.0, value: 20.0, min: -10.0, max: 100.0, isOn: false),
        (name: "Crystallize", key: "centerX", defaultValue: 150.0, value: 150.0, min: -100.0, max: 500.0, isOn: false),
        (name: "Crystallize", key: "centerY", defaultValue: 150.0, value: 150.0, min: -100.0, max: 500.0, isOn: false),
        (name: "HexagonalPixellate", key: "centerX", defaultValue: 150.0, value: 150.0, min: -100.0, max: 500.0, isOn: false),
        (name: "HexagonalPixellate", key: "centerY", defaultValue: 150.0, value: 150.0, min: -100.0, max: 500.0, isOn: false),
        (name: "HexagonalPixellate", key: "scale", defaultValue: 8.0, value: 8.0, min: -1.0, max: 100.0, isOn: false),
        (name: "HighlightShadowAdjust", key: "highlightAmount", defaultValue: 1.0, value: 1.0, min: -1.0, max: 3.0, isOn: false),
        (name: "HighlightShadowAdjust", key: "shadowAmount", defaultValue: 1.0, value: 1.0, min: -1.0, max: 3.0, isOn: false),
        (name: "Pixellate", key: "centerX", defaultValue: 150.0, value: 150.0, min: -100.0, max: 500.0, isOn: false),
        (name: "Pixellate", key: "centerY", defaultValue: 150.0, value: 150.0, min: -100.0, max: 500.0, isOn: false),
        (name: "Pixellate", key: "scale", defaultValue: 8.0, value: 8.0, min: -1.0, max: 200.0, isOn: false),
        (name: "Pointillize", key: "radius", defaultValue: 20.0, value: 20.0, min: -10.0, max: 100.0, isOn: false),
        (name: "Pointillize", key: "centerX", defaultValue: 150.0, value: 150.0, min: -100.0, max: 500.0, isOn: false),
        (name: "Pointillize", key: "centerY", defaultValue: 150.0, value: 150.0, min: -100.0, max: 500.0, isOn: false),
        (name: "Edges", key: "intensity", defaultValue: 1.0, value: 1.0, min: -1.0, max: 3.0, isOn: false),
        (name: "EdgeWork", key: "radius", defaultValue: 3.0, value: 3.0, min: -1.0, max: 10.0, isOn: false),
        
        // 1. Blur
        (name: "BoxBlur",        key: "inputRadius",     defaultValue: 10.0,  value: 10.0,  min: 0.0, max: 100.0, isOn: false),
        (name: "DiscBlur",       key: "inputRadius",     defaultValue: 10.0,  value: 10.0,  min: 0.0, max: 100.0, isOn: false),
        (name: "GaussianBlur",   key: "inputRadius",     defaultValue: 10.0,  value: 10.0,  min: 0.0, max: 100.0, isOn: false),
        (name: "MedianFilter",   key: "noParams",        defaultValue: 0.0,   value: 0.0,   min: 0.0, max: 0.0,   isOn: false),
        (name: "MotionBlur",     key: "inputRadius",     defaultValue: 20.0,  value: 20.0,  min: 0.0, max: 100.0, isOn: false),
        (name: "MotionBlur",     key: "inputAngle",      defaultValue: 0.0,   value: 0.0,   min: 0.0, max: 10.0,  isOn: false),
        (name: "NoiseReduction", key: "inputNoiseLevel", defaultValue: 0.02,  value: 0.02,  min: 0.0, max: 10.0,  isOn: false),
        (name: "NoiseReduction", key: "inputSharpness",  defaultValue: 0.4,   value: 0.4,   min: 0.0, max: 10.0,  isOn: false),
        (name: "ZoomBlur",       key: "inputCenterX",    defaultValue: 150.0, value: 150.0, min: 0.0, max: 300.0, isOn: false),
        (name: "ZoomBlur",       key: "inputCenterY",    defaultValue: 150.0, value: 150.0, min: 0.0, max: 300.0, isOn: false),
        (name: "ZoomBlur",       key: "inputRadius",     defaultValue: 20.0,  value: 20.0,  min: 0.0, max: 100.0, isOn: false),
        
        // 2. ColorAdjustment
        /*
         (name: "ColorClamp", key: "minR", defaultValue: 0.0, value: 0.0, min: 0.0, max: 1.0, isOn: false),
         (name: "ColorClamp", key: "maxR", defaultValue: 1.0, value: 1.0, min: 0.0, max: 1.0, isOn: false),
         (name: "ColorClamp", key: "minG", defaultValue: 0.0, value: 0.0, min: 0.0, max: 1.0, isOn: false),
         (name: "ColorClamp", key: "maxG", defaultValue: 1.0, value: 1.0, min: 0.0, max: 1.0, isOn: false),
         (name: "ColorClamp", key: "minB", defaultValue: 0.0, value: 0.0, min: 0.0, max: 1.0, isOn: false),
         (name: "ColorClamp", key: "maxB", defaultValue: 1.0, value: 1.0, min: 0.0, max: 1.0, isOn: false),
         (name: "ColorClamp", key: "minA", defaultValue: 0.0, value: 0.0, min: 0.0, max: 1.0, isOn: false),
         (name: "ColorClamp", key: "maxA", defaultValue: 1.0, value: 1.0, min: 0.0, max: 1.0, isOn: false),
         */
        (name: "ColorControls", key: "saturation", defaultValue: 1.0, value: 1.0, min: -4.0, max: 4.0, isOn: false),
        (name: "ColorControls", key: "brightness", defaultValue: 0.0, value: 0.0, min: -2.0, max: 2.0, isOn: false),
        (name: "ColorControls", key: "contrast",   defaultValue: 1.0, value: 1.0, min: -4.0, max: 4.0, isOn: false),
        /*
         (name: "ColorMatrix", key: "rVectorR", defaultValue: 1.0, value: 1.0, min: -2.0, max: 2.0, isOn: false),
         (name: "ColorMatrix", key: "rVectorG", defaultValue: 0.0, value: 0.0, min: -2.0, max: 2.0, isOn: false),
         (name: "ColorMatrix", key: "rVectorB", defaultValue: 0.0, value: 0.0, min: -2.0, max: 2.0, isOn: false),
         (name: "ColorMatrix", key: "rVectorA", defaultValue: 0.0, value: 0.0, min: -2.0, max: 2.0, isOn: false),
         (name: "ColorMatrix", key: "gVectorR", defaultValue: 0.0, value: 0.0, min: -2.0, max: 2.0, isOn: false),
         (name: "ColorMatrix", key: "gVectorG", defaultValue: 1.0, value: 1.0, min: -2.0, max: 2.0, isOn: false),
         (name: "ColorMatrix", key: "gVectorB", defaultValue: 0.0, value: 0.0, min: -2.0, max: 2.0, isOn: false),
         (name: "ColorMatrix", key: "gVectorA", defaultValue: 0.0, value: 0.0, min: -2.0, max: 2.0, isOn: false),
         (name: "ColorMatrix", key: "bVectorR", defaultValue: 0.0, value: 0.0, min: -2.0, max: 2.0, isOn: false),
         (name: "ColorMatrix", key: "bVectorG", defaultValue: 0.0, value: 0.0, min: -2.0, max: 2.0, isOn: false),
         (name: "ColorMatrix", key: "bVectorB", defaultValue: 1.0, value: 1.0, min: -2.0, max: 2.0, isOn: false),
         (name: "ColorMatrix", key: "bVectorA", defaultValue: 0.0, value: 0.0, min: -2.0, max: 2.0, isOn: false),
         (name: "ColorMatrix", key: "aVectorR", defaultValue: 0.0, value: 0.0, min: -2.0, max: 2.0, isOn: false),
         (name: "ColorMatrix", key: "aVectorG", defaultValue: 0.0, value: 0.0, min: -2.0, max: 2.0, isOn: false),
         (name: "ColorMatrix", key: "aVectorB", defaultValue: 0.0, value: 0.0, min: -2.0, max: 2.0, isOn: false),
         (name: "ColorMatrix", key: "aVectorA", defaultValue: 1.0, value: 1.0, min: -2.0, max: 2.0, isOn: false),
         (name: "ColorMatrix", key: "biasVectorR", defaultValue: 0.0, value: 0.0, min: -2.0, max: 2.0, isOn: false),
         (name: "ColorMatrix", key: "biasVectorG", defaultValue: 0.0, value: 0.0, min: -2.0, max: 2.0, isOn: false),
         (name: "ColorMatrix", key: "biasVectorB", defaultValue: 0.0, value: 0.0, min: -2.0, max: 2.0, isOn: false),
         (name: "ColorMatrix", key: "biasVectorA", defaultValue: 0.0, value: 0.0, min: -2.0, max: 2.0, isOn: false),
         */
        /*
         (name: "ColorPolynomial", key: "rA0", defaultValue: 0.0, value: 0.0, min: -2.0, max: 2.0, isOn: false),
         (name: "ColorPolynomial", key: "rA1", defaultValue: 1.0, value: 1.0, min: -2.0, max: 2.0, isOn: false),
         (name: "ColorPolynomial", key: "rA2", defaultValue: 0.0, value: 0.0, min: -2.0, max: 2.0, isOn: false),
         (name: "ColorPolynomial", key: "rA3", defaultValue: 0.0, value: 0.0, min: -2.0, max: 2.0, isOn: false),
         (name: "ColorPolynomial", key: "gA0", defaultValue: 0.0, value: 0.0, min: -2.0, max: 2.0, isOn: false),
         (name: "ColorPolynomial", key: "gA1", defaultValue: 1.0, value: 1.0, min: -2.0, max: 2.0, isOn: false),
         (name: "ColorPolynomial", key: "gA2", defaultValue: 0.0, value: 0.0, min: -2.0, max: 2.0, isOn: false),
         (name: "ColorPolynomial", key: "gA3", defaultValue: 0.0, value: 0.0, min: -2.0, max: 2.0, isOn: false),
         (name: "ColorPolynomial", key: "bA0", defaultValue: 0.0, value: 0.0, min: -2.0, max: 2.0, isOn: false),
         (name: "ColorPolynomial", key: "bA1", defaultValue: 1.0, value: 1.0, min: -2.0, max: 2.0, isOn: false),
         (name: "ColorPolynomial", key: "bA2", defaultValue: 0.0, value: 0.0, min: -2.0, max: 2.0, isOn: false),
         (name: "ColorPolynomial", key: "bA3", defaultValue: 0.0, value: 0.0, min: -2.0, max: 2.0, isOn: false),
         (name: "ColorPolynomial", key: "aA0", defaultValue: 0.0, value: 0.0, min: -2.0, max: 2.0, isOn: false),
         (name: "ColorPolynomial", key: "aA1", defaultValue: 1.0, value: 1.0, min: -2.0, max: 2.0, isOn: false),
         (name: "ColorPolynomial", key: "aA2", defaultValue: 0.0, value: 0.0, min: -2.0, max: 2.0, isOn: false),
         (name: "ColorPolynomial", key: "aA3", defaultValue: 0.0, value: 0.0, min: -2.0, max: 2.0, isOn: false),
         */
        (name: "ExposureAdjust", key: "inputEV", defaultValue: 0.5, value: 0.5, min: -4.0, max: 4.0, isOn: false),
        (name: "GammaAdjust", key: "inputPower", defaultValue: 0.75, value: 0.75, min: 0.0, max: 4.0, isOn: false),
        (name: "HueAdjust", key: "inputAngle", defaultValue: 0.0, value: 0.0, min: -4.0, max: 4.0, isOn: false),
        (name: "LinearToSRGBToneCurve", key: "noParams", defaultValue: 0.0, value: 0.0, min: 0.0, max: 0.0, isOn: false),
        (name: "SRGBToneCurveToLinear", key: "noParams", defaultValue: 0.0, value: 0.0, min: 0.0, max: 0.0, isOn: false),
        (name: "TemperatureAndTint", key: "inputNeutralTemp", defaultValue: 6500.0, value: 6500.0, min: 2000.0, max: 12000.0, isOn: false),
        (name: "TemperatureAndTint", key: "inputNeutralTint", defaultValue: 0.0, value: 0.0, min: -800.0, max: 800.0, isOn: false),
        (name: "TemperatureAndTint", key: "targetInputNeutralTemp", defaultValue: 6500.0, value: 6500.0, min: 2000.0, max: 12000.0, isOn: false),
        (name: "TemperatureAndTint", key: "targetInputNeutralTint", defaultValue: 0.0, value: 0.0, min: -800.0, max: 800.0, isOn: false),
        (name: "ToneCurve", key: "inputPoint0X", defaultValue: 0.00, value: 0.00, min: 0.0, max: 1.0, isOn: false),
        (name: "ToneCurve", key: "inputPoint0Y", defaultValue: 0.00, value: 0.00, min: 0.0, max: 1.0, isOn: false),
        (name: "ToneCurve", key: "inputPoint1X", defaultValue: 0.25, value: 0.25, min: 0.0, max: 1.0, isOn: false),
        (name: "ToneCurve", key: "inputPoint1Y", defaultValue: 0.25, value: 0.25, min: 0.0, max: 1.0, isOn: false),
        (name: "ToneCurve", key: "inputPoint2X", defaultValue: 0.50, value: 0.50, min: 0.0, max: 1.0, isOn: false),
        (name: "ToneCurve", key: "inputPoint2Y", defaultValue: 0.50, value: 0.50, min: 0.0, max: 1.0, isOn: false),
        (name: "ToneCurve", key: "inputPoint3X", defaultValue: 0.75, value: 0.75, min: 0.0, max: 1.0, isOn: false),
        (name: "ToneCurve", key: "inputPoint3Y", defaultValue: 0.75, value: 0.75, min: 0.0, max: 1.0, isOn: false),
        (name: "ToneCurve", key: "inputPoint4X", defaultValue: 1.00, value: 1.00, min: 0.0, max: 1.0, isOn: false),
        (name: "ToneCurve", key: "inputPoint4Y", defaultValue: 1.00, value: 1.00, min: 0.0, max: 1.0, isOn: false),
        (name: "Vibrance", key: "inputAmount", defaultValue: 0.0, value: 0.0, min: -4.0, max: 4.0, isOn: false),
        (name: "WhitePointAdjust", key: "inputColor", defaultValue: 0.0, value: 0.0, min: 0.0, max: 0.0, isOn: false),
        
        // 3-1. ColorEffect
        /*
         (name: "ColorCrossPolynomial", key: "rA0", defaultValue: 1.0, value: 1.0, min: -1.0, max: 1.0, isOn: false),
         (name: "ColorCrossPolynomial", key: "rA1", defaultValue: 0.0, value: 0.0, min: -1.0, max: 1.0, isOn: false),
         (name: "ColorCrossPolynomial", key: "rA2", defaultValue: 0.0, value: 0.0, min: -1.0, max: 1.0, isOn: false),
         (name: "ColorCrossPolynomial", key: "rA3", defaultValue: 0.0, value: 0.0, min: -1.0, max: 1.0, isOn: false),
         (name: "ColorCrossPolynomial", key: "rA4", defaultValue: 0.0, value: 0.0, min: -1.0, max: 1.0, isOn: false),
         (name: "ColorCrossPolynomial", key: "rA5", defaultValue: 0.0, value: 0.0, min: -1.0, max: 1.0, isOn: false),
         (name: "ColorCrossPolynomial", key: "rA6", defaultValue: 0.0, value: 0.0, min: -1.0, max: 1.0, isOn: false),
         (name: "ColorCrossPolynomial", key: "rA7", defaultValue: 0.0, value: 0.0, min: -1.0, max: 1.0, isOn: false),
         (name: "ColorCrossPolynomial", key: "rA8", defaultValue: 0.0, value: 0.0, min: -1.0, max: 1.0, isOn: false),
         (name: "ColorCrossPolynomial", key: "rA9", defaultValue: 0.0, value: 0.0, min: -1.0, max: 1.0, isOn: false),
         (name: "ColorCrossPolynomial", key: "gA0", defaultValue: 0.0, value: 0.0, min: -1.0, max: 1.0, isOn: false),
         (name: "ColorCrossPolynomial", key: "gA1", defaultValue: 1.0, value: 1.0, min: -1.0, max: 1.0, isOn: false),
         (name: "ColorCrossPolynomial", key: "gA2", defaultValue: 0.0, value: 0.0, min: -1.0, max: 1.0, isOn: false),
         (name: "ColorCrossPolynomial", key: "gA3", defaultValue: 0.0, value: 0.0, min: -1.0, max: 1.0, isOn: false),
         (name: "ColorCrossPolynomial", key: "gA4", defaultValue: 0.0, value: 0.0, min: -1.0, max: 1.0, isOn: false),
         (name: "ColorCrossPolynomial", key: "gA5", defaultValue: 0.0, value: 0.0, min: -1.0, max: 1.0, isOn: false),
         (name: "ColorCrossPolynomial", key: "gA6", defaultValue: 0.0, value: 0.0, min: -1.0, max: 1.0, isOn: false),
         (name: "ColorCrossPolynomial", key: "gA7", defaultValue: 0.0, value: 0.0, min: -1.0, max: 1.0, isOn: false),
         (name: "ColorCrossPolynomial", key: "gA8", defaultValue: 0.0, value: 0.0, min: -1.0, max: 1.0, isOn: false),
         (name: "ColorCrossPolynomial", key: "gA9", defaultValue: 0.0, value: 0.0, min: -1.0, max: 1.0, isOn: false),
         (name: "ColorCrossPolynomial", key: "bA0", defaultValue: 0.0, value: 0.0, min: -1.0, max: 1.0, isOn: false),
         (name: "ColorCrossPolynomial", key: "bA1", defaultValue: 0.0, value: 0.0, min: -1.0, max: 1.0, isOn: false),
         (name: "ColorCrossPolynomial", key: "bA2", defaultValue: 1.0, value: 1.0, min: -1.0, max: 1.0, isOn: false),
         (name: "ColorCrossPolynomial", key: "bA3", defaultValue: 0.0, value: 0.0, min: -1.0, max: 1.0, isOn: false),
         (name: "ColorCrossPolynomial", key: "bA4", defaultValue: 0.0, value: 0.0, min: -1.0, max: 1.0, isOn: false),
         (name: "ColorCrossPolynomial", key: "bA5", defaultValue: 0.0, value: 0.0, min: -1.0, max: 1.0, isOn: false),
         (name: "ColorCrossPolynomial", key: "bA6", defaultValue: 0.0, value: 0.0, min: -1.0, max: 1.0, isOn: false),
         (name: "ColorCrossPolynomial", key: "bA7", defaultValue: 0.0, value: 0.0, min: -1.0, max: 1.0, isOn: false),
         (name: "ColorCrossPolynomial", key: "bA8", defaultValue: 0.0, value: 0.0, min: -1.0, max: 1.0, isOn: false),
         (name: "ColorCrossPolynomial", key: "bA9", defaultValue: 0.0, value: 0.0, min: -1.0, max: 1.0, isOn: false),
         */
        /*
         // TODO
         (name: "ColorCube", key: "", defaultValue: 0.0, value: 0.0, min: 0.0, max: 0.0, isOn: false),
         (name: "ColorCubeWithColorSpace", key: "", defaultValue: 0.0, value: 0.0, min: 0.0, max: 0.0, isOn: false),
         */
        (name: "CIColorInvert", key: "", defaultValue: 0.0, value: 0.0, min: 0.0, max: 0.0, isOn: false),
        /*
         // TODO
         (name: "ColorMap", key: "", defaultValue: 0.0, value: 0.0, min: 0.0, max: 0.0, isOn: false),
         */
        (name: "ColorMonochrome", key: "colorR", defaultValue: 0.6, value: 0.6, min: 0.0, max: 1.0, isOn: false),
        (name: "ColorMonochrome", key: "colorG", defaultValue: 0.45, value: 0.45, min: 0.0, max: 1.0, isOn: false),
        (name: "ColorMonochrome", key: "colorB", defaultValue: 0.3, value: 0.3, min: 0.0, max: 1.0, isOn: false),
        (name: "ColorMonochrome", key: "colorA", defaultValue: 1.0, value: 1.0, min: 0.0, max: 1.0, isOn: false),
        (name: "ColorMonochrome", key: "intensity", defaultValue: 1.0, value: 1.0, min: 0.0, max: 1.0, isOn: false),
        (name: "ColorPosterize", key: "levels", defaultValue: 6.0, value: 6.0, min: 0.0, max: 20.0, isOn: false),
        (name: "FalseColor", key: "color0R", defaultValue: 0.3, value: 0.3, min: 0.0, max: 1.0, isOn: false),
        (name: "FalseColor", key: "color0G", defaultValue: 0.0, value: 0.0, min: 0.0, max: 1.0, isOn: false),
        (name: "FalseColor", key: "color0B", defaultValue: 0.0, value: 0.0, min: 0.0, max: 1.0, isOn: false),
        (name: "FalseColor", key: "color0A", defaultValue: 1.0, value: 1.0, min: 0.0, max: 1.0, isOn: false),
        (name: "FalseColor", key: "color1R", defaultValue: 1.0, value: 1.0, min: 0.0, max: 1.0, isOn: false),
        (name: "FalseColor", key: "color1G", defaultValue: 0.9, value: 0.9, min: 0.0, max: 1.0, isOn: false),
        (name: "FalseColor", key: "color1B", defaultValue: 0.8, value: 0.8, min: 0.0, max: 1.0, isOn: false),
        (name: "FalseColor", key: "color1A", defaultValue: 1.0, value: 1.0, min: 0.0, max: 1.0, isOn: false),
        (name: "MaskToAlpha", key: "", defaultValue: 0.0, value: 0.0, min: 0.0, max: 0.0, isOn: false),
        (name: "MaximumComponent", key: "", defaultValue: 0.0, value: 0.0, min: 0.0, max: 0.0, isOn: false),
        (name: "MinimumComponent", key: "", defaultValue: 0.0, value: 0.0, min: 0.0, max: 0.0, isOn: false),
        (name: "SepiaTone", key: "intensity", defaultValue: 1.0, value: 1.0, min: -2.0, max: 2.0, isOn: false),
        (name: "Vignette", key: "radius", defaultValue: 1.0, value: 1.0, min: -1.0, max: 3.0, isOn: false),
        (name: "Vignette", key: "intensity", defaultValue: 0.0, value: 0.0, min: -8.0, max: 8.0, isOn: false),
        (name: "VignetteEffect", key: "centerX", defaultValue: 150.0, value: 150.0, min: -1000.0, max: 1000.0, isOn: false),
        (name: "VignetteEffect", key: "centerY", defaultValue: 150.0, value: 150.0, min: -1000.0, max: 1000.0, isOn: false),
        (name: "VignetteEffect", key: "intensity", defaultValue: 1.0, value: 1.0, min: -2.0, max: 2.0, isOn: false),
        (name: "VignetteEffect", key: "falloff", defaultValue: 0.0, value: 0.0, min: -1.0, max: 2.0, isOn: false),
        
        // 3-2. Photo Effect
        (name: "Chrome",   key: "alpha", defaultValue: 1.0, value: 1.0, min: 0.0, max: 1.0, isOn: false),
        (name: "Fade",     key: "alpha", defaultValue: 1.0, value: 1.0, min: 0.0, max: 1.0, isOn: false),
        (name: "Instant",  key: "alpha", defaultValue: 1.0, value: 1.0, min: 0.0, max: 1.0, isOn: false),
        (name: "Mono",     key: "alpha", defaultValue: 1.0, value: 1.0, min: 0.0, max: 1.0, isOn: false),
        (name: "Noir",     key: "alpha", defaultValue: 1.0, value: 1.0, min: 0.0, max: 1.0, isOn: false),
        (name: "Process",  key: "alpha", defaultValue: 1.0, value: 1.0, min: 0.0, max: 1.0, isOn: false),
        (name: "Tonal",    key: "alpha", defaultValue: 1.0, value: 1.0, min: 0.0, max: 1.0, isOn: false),
        (name: "Transfer", key: "alpha", defaultValue: 1.0, value: 1.0, min: 0.0, max: 1.0, isOn: false),
        
        // 4. CompositeOperation
        
        // 5. DistortionEffect
        (name: "BumpDistortion", key: "centerX", defaultValue: 150.0, value: 150.0, min: -100.0, max: 500.0, isOn: false),
        (name: "BumpDistortion", key: "centerY", defaultValue: 150.0, value: 150.0, min: -100.0, max: 500.0, isOn: false),
        (name: "BumpDistortion", key: "radius", defaultValue: 300.0, value: 300.0, min: -100.0, max: 600.0, isOn: false),
        (name: "BumpDistortion", key: "scale", defaultValue: 0.5, value: 0.5, min: -1.0, max: 2.0, isOn: false),
        (name: "HoleDistortion", key: "centerX", defaultValue: 150.0, value: 150.0, min: -100.0, max: 500.0, isOn: false),
        (name: "HoleDistortion", key: "centerY", defaultValue: 150.0, value: 150.0, min: -100.0, max: 500.0, isOn: false),
        (name: "HoleDistortion", key: "radius", defaultValue: 150.0, value: 150.0, min: -100.0, max: 600.0, isOn: false),
        (name: "LightTunnel", key: "centerX", defaultValue: 150.0, value: 150.0, min: -100.0, max: 500.0, isOn: false),
        (name: "LightTunnel", key: "centerY", defaultValue: 150.0, value: 150.0, min: -100.0, max: 500.0, isOn: false),
        (name: "LightTunnel", key: "rotation", defaultValue: 0.0, value: 0.0, min: -1.0, max: 20.0, isOn: false),
        (name: "LightTunnel", key: "radius", defaultValue: 0.0, value: 0.0, min: -10.0, max: 500.0, isOn: false),
        (name: "PinchDistortion", key: "centerX", defaultValue: 150.0, value: 150.0, min: -100.0, max: 500.0, isOn: false),
        (name: "PinchDistortion", key: "centerY", defaultValue: 150.0, value: 150.0, min: -100.0, max: 500.0, isOn: false),
        (name: "PinchDistortion", key: "radius", defaultValue: 300.0, value: 300.0, min: -100.0, max: 600.0, isOn: false),
        (name: "PinchDistortion", key: "scale", defaultValue: 0.5, value: 0.5, min: -1.0, max: 2.0, isOn: false),
        (name: "TorusLensDistortion", key: "centerX", defaultValue: 150.0, value: 150.0, min: -100.0, max: 500.0, isOn: false),
        (name: "TorusLensDistortion", key: "centerY", defaultValue: 150.0, value: 150.0, min: -100.0, max: 500.0, isOn: false),
        (name: "TorusLensDistortion", key: "radius", defaultValue: 160.0, value: 160.0, min: -100.0, max: 600.0, isOn: false),
        (name: "TorusLensDistortion", key: "width", defaultValue: 80.0, value: 80.0, min: -10.0, max: 200.0, isOn: false),
        (name: "TorusLensDistortion", key: "refraction", defaultValue: 1.7, value: 1.7, min: -1.0, max: 9.0, isOn: false),
        (name: "TwirlDistortion", key: "centerX", defaultValue: 150.0, value: 150.0, min: -100.0, max: 500.0, isOn: false),
        (name: "TwirlDistortion", key: "centerY", defaultValue: 150.0, value: 150.0, min: -100.0, max: 500.0, isOn: false),
        (name: "TwirlDistortion", key: "radius", defaultValue: 300.0, value: 300.0, min: -100.0, max: 600.0, isOn: false),
        (name: "TwirlDistortion", key: "angle", defaultValue: Float(M_PI), value: Float(M_PI), min: -1.0, max: 9.0, isOn: false),
        (name: "VortexDistortion", key: "centerX", defaultValue: 150.0, value: 150.0, min: -100.0, max: 500.0, isOn: false),
        (name: "VortexDistortion", key: "centerY", defaultValue: 150.0, value: 150.0, min: -100.0, max: 500.0, isOn: false),
        (name: "VortexDistortion", key: "radius", defaultValue: 300.0, value: 300.0, min: -100.0, max: 600.0, isOn: false),
        (name: "VortexDistortion", key: "angle", defaultValue: Float(M_PI * 18.0), value: Float(M_PI * 18.0), min: -50.0, max: 100.0, isOn: false),
        
        // 6. Generator
        
        // 7. GeometryAdjustment
        
        // 8. Gradient
        
        // 9. HalftoneEffect
        (name: "CircularScreen", key: "centerX", defaultValue: 150.0, value: 150.0, min: -300.0, max: 300.0, isOn: false),
        (name: "CircularScreen", key: "centerY", defaultValue: 150.0, value: 150.0, min: -300.0, max: 300.0, isOn: false),
        (name: "CircularScreen", key: "width", defaultValue: 6.0, value: 6.0, min: -1.0, max: 10.0, isOn: false),
        (name: "CircularScreen", key: "sharpness", defaultValue: 0.7, value: 0.7, min: -1.0, max: 2.0, isOn: false),
        (name: "CMYKHalftone", key: "centerX", defaultValue: 150.0, value: 150.0, min: -300.0, max: 300.0, isOn: false),
        (name: "CMYKHalftone", key: "centerY", defaultValue: 150.0, value: 150.0, min: -300.0, max: 300.0, isOn: false),
        (name: "CMYKHalftone", key: "angle", defaultValue: 0.0, value: 0.0, min: -6.0, max: 6.0, isOn: false),
        (name: "CMYKHalftone", key: "width", defaultValue: 6.0, value: 6.0, min: -1.0, max: 10.0, isOn: false),
        (name: "CMYKHalftone", key: "sharpness", defaultValue: 0.7, value: 0.7, min: -1.0, max: 2.0, isOn: false),
        (name: "CMYKHalftone", key: "GCR", defaultValue: 1.0, value: 1.0, min: -1.0, max: 2.0, isOn: false),
        (name: "CMYKHalftone", key: "UCR", defaultValue: 0.5, value: 0.5, min: -1.0, max: 2.0, isOn: false),
        (name: "DotScreen", key: "centerX", defaultValue: 150.0, value: 150.0, min: -300.0, max: 300.0, isOn: false),
        (name: "DotScreen", key: "centerY", defaultValue: 150.0, value: 150.0, min: -300.0, max: 300.0, isOn: false),
        (name: "DotScreen", key: "angle", defaultValue: 0.0, value: 0.0, min: -6.0, max: 6.0, isOn: false),
        (name: "DotScreen", key: "width", defaultValue: 6.0, value: 6.0, min: -1.0, max: 10.0, isOn: false),
        (name: "DotScreen", key: "sharpness", defaultValue: 0.7, value: 0.7, min: -1.0, max: 2.0, isOn: false),
        (name: "HatchedScreen", key: "centerX", defaultValue: 150.0, value: 150.0, min: -300.0, max: 300.0, isOn: false),
        (name: "HatchedScreen", key: "centerY", defaultValue: 150.0, value: 150.0, min: -300.0, max: 300.0, isOn: false),
        (name: "HatchedScreen", key: "angle", defaultValue: 0.0, value: 0.0, min: -6.0, max: 6.0, isOn: false),
        (name: "HatchedScreen", key: "width", defaultValue: 6.0, value: 6.0, min: -1.0, max: 10.0, isOn: false),
        (name: "HatchedScreen", key: "sharpness", defaultValue: 0.7, value: 0.7, min: -1.0, max: 2.0, isOn: false),
        (name: "LineScreen", key: "centerX", defaultValue: 150.0, value: 150.0, min: -300.0, max: 300.0, isOn: false),
        (name: "LineScreen", key: "centerY", defaultValue: 150.0, value: 150.0, min: -300.0, max: 300.0, isOn: false),
        (name: "LineScreen", key: "angle", defaultValue: 0.0, value: 0.0, min: -6.0, max: 6.0, isOn: false),
        (name: "LineScreen", key: "width", defaultValue: 6.0, value: 6.0, min: -1.0, max: 10.0, isOn: false),
        (name: "LineScreen", key: "sharpness", defaultValue: 0.7, value: 0.7, min: -1.0, max: 2.0, isOn: false),
        
        // 10. Reduction
        
        // 11. Sharpen
        (name: "SharpenLuminance", key: "sharpness", defaultValue: 0.4, value: 0.4, min: -1.0, max: 1.0, isOn: false),
        (name: "UnsharpMask", key: "radius", defaultValue: 2.5, value: 2.5, min: -1.0, max: 10.0, isOn: false),
        (name: "UnsharpMask", key: "intensity", defaultValue: 0.5, value: 0.5, min: -1.0, max: 2.0, isOn: false),
        
        // 12. Stylize
        (name: "Bloom", key: "radius", defaultValue: 10.0, value: 10.0, min: -10.0, max: 30.0, isOn: false),
        (name: "Bloom", key: "intensity", defaultValue: 0.5, value: 0.5, min: -1.0, max: 2.0, isOn: false),
        (name: "Gloom", key: "radius", defaultValue: 10.0, value: 10.0, min: -10.0, max: 30.0, isOn: false),
        (name: "Gloom", key: "intensity", defaultValue: 0.5, value: 0.5, min: -1.0, max: 2.0, isOn: false),
        (name: "ComicEffect", key: "", defaultValue: 0.0, value: 0.0, min: 0.0, max: 0.0, isOn: false),
        
        // 13. TileEffect
        
        // 14. Transition
        
        // 余白
        (name: "???", key: "alpha", defaultValue: 1.0, value: 1.0, min: 0.0, max: 1.0, isOn: false)
    ]
    
    var filter: Filter {
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
        
        var filter: Filter = { image in return image }
        formatted.forEach { d in
            switch d.name {
            // Blur
            case "BoxBlur":
                if #available(iOS 9.0, *) {
                    let inputRadius: CGFloat = d.option["inputRadius"] ?? BoxBlur.defaultInputRadius
                    // filter = filter |>> BoxBlur.filter(inputRadius: inputRadius)
                    filter = filter |>> BoxBlur.filterWithClampAndCrop(inputRadius: inputRadius)
                }
            case "DiscBlur":
                if #available(iOS 9.0, *) {
                    let inputRadius: CGFloat = d.option["inputRadius"] ?? DiscBlur.defaultInputRadius
                    // filter = filter |>> DiscBlur.filter(inputRadius: inputRadius)
                    filter = filter |>> DiscBlur.filterWithClampAndCrop(inputRadius: inputRadius)
                }
            case "GaussianBlur":
                let inputRadius: CGFloat = d.option["inputRadius"] ?? GaussianBlur.defaultInputRadius
                // filter = filter |>> GaussianBlur.filter(inputRadius: inputRadius)
                filter = filter |>> GaussianBlur.filterWithClampAndCrop(inputRadius: inputRadius)
            case "MedianFilter":
                if #available(iOS 9.0, *) {
                    filter = filter |>> MedianFilter.filter
                }
            case "MotionBlur":
                if #available(iOS 9.0, *) {
                    let inputRadius: CGFloat = d.option["inputRadius"] ?? MotionBlur.defaultInputRadius
                    let inputAngle: CGFloat = d.option["inputAngle"] ?? MotionBlur.defaultInputAngle
                    // filter = filter |>> MotionBlur.filter(inputRadius: inputRadius, inputAngle: inputAngle)
                    filter = filter |>> MotionBlur.filterWithClampAndCrop(inputRadius: inputRadius, inputAngle: inputAngle)
                }
            case "NoiseReduction":
                if #available(iOS 9.0, *) {
                    let inputNoiseLevel: CGFloat = d.option["inputNoiseLevel"] ?? NoiseReduction.defaultInputNoiseLevel
                    let inputSharpness: CGFloat = d.option["inputSharpness"] ?? NoiseReduction.defaultInputSharpness
                    filter = filter |>> NoiseReduction.filter(inputNoiseLevel: inputNoiseLevel, inputSharpness: inputSharpness)
                }
            case "ZoomBlur":
                if #available(iOS 9.0, *) {
                    let inputCenterX = d.option["inputCenterX"] ?? 150.0
                    let inputCenterY: CGFloat = d.option["inputCenterY"] ?? 150.0
                    let inputCenter = XYPosition(x: inputCenterX, y: inputCenterY)
                    let inputRadius = d.option["inputRadius"] ?? ZoomBlur.defaultInputRadius
                    // filter = filter |>> ZoomBlur.filter(inputCenter: inputCenter, inputRadius: inputRadius)
                    filter = filter |>> ZoomBlur.filterWithClampAndCrop(inputCenter: inputCenter, inputRadius: inputRadius)
                }
                
            // ColorAdjustment
            case "ColorClamp":
                let minR: CGFloat = d.option["minR"] ?? ColorClamp.defaultInputMinComponents.r
                let maxR: CGFloat = d.option["maxR"] ?? ColorClamp.defaultInputMaxComponents.r
                let minG: CGFloat = d.option["minG"] ?? ColorClamp.defaultInputMinComponents.g
                let maxG: CGFloat = d.option["maxG"] ?? ColorClamp.defaultInputMaxComponents.g
                let minB: CGFloat = d.option["minB"] ?? ColorClamp.defaultInputMinComponents.b
                let maxB: CGFloat = d.option["maxB"] ?? ColorClamp.defaultInputMaxComponents.b
                let minA: CGFloat = d.option["minA"] ?? ColorClamp.defaultInputMinComponents.a
                let maxA: CGFloat = d.option["maxA"] ?? ColorClamp.defaultInputMaxComponents.a
                let inputMinComponents = RGBAComponents(r: minR, g: minG, b: minB, a: minA)
                let inputMaxComponents = RGBAComponents(r: maxR, g: maxG, b: maxB, a: maxA)
                filter = filter |>> ColorClamp.filter(inputMinComponents: inputMinComponents, inputMaxComponents: inputMaxComponents)
            case "ColorControls":
                let inputSaturation: CGFloat = d.option["saturation"] ?? ColorControls.defaultInputSaturation
                let inputBrightness: CGFloat = d.option["brightness"] ?? ColorControls.defaultInputBrightness
                let inputContrast:   CGFloat = d.option["contrast"] ?? ColorControls.defaultInputContrast
                filter = filter |>> ColorControls.filter(inputSaturation: inputSaturation, inputBrightness: inputBrightness, inputContrast: inputContrast)
            case "ColorMatrix":
                let rVectorR: CGFloat = d.option["rVectorR"] ?? 1.0
                let rVectorG: CGFloat = d.option["rVectorG"] ?? 0.0
                let rVectorB: CGFloat = d.option["rVectorB"] ?? 0.0
                let rVectorA: CGFloat = d.option["rVectorA"] ?? 0.0
                let gVectorR: CGFloat = d.option["gVectorR"] ?? 0.0
                let gVectorG: CGFloat = d.option["gVectorG"] ?? 1.0
                let gVectorB: CGFloat = d.option["gVectorB"] ?? 0.0
                let gVectorA: CGFloat = d.option["gVectorA"] ?? 0.0
                let bVectorR: CGFloat = d.option["bVectorR"] ?? 0.0
                let bVectorG: CGFloat = d.option["bVectorG"] ?? 0.0
                let bVectorB: CGFloat = d.option["bVectorB"] ?? 1.0
                let bVectorA: CGFloat = d.option["bVectorA"] ?? 0.0
                let aVectorR: CGFloat = d.option["aVectorR"] ?? 0.0
                let aVectorG: CGFloat = d.option["aVectorG"] ?? 0.0
                let aVectorB: CGFloat = d.option["aVectorB"] ?? 0.0
                let aVectorA: CGFloat = d.option["aVectorA"] ?? 1.0
                let biasVectorR: CGFloat = d.option["biasVectorR"] ?? 0.0
                let biasVectorG: CGFloat = d.option["biasVectorG"] ?? 0.0
                let biasVectorB: CGFloat = d.option["biasVectorB"] ?? 0.0
                let biasVectorA: CGFloat = d.option["biasVectorA"] ?? 0.0
                let rVector = RGBAComponents(r: rVectorR, g: rVectorG, b: rVectorB, a: rVectorA)
                let gVector = RGBAComponents(r: gVectorR, g: gVectorG, b: gVectorB, a: gVectorA)
                let bVector = RGBAComponents(r: bVectorR, g: bVectorG, b: bVectorB, a: bVectorA)
                let aVector = RGBAComponents(r: aVectorR, g: aVectorG, b: aVectorB, a: aVectorA)
                let biasVector = RGBAComponents(r: biasVectorR, g: biasVectorG, b: biasVectorB, a: biasVectorA)
                filter = filter |>> ColorMatrix.filter(inputRVector: rVector, inputGVector: gVector, inputBVector: bVector, inputAVector: aVector, inputBiasVector: biasVector)
            case "ColorPolynomial":
                let rA0: CGFloat = d.option["rA0"] ?? 0.0
                let rA1: CGFloat = d.option["rA1"] ?? 1.0
                let rA2: CGFloat = d.option["rA2"] ?? 0.0
                let rA3: CGFloat = d.option["rA3"] ?? 0.0
                let gA0: CGFloat = d.option["gA0"] ?? 0.0
                let gA1: CGFloat = d.option["gA1"] ?? 1.0
                let gA2: CGFloat = d.option["gA2"] ?? 0.0
                let gA3: CGFloat = d.option["gA3"] ?? 0.0
                let bA0: CGFloat = d.option["bA0"] ?? 0.0
                let bA1: CGFloat = d.option["bA1"] ?? 1.0
                let bA2: CGFloat = d.option["bA2"] ?? 0.0
                let bA3: CGFloat = d.option["bA3"] ?? 0.0
                let aA0: CGFloat = d.option["aA0"] ?? 0.0
                let aA1: CGFloat = d.option["aA1"] ?? 1.0
                let aA2: CGFloat = d.option["aA2"] ?? 0.0
                let aA3: CGFloat = d.option["aA3"] ?? 0.0
                let rCoefficients = PolynomialCoefficients(a0: rA0, a1: rA1, a2: rA2, a3: rA3)
                let gCoefficients = PolynomialCoefficients(a0: gA0, a1: gA1, a2: gA2, a3: gA3)
                let bCoefficients = PolynomialCoefficients(a0: bA0, a1: bA1, a2: bA2, a3: bA3)
                let aCoefficients = PolynomialCoefficients(a0: aA0, a1: aA1, a2: aA2, a3: aA3)
                filter = filter |>> ColorPolynomial.filter(inputRedCoefficients: rCoefficients, inputGreenCoefficients: gCoefficients, inputBlueCoefficients: bCoefficients, inputAlphaCoefficients: aCoefficients)
            case "ExposureAdjust":
                let inputEV: CGFloat = d.option["inputEV"] ?? ExposureAdjust.defaultInputEV
                filter = filter |>> ExposureAdjust.filter(inputEV: inputEV)
            case "GammaAdjust":
                let inputPower: CGFloat = d.option["inputPower"] ?? GammaAdjust.defaultInputPower
                filter = filter |>> GammaAdjust.filter(inputPower: inputPower)
            case "HueAdjust":
                let inputAngle: CGFloat = d.option["inputAngle"] ?? HueAdjust.defaultInputAngle
                filter = filter |>> HueAdjust.filter(inputAngle: inputAngle)
            case "LinearToSRGBToneCurve":
                filter = filter |>> LinearToSRGBToneCurve.filter
            case "SRGBToneCurveToLinear":
                filter = filter |>> SRGBToneCurveToLinear.filter
            case "TemperatureAndTint":
                let inputNeutralTemp: CGFloat = d.option["inputNeutralTemp"] ?? TemperatureAndTint.defaultInputNeutral.temp
                let inputNeutralTint: CGFloat = d.option["inputNeutralTint"] ?? TemperatureAndTint.defaultInputNeutral.tint
                let targetInputNeutralTemp: CGFloat = d.option["targetInputNeutralTemp"] ?? TemperatureAndTint.defaultTargetInputNeutral.temp
                let targetInputNeutralTint: CGFloat = d.option["targetInputNeutralTint"] ?? TemperatureAndTint.defaultTargetInputNeutral.tint
                let inputNeutral = TempAndTint(temp: inputNeutralTemp, tint: inputNeutralTint)
                let targetInputNeutral = TempAndTint(temp: targetInputNeutralTemp, tint: targetInputNeutralTint)
                filter = filter |>> TemperatureAndTint.filter(inputNeutral: inputNeutral, targetInputNeutral: targetInputNeutral)
            case "ToneCurve":
                let inputPoint0X: CGFloat = d.option["inputPoint0X"] ?? ToneCurve.defaultInputPoint0.x
                let inputPoint0Y: CGFloat = d.option["inputPoint0Y"] ?? ToneCurve.defaultInputPoint0.y
                let inputPoint1X: CGFloat = d.option["inputPoint1X"] ?? ToneCurve.defaultInputPoint1.x
                let inputPoint1Y: CGFloat = d.option["inputPoint1Y"] ?? ToneCurve.defaultInputPoint1.y
                let inputPoint2X: CGFloat = d.option["inputPoint2X"] ?? ToneCurve.defaultInputPoint2.x
                let inputPoint2Y: CGFloat = d.option["inputPoint2Y"] ?? ToneCurve.defaultInputPoint2.y
                let inputPoint3X: CGFloat = d.option["inputPoint3X"] ?? ToneCurve.defaultInputPoint3.x
                let inputPoint3Y: CGFloat = d.option["inputPoint3Y"] ?? ToneCurve.defaultInputPoint3.y
                let inputPoint4X: CGFloat = d.option["inputPoint4X"] ?? ToneCurve.defaultInputPoint4.x
                let inputPoint4Y: CGFloat = d.option["inputPoint4Y"] ?? ToneCurve.defaultInputPoint4.y
                let inputPoint0 = XYOffset(x: inputPoint0X, y: inputPoint0Y)
                let inputPoint1 = XYOffset(x: inputPoint1X, y: inputPoint1Y)
                let inputPoint2 = XYOffset(x: inputPoint2X, y: inputPoint2Y)
                let inputPoint3 = XYOffset(x: inputPoint3X, y: inputPoint3Y)
                let inputPoint4 = XYOffset(x: inputPoint4X, y: inputPoint4Y)
                filter = filter |>> ToneCurve.filter(inputPoint0: inputPoint0, inputPoint1: inputPoint1, inputPoint2: inputPoint2, inputPoint3: inputPoint3, inputPoint4: inputPoint4)
            case "Vibrance":
                let inputAmount: CGFloat? = d.option["inputAmount"]
                filter = filter |>> Vibrance.filter(inputAmount: inputAmount)
            case "WhitePointAdjust":
                // TODO
                let inputColor: CIColor? = nil
                filter = filter |>> WhitePointAdjust.filter(inputColor: inputColor)
                
            // ColorEffect
            case "ColorCrossPolynomial":
                let rA0: CGFloat = d.option["rA0"] ?? ColorCrossPolynomial.defaultInputRedCoefficients.a0
                let rA1: CGFloat = d.option["rA1"] ?? ColorCrossPolynomial.defaultInputRedCoefficients.a1
                let rA2: CGFloat = d.option["rA2"] ?? ColorCrossPolynomial.defaultInputRedCoefficients.a2
                let rA3: CGFloat = d.option["rA3"] ?? ColorCrossPolynomial.defaultInputRedCoefficients.a3
                let rA4: CGFloat = d.option["rA4"] ?? ColorCrossPolynomial.defaultInputRedCoefficients.a4
                let rA5: CGFloat = d.option["rA5"] ?? ColorCrossPolynomial.defaultInputRedCoefficients.a5
                let rA6: CGFloat = d.option["rA6"] ?? ColorCrossPolynomial.defaultInputRedCoefficients.a6
                let rA7: CGFloat = d.option["rA7"] ?? ColorCrossPolynomial.defaultInputRedCoefficients.a7
                let rA8: CGFloat = d.option["rA8"] ?? ColorCrossPolynomial.defaultInputRedCoefficients.a8
                let rA9: CGFloat = d.option["rA9"] ?? ColorCrossPolynomial.defaultInputRedCoefficients.a9
                let gA0: CGFloat = d.option["gA0"] ?? ColorCrossPolynomial.defaultInputGreenCoefficients.a0
                let gA1: CGFloat = d.option["gA1"] ?? ColorCrossPolynomial.defaultInputGreenCoefficients.a1
                let gA2: CGFloat = d.option["gA2"] ?? ColorCrossPolynomial.defaultInputGreenCoefficients.a2
                let gA3: CGFloat = d.option["gA3"] ?? ColorCrossPolynomial.defaultInputGreenCoefficients.a3
                let gA4: CGFloat = d.option["gA4"] ?? ColorCrossPolynomial.defaultInputGreenCoefficients.a4
                let gA5: CGFloat = d.option["gA5"] ?? ColorCrossPolynomial.defaultInputGreenCoefficients.a5
                let gA6: CGFloat = d.option["gA6"] ?? ColorCrossPolynomial.defaultInputGreenCoefficients.a6
                let gA7: CGFloat = d.option["gA7"] ?? ColorCrossPolynomial.defaultInputGreenCoefficients.a7
                let gA8: CGFloat = d.option["gA8"] ?? ColorCrossPolynomial.defaultInputGreenCoefficients.a8
                let gA9: CGFloat = d.option["gA9"] ?? ColorCrossPolynomial.defaultInputGreenCoefficients.a9
                let bA0: CGFloat = d.option["bA0"] ?? ColorCrossPolynomial.defaultInputBlueCoefficients.a0
                let bA1: CGFloat = d.option["bA1"] ?? ColorCrossPolynomial.defaultInputBlueCoefficients.a1
                let bA2: CGFloat = d.option["bA2"] ?? ColorCrossPolynomial.defaultInputBlueCoefficients.a2
                let bA3: CGFloat = d.option["bA3"] ?? ColorCrossPolynomial.defaultInputBlueCoefficients.a3
                let bA4: CGFloat = d.option["bA4"] ?? ColorCrossPolynomial.defaultInputBlueCoefficients.a4
                let bA5: CGFloat = d.option["bA5"] ?? ColorCrossPolynomial.defaultInputBlueCoefficients.a5
                let bA6: CGFloat = d.option["bA6"] ?? ColorCrossPolynomial.defaultInputBlueCoefficients.a6
                let bA7: CGFloat = d.option["bA7"] ?? ColorCrossPolynomial.defaultInputBlueCoefficients.a7
                let bA8: CGFloat = d.option["bA8"] ?? ColorCrossPolynomial.defaultInputBlueCoefficients.a8
                let bA9: CGFloat = d.option["bA9"] ?? ColorCrossPolynomial.defaultInputBlueCoefficients.a9
                let r = CrossPolynomialCoefficients(a0: rA0, a1: rA1, a2: rA2, a3: rA3, a4: rA4, a5: rA5, a6: rA6, a7: rA7, a8: rA8, a9: rA9)
                let g = CrossPolynomialCoefficients(a0: gA0, a1: gA1, a2: gA2, a3: gA3, a4: gA4, a5: gA5, a6: gA6, a7: gA7, a8: gA8, a9: gA9)
                let b = CrossPolynomialCoefficients(a0: bA0, a1: bA1, a2: bA2, a3: bA3, a4: bA4, a5: bA5, a6: bA6, a7: bA7, a8: bA8, a9: bA9)
                filter = filter |>> ColorCrossPolynomial.filter(inputRedCoefficients: r, inputGreenCoefficients: g, inputBlueCoefficients: b)
            case "ColorCube":
                // TODO
                break
            case "ColorCubeWithColorSpace":
                // TODO
                break
            case "CIColorInvert":
                filter = filter |>> ColorInvert.filter
            case "ColorMap":
                // TODO
                break
            case "ColorMonochrome":
                let colorR: CGFloat = d.option["colorR"] ?? 0.6
                let colorG: CGFloat = d.option["colorG"] ?? 0.45
                let colorB: CGFloat = d.option["colorB"] ?? 0.3
                let colorA: CGFloat = d.option["colorA"] ?? 1.0
                let intensity: CGFloat = d.option["intensity"] ?? ColorMonochrome.defaultInputIntensity
                let color = CIColor(red: colorR, green: colorG, blue: colorB, alpha: colorA)
                filter = filter |>> ColorMonochrome.filter(inputColor: color, inputIntensity: intensity)
            case "ColorPosterize":
                let levels: CGFloat = d.option["levels"] ?? ColorPosterize.defaultInputLevels
                filter = filter |>> ColorPosterize.filter(inputLevels: levels)
            case "FalseColor":
                let color0R: CGFloat = d.option["color0R"] ?? 0.3
                let color0G: CGFloat = d.option["color0G"] ?? 0.0
                let color0B: CGFloat = d.option["color0B"] ?? 0.0
                let color0A: CGFloat = d.option["color0A"] ?? 1.0
                let color1R: CGFloat = d.option["color1R"] ?? 1.0
                let color1G: CGFloat = d.option["color1G"] ?? 0.9
                let color1B: CGFloat = d.option["color1B"] ?? 0.8
                let color1A: CGFloat = d.option["color1A"] ?? 1.0
                let color0 = CIColor(red: color0R, green: color0G, blue: color0B, alpha: color0A)
                let color1 = CIColor(red: color1R, green: color1G, blue: color1B, alpha: color1A)
                filter = filter |>> FalseColor.filter(inputColor0: color0, inputColor1: color1)
            case "MaskToAlpha":
                filter = filter |>> MaskToAlpha.filter
            case "MaximumComponent":
                filter = filter |>> MaximumComponent.filter
            case "MinimumComponent":
                filter = filter |>> MinimumComponent.filter
            case "SepiaTone":
                let intensity: CGFloat = d.option["intensity"] ?? SepiaTone.defaultInputIntensity
                filter = filter |>> SepiaTone.filter(inputIntensity: intensity)
            case "Vignette":
                let radius: CGFloat = d.option["radius"] ?? Vignette.defaultInputRadius
                let intensity: CGFloat = d.option["intensity"] ?? Vignette.defaultInputIntensity
                filter = filter |>> Vignette.filter(inputRadius: radius, inputIntensity: intensity)
                
            case "VignetteEffect":
                let centerX: CGFloat = d.option["centerX"] ?? VignetteEffect.defaultInputCenter.x
                let centerY: CGFloat = d.option["centerY"] ?? VignetteEffect.defaultInputCenter.y
                let intensity: CGFloat = d.option["intensity"] ?? VignetteEffect.defaultInputIntensity
                let falloff: CGFloat = d.option["falloff"] ?? VignetteEffect.defaultInputFalloff
                let center = XYPosition(x: centerX, y: centerY)
                filter = filter |>> VignetteEffect.filter(inputCenter: center, inputIntensity: intensity, inputFalloff: falloff)
                
            // Photo Effect
            case "Chrome":
                let alpha = d.option["alpha"]!
                filter = filter |>> PhotoEffect.chrome(alpha: alpha)
            case "Fade":
                let alpha = d.option["alpha"]!
                filter = filter |>> PhotoEffect.fade(alpha: alpha)
            case "Instant":
                let alpha = d.option["alpha"]!
                filter = filter |>> PhotoEffect.instant(alpha: alpha)
            case "Mono":
                let alpha = d.option["alpha"]!
                filter = filter |>> PhotoEffect.mono(alpha: alpha)
            case "Noir":
                let alpha = d.option["alpha"]!
                filter = filter |>> PhotoEffect.noir(alpha: alpha)
            case "Process":
                let alpha = d.option["alpha"]!
                filter = filter |>> PhotoEffect.process(alpha: alpha)
            case "Tonal":
                let alpha = d.option["alpha"]!
                filter = filter |>> PhotoEffect.tonal(alpha: alpha)
            case "Transfer":
                let alpha = d.option["alpha"]!
                filter = filter |>> PhotoEffect.transfer(alpha: alpha)
                
            // HalftoneEffect
            case "CircularScreen":
                let centerX: CGFloat = d.option["centerX"] ?? CircularScreen.defaultInputCenter.x
                let centerY: CGFloat = d.option["centerY"] ?? CircularScreen.defaultInputCenter.y
                let center = XYPosition(x: centerX, y: centerY)
                let width: CGFloat = d.option["width"] ?? CircularScreen.defaultInputWidth
                let sharpness: CGFloat = d.option["sharpness"] ?? CircularScreen.defaultInputSharpness
                filter = filter |>> CircularScreen.filter(inputCenter: center, inputWidth: width, inputSharpness: sharpness)
            case "CMYKHalftone":
                if #available(iOS 9.0, *) {
                    let centerX: CGFloat = d.option["centerX"] ?? CMYKHalftone.defaultInputCenter.x
                    let centerY: CGFloat = d.option["centerY"] ?? CMYKHalftone.defaultInputCenter.y
                    let center = XYPosition(x: centerX, y: centerY)
                    let angle: CGFloat = d.option["angle"] ?? CMYKHalftone.defaultInputAngle
                    let width: CGFloat = d.option["width"] ?? CMYKHalftone.defaultInputWidth
                    let sharpness: CGFloat = d.option["sharpness"] ?? CMYKHalftone.defaultInputSharpness
                    let GCR: CGFloat = d.option["GCR"] ?? CMYKHalftone.defaultInputGCR
                    let UCR: CGFloat = d.option["UCR"] ?? CMYKHalftone.defaultInputUCR
                    filter = filter |>> CMYKHalftone.filter(inputCenter: center, inputAngle: angle, inputWidth: width, inputSharpness: sharpness, inputGCR: GCR, inputUCR: UCR)
                }
            case "DotScreen":
                let centerX: CGFloat = d.option["centerX"] ?? DotScreen.defaultInputCenter.x
                let centerY: CGFloat = d.option["centerY"] ?? DotScreen.defaultInputCenter.y
                let center = XYPosition(x: centerX, y: centerY)
                let angle: CGFloat = d.option["angle"] ?? DotScreen.defaultInputAngle
                let width: CGFloat = d.option["width"] ?? DotScreen.defaultInputWidth
                let sharpness: CGFloat = d.option["sharpness"] ?? DotScreen.defaultInputSharpness
                filter = filter |>> DotScreen.filter(inputCenter: center, inputAngle: angle, inputWidth: width, inputSharpness: sharpness)
            case "HatchedScreen":
                let centerX: CGFloat = d.option["centerX"] ?? HatchedScreen.defaultInputCenter.x
                let centerY: CGFloat = d.option["centerY"] ?? HatchedScreen.defaultInputCenter.y
                let center = XYPosition(x: centerX, y: centerY)
                let angle: CGFloat = d.option["angle"] ?? HatchedScreen.defaultInputAngle
                let width: CGFloat = d.option["width"] ?? HatchedScreen.defaultInputWidth
                let sharpness: CGFloat = d.option["sharpness"] ?? HatchedScreen.defaultInputSharpness
                filter = filter |>> HatchedScreen.filter(inputCenter: center, inputAngle: angle, inputWidth: width, inputSharpness: sharpness)
            case "LineScreen":
                let centerX: CGFloat = d.option["centerX"] ?? LineScreen.defaultInputCenter.x
                let centerY: CGFloat = d.option["centerY"] ?? LineScreen.defaultInputCenter.y
                let center = XYPosition(x: centerX, y: centerY)
                let angle: CGFloat = d.option["angle"] ?? LineScreen.defaultInputAngle
                let width: CGFloat = d.option["width"] ?? LineScreen.defaultInputWidth
                let sharpness: CGFloat = d.option["sharpness"] ?? LineScreen.defaultInputSharpness
                filter = filter |>> LineScreen.filter(inputCenter: center, inputAngle: angle, inputWidth: width, inputSharpness: sharpness)
                
            // Sharpen
            case "SharpenLuminance":
                let sharpness: CGFloat = d.option["sharpness"] ?? SharpenLuminance.defaultInputSharpness
                filter = filter |>> SharpenLuminance.filter(inputSharpness: sharpness)
            case "UnsharpMask":
                let radius: CGFloat = d.option["radius"] ?? UnsharpMask.defaultInputRadius
                let intensity: CGFloat = d.option["intensity"] ?? UnsharpMask.defaultInputIntensity
                filter = filter |>> UnsharpMask.filter(inputRadius: radius, inputIntensity: intensity)
                
            // Stylize
            case "Bloom":
                let radius: CGFloat = d.option["radius"] ?? Bloom.defaultInputRadius
                let intensity: CGFloat = d.option["intensity"] ?? Bloom.defaultInputIntensity
                // filter = filter |>> Bloom.filter(inputRadius: radius, inputIntensity: intensity)
                filter = filter |>> Bloom.filterWithClampAndCrop(inputRadius: radius, inputIntensity: intensity)
            case "Gloom":
                let radius: CGFloat = d.option["radius"] ?? Gloom.defaultInputRadius
                let intensity: CGFloat = d.option["intensity"] ?? Gloom.defaultInputIntensity
                // filter = filter |>> Gloom.filter(inputRadius: radius, inputIntensity: intensity)
                filter = filter |>> Gloom.filterWithClampAndCrop(inputRadius: radius, inputIntensity: intensity)
            case "ComicEffect":
                if #available(iOS 9.0, *) {
                    filter = filter |>> ComicEffect.filter
                }
            case "Crystallize":
                if #available(iOS 9.0, *) {
                    let radius: CGFloat = d.option["radius"] ?? Crystallize.defaultInputRadius
                    let centerX: CGFloat = d.option["centerX"] ?? Crystallize.defaultInputCenter.x
                    let centerY: CGFloat = d.option["centerY"] ?? Crystallize.defaultInputCenter.y
                    let center = XYPosition(x: centerX, y: centerY)
                    // filter = filter |>> Crystallize.filter(inputRadius: radius, inputCenter: center)
                    filter = filter |>> Crystallize.filterWithClampAndCrop(inputRadius: radius, inputCenter: center)
                }
            case "Edges":
                if #available(iOS 9.0, *) {
                    let intensity: CGFloat = d.option["intensity"] ?? Edges.defaultInputIntensity
                    filter = filter |>> Edges.filter(inputIntensity: intensity)
                }
            case "EdgeWork":
                if #available(iOS 9.0, *) {
                    let radius: CGFloat = d.option["radius"] ?? EdgeWork.defaultInputRadius
                    // filter = filter |>> EdgeWork.filter(inputRadius: radius)
                    filter = filter |>> EdgeWork.filterWithClampAndCrop(inputRadius: radius)
                }
            case "HexagonalPixellate":
                if #available(iOS 9.0, *) {
                    let centerX: CGFloat = d.option["centerX"] ?? HexagonalPixellate.defaultInputCenter.x
                    let centerY: CGFloat = d.option["centerY"] ?? HexagonalPixellate.defaultInputCenter.y
                    let center = XYPosition(x: centerX, y: centerY)
                    let scale: CGFloat = d.option["scale"] ?? HexagonalPixellate.defaultInputScale
                    // filter = filter |>> HexagonalPixellate.filter(inputCenter: center, inputScale: scale)
                    filter = filter |>> HexagonalPixellate.filterWithClampAndCrop(inputCenter: center, inputScale: scale)
                }
            case "HighlightShadowAdjust":
                let highlightAmount: CGFloat = d.option["highlightAmount"] ?? HighlightShadowAdjust.defaultInputHighlightAmount
                let shadowAmount: CGFloat = d.option["shadowAmount"] ?? HighlightShadowAdjust.defaultInputShadowAmount
                filter = filter |>> HighlightShadowAdjust.filter(inputHighlightAmount: highlightAmount, inputShadowAmount: shadowAmount)
            case "Pixellate":
                let centerX: CGFloat = d.option["centerX"] ?? Pixellate.defaultInputCenter.x
                let centerY: CGFloat = d.option["centerY"] ?? Pixellate.defaultInputCenter.y
                let center = XYPosition(x: centerX, y: centerY)
                let scale: CGFloat = d.option["scale"] ?? Pixellate.defaultInputScale
                // filter = filter |>> Pixellate.filter(inputCenter: center, inputScale: scale)
                filter = filter |>> Pixellate.filterWithClampAndCrop(inputCenter: center, inputScale: scale)
            case "Pointillize":
                if #available(iOS 9.0, *) {
                    let radius: CGFloat = d.option["radius"] ?? Pointillize.defaultInputRadius
                    let centerX: CGFloat = d.option["centerX"] ?? Pointillize.defaultInputCenter.x
                    let centerY: CGFloat = d.option["centerY"] ?? Pointillize.defaultInputCenter.y
                    let center = XYPosition(x: centerX, y: centerY)
                    // filter = filter |>> Pointillize.filter(inputRadius: radius, inputCenter: center)
                    filter = filter |>> Pointillize.filterWithClampAndCrop(inputRadius: radius, inputCenter: center)
                }
            case "BumpDistortion":
                let centerX: CGFloat = d.option["centerX"] ?? BumpDistortion.defaultInputCenter.x
                let centerY: CGFloat = d.option["centerY"] ?? BumpDistortion.defaultInputCenter.y
                let center = XYPosition(x: centerX, y: centerY)
                let radius: CGFloat = d.option["radius"] ?? BumpDistortion.defaultInputRadius
                let scale: CGFloat = d.option["scale"] ?? BumpDistortion.defaultInputScale
                // filter = filter |>> BumpDistortion.filter(inputCenter: center, inputRadius: radius, inputScale: scale)
                filter = filter |>> BumpDistortion.filterWithClampAndCrop(inputCenter: center, inputRadius: radius, inputScale: scale)
            case "HoleDistortion":
                let centerX: CGFloat = d.option["centerX"] ?? HoleDistortion.defaultInputCenter.x
                let centerY: CGFloat = d.option["centerY"] ?? HoleDistortion.defaultInputCenter.y
                let center = XYPosition(x: centerX, y: centerY)
                let radius: CGFloat = d.option["radius"] ?? HoleDistortion.defaultInputRadius
                // filter = filter |>> HoleDistortion.filter(inputCenter: center, inputRadius: radius)
                filter = filter |>> HoleDistortion.filterWithClampAndCrop(inputCenter: center, inputRadius: radius)
            case "LightTunnel":
                let centerX: CGFloat = d.option["centerX"] ?? LightTunnel.defaultInputCenter.x
                let centerY: CGFloat = d.option["centerY"] ?? LightTunnel.defaultInputCenter.y
                let center = XYPosition(x: centerX, y: centerY)
                let rotation: CGFloat = d.option["rotation"] ?? LightTunnel.defaultInputRotation
                let radius: CGFloat = d.option["radius"] ?? LightTunnel.defaultInputRadius
                // filter = filter |>> LightTunnel.filter(inputCenter: center, inputRotation: rotation, inputRadius: radius)
                filter = filter |>> LightTunnel.filterWithClampAndCrop(inputCenter: center, inputRotation: rotation, inputRadius: radius)
            case "PinchDistortion":
                let centerX: CGFloat = d.option["centerX"] ?? PinchDistortion.defaultInputCenter.x
                let centerY: CGFloat = d.option["centerY"] ?? PinchDistortion.defaultInputCenter.y
                let center = XYPosition(x: centerX, y: centerY)
                let radius: CGFloat = d.option["radius"] ?? PinchDistortion.defaultInputRadius
                let scale: CGFloat = d.option["scale"] ?? PinchDistortion.defaultInputScale
                // filter = filter |>> PinchDistortion.filter(inputCenter: center, inputRadius: radius, inputScale: scale)
                filter = filter |>> PinchDistortion.filterWithClampAndCrop(inputCenter: center, inputRadius: radius, inputScale: scale)
            case "TorusLensDistortion":
                if #available(iOS 9.0, *) {
                    let centerX: CGFloat = d.option["centerX"] ?? TorusLensDistortion.defaultInputCenter.x
                    let centerY: CGFloat = d.option["centerY"] ?? TorusLensDistortion.defaultInputCenter.y
                    let center = XYPosition(x: centerX, y: centerY)
                    let radius: CGFloat = d.option["radius"] ?? TorusLensDistortion.defaultInputRadius
                    let width: CGFloat = d.option["width"] ?? TorusLensDistortion.defaultInputWidth
                    let refraction: CGFloat = d.option["refraction"] ?? TorusLensDistortion.defaultInputRefraction
                    // filter = filter |>> TorusLensDistortion.filter(inputCenter: center, inputRadius: radius, inputWidth: width, inputRefraction: refraction)
                    filter = filter |>> TorusLensDistortion.filterWithClampAndCrop(inputCenter: center, inputRadius: radius, inputWidth: width, inputRefraction: refraction)
                }
            case "TwirlDistortion":
                let centerX: CGFloat = d.option["centerX"] ?? TwirlDistortion.defaultInputCenter.x
                let centerY: CGFloat = d.option["centerY"] ?? TwirlDistortion.defaultInputCenter.y
                let center = XYPosition(x: centerX, y: centerY)
                let radius: CGFloat = d.option["radius"] ?? TwirlDistortion.defaultInputRadius
                let angle: CGFloat = d.option["angle"] ?? TwirlDistortion.defaultInputAngle
                // filter = filter |>> TwirlDistortion.filter(inputCenter: center, inputRadius: radius, inputAngle: angle)
                filter = filter |>> TwirlDistortion.filterWithClampAndCrop(inputCenter: center, inputRadius: radius, inputAngle: angle)
            case "VortexDistortion":
                let centerX: CGFloat = d.option["centerX"] ?? VortexDistortion.defaultInputCenter.x
                let centerY: CGFloat = d.option["centerY"] ?? VortexDistortion.defaultInputCenter.y
                let center = XYPosition(x: centerX, y: centerY)
                let radius: CGFloat = d.option["radius"] ?? VortexDistortion.defaultInputRadius
                let angle: CGFloat = d.option["angle"] ?? VortexDistortion.defaultInputAngle
                // filter = filter |>> VortexDistortion.filter(inputCenter: center, inputRadius: radius, inputAngle: angle)
                filter = filter |>> VortexDistortion.filterWithClampAndCrop(inputCenter: center, inputRadius: radius, inputAngle: angle)
            case "TiltShiftCircle":
                let blurType: TiltShiftCircle.BlurType
                if let blurRadius = d.option["blurRadius"] {
                    if let _ = d.option["gaussian"] {
                        blurType = .gaussian(radius: blurRadius)
                    } else if let _ = d.option["box"] {
                        blurType = .box(radius: blurRadius)
                    } else if let _ = d.option["disc"] {
                        blurType = .disc(radius: blurRadius)
                    } else if let _ = d.option["motion"] {
                        blurType = .motion(radius: blurRadius, angle: 0.0)
                    } else if let _ = d.option["zoom"] {
                        blurType = .zoom(radius: blurRadius)
                    } else {
                        blurType = .gaussian(radius: blurRadius)
                    }
                } else {
                    blurType = TiltShiftCircle.defaultBlurType
                }
                let center: XYPosition?
                if let x = d.option["centerX"], let y = d.option["centerY"] {
                    center = XYPosition(x: x, y: y)
                } else {
                    center = nil
                }
                filter = filter |>> TiltShiftCircle.filter(blurType: blurType, center: center, radius0: d.option["radius0"], radius1: d.option["radius1"])
            case "TiltShiftLine":
                let blurRadius: CGFloat = d.option["blurRadius"] ?? 20.0
                let center: XYPosition?
                if let x = d.option["centerX"], let y = d.option["centerY"] {
                    center = XYPosition(x: x, y: y)
                } else {
                    center = nil
                }
                filter = filter |>> TiltShiftLine.filter(center: center, blurRadius: blurRadius)
            default:
                break
            }
        }
        return filter
    }
        
    weak var filterListTableViewDelegate: CIFilterListTableViewDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        commonInit()
    }
    
    private func commonInit() {
        register(CIFilterCell.nibForRegisterTableView(), forCellReuseIdentifier: CIFilterCell.defaultReuseIdentifier)
        delegate = self
        dataSource = self
        isEditing = true
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

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    private var movingData: FilterCellData?

    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        let si = sourceIndexPath.row
        let di = proposedDestinationIndexPath.row
        let at: Int
        if let movingData = movingData, let a = data.index(where: { d in return d.name == movingData.name }) {
            at = a
        } else {
            at = si
        }
        let d = data.remove(at: at)
        data.insert(d, at: di)
        movingData = d
        filterListTableViewDelegate?.filterDidUpdate(tableView: self)
        return proposedDestinationIndexPath
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // これが実装されていないと並び換えの右側の 三 みたいなやつが出てこない。
        movingData = nil
        tableView.reloadData()
    }
    
    // MARK:- CIFilterCellDelegate
    
    func touchUpInsideDefaultButton(cell: CIFilterCell) {
        guard let index = indexPath(for: cell)?.row else { return }
        print(index)
    }
    
    func valueChangedSlider(cell: CIFilterCell, value: Float) {
        guard let index = indexPath(for: cell)?.row else { return }
        data[index].value = value
        filterListTableViewDelegate?.filterDidUpdate(tableView: self)
    }
    
    func valueChangedSwitch(cell: CIFilterCell, isOn: Bool) {
        guard let index = indexPath(for: cell)?.row else { return }
        data[index].isOn = isOn
        filterListTableViewDelegate?.filterDidUpdate(tableView: self)
    }
    
}
