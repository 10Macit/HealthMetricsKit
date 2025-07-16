import Foundation

/// Errors that can occur when accessing health data
public enum HealthDataError: Error, LocalizedError {
    /// Permission to access health data was denied
    case permissionDenied
    
    /// Health data is not available on this device
    case healthDataNotAvailable
    
    /// Failed to fetch data from the health store
    case dataFetchFailed(Error)
    
    /// The received data is invalid or corrupted
    case invalidData
    
    /// User-friendly error descriptions
    public var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Health data access permission was denied"
        case .healthDataNotAvailable:
            return "Health data is not available on this device"
        case .dataFetchFailed(let error):
            return "Failed to fetch health data: \(error.localizedDescription)"
        case .invalidData:
            return "Invalid health data received"
        }
    }
}