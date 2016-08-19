//
//  SplashscreenViewController.swift
//  TimeLearner
//
//  Created by Ky Nguyen on 8/18/16.
//  Copyright © 2016 phuot. All rights reserved.
//

import UIKit
import Alamofire

class SplashscreenViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        getDataFromService()
        Datastore.getDataFromLocal { (questions) in
            let controller = UIStoryboard(name: "TimeLearner", bundle: nil).instantiateViewControllerWithIdentifier("QuestionViewController") as! QuestionViewController
            controller.presenter.setDatastore(questions)
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
}

