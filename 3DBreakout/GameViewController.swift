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
    
    var scnView: SCNView!
    var scnScene: SCNScene!
    var game = GameHelper.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupScene()
        setupNodes()
        setupSounds()
    }
    
    func setupScene() {
        scnView = (self.view as! SCNView)
        scnView.delegate = self
        scnScene = SCNScene(named: "Breaker.scnassets/Scenes/Game.scn")
        scnView.scene = scnScene
    }
    
    func setupNodes() {
        scnScene.rootNode.addChildNode(game.hudNode)
    }
    
    func setupSounds() {
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }
}

extension GameViewController: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
//        game.updateHUD()
    }
}
