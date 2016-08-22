//
//  Question.swift
//  TimeLearner
//
//  Created by Ky Nguyen on 8/18/16.
//  Copyright © 2016 phuot. All rights reserved.
//

import Foundation

struct Question {
    
    var options : [String]!
    var timeToDisplay = ""
    
    init(data: AnyObject) {
        timeToDisplay = data.valueForKeyPath("time_to_display") as! String
        options = data.valueForKeyPath("options") as! [String]
    }
    
    init(displayTime: String, answers: [String]) {
        timeToDisplay = displayTime
        options = answers
    }
    
    
    
}