import Base
import XCTest

final class FreeFuncsTests: XCTestCase {
    func testAngleConversions() throws {
        XCTAssertEqual(degreesToRadians(Float(floatLiteral: 180)), .pi)
        XCTAssertEqual(degreesToRadians(Double(floatLiteral: 180)), .pi)
        XCTAssertEqual(degreesToRadians(CGFloat(floatLiteral: 180)), .pi)
        
        XCTAssertEqual(radiansToDegrees(Float.pi), 180)
        XCTAssertEqual(radiansToDegrees(Double.pi), 180)
        XCTAssertEqual(radiansToDegrees(CGFloat.pi), 180)
    }
}
