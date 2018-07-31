//
//  Bundle+Test.swift
//  RxCoreData_Tests
//
//  Created by Krunoslav Zaher on 7/28/18.
//  Copyright © 2018 Krunoslav Zaher. All rights reserved.
//

import Foundation

private class Test {}

extension Bundle {
    static var test: Bundle {
        return Bundle(for: Test.self)
    }
}
