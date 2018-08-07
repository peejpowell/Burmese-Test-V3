//
//  TestTabViewModel.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 02/08/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Foundation

class TestTabViewModel {
    
    var multipleChoiceTest : MultipleChoiceTest = MultipleChoiceTest()
    var testStarted : Bool {
        return multipleChoiceTest.testStarted
    }
    
    func updateTestStarted(state: Bool) {
        multipleChoiceTest.testStarted = state
    }
}
