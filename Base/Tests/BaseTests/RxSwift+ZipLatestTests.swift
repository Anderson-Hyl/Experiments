import Base
import Foundation
import RxRelay
import RxSwift
import XCTest

class ZipLatestTests: XCTestCase {
    struct ResultItem: Equatable, CustomStringConvertible {
        var description: String {
            "(\(a),\(b))"
        }
        
        let a: Int
        let b: Int
    }
    
    func testSource1Longer() {
        let source1 = Observable.from([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
        let source2 = Observable.from([1, 2, 3, 4])
        
        var result = [ResultItem]()
        _ = Observable.zipLatest(source1, source2).subscribe(onNext: { element in
            result.append(ResultItem(a: element.0, b: element.1))
        })
        
        var expectedResult = [ResultItem]()
        _ = Observable.zip(source1, source2).subscribe(onNext: { element in
            expectedResult.append(ResultItem(a: element.0, b: element.1))
        })
        
        XCTAssertEqual(result, expectedResult)
    }
    
    func testSource2Longer() {
        let source1 = Observable.from([1, 2, 3, 4])
        let source2 = Observable.from([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
        
        var result = [ResultItem]()
        _ = Observable.zipLatest(source1, source2).subscribe(onNext: { element in
            result.append(ResultItem(a: element.0, b: element.1))
        })
        
        var expectedResult = [ResultItem]()
        _ = Observable.zip(source1, source2).subscribe(onNext: { element in
            expectedResult.append(ResultItem(a: element.0, b: element.1))
        })
        
        XCTAssertEqual(result, expectedResult)
    }
    
    func testSource1AndSource2EqualLength() {
        let source1 = Observable.from([1, 2, 3, 4])
        let source2 = Observable.from([5, 6, 7, 8])
        
        var result = [ResultItem]()
        _ = Observable.zipLatest(source1, source2).subscribe(onNext: { element in
            result.append(ResultItem(a: element.0, b: element.1))
        })
        
        var expectedResult = [ResultItem]()
        _ = Observable.zip(source1, source2).subscribe(onNext: { element in
            expectedResult.append(ResultItem(a: element.0, b: element.1))
        })
        
        XCTAssertEqual(result, expectedResult)
    }
    
    func testSource1LowerEventRate() {
        let source1 = PublishRelay<Int>()
        let source2 = PublishRelay<Int>()
        
        var result = [ResultItem]()
        _ = Observable.zipLatest(source1, source2).subscribe(onNext: { element in
            result.append(ResultItem(a: element.0, b: element.1))
        })
        
        let expectedResult = [
            ResultItem(a: 0, b: 0),
            ResultItem(a: 1, b: 4),
            ResultItem(a: 2, b: 5),
            ResultItem(a: 3, b: 8),
            ResultItem(a: 4, b: 12)
        ]
        
        source1.accept(0)
        
        source2.accept(0)
        source2.accept(1)
        source2.accept(2)
        source2.accept(3)
        source2.accept(4)
        
        source1.accept(1)
        source1.accept(2)
        
        source2.accept(5)
        source2.accept(6)
        source2.accept(7)
        source2.accept(8)
        
        source1.accept(3)
        
        source2.accept(9)
        source2.accept(10)
        source2.accept(11)
        source2.accept(12)
        
        source1.accept(4)
        
        XCTAssertEqual(result, expectedResult)
    }
    
    func testSource2LowerEventRate() {
        let source1 = PublishRelay<Int>()
        let source2 = PublishRelay<Int>()
        
        var result = [ResultItem]()
        _ = Observable.zipLatest(source1, source2).subscribe(onNext: { element in
            result.append(ResultItem(a: element.0, b: element.1))
        })
        
        let expectedResult = [
            ResultItem(a: 0, b: 0),
            ResultItem(a: 2, b: 1),
            ResultItem(a: 6, b: 2),
            ResultItem(a: 10, b: 3)
        ]
        
        source1.accept(0)
        
        source2.accept(0)
        
        source1.accept(1)
        source1.accept(2)
        
        source2.accept(1)
        
        source1.accept(3)
        source1.accept(4)
        source1.accept(5)
        source1.accept(6)
        
        source2.accept(2)
        
        source1.accept(7)
        source1.accept(8)
        source1.accept(9)
        source1.accept(10)
        
        source2.accept(3)
        
        XCTAssertEqual(result, expectedResult)
    }
}
