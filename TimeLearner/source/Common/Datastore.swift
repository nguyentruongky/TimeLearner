//
//  Datasore.swift
//  TimeLearner
//
//  Created by Ky Nguyen on 8/19/16.
//  Copyright © 2016 phuot. All rights reserved.
//

import Foundation
import Alamofire

let maxOptions = 3

struct Datastore {
    static func getDataFromService(completed: (questions: [Question]) -> Void) {
        let url = "service_url"
        Alamofire.request(.GET, url, parameters: nil)
            .responseJSON { response in
//                if let data = response.result.value {
//                    
//                }
        }
    }
    
    static func getDataFromLocal(completed: (questions: [Question]) -> Void) {
        let path = NSBundle.mainBundle().pathForResource("time", ofType: "json")
        let jsonData = NSData(contentsOfURL: NSURL(fileURLWithPath: path!))
        guard jsonData != nil else { return }
        
        do {
            let data = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.MutableContainers)
            let questions = parseData(data)
            completed(questions: questions)
        }
        catch {
            //handle errors here
            print("error")
        }
    }
    
    static func parseData(data: AnyObject) -> [Question] {
        let questionsData = data.valueForKeyPath("questions") as! NSArray
        let questions = questionsData.map { (ques) -> Question in
            return Question(data: ques)
        }
        return questions
    }
    
    static func generateRandomQuestions(numberOfQuestions: Int) -> [Question] {
        var autoGenQuestions = [Question]()
        
        for _ in 0 ..< numberOfQuestions {
            autoGenQuestions.append(createQuestion())
        }
        
        return autoGenQuestions
    }
    
    private static func createQuestion() -> Question {
        let timeToDisplay = generateHourString()
        let options = randomOptions(timeToDisplay)
        return Question(displayTime: timeToDisplay, answers: options)
    }
    
    private static func generateHourString() -> String {
        let hour = Int(arc4random_uniform(24))
        let minute = Int(arc4random_uniform(60))
        return "\(convertNumberToString(hour)):\(convertNumberToString(minute))"
    }
    
    private static func convertNumberToString(number: Int) -> String {
        return number >= 10 ? "\(number)" : "0\(number)"
    }
    
    private static func randomOptions(correctAnswer: String) -> [String] {
        let randomIndex = Int(arc4random_uniform(3))
        var options = [String]()
        for i in 0 ..< maxOptions {
            
            let wrongAnswer = generateWrongAnswer(correctAnswer)
            i == randomIndex ?
                options.append(correctAnswer) :
                options.append(wrongAnswer)
        }
        
        return options
    }
    
    private static func generateWrongAnswer(correctAnswer: String) -> String {
        var wrongAnswer = generateHourString()
        while wrongAnswer == correctAnswer {
            wrongAnswer = generateHourString()
        }
        return wrongAnswer
    }
    
}