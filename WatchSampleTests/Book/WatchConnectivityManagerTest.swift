//
//  WatchConnectivityManagerTest.swift
//  WatchSample
//
//  Created by Koichi Kishimoto on 2024/10/14.
//

// WatchConnectivityManagerTests.swift

import XCTest
import WatchConnectivity
@testable import WatchSample // あなたのアプリのモジュール名に置き換えてください

class WatchConnectivityManagerTests: XCTestCase {
    var connectivityManager: WatchConnectivityManager!
    var mockSession: MockWCSession!
    var mockDataController: MockDataController!

    override func setUp() {
        super.setUp()
        mockSession = MockWCSession()
        mockDataController = MockDataController()
        connectivityManager = WatchConnectivityManager(session: mockSession)
    }

    override func tearDown() {
        connectivityManager = nil
        mockSession = nil
        super.tearDown()
    }

    func testSendDataWhenReachable() {
        // Arrange
        mockSession.isReachable = true
        let testData = "Test Data".data(using: .utf8)!

        // Act
        connectivityManager.sendData(testData)

        // Assert
        XCTAssertEqual(mockSession.sentMessages.count, 1)
        XCTAssertEqual(mockSession.sentMessages.first?["data"] as? Data, testData)
    }

    func testSendDataWhenNotReachable() {
        // Arrange
        mockSession.isReachable = false
        let testData = "Test Data".data(using: .utf8)!

        // Act
        connectivityManager.sendData(testData)

        // Assert
        XCTAssertEqual(mockSession.applicationContext["data"] as? Data, testData)
    }

    func testSessionActivation() {
        // Act
        connectivityManager = WatchConnectivityManager(session: mockSession)

        // Assert
        XCTAssertTrue(mockSession.didActivateCalled)
        XCTAssertEqual(mockSession.activationState, .activated)
    }

    func testReachabilityChange() {
        // Arrange
        connectivityManager = WatchConnectivityManager(session: mockSession)

        // Act
        mockSession.isReachable = true
        connectivityManager.sessionReachabilityDidChange(WCSession.default)

        // Assert
        XCTAssertTrue(connectivityManager.isReachable)
    }

    func testHandleReceivedData() async {
        // Arrange
        let testData = "Test Data".data(using: .utf8)!
        let testMessage: [String: Any] = ["data": testData]

        // Act
        await connectivityManager.session(WCSession.default, didReceiveMessage: testMessage)

        // Assert
        XCTAssertEqual(mockDataController.receivedData, testData)
    }
}
