import Foundation

/// Base protocol for all use cases
/// Use cases encapsulate business logic and are independent of external frameworks
public protocol UseCase {
    associatedtype Input
    associatedtype Output
    
    func execute(_ input: Input) async throws -> Output
}

/// Protocol for use cases that don't require input parameters
public protocol NoInputUseCase {
    associatedtype Output
    
    func execute() async throws -> Output
}