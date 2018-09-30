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
    @IBOutlet weak var returnButton: UIButton!
    @IBOutlet weak var startTitle: UILabel!
    @IBOutlet weak var startInstructions: UITextView!
    @IBOutlet weak var livesLabel: UILabel!
    @IBOutlet weak var livesNumberLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var scoreNumberLabel: UILabel!
    
    var scene: GameScene? = nil
    var numLives = 3
    
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
        
        // set the number of ship lives
        self.livesNumberLabel.text = String(self.numLives)
        
        // hide things
        scoreLabel.isHidden = true
        scoreNumberLabel.isHidden = true
        returnButton.isEnabled = false
        returnButton.isHidden = true
        
        skView.presentScene(scene)
    }
    
    @IBAction func startButtonPressed(_ sender: Any) {
        startButton.isHidden = true
        startTitle.isHidden = true
        startInstructions.isHidden = true
        livesLabel.isHidden = true
        livesNumberLabel.isHidden = true
        
        scene?.startGame()
    }
    
    func endGame() {
        startButton.isHidden = false
        startTitle.isHidden = false
        startInstructions.isHidden = false
        
        numLives -= 1
        self.livesNumberLabel.text = String(self.numLives)
        
        livesLabel.isHidden = false
        livesNumberLabel.isHidden = false
        
        // no more lives, show final score and return button
        if numLives == 0 {
            startButton.isEnabled = false
            scoreLabel.isHidden = false
            
            returnButton.isEnabled = true
            returnButton.isHidden = false
            
            scoreNumberLabel.text = "\(String(describing: scene!.score))"
            scoreNumberLabel.isHidden = false
            startButton.isHidden = true
        }
        
        
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
}
