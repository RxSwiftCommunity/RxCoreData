//
//  NSManagedObjectContext+ObserveContextTests.swift
//  RxCoreData_Tests
//
//  Created by Krunoslav Zaher on 7/28/18.
//  Copyright © 2018 Krunoslav Zaher. All rights reserved.
//

import Foundation
import XCTest
import RxSwift
import RxCoreData
import CoreData

class NSManagedObjectContext_ObserveContextTests: XCTestCase {

    var testMOC: NSManagedObjectContext!
    var disposeBag: DisposeBag!

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
        testMOC = NSManagedObjectContext.test
    }

    override func tearDown() {
        testMOC = nil
        disposeBag = nil
        super.tearDown()
    }

    // MARK: - Tests

    func testObserveContext_insertion() {
        let insertionExpectation = expectation(description: "Expect to get insert event")

        testMOC.rx.changes().take(1).subscribe(onNext: { changeEvent in
            XCTAssertEqual(changeEvent.deleted.count, 0)
            XCTAssertEqual(changeEvent.updated.count, 0)
            XCTAssertEqual(changeEvent.refreshed.count, 0)

            XCTAssertEqual(changeEvent.inserted.count, 1)
            let insertedGroup = changeEvent.inserted.first as? Group
            XCTAssertEqual(insertedGroup?.name, "Test group")

            insertionExpectation.fulfill()
        }).disposed(by: disposeBag)

        let group = Group.new(in: testMOC)
        group.name = "Test group"

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testObserveContext_update() {
        let insertionExpectation = expectation(description: "Expect to get update event")

        let group = Group.new(in: testMOC)
        group.name = "Test group"
        try! testMOC.save()

        testMOC.rx.changes().take(1).subscribe(onNext: { changeEvent in
            XCTAssertEqual(changeEvent.inserted.count, 0)
            XCTAssertEqual(changeEvent.deleted.count, 0)
            XCTAssertEqual(changeEvent.refreshed.count, 0)

            XCTAssertEqual(changeEvent.updated.count, 1)
            let updatedGroup = changeEvent.updated.first as? Group
            XCTAssertEqual(updatedGroup?.name, "Updated test group")

            insertionExpectation.fulfill()
        }).disposed(by: disposeBag)

        group.name = "Updated test group"

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testObserveContext_delete() {
        let insertionExpectation = expectation(description: "Expect to get delete event")

        let group = Group.new(in: testMOC)
        group.name = "Test group"
        try! testMOC.save()

        testMOC.rx.changes().take(1).subscribe(onNext: { changeEvent in
            XCTAssertEqual(changeEvent.inserted.count, 0)
            XCTAssertEqual(changeEvent.updated.count, 0)
            XCTAssertEqual(changeEvent.refreshed.count, 0)

            XCTAssertEqual(changeEvent.deleted.count, 1)
            let deletedGroup = changeEvent.deleted.first as? Group
            XCTAssertEqual(deletedGroup?.name, "Test group")

            insertionExpectation.fulfill()
        }).disposed(by: disposeBag)

        testMOC.delete(group)

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testObserveContext_refresh() {
        let insertionExpectation = expectation(description: "Expect to get refresh event")

        let group = Group.new(in: testMOC)
        group.name = "Test group"
        try! testMOC.save()
        
        testMOC.rx.changes().take(1).subscribe(onNext: { changeEvent in
            XCTAssertEqual(changeEvent.inserted.count, 0)
            XCTAssertEqual(changeEvent.updated.count, 0)
            XCTAssertEqual(changeEvent.deleted.count, 0)

            XCTAssertEqual(changeEvent.refreshed.count, 1)
            let refreshedGroup = changeEvent.refreshed.first as? Group
            XCTAssertEqual(refreshedGroup?.name, "Test group")

            insertionExpectation.fulfill()
        }).disposed(by: disposeBag)

        testMOC.refreshAllObjects()

        waitForExpectations(timeout: 1.0, handler: nil)
    }

}
