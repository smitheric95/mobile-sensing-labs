//
//  GameViewController.swift
//  Lab3
//
//  Created by Eric Smith on 9/25/18.
//  Copyright © 2018 Jake Carlson. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var startTitle: UILabel!
    @IBOutlet weak var startInstructions: UITextView!
    
    var scene: GameScene? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup game scene
        scene = GameScene(size: view.bounds.size)
        let skView = view as! SKView // the view in storyboard must be an SKView
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.ignoresSiblingOrder = true
        scene?.scaleMode = .resizeFill
        scene?.setViewController(viewController: self)
        skView.presentScene(scene)
    }
    
    @IBAction func startButtonPressed(_ sender: Any) {
        startButton.isHidden = true
        startTitle.isHidden = true
        startInstructions.isHidden = true
        
        scene?.startGame()
    }
    
    func endGame() {
        startButton.isHidden = false
        startTitle.isHidden = false
        startInstructions.isHidden = false
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
}
