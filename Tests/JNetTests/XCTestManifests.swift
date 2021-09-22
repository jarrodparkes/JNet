import XCTest

#if !canImport(ObjectiveC)
/// Describes all tests to run for unit testing.
/// - Returns: An array of test cases to run.
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(JNetTests.allTests)
    ]
}
#endif
