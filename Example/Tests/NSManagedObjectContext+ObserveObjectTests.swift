//
//  NSManagedObjectContext+ObserveObjectTests.swift
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

class NSManagedObjectContext_ObserveObjectTests: XCTestCase {

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

    func testObjectFieldUpdate() {
        let objectUpdateExpectation = expectation(description: "Expect to get object in stream when field is changed")

        let group = Group.new(in: testMOC)
        group.name = "Test group"
        try! testMOC.save()

        testMOC.rx.entity(group).take(1).subscribe(onNext: { group in
            XCTAssertEqual(group.name, "Updated test group")
            objectUpdateExpectation.fulfill()
        }).disposed(by: disposeBag)

        group.name = "Updated test group"

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testObjectOneLevelRelationshipFieldUpdate() {
        let objectUpdateExpectation = expectation(description: "Expect to get object in stream when field is changed")

        let contact = Contact.new(in: testMOC)
        contact.name = "John Doe"

        let group = Group.new(in: testMOC)
        group.name = "Test group"
        group.contacts = NSSet(objects: contact)

        try! testMOC.save()

        testMOC.rx.entity(group).take(1).subscribe(onNext: { group in
            let updatedContactName = (group.contacts?.allObjects.first as? Contact)?.name
            XCTAssertEqual(updatedContactName, "Alice")

            objectUpdateExpectation.fulfill()
        }).disposed(by: disposeBag)

        contact.name = "Alice"

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testObjectTwoLevelRelationshipFieldUpdate() {
        let objectUpdateExpectation = expectation(description: "Expect to get object in stream when field is changed")

        let phoneNumber = PhoneNumber.new(in: testMOC)
        phoneNumber.phoneNumber = "987654321"
        phoneNumber.title = "Mobile"

        let contact = Contact.new(in: testMOC)
        contact.name = "John Doe"
        contact.phoneNumbers = NSSet(objects: phoneNumber)

        let group = Group.new(in: testMOC)
        group.name = "Test group"
        group.contacts = NSSet(objects: contact)

        try! testMOC.save()

        testMOC.rx.entity(group).take(1).subscribe(onNext: { group in
            let updatedPhoneNumber = ((group.contacts?.allObjects.first as? Contact)?.phoneNumbers?.allObjects.first as? PhoneNumber)?.phoneNumber
            XCTAssertEqual(updatedPhoneNumber, "987654321")

            objectUpdateExpectation.fulfill()
        }).disposed(by: disposeBag)

        phoneNumber.phoneNumber = "987654321"

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testObjectDeletion() {
        let objectDeleteExpectation = expectation(description: "Expect to get an error in stream when object deleted")

        let group = Group.new(in: testMOC)
        group.name = "Test group"

        try! testMOC.save()

        testMOC.rx.entity(group).take(1).subscribe(onError: { error in
            guard case CoreDataObserverError.objectDeleted = error else {
                XCTFail("Should get CoreDataObserverError.objectDeleted error in stream")
                return
            }
            objectDeleteExpectation.fulfill()
        }).disposed(by: disposeBag)

        testMOC.delete(group)

        waitForExpectations(timeout: 1.0, handler: nil)
    }

}
