//
//  GameScene.swift
//  Duel
//
//  Created by Zifan  Yang on 5/12/18.
//  Copyright © 2018 Zifan  Yang. All rights reserved.
//

import SpriteKit
import GameplayKit

enum Layer: CGFloat {
    case Background
    case Foreground
    case Player
}

class GameScene: SKScene {
    let worldNode = SKNode()
    var playableStart:CGFloat = 0
    var playableHeight:CGFloat = 0
    let player = SKSpriteNode(imageNamed: "player")
    var timeflag:Int = 0
    var normalJumpAroundFlag:Bool = true
    var rightDashFlag:Bool = false
    
    let playerScale = 0.5
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    
    
    
    override func didMove(to view: SKView) {
        addChild(worldNode)
        setupBackground()
        setupForeground()
        setupPlayer()
        
        let rightSwipe = UISwipeGestureRecognizer()
        rightSwipe.addTarget(self, action: #selector(GameScene.rightSwipe))
        rightSwipe.direction =  UISwipeGestureRecognizerDirection.right
        self.view?.addGestureRecognizer(rightSwipe)

    }
    
    func setupBackground(){
        // 1
        let background = SKSpriteNode(imageNamed: "background")
        background.anchorPoint = CGPoint(x:0.5, y:1)
        background.position = CGPoint(x:size.width/2.0, y:size.height)
        background.zPosition = Layer.Background.rawValue
        print("background")
        print(background.zPosition)
        worldNode.addChild(background)
        
        // 2
        playableStart = size.height - background.size.height
        playableHeight = background.size.height
    }
    
    func setupForeground() {
        
        let foreground = SKSpriteNode(imageNamed: "foreground")
        foreground.anchorPoint = CGPoint(x: 0, y: 1)
        foreground.position = CGPoint(x: 0, y: playableStart)
        foreground.zPosition = Layer.Foreground.rawValue
        print("frontground")
        print(foreground.zPosition)
        worldNode.addChild(foreground)
    }
    
    func setupPlayer(){
        player.scale(to: CGSize(width: 128*playerScale,height: 115*playerScale))
        player.anchorPoint = CGPoint(x: 0.5, y: 2.4)
        player.position = CGPoint(x:size.width * 0.2, y:playableHeight * 0.4 + playableStart)
        player.zPosition = Layer.Player.rawValue
        worldNode.addChild(player)
        
        
    }

    
    
//
//    func touchDown(atPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.green
//            self.addChild(n)
//        }
//    }
//
//    func touchMoved(toPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.blue
//            self.addChild(n)
//        }
//    }
//
//    func touchUp(atPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.red
//            self.addChild(n)
//        }
//    }
//
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
////        if let label = self.label {
////            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
////        }
////
////        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
//        player.texture = SKTexture(imageNamed: "prepare")
//        player.scale(to: CGSize(width: 126,height: 95))
//    }
////
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchesMoved(toPoint: t.location(in: self)) }
//    }
    
    @objc func rightSwipe(sender:UISwipeGestureRecognizer)
    {
        print("recognizing right swipe, performing RIGHT DASH")
        timeflag = 0
        normalJumpAroundFlag = false
        rightDashFlag = true
        
        player.texture = SKTexture(imageNamed: "rightdash")
        player.scale(to: CGSize(width: 153*playerScale,height: 116*playerScale))
    }
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
//    }
//
//    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
//    }
//
//
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        updatePlayer()
    }
    
    func updatePlayer(){
        if normalJumpAroundFlag == true {
            normalJumpAround()
        }
        else if rightDashFlag == true {
            rightDash()
        }
    }
    
    func normalJumpAround() {
        let deltaX = CGFloat(1.5)
        let deltaY = CGFloat(1.5)
        let timeWindow = 8
        if timeflag % timeWindow != 0 {
            timeflag += 1
        }
        else if timeflag == timeWindow * 0 {
            player.position.x += deltaX              //计算player的位置
            player.position.y += deltaY
            timeflag += 1
        }
        else if timeflag == timeWindow * 1 {
            player.position.x += deltaX              //计算player的位置
            player.position.y -= deltaY
            timeflag += 1
        }
        else if timeflag == timeWindow * 2 {
            player.position.x -= deltaX              //计算player的位置
            player.position.y += deltaY
            timeflag += 1
        }
        else if timeflag == timeWindow * 3 {
            player.position.x -= deltaX             //计算player的位置
            player.position.y -= deltaY
            timeflag += 1
        }
            
            
        else if timeflag == timeWindow * 4 {
            player.position.x -= deltaX              //计算player的位置
            player.position.y += deltaY
            timeflag += 1
        }
        else if timeflag == timeWindow * 5 {
            player.position.x -= deltaX              //计算player的位置
            player.position.y -= deltaY
            timeflag += 1
        }
        else if timeflag == timeWindow * 6 {
            player.position.x += deltaX              //计算player的位置
            player.position.y += deltaY
            timeflag += 1
        }
        else if timeflag == timeWindow * 7 {
            player.position.x += deltaX             //计算player的位置
            player.position.y -= deltaY
            timeflag = -1
        }
        else {
            timeflag += 1
        }
    }
    
    func rightDash() {
        let dashDistance = CGFloat(8)
        let timeWindow = 2
        if timeflag % timeWindow != 0 {
            timeflag += 1
        }
        else if timeflag == timeWindow * 0 {
            player.position.x += dashDistance            //计算player的位置
            timeflag += 1
        }
        else if timeflag == timeWindow * 1 {
            player.position.x += dashDistance              //计算player的位置
            timeflag += 1
        }
        else if timeflag == timeWindow * 2 {
            player.position.x += dashDistance              //计算player的位置
            timeflag += 1
        }
        else if timeflag == timeWindow * 3 {
            player.position.x += dashDistance              //计算player的位置
            timeflag += 1
        }
        else if timeflag == timeWindow * 4 {
            player.position.x += dashDistance              //计算player的位置
            timeflag += 1
        }
        else if timeflag == timeWindow * 5 {
            player.position.x += dashDistance              //计算player的位置
            timeflag += 1
        }
        else if timeflag == timeWindow * 6 {
            player.position.x += dashDistance              //计算player的位置
            timeflag += 1
        }
        else if timeflag == timeWindow * 7 {
            player.position.x += dashDistance              //计算player的位置
            timeflag = 0
            
            rightDashFlag = false
            normalJumpAroundFlag = true
            player.texture = SKTexture(imageNamed: "player")
            player.scale(to: CGSize(width: 128*playerScale,height: 115*playerScale))
        }
        else {
            timeflag += 1
        }
    }
    
    
}
