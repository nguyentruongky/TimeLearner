//
//  AnalogClockView.swift
//  TimeLearner
//
//  Created by Ky Nguyen on 8/18/16.
//  Copyright © 2016 phuot. All rights reserved.
//

import UIKit

extension NSObject {
    func performBlock(block: dispatch_block_t, onQueue: dispatch_queue_t, afterDelay: Double) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(afterDelay) * Int64(NSEC_PER_SEC)), onQueue, block)
    }
    
    func performBlockOnMainQueue(block: dispatch_block_t, afterDelay: Double) {
        performBlock(block, onQueue: dispatch_get_main_queue(), afterDelay: afterDelay)
    }
}

struct HandAngles {
    var hour: CGFloat = 0
    var minute: CGFloat = 0
    var second: CGFloat = 0
}

class AnalogClockView: UIView {
    var clockTimer: NSTimer!
    var calendar = NSCalendar.currentCalendar()
    var timeTextLabel: UILabel!
    var timeFormatter: NSDateFormatter!
    var oldAngles: HandAngles!
    var enterBackgroundNotification: NSObjectProtocol!
    var enterForegroundNotification: NSObjectProtocol!

    var timePeriod = "" // AM or PM
    var shouldShowTimePeriod = true
    
    private var _aDate : NSDate!
    var aDate: NSDate! {
        get { return _aDate }
        set(date) {
            _aDate = date
            setTimeAnimated(false)
        }
    }
    
    @IBOutlet weak var hourHand: UIImageView!
    @IBOutlet weak var minuteHand: UIImageView!
    @IBOutlet weak var secondHand: UIImageView!
    
    private var _running = false
    var running: Bool {
        get { return _running }
        set(isRunning) {
            _running = running
            if clockTimer != nil {
                clockTimer.invalidate()
            }
            
            if running {
                let nextSecondInterval = floor(NSDate.timeIntervalSinceReferenceDate() + 1)
                let nextSecond = NSDate(timeIntervalSinceReferenceDate: nextSecondInterval)
                let newTimer = NSTimer(fireDate: nextSecond, interval: 1, target: self, selector: #selector(displayTime), userInfo: nil, repeats: true)
                clockTimer = newTimer
                
                NSRunLoop.mainRunLoop().addTimer(clockTimer, forMode: "NSRunLoopCommonModes")
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    func setup() {
        enterForegroundNotification = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationWillEnterForegroundNotification, object: nil, queue: nil, usingBlock: { (note) in
            self.setTimeAnimated(true)
        })
        
        enterBackgroundNotification = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidEnterBackgroundNotification, object: nil, queue: nil, usingBlock: { (note) in
            guard self.clockTimer != nil else { return }
            self.clockTimer.invalidate()
        })
    }
    
    func setupView() {
//    override func awakeFromNib() {
        let circle = CALayer()
        var bounds = layer.frame
        bounds.size.height = layer.frame.size.width
        circle.frame = bounds
        circle.cornerRadius = bounds.size.width / 2
        circle.borderWidth = 1
        circle.borderColor = UIColor.lightGrayColor().CGColor
        circle.backgroundColor = UIColor.whiteColor().CGColor
        let position = CGPoint(x: CGRectGetMidX(bounds), y: CGRectGetMidY(bounds))
        circle.position = position
        layer.superlayer?.insertSublayer(circle, below: layer)
        
        //Create an array of our labels for the clock face.
        let labelString: NSArray = ["12", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"]
//        let labelString = ["12", "3", "6", "9"]

        //Calculate the radius of the circle where we put our time labels.
        let radius = bounds.width / 2 - 20

        labelString.enumerateObjectsUsingBlock { (string, index, stop) in

            let angle = Float(CGFloat(index) * CGFloat(M_PI) * CGFloat(2) / CGFloat(labelString.count) - CGFloat(M_PI_2))
            let x = CGFloat(round(cosf(angle) * Float(radius))) + CGRectGetMidX(self.layer.bounds)
            let y = CGFloat(round(sinf(angle) * Float(radius))) + CGRectGetMidY(self.layer.bounds) + 5

            let center = CGPoint(x: x, y: y)
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 25, height: 18))
            label.font = UIFont.systemFontOfSize(20)
            label.textColor = UIColor.blackColor()
            label.center = center
            label.textAlignment = NSTextAlignment.Center
            label.text = string as? String
            self.addSubview(label)
            
            //Create a label for a
            //digital time at the bottom of the clock face.
            
            if self.timeTextLabel == nil {
                self.timeTextLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 28))
                self.timeTextLabel.textAlignment = NSTextAlignment.Center
                self.timeTextLabel.font = UIFont.boldSystemFontOfSize(15)
                self.timeTextLabel.center = CGPoint(x: CGRectGetMidX(self.layer.bounds) / 2,
                    y: CGRectGetMidY(self.layer.bounds))
                self.timeTextLabel.layer.borderWidth = 1
                self.timeTextLabel.layer.borderColor = UIColor.blackColor().CGColor
                self.addSubview(self.timeTextLabel)
            }
            self.setTimeAnimated(false)
            self.hourHand.alpha = 0.5
            self.minuteHand.alpha = 0.5
            self.secondHand.alpha = 0.0
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(enterBackgroundNotification)
        NSNotificationCenter.defaultCenter().removeObserver(enterForegroundNotification)
        enterForegroundNotification = nil
        enterForegroundNotification = nil
    }

    func displayTime(timer: NSTimer) {
        setTimeAnimated(true)
    }
    
    func setTimeToDate(date: NSDate, animated: Bool) {
        let angle = calculateHandAngleForDate(date)
        if !animated {
            hourHand.transform = CGAffineTransformMakeRotation(angle.hour)
            minuteHand.transform = CGAffineTransformMakeRotation(angle.minute)
            secondHand.transform = CGAffineTransformMakeRotation(angle.second)
        }
        else {
            var duration: Double!
            var big_change: Bool {
                let change = fabs(Double(angle.second - oldAngles.second)) > M_PI_4
                duration = change ? 0.6 : 0.3
                animateHandView(secondHand, toAngle: angle.second, duration: duration)
                return change
            }
            
            performBlockOnMainQueue({ 
                var duration: Double!
                var big_change: Bool = fabs(Double(angle.minute - self.oldAngles.minute)) > M_PI_4
                duration = big_change ? 0.6 : 0.3;
                self.animateHandView(self.minuteHand, toAngle: angle.minute, duration: duration)
                
                big_change = fabs(Double(angle.hour - self.oldAngles.hour)) > M_PI_4
                duration = big_change ? 0.6 : 0.3;
                self.animateHandView(self.minuteHand, toAngle: angle.hour, duration: duration)
                }, afterDelay: 0.05)

        }
        oldAngles = angle
        if timeFormatter == nil {
            timeFormatter = NSDateFormatter()
            timeFormatter.dateFormat = "h:mm:ss"
        }
        
        guard timeTextLabel != nil else { return }
        timeTextLabel.hidden = !shouldShowTimePeriod
        timeTextLabel.text = timePeriod
    }

    func calculateHandAngleForDate(date: NSDate) -> HandAngles {
        var result = HandAngles()
        
        calendar.timeZone = NSTimeZone(name: "UTC")!
        let timeComponent = calendar.components([NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second], fromDate: date)
        
        let hour = timeComponent.hour % 12
        let minute = timeComponent.minute
        let second = timeComponent.second
        let fractionalHours = CGFloat(hour) + CGFloat(minute) / 60.0
        
        let pi2 = CGFloat(M_PI) * 2
        result.hour = pi2 * fractionalHours / 12
        result.minute = pi2 * CGFloat(minute) / 60.0
        result.second = pi2 * CGFloat(second) / 60.0
        
        timePeriod = timeComponent.hour > 12 ? "PM" : "AM"
        return result
    }

    func animateHandView(handView: UIView, toAngle: CGFloat, duration: Double) {
        var damping: CGFloat = 0.2
        if duration > 0.4 {
            damping = 0.6
            UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: 0.8, options: UIViewAnimationOptions.CurveEaseIn, animations: { 
                handView.transform = CGAffineTransformMakeRotation(toAngle)
                }, completion: nil)
        }
    }

    func setTimeAnimated(animated: Bool) {
        guard aDate != nil else { return }
        setTimeToDate(aDate, animated: animated)
    }
}
