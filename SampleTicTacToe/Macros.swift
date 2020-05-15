//
//  Macros.swift
//  SampleTicTacToe
//
//  Created by Anton Umnitsyn on 15.05.2020.
//  Copyright © 2020 Anton Umnitsyn. All rights reserved.
//

import Foundation
import UIKit

#if DEBUG
public func DLog(_ object: Any?, filename: String = #file, line: Int = #line, funcname: String = #function) {
    #if DEBUG
    print("****\(Date()) \(filename)(\(line)) \(funcname):\r\(object ?? "nil")\n")
    #endif
}
#endif
