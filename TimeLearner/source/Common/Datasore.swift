//
//  Datasore.swift
//  TimeLearner
//
//  Created by Ky Nguyen on 8/19/16.
//  Copyright © 2016 phuot. All rights reserved.
//

import Foundation
import Alamofire

struct Datastore {
    static func getDataFromService(completed: (questions: [Question]) -> Void) {
        let url = "http://time-learner.vinagility.vn/get-questions.json"
        Alamofire.request(.GET, url, parameters: nil)
            .responseJSON { response in
//                if let data = response.result.value {
//                    
//                }
        }
    }
    
    static func getDataFromLocal(completed: (questions: [Question]) -> Void) {
        let path = "/Users/kynguyen/Documents/Personal/Dev Center/TimeLearner/TimeLearner/time.json"
        
        let jsonData = NSData(contentsOfURL: NSURL(fileURLWithPath: path))
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
}