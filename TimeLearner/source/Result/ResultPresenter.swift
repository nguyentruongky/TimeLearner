//
//  ResultPresenter.swift
//  TimeLearner
//
//  Created by Ky Nguyen on 8/19/16.
//  Copyright © 2016 phuot. All rights reserved.
//

import Foundation

struct ResultPresenter {
    func giveCommentOnScore(score: Int) -> String {
        if score > 8 {
            return "Excellent"
        }
        if score > 6 {
            return "Great job"
        }
        if score > 3 {
            return "Better next time"
        }
        
        return "Try again"
    }
    
    func getData(completed: (questions: [Question]) -> Void) {
        let questions = Datastore.generateRandomQuestions(10)
        completed(questions: questions)
    }
    
    
}

