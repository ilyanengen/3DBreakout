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

    enum Constants {
        static let ballRadius: Float = 1.0 // 0.105
    }

    // MARK: - Properties
    
    var scnView: SCNView!
    var scnScene: SCNScene!
    var game = GameHelper.sharedInstance
    var ball: SCNNode!
    
    var originalBallPosition: SCNVector3!
//    var newBallPosition: SCNVector3!

    var isKickInProgress: Bool = false
    var startKickTime: TimeInterval = .zero

    var ballTrajectory: [Float : SCNVector3] = [:]

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

    // TODO: add parameters of power, curl, kick area, etc.
    private func calculateTrajectory() -> [Float : SCNVector3] {
        var trajectory: [Float : SCNVector3] = [:]

        // gravitational field vector
        let g = SCNVector3(0, -9.8, 0)

        // initial ball position
        var ballPos = originalBallPosition!

        // density of soccer ball - 74 times the density of air
        let rhoSoccer = Float(74 * 1.02)
        // calculate the mass of the soccer ball
        let ballMassPart = pow(Constants.ballRadius, 3)
        let ballMass = Float((rhoSoccer * 4 * .pi * ballMassPart) / 3)

        // Angular velocity of ball - YOU CAN CHANGE THIS = CURLING
        let omega = SCNVector3(0, 20, 0)

        // launch speed in m/s - YOU CAN CHANGE THIS = POWER
        let v0: Float = 15
        // launch angle - YOU CAN CHANGE THIS = KICK ANGLE
        let theta: Float = 30 * .pi / 180

        // horizontalKickArea of the ball - YOU CAN CHANGE THIS = KICK ANGLE
        let horizontalKickArea: Float = 0.15

        // initial velocity vector
        // v0 * SCNVector3(0.15, sin(theta), -cos(theta))
        // ball.v
        var ballV = SCNVector3(horizontalKickArea, sin(theta), -cos(theta)) * v0

        // initial momentum vector
        // ball.p
        var ballP = ballV * ballMass

        let rho: Float = 1.02 // density of air
        let C: Float = 0.47 // the drag coefficient for a sphere
        let A: Float = Float(.pi * pow(Constants.ballRadius, 2))
        let s: Float = 0.0033 // this is a magnus force constant

        var time: Float = 0
        let deltaTime: Float = 0.001

        let ballMinY = Constants.ballRadius

        while ballPos.y >= ballMinY {

            // update the time
            let updatedTime = time + deltaTime
            let roundedValue = round(updatedTime * 1000) / 1000.0
            time = roundedValue

            // calculate the velocity- it makes it easier to calc air drag
            ballV = ballP / ballMass

            // calculate the force
            // note that to square velocity, must first find magnitude
            // in order to make it a vector, I multiply by unit vector for v
            // F = ball.m * g - 0.5 * rho * A * C * norm(ball.v) * mag(ball.v)**2 + s*cross(ball.omega,ball.v)

            // 1. ball.m * g
            let one = g * ballMass

            // 2. 0.5*rho*A*C
            let dragForcePartTwo = 0.5 * rho * A
            let two = dragForcePartTwo * C

            // 3. norm(ball.v)*mag(ball.v)**2
            let velocityDirection = ballV.unit // normalized
            let velocityMagnitude = Float(ballV.length)
            let velocityMagnitudeSquare = velocityMagnitude * velocityMagnitude
            let three = velocityDirection * velocityMagnitudeSquare

            // 4. s*cross(ball.omega,ball.v)
            let magnusForceOne = omega.cross(toVector: ballV)
            let four = magnusForceOne * s

            let twoThree = three * two
            let force = one - twoThree + four

            // update the momentum
            ballP = ballP + force * deltaTime

            // update the position
            let ballPosPart = deltaTime / ballMass
            ballPos = ballPos + ballP * ballPosPart

            print("time = \(time) : ballPos = (x: \(ballPos.x), y: \(ballPos.y), z: \(ballPos.z))")

            trajectory[time] = ballPos
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
    }
    
    private func setupNodes() {
        ball = scnScene.rootNode.childNode(withName: "ball", recursively: true)!
        originalBallPosition = ball.position
    }
    
    private func setupGestures() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(sceneViewDidTap(recognizer:)))
        scnView.addGestureRecognizer(tapGestureRecognizer)
    }

    private func kickBall(at point: CGPoint) {
        ballTrajectory = calculateTrajectory()
        isKickInProgress = true
    }
    
//    private func convert2DPointTo3DVector(point: CGPoint, node: SCNNode) -> SCNVector3 {
//        let nodeCenter = scnView.projectPoint(node.position)
//        let projectedNodeZ = CGFloat(nodeCenter.z)
//        let vector = SCNVector3(point.x, point.y, projectedNodeZ)
//        return scnView.unprojectPoint(vector)
//    }

    private func updateBallPosition(totalElapsedTime: TimeInterval) {
        let timeElapsedSinceKick = Float(totalElapsedTime - startKickTime)
        let roundedTimeElapsed = round(timeElapsedSinceKick * 1000) / 1000.0
        guard
            roundedTimeElapsed > 0.0,
            let newBallPosition = ballTrajectory[roundedTimeElapsed]
        else {
            return
        }
        print("t = \(roundedTimeElapsed), newBallPosition = \(newBallPosition)")
        ball.position = newBallPosition
    }
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

        if isKickInProgress {
            if startKickTime == .zero {
                startKickTime = time
            }
            updateBallPosition(totalElapsedTime: time)
        } else {
            ball.position = originalBallPosition
        }

        //ball.position = newBallPosition
    }
}
