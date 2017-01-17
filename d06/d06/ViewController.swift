//
//  ViewController.swift
//  d06
//
//  Created by Lucas BELVALETTE on 10/12/16.
//  Copyright © 2016 Lucas BELVALETTE. All rights reserved.
//


import UIKit
import CoreMotion

class ViewController: UIViewController {
    var animator: UIDynamicAnimator!
    var gravity: UIGravityBehavior!
    var collision: UICollisionBehavior!
    var itemBehaviour: UIDynamicItemBehavior!
    var attachment: UIAttachmentBehavior!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let motionManager = CMMotionManager()
        if motionManager.accelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.2
            let queue = NSOperationQueue.mainQueue()
            motionManager.startDeviceMotionUpdatesToQueue(queue, withHandler: accelerometerHandler)
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler(_:)))
        view.addGestureRecognizer(tapGesture)
        animator = UIDynamicAnimator(referenceView: view)
        gravity = UIGravityBehavior()
        collision = UICollisionBehavior()
        itemBehaviour = UIDynamicItemBehavior()
        itemBehaviour.elasticity = 0.5
        gravity.magnitude = 0.6
        collision.translatesReferenceBoundsIntoBoundary = true
        animator.addBehavior(collision)
        animator.addBehavior(gravity)
        animator.addBehavior(itemBehaviour)
    }
    
    func accelerometerHandler(data: CMDeviceMotion?, error: NSError?) {
        if (error != nil) {
            NSLog("\(error)")
        }
        
        let grav : CMAcceleration = data!.gravity;
        
        let x = CGFloat(grav.x);
        let y = CGFloat(grav.y);
        
        let v = CGVectorMake(x, y);
        gravity.gravityDirection = v;
    }
    
    func tapGestureHandler(gesture: UITapGestureRecognizer) {
        if gesture.state == .Ended {
            let obj = FormObject.init(x: gesture.locationInView(view).x, y: gesture.locationInView(view).y)
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler(_:)))
            let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchGestureHandler(_:)))
            let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotateGestureHandler(_:)))
            obj.addGestureRecognizer(panGesture)
            obj.addGestureRecognizer(pinchGesture)
            obj.addGestureRecognizer(rotateGesture)
            animator.addBehavior(collision)
            animator.addBehavior(gravity)
            view.addSubview(obj)
            gravity.addItem(obj)
            collision.addItem(obj)
            itemBehaviour.addItem(obj)
        }
    }
    
    func rotateGestureHandler(gesture: UIRotationGestureRecognizer) {
        switch gesture.state {
        case .Began:
            gravity.removeItem(gesture.view!)
            collision.removeItem(gesture.view!)
            itemBehaviour.removeItem(gesture.view!)
        case .Changed:
            gesture.view?.transform = CGAffineTransformMakeRotation(gesture.rotation);
        case .Ended:
            gravity.addItem(gesture.view!)
            collision.addItem(gesture.view!)
            itemBehaviour.addItem(gesture.view!)
        default:
            gravity.addItem(gesture.view!)
            collision.addItem(gesture.view!)
            itemBehaviour.addItem(gesture.view!)
        }
        gesture.rotation = 1
    }
    
    func pinchGestureHandler(gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .Began:
            gravity.removeItem(gesture.view!)
            collision.removeItem(gesture.view!)
            itemBehaviour.removeItem(gesture.view!)
        case .Changed:
            let scale = gesture.scale
            var width: CGFloat = (gesture.view?.frame.width)!  * scale
            var height: CGFloat = (gesture.view?.frame.height)!  * scale
            if width < 20 || height < 20{
                width = CGFloat(20)
                height = CGFloat(20)
            }
            if width != height {
                height = width
            }
            let x = gesture.locationInView(view).x - width/2
            let y = gesture.locationInView(view).y - height/2
            gesture.view?.frame = CGRect(x: x, y: y, width: width, height: width)
            if let obj = gesture.view as? FormObject {
                if obj.form == "circle" {
                    gesture.view?.layer.cornerRadius = (gesture.view?.frame.width)! / 2
                }
            }
        case .Ended:
            gravity.addItem(gesture.view!)
            collision.addItem(gesture.view!)
            itemBehaviour.addItem(gesture.view!)
        default:
            gravity.addItem(gesture.view!)
            collision.addItem(gesture.view!)
            itemBehaviour.addItem(gesture.view!)
        }
        gesture.scale = 1
    }
    
    func panGestureHandler(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Began:
            gravity.removeItem(gesture.view!)
            attachment = UIAttachmentBehavior(item: gesture.view!, attachedToAnchor: CGPointMake(gesture.view!.center.x, gesture.view!.center.y))
            animator.addBehavior(attachment)
        case .Changed:
            attachment.damping = 100
            attachment.length = 0
            attachment.frequency = 50
            attachment.anchorPoint = gesture.locationInView(view)
        case .Ended:
            animator.removeBehavior(attachment)
            gravity.addItem(gesture.view!)
        default:
            animator.removeBehavior(attachment)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}