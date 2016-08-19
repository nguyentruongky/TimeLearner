//
//  QuestionPresenter.swift
//  TimeLearner
//
//  Created by Ky Nguyen on 8/19/16.
//  Copyright © 2016 phuot. All rights reserved.
//

import UIKit

struct QuestionPresenter {
    
    var dataStore : QuestionDatastore!
    
    var currentQuest = 0
    var score = 0
    
    mutating func setDatastore(questions: [Question]) {
        dataStore = QuestionDatastore(questions: questions)
    }
    
    func showQuestionAtIndex(index: Int, updateClock: (date: NSDate) -> Void, updateOptions: (options: [String]) -> Void) {
        guard index >= 0 && index <= 10 else { return }
        let question = dataStore.questions[index]
        let string = formatDateString(question.timeToDisplay)
        let date = convertStringToDate(string)
        updateClock(date: date!)
        updateOptions(options: question.options)
    }
    
    private func formatDateString(string: String) -> String {
        return "\(string):00"
    }
    
    private func convertStringToDate(string: String) -> NSDate? {
        let dateString = string
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "UTC")
        dateFormatter.locale = NSLocale.currentLocale()
        dateFormatter.dateFormat = "HH:mm:ss"
        let date = dateFormatter.dateFromString(dateString)
        return date
    }
    
    mutating func answerTheQuestion(answer: String,
                                    completedQuiz: (controller: ResultViewController) -> Void,
                                    correctAnswer: () -> Void,
                                    wrongAnswer: (controller: ResultViewController) -> Void) {
        let currentQuestion = dataStore.questions[currentQuest]
        
        if answer == currentQuestion.timeToDisplay {
            score += 1
            guard !didFinishedQuiz(currentQuest, totalQuestions: dataStore.questions.count) else {
                let controller = getResultController(score)
                completedQuiz(controller: controller)
                return
            }
            
            currentQuest += 1
            answerCorrect(correctAnswer)
        }
        else {
            answerWrong(wrongAnswer)
        }
    }
    
    mutating func timeOut(action: (controller: ResultViewController) -> Void) {
        answerWrong(action)
    }
    
    private func didFinishedQuiz(currentQuestion: Int, totalQuestions: Int) -> Bool {
        return currentQuestion == totalQuestions - 1
//        return currentQuestion == 4
    }
    
    private mutating func answerCorrect(action: Void -> Void) {
        action()
    }
    
    private mutating func answerWrong(action: (controller: ResultViewController) -> Void) {
        let controller = getResultController(score)
        action(controller: controller)
        resetGame()
    }
    
    private func getResultController(score: Int) -> ResultViewController {
        let controller = UIStoryboard(name: "TimeLearner", bundle: nil).instantiateViewControllerWithIdentifier("ResultViewController") as! ResultViewController
        controller.score = score
        return controller
    }
    
    mutating func resetGame() {
        currentQuest = 0
        score = 0
    }
}

