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
 Scen editor controls:
 
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
        let location = recognizer.location(in: scnView)
        let hitResults = scnView.hitTest(location, options: nil)
        guard
            let tappedNode = hitResults.first?.node,
            tappedNode.name == "ball"
        else {
            return
        }
        kickBall()
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
    }
    
    private func setupGestures() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(sceneViewDidTap(recognizer:)))
        scnView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func kickBall() {
        // TODO: Использовать далее вот этот метод - приложить силу в конкретную точку
        //ball.physicsBody?.applyForce(T##direction: SCNVector3##SCNVector3, at: T##SCNVector3, asImpulse: T##Bool)
        
        let direction = SCNVector3(0, 3, -5)
        ball.physicsBody?.applyForce(direction, asImpulse: true)
    }
}

// MARK: - SCNSceneRendererDelegate

extension GameViewController: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
//        game.updateHUD()
    }
}
