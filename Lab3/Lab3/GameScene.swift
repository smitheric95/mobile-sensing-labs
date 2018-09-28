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
    let spinBlock = SKSpriteNode()
    var numAsteroids = 3
    var asteroids = Array<SKSpriteNode>()
    var addAsteroidTimer: Timer?
    let scoreLabel = SKLabelNode(fontNamed: "Verdana")
    let bottom = SKSpriteNode()
    var score:Int = 0 {
        willSet(newValue){
            DispatchQueue.main.async{
                self.scoreLabel.text = "Score: \(newValue)"
            }
        }
    }
    
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
                    let randNumberX = self.random(min: CGFloat(0.0), max: CGFloat(0.99))
                    let randNumberY = self.random(min: CGFloat(0.1), max: self.size.height)
                    self.addAstroid(CGPoint(x: self.size.width * randNumberX, y: self.size.height + randNumberY), entity: newAsteroid)
                    newAsteroid.run(asteroidFallMovement)
                    self.asteroids.append(newAsteroid)
                }
                self.score += 1
            }
        }

        
        self.addShip()
        
        self.addScore()
        
        self.addSidesAndTop()  // add borders around perimeter
        
        self.addBottom()
        
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
    
    
    func addShip(){
        let ship = SKSpriteNode(imageNamed: "sprite")
        
        ship.size = CGSize(width:size.width*0.06,height:size.height * 0.06)
        
        ship.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        
        ship.physicsBody = SKPhysicsBody(rectangleOf:ship.size)
        ship.physicsBody?.restitution = CGFloat(0.1)
        ship.physicsBody?.isDynamic = true
        ship.physicsBody?.contactTestBitMask = 0x00000001
        ship.physicsBody?.collisionBitMask = 0x00000001
        ship.physicsBody?.categoryBitMask = 0x00000001
        
        self.addChild(ship)
    }
    
    func addAstroid(_ point:CGPoint, entity:SKSpriteNode){
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
    
    func addBottom() {
        self.bottom.size = CGSize(width:size.width,height:size.height*0.01)
        self.bottom.position = CGPoint(x:size.width*0.5, y:-0.1*size.height)
        self.bottom.physicsBody = SKPhysicsBody(rectangleOf:self.bottom.size)
        self.bottom.physicsBody?.isDynamic = true
        self.bottom.physicsBody?.pinned = true
        self.bottom.physicsBody?.allowsRotation = false
        
        self.addChild(self.bottom)
    }
    
    // MARK: =====Delegate Functions=====
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.addShip()
    }
    
    // MARK: Utility Functions (thanks ray wenderlich!)
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node == self.bottom {
            contact.bodyB.node?.removeFromParent()
        }
        else if contact.bodyB.node == self.bottom {
            contact.bodyA.node?.removeFromParent()
        }
    }
}
