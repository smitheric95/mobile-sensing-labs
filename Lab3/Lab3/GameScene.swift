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
    var numAsteroids = 1
    var asteroids = Array<SKSpriteNode>()
    var addAsteroidTimer: Timer?
    var asteroidFallSpeed = 15.0  // higher == slower
    
    let scoreLabel = SKLabelNode(fontNamed: "Verdana")
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
        let concurrentQueue = DispatchQueue(label: "addAsteroidQueue", attributes: .concurrent)
        // add timer for creating asteroids (we want this to happen asap)
        self.addAsteroidTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
            for _ in 0...self.numAsteroids {
                concurrentQueue.async {
                    usleep(UInt32.random(in: 20000...2000000))
                    DispatchQueue.main.async {
                        self.asteroids.append(self.addAstroid())
                    }
                }
            }
            if self.asteroidFallSpeed > 2.0 {
                self.asteroidFallSpeed = self.asteroidFallSpeed - 0.5
                self.numAsteroids += 1
            }
            
            self.score += 1
        }
        
        physicsWorld.contactDelegate = self
        backgroundColor = SKColor.black
        
        // start motion for gravity
        self.startMotionUpdates()
        
        self.addShip()
        
        self.addScore()
        
        self.addSidesAndTop()  // add borders around perimeter
        
        self.score = 0
    }
    
    // MARK: Create Sprites Functions
    func addScore(){
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = SKColor.white
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.minY)
        
        addChild(scoreLabel)
    }
    
    
    func addShip(){
        let ship = SKSpriteNode(imageNamed: "ship")
        
        ship.size = CGSize(width:size.width*0.1,height:size.height * 0.1)
        
        ship.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        
        ship.physicsBody = SKPhysicsBody(rectangleOf:ship.size)
        ship.physicsBody?.restitution = CGFloat(0.1)
        ship.physicsBody?.isDynamic = true
        ship.physicsBody?.contactTestBitMask = 0x00000001
        ship.physicsBody?.collisionBitMask = 0x00000001
        ship.physicsBody?.categoryBitMask = 0x00000001
        
        self.addChild(ship)
    }
    
    func addAstroid() -> SKSpriteNode{
        let newAsteroid = SKSpriteNode(imageNamed: "asteroid")
        
        // make asteroid a random size
        let randomSize = size.width * random(min: CGFloat(0.005), max: CGFloat(0.19))
        newAsteroid.size = CGSize(width:randomSize,height:randomSize)
        
        // put asteroid at random location across the top of the screen
        let randNumberX = self.random(min: CGFloat(0.0), max: CGFloat(0.99))
        let randNumberY = self.random(min: CGFloat(0.1), max: self.size.height)
        newAsteroid.position = CGPoint(x: self.size.width * randNumberX, y: self.size.height + randNumberY)
        
        // rotate the astroid
        newAsteroid.zRotation = self.random(min: 0, max: 2 * .pi)
        
        newAsteroid.physicsBody = SKPhysicsBody(rectangleOf:newAsteroid.size)
        newAsteroid.physicsBody?.contactTestBitMask = 0x00000001
        newAsteroid.physicsBody?.collisionBitMask = 0x00000001
        newAsteroid.physicsBody?.categoryBitMask = 0x00000001
        newAsteroid.physicsBody?.isDynamic = false
        
        // make asteroid fall
        newAsteroid.run(SKAction.moveTo(y: -1 * (newAsteroid.position.y + self.size.height), duration: self.asteroidFallSpeed))
        
        self.addChild(newAsteroid)
        
        return newAsteroid
    }
    
    // draws a barrier that ship can't get past
    func addSidesAndTop(){
        let left = SKSpriteNode()
        let right = SKSpriteNode()
        let top = SKSpriteNode()
        
        left.size = CGSize(width:size.width*0.001,height:size.height)
        left.position = CGPoint(x:0, y:size.height*0.5)
        
        right.size = CGSize(width:size.width*0.001,height:size.height)
        right.position = CGPoint(x:size.width, y:size.height*0.5)
        
        top.size = CGSize(width:size.width,height:size.height*0.001)
        top.position = CGPoint(x:size.width*0.5, y:size.height)
        
        for obj in [left,right,top]{
            obj.color = UIColor.black
            obj.physicsBody = SKPhysicsBody(rectangleOf:obj.size)
            obj.physicsBody?.isDynamic = true
            obj.physicsBody?.pinned = true
            obj.physicsBody?.allowsRotation = false
            self.addChild(obj)
        }
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
}
