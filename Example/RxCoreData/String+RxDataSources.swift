//
//  String+RxDataSources.swift
//  RxCoreData
//
//  Created by Scott Gardner on 5/19/16.
//  Copyright © 2016 Scott Gardner. All rights reserved.
//

import Foundation
import RxDataSources

extension String : IdentifiableType {
    
    public typealias Identity = String
    
    public var identity: String {
        return self
    }
    
}
