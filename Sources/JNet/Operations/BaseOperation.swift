import Foundation

// MARK: - OperationState

enum OperationState: Equatable {
    case ready, executing, finished

    // MARK: Key Paths

    func keyPath() -> String {
        switch self {
        case .ready:
            return "isReady"
        case .executing:
            return "isExecuting"
        case .finished:
            return "isFinished"
        }
    }
}

// MARK: - BaseOperation: Operation

open class BaseOperation: Operation {

    // MARK: Properties

    var state: OperationState = .ready {
        // send KVO triggers for state and anything that observes isReady, isExecuting, etc.
        willSet {
            willChangeValue(forKey: newValue.keyPath())
            willChangeValue(forKey: state.keyPath())
        }
        didSet {
            didChangeValue(forKey: oldValue.keyPath())
            didChangeValue(forKey: state.keyPath())
        }
    }

    // MARK: Operation

    override public var isReady: Bool { return super.isReady && state == .ready }
    override public var isExecuting: Bool { return state == .executing }
    override public var isFinished: Bool { return state == .finished }
    override public var isAsynchronous: Bool { return false }
}
