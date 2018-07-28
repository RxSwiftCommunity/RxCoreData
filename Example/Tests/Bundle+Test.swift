//
//  Bundle+Test.swift
//  RxCoreData_Example
//
//  Created by Evghenii Nicolaev on 7/28/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation

private class Test {}

extension Bundle {
    static var test: Bundle {
        return Bundle(for: Test.self)
    }
}
