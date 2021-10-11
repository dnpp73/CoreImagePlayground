// respect: https://github.com/ReactiveX/RxSwift/blob/main/RxCocoa/RxCocoa.swift
import Foundation

func castOrFatalError<T>(_ value: Any?, message: String) -> T {
    guard let result = value as? T else {
        fatalError(message)
    }
    return result
}

func castOrFatalError<T>(_ value: Any?) -> T {
    guard let result = value as? T else {
        fatalError("Failure converting from \(String(describing: value)) to \(T.self)")
    }
    return result
}
