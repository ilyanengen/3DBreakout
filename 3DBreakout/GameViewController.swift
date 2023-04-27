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
    var trajectoryPoints: [String: SCNVector3] = [:]

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

        test()
    }

    private func test() {
        // gravitational field vector
        let g = SCNVector3(0, -9.8, 0)

        // the soccer ball
        let ball = SCNSphere(radius: 0.105)
        ball.firstMaterial?.diffuse.contents = UIColor.white
        ball.firstMaterial?.specular.contents = UIColor.white
        let ballNode = SCNNode(geometry: ball)
        ballNode.position = SCNVector3(0, -1.4, 9.5)

        //!!!
        var ballPos = SCNVector3(0, -1.4, 9.5)

        // density of soccer ball - 74 times the density of air
        let rhoSoccer = 74 * 1.02
        // calculate the mass of the soccer ball
        let ballMassPart = pow(ball.radius, 3)
        let ballMass = Float((rhoSoccer * 4 * .pi * ballMassPart) / 3)

        // Angular velocity of ball - YOU CAN CHANGE THIS = CURLING
        let omega = SCNVector3(0, 20, 0)

        // launch speed in m/s - YOU CAN CHANGE THIS = POWER
        let v0: Float = 15
        // launch angle - YOU CAN CHANGE THIS = KICK ANGLE
        let theta: Float = 30 * .pi / 180

        // initial velocity vector
        // v0 * SCNVector3(0.15, sin(theta), -cos(theta))
        // ball.v
        var ballV = SCNVector3(0.15, sin(theta), -cos(theta)) * v0

        // initial momentum vector
        // ball.p
        var ballP = ballV * ballMass

        let rho: Float = 1.02 // density of air
        let C: Float = 0.47 // the drag coefficient for a sphere
        let A: Float = Float(.pi * pow(ball.radius, 2))
        let s: Float = 0.0033 // this is a magnus force constant

        var time: Float = 0
        let deltaTime: Float = 0.001

        // TODO: NEED FIX and remove WHILE LOOP!
        while ballPos.y >= -1.4 {
            // calculate the velocity- it makes it easier to calc air drag
            // ball.v=ball.p/ball.m
            ballV = ballP / Float(ballMass)

            // calculate the force
            // note that to square velocity, must first find magnitude
            // in order to make it a vector, I multiply by unit vector for v

            // ???
//            F=ball.m * g
//            -.5*rho*A*C
//            *norm(ball.v)*mag(ball.v)**2
//            +s*cross(ball.omega,ball.v)


            let velocityMagnitude = Float(ballV.length)
            let velocityMagnitudeSquare = velocityMagnitude * velocityMagnitude
            let velocityDirection = ballV.unit // normalized
            let dragForcePart = velocityDirection * velocityMagnitudeSquare
            let dragForcePartTwo = -0.5 * rho * A
            let dragForcePartThree = dragForcePartTwo * C
            let dragForce = dragForcePart * dragForcePartThree
            let magnusForce = ballV.cross(toVector: omega) * s

            let force1 = g * Float(ballMass)
            let force = force1 + dragForce + magnusForce

            // update the momentum
            ballP = ballP + force * deltaTime

            ballNode.physicsBody?.applyForce(force, asImpulse: false)

            // update the position
            let ballPosPart = deltaTime / ballMass
            ballPos = ballPos + ballP * ballPosPart

            print("ballPos = (\(ballPos.x), \(ballPos.y), \(ballPos.z))")

            // update the time
            time += deltaTime
        }
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
//        print(ball.position)
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
        // OLD CODE WITH applyForce logic
//        let direction = SCNVector3(0, 3, -7) // x, y, z
//        let tapPosition = convert2DPointTo3DVector(point: point, node: ball)
//        print("tap vector = \(tapPosition)")
//
//        // Position in the local coordinate system of ball
//        let kickPosition = SCNVector3(tapPosition.x, tapPosition.y, 0)
//        ball.physicsBody?.applyForce(direction, at: kickPosition, asImpulse: true)

        let power = 100
        let kickPosition = convert2DPointTo3DVector(point: point, node: ball)
        trajectoryPoints = calculateTrajectory(kickPosition: kickPosition, power: power)
        isKickInProgress = true
    }
    
    private func convert2DPointTo3DVector(point: CGPoint, node: SCNNode) -> SCNVector3 {
        let nodeCenter = scnView.projectPoint(node.position)
        let projectedNodeZ = CGFloat(nodeCenter.z)
        let vector = SCNVector3(point.x, point.y, projectedNodeZ)
        return scnView.unprojectPoint(vector)
    }

    private func calculateTrajectory(kickPosition: SCNVector3, power: Int) -> [String: SCNVector3] {
        // Constants
        let gravity = SCNVector3(0, -9.81, 0) // Gravity vector in meters per second squared
        let airResistance: Float = 0.1 // Coefficient of air resistance
        let spin = SCNVector3(0, 1, 0) // Spin vector (5 revolutions per second around the y-axis)
        let ballMass: Float = 0.43 // Mass of the ball in kilograms

        // Initial velocity vector
//        let initialVelocity = SCNVector3(0, 0, Float(power) / 10.0)
        let initialVelocity = SCNVector3(0, 0, Float(power) * 0.2)

        // Calculate the trajectory
        var trajectory: [String: SCNVector3] = [:]
        var currentPosition = kickPosition
        var currentVelocity = initialVelocity
        var currentTime: TimeInterval = 0
        let timeStep: TimeInterval = 0.01 // Time step in seconds

        while currentPosition.y >= 0 {
            // Calculate forces on the ball
            let gravityForce = gravity * ballMass

            let airResistanceForce1 = -currentVelocity.unit
            let airResistanceForce2 = airResistance * currentVelocity.lengthSquared
            let airResistanceForce = airResistanceForce1 * airResistanceForce2 * ballMass
            let magnusForce = spin.cross(toVector: currentVelocity) * (spin.unit * currentVelocity.unit * ballMass)
            let totalForce = gravityForce + airResistanceForce + magnusForce

            // Update velocity and position
            let acceleration = totalForce / ballMass
            currentVelocity += acceleration * SCNFloat(timeStep)
            currentPosition += currentVelocity * SCNFloat(timeStep)

            // Update time
            currentTime += timeStep
            let roundedTime = String(format: "%.2f", currentTime)

            // Add the position to the trajectory
            trajectory[roundedTime] = currentPosition
        }

        print("trajectory")
        trajectory.forEach { time, pos in
            print("time = \(time)")
            print("pos = \(pos)")
        }

        return trajectory
    }

    private func updateBallPosition(totalElapsedTime: TimeInterval) {
        let timeElapsedSinceKick = totalElapsedTime - startKickTime
        let roundedTimeElapsed = String(format: "%.2f", timeElapsedSinceKick)
        print("roundedTimeElapsed = \(roundedTimeElapsed)")

        guard let newBallPosition = trajectoryPoints[roundedTimeElapsed] else { return }
        print("newBallPosition = \(newBallPosition)")

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
            ball.position = ballOriginalPosition
        }
    }
}
