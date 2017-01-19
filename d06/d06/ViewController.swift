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
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.2
            let queue = OperationQueue.main
            motionManager.startDeviceMotionUpdates(to: queue, withHandler: accelerometerHandler as! CMDeviceMotionHandler)
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
    
    func accelerometerHandler(_ data: CMDeviceMotion?, error: NSError?) {
        if (error != nil) {
            NSLog("\(error)")
        }
        
        let grav : CMAcceleration = data!.gravity;
        
        let x = CGFloat(grav.x);
        let y = CGFloat(grav.y);
        
        let v = CGVector(dx: x, dy: y);
        gravity.gravityDirection = v;
    }
    
    func tapGestureHandler(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            let obj = FormObject.init(x: gesture.location(in: view).x, y: gesture.location(in: view).y)
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
    
    func rotateGestureHandler(_ gesture: UIRotationGestureRecognizer) {
        switch gesture.state {
        case .began:
            gravity.removeItem(gesture.view!)
            collision.removeItem(gesture.view!)
            itemBehaviour.removeItem(gesture.view!)
        case .changed:
            gesture.view?.transform = CGAffineTransform(rotationAngle: gesture.rotation);
        case .ended:
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
    
    func pinchGestureHandler(_ gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began:
            gravity.removeItem(gesture.view!)
            collision.removeItem(gesture.view!)
            itemBehaviour.removeItem(gesture.view!)
        case .changed:
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
            let x = gesture.location(in: view).x - width/2
            let y = gesture.location(in: view).y - height/2
            gesture.view?.frame = CGRect(x: x, y: y, width: width, height: width)
            if let obj = gesture.view as? FormObject {
                if obj.form == "circle" {
                    gesture.view?.layer.cornerRadius = (gesture.view?.frame.width)! / 2
                }
            }
        case .ended:
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
    
    func panGestureHandler(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            gravity.removeItem(gesture.view!)
            attachment = UIAttachmentBehavior(item: gesture.view!, attachedToAnchor: CGPoint(x: gesture.view!.center.x, y: gesture.view!.center.y))
            animator.addBehavior(attachment)
        case .changed:
            attachment.damping = 100
            attachment.length = 0
            attachment.frequency = 50
            attachment.anchorPoint = gesture.location(in: view)
        case .ended:
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
