//
//  GameViewController.swift
//  3DBreakout
//
//  Created by Ilia Biltuev on 02.05.2021.
//

import UIKit
import QuartzCore
import SceneKit

/*
 Scene editor controls:
 
 Option + Mouse ---> Pan
 Mouse ---> Rotate
 Option + Mouse Wheel ---> Zoom
 Cmd + LMB ---> Select multiple nodes
 */
class GameViewController: UIViewController {
    
    // MARK: - Properties
    
    var scnView: SCNView!
    var scnScene: SCNScene!
    var game = GameHelper.sharedInstance
    var ball: SCNNode!
    
    var ballOriginalPosition: SCNVector3!
    
    // MARK: - Override
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupScene()
        setupNodes()
        setupGestures()
    }
    
    // MARK: - UIGestureRecognizer
    
    @objc func sceneViewDidTap(recognizer: UIGestureRecognizer) {
        let locationPoint = recognizer.location(in: scnView)
        let hitResults = scnView.hitTest(locationPoint, options: nil)
        guard
            let tappedNode = hitResults.first?.node,
            tappedNode.name == "ball"
        else {
            return
        }
        kickBall(at: locationPoint)
    }
    
    // MARK: - Private
    
    private func setupScene() {
        scnView = (self.view as! SCNView)
        scnView.delegate = self
        scnScene = SCNScene(named: "Breaker.scnassets/Scenes/Game.scn")
        scnView.scene = scnScene
    }
    
    private func setupNodes() {
        ball = scnScene.rootNode.childNode(withName: "ball", recursively: true)!
        ballOriginalPosition = ball.position
        print(ball.position)
    }
    
    private func setupGestures() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(sceneViewDidTap(recognizer:)))
        scnView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    /*
     -direction
     The direction and magnitude of the force (in newtons) or of the impulse (in newton-seconds).
     
     -position
     The point on the body where the force or impulse should be applied, in the local coordinate system of the SCNNode object containing the physics body.
     
     -impulse
     true to apply an instantaneous change in momentum; false to apply a force that affects the body at the end of the simulation step.
     */
    private func kickBall(at point: CGPoint) {
        
        // TODO:
        // Все-таки нужен отдельный объект НОГИ, которая будет пинать мяч!
        
        let direction = SCNVector3(0, 3, -7) // x, y, z
        let tapPosition = convert2DPointTo3DVector(point: point, node: ball)
        print("tap vector = \(tapPosition)")
        
        // Position in the local coordinate system of ball
        let kickPosition = SCNVector3(tapPosition.x, tapPosition.y, 0)
        ball.physicsBody?.applyForce(direction, at: kickPosition, asImpulse: true)
    }
    
    private func convert2DPointTo3DVector(point: CGPoint, node: SCNNode) -> SCNVector3 {
        let nodeCenter = scnView.projectPoint(node.position)
        let projectedNodeZ = CGFloat(nodeCenter.z)
        let vector = SCNVector3(point.x, point.y, projectedNodeZ)
        return scnView.unprojectPoint(vector)
    }
}

// MARK: - SCNSceneRendererDelegate

extension GameViewController: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
//        game.updateHUD()
        
        let isBallStopped = ball.physicsBody?.isResting ?? false
        
        if ball.physicsBody?.isResting ?? false {
            print("BALL STOPPED!")
            ball.position = ballOriginalPosition
        }
        
    }
}
