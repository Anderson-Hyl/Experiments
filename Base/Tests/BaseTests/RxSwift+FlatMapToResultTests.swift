import Base
import Foundation
import RxCocoa
import RxSwift
import XCTest

class FlatMapToResultTests: XCTestCase {
    enum MyError: Error {
        case error1, error2
    }
    
    typealias MyResult = Result<Int, MyError>
    
    func testMapToResultSuccess() {
        let sourceRaw = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        let source = Observable.from(sourceRaw)
        
        var result = [MyResult]()
        _ = source.mapToResult().map { item -> MyResult in
            item.mapError { _ in .error1 }
        }
        .subscribe(onNext: { element in
            result.append(element)
        })
        
        let expectedResult = sourceRaw.map { MyResult.success($0) }
        
        XCTAssertEqual(result, expectedResult)
    }
    
    func testMapToResultError() {
        let sourceRaw = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        let source = Observable.from(sourceRaw).map { item -> Int in
            if item < 5 {
                return item
            }
            throw MyError.error2
        }
        
        var result = [MyResult]()
        _ = source.mapToResult().map { item -> MyResult in
            item.mapError {
                if let error = $0 as? MyError {
                    return error
                }
                return .error1
            }
        }.subscribe(onNext: { element in
            result.append(element)
        })
        
        let expectedResult = sourceRaw.prefix(5).map { item -> MyResult in
            if item < 5 {
                return MyResult.success(item)
            }
            return MyResult.failure(.error2)
        }
        
        XCTAssertEqual(result, expectedResult)
    }
    
    func testFlatMapToResultSuccess() {
        let workRaw = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        let work = Observable.from(workRaw)
        
        var result = [MyResult]()
        
        _ = Observable<Int>.just(0)
            .flatMapToResult { _ in work }
            .map { item -> MyResult in
                item.mapError { _ in .error1 }
            }
            .subscribe(onNext: { element in
                result.append(element)
            }, onError: { _ in
                XCTFail("Stream termination by error!")
            })
        
        let expectedResult = workRaw.map { MyResult.success($0) }
        
        XCTAssertEqual(result, expectedResult)
    }
    
    func testFlatMapToResultError() {
        let workRaw = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        let work = Observable.from(workRaw).map { item -> Int in
            if item < 5 {
                return item
            }
            throw MyError.error2
        }
        
        var result = [MyResult]()
        _ = Observable<Int>.just(0)
            .flatMapToResult { _ in work }
            .map { item -> MyResult in
                item.mapError {
                    if let error = $0 as? MyError {
                        return error
                    }
                    return .error1
                }
            }
            .subscribe(onNext: { element in
                result.append(element)
            }, onError: { _ in
                XCTFail("Stream termination by error!")
            })
        
        let expectedResult = workRaw.prefix(5).map { item -> MyResult in
            if item < 5 {
                return MyResult.success(item)
            }
            return MyResult.failure(.error2)
        }
        
        XCTAssertEqual(result, expectedResult)
    }
    
    func testFlatMapToResultError2() {
        let requests = [1, 2, 3]
        let workRaw = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        let work = Observable.from(workRaw).map { item -> Int in
            if item < 5 {
                return item
            }
            throw MyError.error2
        }
        
        var result = [MyResult]()
        _ = Observable.from(requests)
            .flatMapToResult { _ in work }
            .map { item -> MyResult in
                item.mapError {
                    if let error = $0 as? MyError {
                        return error
                    }
                    return .error1
                }
            }
            .subscribe(onNext: { element in
                result.append(element)
            }, onError: { _ in
                XCTFail("Stream termination by error!")
            })
        
        XCTAssertEqual(result.count, 15)
    }
    
    func testFlatMapToLatestResultSuccess() {
        let workRaw = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        let work = Observable.from(workRaw)
        
        var result = [MyResult]()
        
        _ = Observable<Int>.just(0)
            .flatMapLatestToResult { _ in work }
            .map { item -> MyResult in
                item.mapError { _ in .error1 }
            }
            .subscribe(onNext: { element in
                result.append(element)
            }, onError: { _ in
                XCTFail("Stream termination by error!")
            })
        
        let expectedResult = workRaw.map { MyResult.success($0) }
        
        XCTAssertEqual(result, expectedResult)
    }
    
    func testFlatMapLatestToResultError() {
        let workRaw = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        let work = Observable.from(workRaw).map { item -> Int in
            if item < 5 {
                return item
            }
            throw MyError.error2
        }
        
        var result = [MyResult]()
        _ = Observable<Int>.just(0)
            .flatMapLatestToResult { _ in work }
            .map { item -> MyResult in
                item.mapError {
                    if let error = $0 as? MyError {
                        return error
                    }
                    return .error1
                }
            }
            .subscribe(onNext: { element in
                result.append(element)
            }, onError: { _ in
                XCTFail("Stream termination by error!")
            })
        
        let expectedResult = workRaw.prefix(5).map { item -> MyResult in
            if item < 5 {
                return MyResult.success(item)
            }
            return MyResult.failure(.error2)
        }
        
        XCTAssertEqual(result, expectedResult)
    }
    
    func testFlatMapLatestToResultError2() {
        let requests = [1, 2, 3]
        let workRaw = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        let work = Observable.from(workRaw).map { item -> Int in
            if item < 5 {
                return item
            }
            throw MyError.error2
        }
        
        var result = [MyResult]()
        _ = Observable.from(requests)
            .flatMapLatestToResult { _ in work }
            .map { item -> MyResult in
                item.mapError {
                    if let error = $0 as? MyError {
                        return error
                    }
                    return .error1
                }
            }
            .subscribe(onNext: { element in
                result.append(element)
            }, onError: { _ in
                XCTFail("Stream termination by error!")
            })
        
        XCTAssertEqual(result.count, 7)
    }
    
    func testAsDriverWithSuccess() {
        let sourceRaw = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        let source = Observable.from(sourceRaw)
        
        var result = [MyResult]()
        _ = source
            .mapToResult()
            .asDriver()
            .map { item -> MyResult in
                item.mapError { _ in .error1 }
            }
            .asObservable()
            .subscribe(onNext: { element in
                result.append(element)
            }, onError: { _ in
                XCTFail("Stream termination by error!")
            })
        
        let expectedResult = sourceRaw.map { MyResult.success($0) }
        
        XCTAssertEqual(result, expectedResult)
    }
    
    func testAsDriverWithError() {
        let requests = [15, 16]
        let workRaw = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        let work = Observable.from(workRaw)
        
        var result = [MyResult]()
        
        _ = Observable.from(requests)
            .map { item -> Int in
                if item == 15 {
                    return item
                }
                throw MyError.error2
            }
            .flatMapToResult { _ in work }
            .asDriver()
            .map { item -> MyResult in
                item.mapError {
                    if let error = $0 as? MyError {
                        return error
                    }
                    return .error1
                }
            }
            .asObservable()
            .subscribe(onNext: { element in
                result.append(element)
            }, onError: { _ in
                XCTFail("Stream termination by error!")
            })
        
        let expectedResult = [MyResult.success(workRaw.first!), MyResult.failure(.error2)]
        
        XCTAssertEqual(result, expectedResult)
    }
}
