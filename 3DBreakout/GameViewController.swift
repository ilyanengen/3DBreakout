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

    var isKickInProgress: Bool = false
    var startKickTime: TimeInterval = .zero

    // MARK: - Override
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        test()

        setupScene()
        setupNodes()
        setupGestures()
    }

    func test() {
        let trajectory = calculateBallTrajectory(
            kickForce: 22,
            kickAngleInDegrees: 40,
            initialBallPosition: CGPoint(x: 0, y: 0),
            curl: 1.0)

        print("trajectory")
        trajectory.forEach { vector in
            print("x = \(vector.x), y = \(vector.y), z = \(vector.z)")
        }
    }

    // kickForce - meters per second
    // kickAngleInDegrees - in degrees
    // curl: from -5 to 5; 0 - no curling
    func calculateBallTrajectory(kickForce: Double, kickAngleInDegrees: Double, initialBallPosition: CGPoint, curl: Double = 0.0) -> [SCNVector3] {
        let radians = kickAngleInDegrees * Double.pi / 180.0

        let initialVelocityX = kickForce * cos(radians)
        let initialVelocityY = kickForce * sin(radians)
        let initialVelocityZ = kickForce * sin(radians) // added calculation of z velocity

        let gravity = -9.8 // meters per second squared

        var time = 0.0
        let deltaTime = 0.01
        var position = SCNVector3(Float(initialBallPosition.x), Float(initialBallPosition.y), 0.0)
        var velocity = SCNVector3(Float(initialVelocityX), Float(initialVelocityY), Float(initialVelocityZ))
        var trajectory = [position]

        while position.y >= 0 {
            time += deltaTime

            let acceleration = SCNVector3(Float(curl), Float(gravity), 0) // add curl to x-axis acceleration, gravity to y-axis
            velocity = velocity + acceleration * Float(deltaTime)
            position = position + velocity * Float(deltaTime)

            trajectory.append(position)
        }

        return trajectory
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
        scnView.allowsCameraControl = true
    }
    
    private func setupNodes() {
        ball = scnScene.rootNode.childNode(withName: "ball", recursively: true)!
        ballOriginalPosition = ball.position
//        print(ball.position)
    }
    
    private func setupGestures() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(sceneViewDidTap(recognizer:)))
        scnView.addGestureRecognizer(tapGestureRecognizer)
    }

    private func kickBall(at point: CGPoint) {
        // TODO
        isKickInProgress = true
    }
    
//    private func convert2DPointTo3DVector(point: CGPoint, node: SCNNode) -> SCNVector3 {
//        let nodeCenter = scnView.projectPoint(node.position)
//        let projectedNodeZ = CGFloat(nodeCenter.z)
//        let vector = SCNVector3(point.x, point.y, projectedNodeZ)
//        return scnView.unprojectPoint(vector)
//    }
}

// MARK: - SCNSceneRendererDelegate

extension GameViewController: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
//        game.updateHUD()

//        let isBallStopped = ball.physicsBody?.isResting ?? false
//
//        if ball.physicsBody?.isResting ?? false {
//            print("BALL STOPPED!")
//            ball.position = ballOriginalPosition
//        }

//        if isKickInProgress {
//            if startKickTime == .zero {
//                startKickTime = time
//            }
//            updateBallPosition(totalElapsedTime: time)
//        } else {
//            ball.position = ballOriginalPosition
//        }
    }
}
