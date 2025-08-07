import Base
import XCTest

final class DateValueCodableStrategyTests: XCTestCase {
    func testCompletedData() throws {
        let jsonString = "{\"endDate\":\"2025-04-20\",\"id\":\"1\",\"startDate\":\"2025-04-20\"}"
        
        try codable(with: jsonString)
    }
    
    func testUncompletedData() throws {
        let jsonString = "{\"id\":\"1\",\"startDate\":\"2025-04-20\"}"
        
        try codable(with: jsonString)
    }
    
    private func codable(with jsonString: String) throws {
        let jsonData = jsonString.data(using: .utf8)
        
        XCTAssertNotNil(jsonData, "invalid data")
        
        let jsonDecoder = JSONDecoder()
        
        let trainingPlan = try jsonDecoder.decode(BackendSuuntoPlusTrainingPlan.self, from: jsonData!)
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .sortedKeys
        
        let outputData = try jsonEncoder.encode(trainingPlan)
        
        let outputString = String(data: outputData, encoding: .utf8)
        
        XCTAssertEqual(jsonString, outputString)
    }
}

fileprivate struct BackendSuuntoPlusTrainingPlan: Codable {
    var id: String
    
    @DateFormatted<DayDateStrategy>
    var startDate: Date
    
    @DateOptionalFormatted<DayDateStrategy>
    var endDate: Date?
    
    enum CodingKeys: CodingKey {
        case id
        case startDate
        case endDate
    }
    
    init(id: String, startDate: Date, endDate: Date?) {
        self.id = id
        // Make sure to use `DateFormatted` if custom initialize method
        self._startDate = .init(wrappedValue: startDate)
        self._endDate = .init(wrappedValue: endDate)
    }
}
