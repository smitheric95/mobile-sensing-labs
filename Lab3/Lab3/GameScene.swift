//
//  GameScene.swift
//  Lab3
//
//  Created by Eric Smith on 9/25/18.
//  Copyright © 2018 Jake Carlson. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //@IBOutlet weak var scoreLabel: UILabel!
    
    // MARK: Raw Motion Functions
    let motion = CMMotionManager()
    func startMotionUpdates(){        
        if self.motion.isDeviceMotionAvailable{
            self.motion.deviceMotionUpdateInterval = 0.1
            self.motion.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: self.handleMotion )
        }
    }
    
    func handleMotion(_ motionData:CMDeviceMotion?, error:Error?){
        if let gravity = motionData?.gravity {
            self.physicsWorld.gravity = CGVector(dx: CGFloat(9.8*gravity.x), dy: CGFloat(9.8*gravity.y))
        }
        
    }
    
    // MARK: View Hierarchy Functions
    let spinBlock = SKSpriteNode()
    var numAsteroids = 3
    var asteroids = Array<SKSpriteNode>()
    var addAsteroidTimer: Timer?
    let scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
    var score:Int = 0 {
        willSet(newValue){
            DispatchQueue.main.async{
                self.scoreLabel.text = "Score: \(newValue)"
            }
        }
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        backgroundColor = SKColor.white
        
        let asteroidFallMovement = SKAction.moveTo(y: -100, duration: 10)
        
        // start motion for gravity
        self.startMotionUpdates()
    
        
        // add timer for creating asteroids
        self.addAsteroidTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) {
            _ in DispatchQueue.main.async {
                for _ in 0...self.numAsteroids {
                    let newAsteroid = SKSpriteNode()
                    let randNumberX = self.random(min: CGFloat(0.1), max: CGFloat(0.9))
                    let randNumberY = self.random(min: CGFloat(0.1), max: self.size.height)
                    self.addBlockAtPoint(CGPoint(x: self.size.width * randNumberX, y: self.size.height + randNumberY), entity: newAsteroid)
                    newAsteroid.run(asteroidFallMovement)
                    self.asteroids.append(newAsteroid)
                }
            }
        }
        
        // add asteroid
        self.addBlockAtPoint(CGPoint(x: size.width * 0.7, y: size.height * 0.99), entity:self.spinBlock)
       
        self.spinBlock.run(asteroidFallMovement)
        
        self.addSprite()
        
        self.addScore()
        
        self.addSidesAndTop()
        
        self.score = 0
    }
    
    // MARK: Create Sprites Functions
    func addScore(){
        
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = SKColor.blue
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.minY)
        
        addChild(scoreLabel)
    }
    
    
    func addSprite(){
        let spriteA = SKSpriteNode(imageNamed: "sprite") // this is literally a sprite bottle... 😎
        
        spriteA.size = CGSize(width:size.width*0.1,height:size.height * 0.1)
        
        let randNumber = random(min: CGFloat(0.1), max: CGFloat(0.9))
        spriteA.position = CGPoint(x: size.width * randNumber, y: size.height * 0.75)
        
        spriteA.physicsBody = SKPhysicsBody(rectangleOf:spriteA.size)
        spriteA.physicsBody?.restitution = random(min: CGFloat(1.0), max: CGFloat(1.5))
        spriteA.physicsBody?.isDynamic = true
        spriteA.physicsBody?.contactTestBitMask = 0x00000001
        spriteA.physicsBody?.collisionBitMask = 0x00000001
        spriteA.physicsBody?.categoryBitMask = 0x00000001
        
        self.addChild(spriteA)
    }
    
    func addBlockAtPoint(_ point:CGPoint, entity:SKSpriteNode){
        entity.color = UIColor.red
        let randNumberX = random(min: CGFloat(0.005), max: CGFloat(0.12))
        let randNumberY = random(min: CGFloat(0.005), max: CGFloat(0.1))
        entity.size = CGSize(width:size.width*randNumberX,height:size.height * randNumberY)
        entity.position = point
        
        entity.physicsBody = SKPhysicsBody(rectangleOf:entity.size)
        entity.physicsBody?.contactTestBitMask = 0x00000001
        entity.physicsBody?.collisionBitMask = 0x00000001
        entity.physicsBody?.categoryBitMask = 0x00000001
    
        entity.physicsBody?.velocity.dy = 0.5
        entity.physicsBody?.isDynamic = false
        
        self.addChild(entity)
    }
    
    func addStaticBlockAtPoint(_ point:CGPoint){
        let 🔲 = SKSpriteNode()
        
        🔲.color = UIColor.red
        🔲.size = CGSize(width:size.width*0.1,height:size.height * 0.05)
        🔲.position = point
        
        🔲.physicsBody = SKPhysicsBody(rectangleOf:🔲.size)
        🔲.physicsBody?.isDynamic = false
        🔲.physicsBody?.pinned = true
        🔲.physicsBody?.allowsRotation = true
        
        self.addChild(🔲)
        
    }
    
    func addSidesAndTop(){
        let left = SKSpriteNode()
        let right = SKSpriteNode()
        let top = SKSpriteNode()
        
        left.size = CGSize(width:size.width*0.01,height:size.height)
        left.position = CGPoint(x:0, y:size.height*0.5)
        
        right.size = CGSize(width:size.width*0.01,height:size.height)
        right.position = CGPoint(x:size.width, y:size.height*0.5)
        
        top.size = CGSize(width:size.width,height:size.height*0.01)
        top.position = CGPoint(x:size.width*0.5, y:size.height)
        
        for obj in [left,right,top]{
            obj.color = UIColor.red
            obj.physicsBody = SKPhysicsBody(rectangleOf:obj.size)
            obj.physicsBody?.isDynamic = true
            obj.physicsBody?.pinned = true
            obj.physicsBody?.allowsRotation = false
            self.addChild(obj)
        }
    }
    
    // MARK: =====Delegate Functions=====
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.addSprite()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node == spinBlock || contact.bodyB.node == spinBlock {
            self.score += 1
        }
    }
    
    // MARK: Utility Functions (thanks ray wenderlich!)
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
}
