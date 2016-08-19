//
//  QuestionViewController.swift
//  TimeLearner
//
//  Created by Ky Nguyen on 8/18/16.
//  Copyright © 2016 phuot. All rights reserved.
//

import UIKit

protocol NewGameDelegate {
    func startNewGame(questions: [Question])
}

class QuestionViewController: UIViewController {

    @IBOutlet weak var analogClockView: AnalogClockView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var currentQuestionLabel: UILabel!
    @IBOutlet weak var totalQuestionLabel: UILabel!
    @IBOutlet var options: [UIButton]!
    @IBOutlet weak var clockHeight: NSLayoutConstraint!

    var presenter = QuestionPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        reset()
        showQuestionAtIndex(0)
        analogClockView.alpha = 0
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        analogClockView.setupView()
        UIView.animateWithDuration(0.25) { 
            self.analogClockView.alpha = 1
        }
    }

    func setupView() {
        for option in options {
            option.createBorder(0.5, color: UIColor.lightGrayColor())
            option.createRoundCorner(5)
            option.addTarget(self, action: #selector(answer(_:)), forControlEvents: .TouchUpInside)
        }
    }
    
    func showQuestionAtIndex(index: Int) {
        
        presenter.showQuestionAtIndex(index, updateClock: { [unowned self] (date) in
            self.analogClockView.aDate = date
        }) { [unowned self] (options) in
            for i in 0 ..< options.count {
                self.options[i].setTitle(options[i], forState: .Normal)
            }
        }
    }
    
    func answer(sender: UIButton) {
        
        presenter.answerTheQuestion(sender.currentTitle!,
                                    completedQuiz: completeQuiz,
                                    correctAnswer: correctAnswer,
                                    wrongAnswer: wrongAnswer)
        
    }
}

// answer the question
extension QuestionViewController {
    
    func completeQuiz(controller: ResultViewController) {
        controller.delegate = self
        self.presentViewController(controller, animated: true, completion: { [unowned self] in
            self.presenter.resetGame()
            })
    }
    
    func correctAnswer() {
        animateToChangeQuestion()
    }
    
    func wrongAnswer(controller: ResultViewController) {
        controller.delegate = self
        self.presentViewController(controller, animated: true, completion: { [unowned self] in
            self.presenter.resetGame()
            })
    }
    
    func reset() {
        scoreLabel.text = "0"
        currentQuestionLabel.text = "1"
    }
    
    func animateToChangeQuestion() {
        
        let duration = 0.25
        UIView.animateWithDuration(duration, animations: {
            self.currentQuestionLabel.text = "\(self.presenter.currentQuest + 1)"
            self.scoreLabel.text = "\(self.presenter.score)"
            self.showQuestionAtIndex(self.presenter.currentQuest)
            }, completion: nil)
    }
}

extension QuestionViewController : NewGameDelegate {
    func startNewGame(questions: [Question]) {
        presenter.setDatastore(questions)
        presenter.resetGame()
        showQuestionAtIndex(0)
        reset()
    }
}
