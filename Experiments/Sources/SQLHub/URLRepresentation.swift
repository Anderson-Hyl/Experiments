
import Foundation
import StructuredQueriesCore

extension URL {
    public struct URLRepresentation: QueryBindable {
        public typealias QueryOutput = URL
        public var queryOutput: URL
        public init(queryOutput: URL) {
            self.queryOutput = queryOutput
        }
        public init(decoder: inout some QueryDecoder) throws {
            let urlString = try String(decoder: &decoder)
            guard let url = URL(string: urlString) else {
                throw URLError(.badURL)
            }
            self.init(queryOutput: url)
        }
        
        public var queryBinding: QueryBinding {
            .text(queryOutput.absoluteString)
        }
    }
}
