import Foundation

struct DataUsageData {
    /// A data series for the bars.
    struct Series: Identifiable {
        /// Data Group.
        let category: String

        /// Size of data in gigabytes?
        let size: Double

        /// The identifier for the series.
        var id: String { category }
    }

    static let example: [Series] = [
        .init(category: "Apps", size: 61.6),
        .init(category: "Photos", size: 8.2),
        .init(category: "iOS", size: 5.7),
        .init(category: "System Data", size: 2.6)
    ]
}
