//
//  ResultViewController.swift
//  TimeLearner
//
//  Created by Ky Nguyen on 8/19/16.
//  Copyright © 2016 phuot. All rights reserved.
//

import UIKit
import FBSDKShareKit

class ResultViewController: UIViewController {

    @IBOutlet weak var commentLabel: UILabel!
    
    @IBOutlet weak var pointLabel: UILabel!
    
    @IBOutlet weak var playAgainButton: UIButton!
    
    @IBOutlet weak var shareButton: UIButton!
    
    var delegate : NewGameDelegate!
    var score = 0
    var presenter = ResultPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentLabel.text = presenter.giveCommentOnScore(score)
        pointLabel.text = "You got \(score) point\(score == 1 ? "" : "s")"
        playAgainButton.createRoundCorner(5)
        playAgainButton.createBorder(0.5, color: UIColor.lightGrayColor())
        playAgainButton.addTarget(self, action: #selector(startOver), forControlEvents: .TouchUpInside)
        shareButton.addTarget(self, action: #selector(shareOnFacebook), forControlEvents: .TouchUpInside)
    }
    
    func startOver() {
        presenter.getData { (questions) in
            self.delegate.startNewGame(questions)
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func shareOnFacebook() {
        let content = FBSDKShareLinkContent()
        content.contentURL = NSURL(string: "https://github.com/nguyentruongky/TimeLearner")
        content.contentTitle = "I got \(score) at TimeLearner. Try it yourself!"
        FBSDKShareDialog.showFromViewController(self, withContent: content, delegate: nil)
    }
}
