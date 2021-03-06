//
//  GameScene.swift
//  Duel
//
//  Created by Zifan  Yang on 5/12/18.
//  Copyright © 2018 Zifan  Yang. All rights reserved.
//

import SpriteKit
import GameplayKit
import AudioToolbox

enum Layer: CGFloat {
    case Background
    case Foreground
    case Player
    case PAi
}

struct PhysicsCategory {
    static let Player: UInt32 =     0b1 // 1
    static let AI: UInt32 =  0b10 // 2
    static let Ground: UInt32 =   0b100 // 4
}

struct Status {
    static let attacking: UInt32 = 0b1
    static let defensing: UInt32 = 0b10
    static let doingNothing: UInt32 = 0b100
}


class GameScene: SKScene,SKPhysicsContactDelegate {
    let worldNode = SKNode()
    var playableStart:CGFloat = 0
    var playableHeight:CGFloat = 0
    
    var hitAI:Bool = false
    var PlayerStatus:UInt32 = Status.doingNothing
    var AIStatus:UInt32 = Status.doingNothing
    
    let player = SKSpriteNode(imageNamed: "player")
    let AI = SKSpriteNode(imageNamed: "AIplayer")
    var timeflag:Int = 0
    var normalJumpAroundFlag:Bool = true
    var forwardDashFlag:Bool = false
    var defenseFlag:Bool = false
    
    var AInormalJumpAroundFlag:Bool = true
    var AIforwardDashFlag:Bool = false
    var AIdefenseFlag:Bool = false
    
    let playerScale = 0.5
    
    var playerRemaindist:CGFloat = 0
    var AIRemaindist:CGFloat = 0
    
    var sleepFlag:Bool = false
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    
    
    
    override func didMove(to view: SKView) {
        addChild(worldNode)
        setupBackground()
        setupForeground()
        setupPlayer()
        setupAI()
        
        physicsWorld.contactDelegate = self
        
        let rightSwipe = UISwipeGestureRecognizer()
        rightSwipe.addTarget(self, action: #selector(GameScene.rightSwipe))
        rightSwipe.direction =  UISwipeGestureRecognizerDirection.right
        self.view?.addGestureRecognizer(rightSwipe)
        
        let leftSwipe = UISwipeGestureRecognizer()
        leftSwipe.addTarget(self, action: #selector(GameScene.leftSwipe))
        leftSwipe.direction =  UISwipeGestureRecognizerDirection.left
        self.view?.addGestureRecognizer(leftSwipe)

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
        
        let lowerLeft = CGPoint(x: 0, y: playableStart)//地板表面的最左侧一点
        let lowerRight = CGPoint(x: size.width, y: playableStart) //地板表面的最右侧一点
        
        self.physicsBody = SKPhysicsBody(edgeFrom: lowerLeft, to: lowerRight)
        self.physicsBody?.categoryBitMask = PhysicsCategory.Ground
        self.physicsBody?.collisionBitMask = PhysicsCategory.Player | PhysicsCategory.AI
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Player | PhysicsCategory.AI
        
        worldNode.addChild(foreground)
    }
    
    func setupPlayer(){
        player.scale(to: CGSize(width: 128*playerScale,height: 115*playerScale))
//        player.anchorPoint = CGPoint(x: 0.5, y: 2.4)
        player.position = CGPoint(x:size.width * 0.2, y:playableHeight * 0.4 + playableStart)
        player.zPosition = Layer.Player.rawValue
        
        
        player.physicsBody = SKPhysicsBody(circleOfRadius: 25)
        player.physicsBody?.categoryBitMask = PhysicsCategory.Player
        player.physicsBody?.collisionBitMask = PhysicsCategory.Ground
        player.physicsBody?.contactTestBitMask = PhysicsCategory.AI
        
        PlayerStatus = Status.doingNothing
        worldNode.addChild(player)
    }
    
    func setupAI(){
        AI.scale(to: CGSize(width: 128*playerScale,height: 115*playerScale))
//        AI.anchorPoint = CGPoint(x: 7.5, y: 5.4)
        AI.position = CGPoint(x:size.width * 0.8, y:playableHeight * 0.4 + playableStart)
        AI.zPosition = Layer.PAi.rawValue
        
        
        AI.physicsBody = SKPhysicsBody(circleOfRadius: 25)
        AI.physicsBody?.categoryBitMask = PhysicsCategory.AI
        AI.physicsBody?.collisionBitMask = PhysicsCategory.Ground
        AI.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        
        AIStatus = Status.doingNothing
        worldNode.addChild(AI)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let other = contact.bodyA.categoryBitMask == PhysicsCategory.Player ? contact.bodyB : contact.bodyA

        if other.categoryBitMask == PhysicsCategory.AI {
//            hitAI = true
            if PlayerStatus == Status.attacking && (AIStatus == Status.doingNothing) {
                AIFall()
            }
            else if AIStatus == Status.attacking && (PlayerStatus == Status.doingNothing) {
                PlayerFall()
            }
            else if PlayerStatus == Status.attacking && AIStatus == Status.attacking {
                if playerRemaindist >= AIRemaindist {
                    AIFall()
                }
                else {
                    PlayerFall()
                }
            }
        }
        else if other.categoryBitMask == PhysicsCategory.Ground {
//            print("## hit ground ##")
        }
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
        print("recognizing right swipe, performing Forward DASH")
        timeflag = 0
        
        playerRemaindist = 7*8
        
        activeOneFlag(activeFlag: "forwardDashFlag")
        AIactiveOneFlag(activeFlag: randomAIFlag())
        
        player.texture = SKTexture(imageNamed: "rightdash")
        player.scale(to: CGSize(width: 153*playerScale,height: 116*playerScale))
    }
    
    @objc func leftSwipe(sender:UISwipeGestureRecognizer)
    {
        print("recognizing left swipe, performing Defense")
        timeflag = 0
        
        playerRemaindist = 0
        
        activeOneFlag(activeFlag: "defenseFlag")
        AIactiveOneFlag(activeFlag: randomAIFlag())
        
        player.texture = SKTexture(imageNamed: "defense1")
        player.scale(to: CGSize(width: 140*playerScale,height: 117*playerScale))
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
        checkHitAI()
        updateAI()
        checkHitAI()
    }
    
    func checkHitAI() {
        if hitAI == true {
            if PlayerStatus == Status.attacking && (AIStatus == Status.doingNothing) {
                AIFall()
            }
            else if AIStatus == Status.attacking && (PlayerStatus == Status.doingNothing) {
                PlayerFall()
            }
        }
    }
    
    func AIFall() {
        if sleepFlag == false {
            sleepFlag = true
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            Thread.sleep(forTimeInterval: 1.0)
        }
        AI.physicsBody?.collisionBitMask = 0
    }
    
    func PlayerFall() {
        if sleepFlag == false {
            sleepFlag = true
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            Thread.sleep(forTimeInterval: 1.0)
        }
        player.physicsBody?.collisionBitMask = 0
    }
    
    func updatePlayer(){
        if normalJumpAroundFlag == true {
            normalJumpAround()
        }
        else if forwardDashFlag == true {
            forwardDash()
        }
        else if defenseFlag == true {
            defense()
        }
    }
    
    func normalJumpAround() {
        PlayerStatus = Status.doingNothing
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
    
    func forwardDash() {
        PlayerStatus = Status.attacking
        let dashDistance = CGFloat(8)
        let timeWindow = 2
        if timeflag % timeWindow != 0 {
//            player.position.y = playableHeight * 0.4 + playableStart
            timeflag += 1
        }
        else if timeflag == timeWindow * 0 {
//            player.position.x += dashDistance            //计算player的位置
            playerConditionalMove(dist: dashDistance, dict: "right")
//            player.position.y = playableHeight * 0.4 + playableStart
            timeflag += 1
            playerRemaindist -= abs(dashDistance)
        }
        else if timeflag == timeWindow * 1 {
//            player.position.x += dashDistance              //计算player的位置
            playerConditionalMove(dist: dashDistance, dict: "right")
//            player.position.y = playableHeight * 0.4 + playableStart
            timeflag += 1
            playerRemaindist -= abs(dashDistance)
        }
        else if timeflag == timeWindow * 2 {
//            player.position.x += dashDistance              //计算player的位置
            playerConditionalMove(dist: dashDistance, dict: "right")
//            player.position.y = playableHeight * 0.4 + playableStart
            timeflag += 1
            playerRemaindist -= abs(dashDistance)
        }
        else if timeflag == timeWindow * 3 {
//            player.position.x += dashDistance              //计算player的位置
            playerConditionalMove(dist: dashDistance, dict: "right")
//            player.position.y = playableHeight * 0.4 + playableStart
            timeflag += 1
            playerRemaindist -= abs(dashDistance)
        }
        else if timeflag == timeWindow * 4 {
//            player.position.x += dashDistance              //计算player的位置
            playerConditionalMove(dist: dashDistance, dict: "right")
//            player.position.y = playableHeight * 0.4 + playableStart
            timeflag += 1
            playerRemaindist -= abs(dashDistance)
        }
        else if timeflag == timeWindow * 5 {
//            player.position.x += dashDistance              //计算player的位置
            playerConditionalMove(dist: dashDistance, dict: "right")
//            player.position.y = playableHeight * 0.4 + playableStart
            timeflag += 1
            playerRemaindist -= abs(dashDistance)
        }
        else if timeflag == timeWindow * 6 {
//            player.position.x += dashDistance              //计算player的位置
            playerConditionalMove(dist: dashDistance, dict: "right")
//            player.position.y = playableHeight * 0.4 + playableStart
            timeflag += 1
            playerRemaindist -= abs(dashDistance)
        }
        else if timeflag == timeWindow * 7 {
//            player.position.x += dashDistance              //计算player的位置
            playerConditionalMove(dist: dashDistance, dict: "right")
//            player.position.y = playableHeight * 0.4 + playableStart
            timeflag = 0
            playerRemaindist -= abs(dashDistance)
            
            activeOneFlag(activeFlag: "normalJumpAroundFlag")
            
            player.texture = SKTexture(imageNamed: "player")
            player.scale(to: CGSize(width: 128*playerScale,height: 115*playerScale))
            PlayerStatus = Status.doingNothing
            playerRemaindist = 0
//            player.position.y = playableHeight * 0.4 + playableStart
        }
        else {
            timeflag += 1
        }
    }
    
    func defense() {
        let dashDistance = CGFloat(4)
        let timeWindow = 2
        PlayerStatus = Status.defensing
        if timeflag % timeWindow != 0 {
            timeflag += 1
        }
        else if timeflag == timeWindow * 0 {
//            player.position.x -= dashDistance            //计算player的位置
            playerConditionalMove(dist: dashDistance, dict: "left")
//            player.position.y = playableHeight * 0.4 + playableStart
            timeflag += 1
        }
        else if timeflag == timeWindow * 1 {
//            player.position.x -= dashDistance              //计算player的位置
            playerConditionalMove(dist: dashDistance, dict: "left")
//            player.position.y = playableHeight * 0.4 + playableStart
            timeflag += 1
        }
        else if timeflag == timeWindow * 2 {
//            player.position.x -= dashDistance              //计算player的位置
            playerConditionalMove(dist: dashDistance, dict: "left")
            timeflag += 1
            player.texture = SKTexture(imageNamed: "defense2")
            player.scale(to: CGSize(width: 138*playerScale,height: 117*playerScale))
//            player.position.y = playableHeight * 0.4 + playableStart
        }
        else if timeflag == timeWindow * 3 {
//            player.position.x -= dashDistance              //计算player的位置
            playerConditionalMove(dist: dashDistance, dict: "left")
//            player.position.y = playableHeight * 0.4 + playableStart
            timeflag += 1
        }
        else if timeflag == timeWindow * 4 {
//            player.position.x -= dashDistance              //计算player的位置
            playerConditionalMove(dist: dashDistance, dict: "left")
//            player.position.y = playableHeight * 0.4 + playableStart
            
            timeflag += 1
            player.texture = SKTexture(imageNamed: "defense3")
            player.scale(to: CGSize(width: 142*playerScale,height: 116*playerScale))
//            player.position.y = playableHeight * 0.4 + playableStart
        }
        else if timeflag == timeWindow * 5 {
//            player.position.x -= dashDistance              //计算player的位置
            playerConditionalMove(dist: dashDistance, dict: "left")
//            player.position.y = playableHeight * 0.4 + playableStart
            timeflag += 1
        }
        else if timeflag == timeWindow * 6 {
//            player.position.x -= dashDistance              //计算player的位置
            playerConditionalMove(dist: dashDistance, dict: "left")
//            player.position.y = playableHeight * 0.4 + playableStart
            timeflag += 1
        }
        else if timeflag == timeWindow * 7 {
//            player.position.x -= dashDistance              //计算player的位置
            playerConditionalMove(dist: dashDistance, dict: "left")
//            player.position.y = playableHeight * 0.4 + playableStart
            timeflag = 0
            
            activeOneFlag(activeFlag: "normalJumpAroundFlag")
            
            player.texture = SKTexture(imageNamed: "player")
            player.scale(to: CGSize(width: 128*playerScale,height: 115*playerScale))
//            player.position.y = playableHeight * 0.4 + playableStart
            PlayerStatus = Status.doingNothing
        }
        else {
            timeflag += 1
        }
    }
    
    
    func activeOneFlag(activeFlag:String) {
        normalJumpAroundFlag = false
        forwardDashFlag = false
        defenseFlag = false
        
        if activeFlag == "normalJumpAroundFlag" {
            normalJumpAroundFlag = true
        }
        else if activeFlag == "forwardDashFlag" {
            forwardDashFlag = true
        }
        else if activeFlag == "defenseFlag" {
            defenseFlag = true
        }
    }
    
    func updateAI(){
        if AInormalJumpAroundFlag == true {
            AI.texture = SKTexture(imageNamed: "AIplayer")
            AI.scale(to: CGSize(width: 128*playerScale,height: 115*playerScale))
            AIStatus = Status.doingNothing
            AInormalJumpAround()
        }
        else if AIforwardDashFlag == true {
            AI.texture = SKTexture(imageNamed: "AIrightdash")
            AI.scale(to: CGSize(width: 153*playerScale,height: 116*playerScale))
            AIStatus = Status.attacking
            AIforwardDash()
        }
        else if AIdefenseFlag == true {
            AI.texture = SKTexture(imageNamed: "AIdefense1")
            AI.scale(to: CGSize(width: 140*playerScale,height: 117*playerScale))
            AIStatus = Status.defensing
            AIdefense()
        }
    }
    
    func AInormalJumpAround() {
        AIStatus = Status.doingNothing

        let deltaX = CGFloat(1.5)
        let deltaY = CGFloat(1.5)
        let timeWindow = 8
        if timeflag % timeWindow != 0 {
        }
        else if timeflag == timeWindow * 0 {
            AI.position.x += deltaX              //计算player的位置
            AI.position.y += deltaY
        }
        else if timeflag == timeWindow * 1 {
            AI.position.x += deltaX              //计算player的位置
            AI.position.y -= deltaY
        }
        else if timeflag == timeWindow * 2 {
            AI.position.x -= deltaX              //计算player的位置
            AI.position.y += deltaY
        }
        else if timeflag == timeWindow * 3 {
            AI.position.x -= deltaX             //计算player的位置
            AI.position.y -= deltaY
        }
            
            
        else if timeflag == timeWindow * 4 {
            AI.position.x -= deltaX              //计算player的位置
            AI.position.y += deltaY
        }
        else if timeflag == timeWindow * 5 {
            AI.position.x -= deltaX              //计算player的位置
            AI.position.y -= deltaY
        }
        else if timeflag == timeWindow * 6 {
            AI.position.x += deltaX              //计算player的位置
            AI.position.y += deltaY
        }
        else if timeflag == timeWindow * 7 {
            AI.position.x += deltaX             //计算player的位置
            AI.position.y -= deltaY
        }
        else {
        }
    }
    
    func AIforwardDash() {
        AIStatus = Status.attacking
        let dashDistance = CGFloat(-8)
        let timeWindow = 2
        if timeflag % timeWindow != 0 {
            //            player.position.y = playableHeight * 0.4 + playableStart
        }
        else if timeflag == timeWindow * 0 {
//            AI.position.x += dashDistance            //计算player的位置
            AIConditionalMove(dist:abs(dashDistance), dict:"left")
            AIRemaindist -= abs(dashDistance)
        }
        else if timeflag == timeWindow * 1 {
//            AI.position.x += dashDistance              //计算player的位置
            AIConditionalMove(dist:abs(dashDistance), dict:"left")
            AIRemaindist -= abs(dashDistance)
        }
        else if timeflag == timeWindow * 2 {
//            AI.position.x += dashDistance              //计算player的位置
            AIConditionalMove(dist:abs(dashDistance), dict:"left")
            AIRemaindist -= abs(dashDistance)
        }
        else if timeflag == timeWindow * 3 {
//            AI.position.x += dashDistance              //计算player的位置
            AIConditionalMove(dist:abs(dashDistance), dict:"left")
            AIRemaindist -= abs(dashDistance)
        }
        else if timeflag == timeWindow * 4 {
//            AI.position.x += dashDistance              //计算player的位置
            AIConditionalMove(dist:abs(dashDistance), dict:"left")
            AIRemaindist -= abs(dashDistance)
        }
        else if timeflag == timeWindow * 5 {
//            AI.position.x += dashDistance              //计算player的位置
            AIConditionalMove(dist:abs(dashDistance), dict:"left")
            AIRemaindist -= abs(dashDistance)
        }
        else if timeflag == timeWindow * 6 {
//            AI.position.x += dashDistance              //计算player的位置
            AIConditionalMove(dist:abs(dashDistance), dict:"left")
            AIRemaindist -= abs(dashDistance)
        }
        else if timeflag == timeWindow * 7 {
//            AI.position.x += dashDistance              //计算player的位置
            AIConditionalMove(dist:abs(dashDistance), dict:"left")
            AIRemaindist -= abs(dashDistance)
            
            AIactiveOneFlag(activeFlag: "AInormalJumpAroundFlag")
            
            AI.texture = SKTexture(imageNamed: "AIplayer")
            AI.scale(to: CGSize(width: 128*playerScale,height: 115*playerScale))
            AIStatus = Status.doingNothing
            AIRemaindist = 0
        }
        else {
        }
    }
    
    func AIdefense() {
        let dashDistance = CGFloat(-4)
        let timeWindow = 2
        AIStatus = Status.defensing
        if timeflag % timeWindow != 0 {
        }
        else if timeflag == timeWindow * 0 {
//            AI.position.x -= dashDistance            //计算player的位置
            AIConditionalMove(dist:abs(dashDistance), dict:"right")
        }
        else if timeflag == timeWindow * 1 {
//            AI.position.x -= dashDistance              //计算player的位置
            AIConditionalMove(dist:abs(dashDistance), dict:"right")
        }
        else if timeflag == timeWindow * 2 {
//            AI.position.x -= dashDistance              //计算player的位置
            AIConditionalMove(dist:abs(dashDistance), dict:"right")
            AI.texture = SKTexture(imageNamed: "AIdefense2")
            AI.scale(to: CGSize(width: 138*playerScale,height: 117*playerScale))
        }
        else if timeflag == timeWindow * 3 {
//            AI.position.x -= dashDistance              //计算player的位置
            AIConditionalMove(dist:abs(dashDistance), dict:"right")
        }
        else if timeflag == timeWindow * 4 {
//            AI.position.x -= dashDistance              //计算player的位置
            AIConditionalMove(dist:abs(dashDistance), dict:"right")

            AI.texture = SKTexture(imageNamed: "AIdefense3")
            AI.scale(to: CGSize(width: 142*playerScale,height: 116*playerScale))
        }
        else if timeflag == timeWindow * 5 {
//            AI.position.x -= dashDistance              //计算player的位置
            AIConditionalMove(dist:abs(dashDistance), dict:"right")
        }
        else if timeflag == timeWindow * 6 {
//            AI.position.x -= dashDistance              //计算player的位置
            AIConditionalMove(dist:abs(dashDistance), dict:"right")
        }
        else if timeflag == timeWindow * 7 {
//            AI.position.x -= dashDistance              //计算player的位置
            AIConditionalMove(dist:abs(dashDistance), dict:"right")
            
            AIactiveOneFlag(activeFlag: "AInormalJumpAroundFlag")
            
            AI.texture = SKTexture(imageNamed: "AIplayer")
            AI.scale(to: CGSize(width: 128*playerScale,height: 115*playerScale))
            AIStatus = Status.doingNothing
        }
        else {
        }
    }
    
    
    func AIactiveOneFlag(activeFlag:String) {
        AInormalJumpAroundFlag = false
        AIforwardDashFlag = false
        AIdefenseFlag = false
        
        if activeFlag == "AInormalJumpAroundFlag" {
            AIRemaindist = 0
            AInormalJumpAroundFlag = true
        }
        else if activeFlag == "AIforwardDashFlag" {
            AIRemaindist = 7*8
            AIforwardDashFlag = true
        }
        else if activeFlag == "AIdefenseFlag" {
            AIRemaindist = 0
            AIdefenseFlag = true
        }
    }
    
    func randomAIFlag() -> String {
        let diceFaceCount: UInt32 = 2
        let randomRoll = Int(arc4random_uniform(diceFaceCount))+1
        if randomRoll == 1 {
            return "AIforwardDashFlag"
        }
        else if randomRoll == 2 {
            return  "AIdefenseFlag"
        }
        return "AInormalJumpAroundFlag"
    }
    
    func playerConditionalMove(dist:CGFloat, dict:String) {
        if dict == "left" {
            if player.position.x - dist <= size.width * 0.05 {
                player.position.x = size.width * 0.05
            }
            else {
                player.position.x -= dist
            }
        }
        else {
            if player.position.x + dist >= size.width * (1-0.1) {
                player.position.x = size.width * (1-0.1)
            }
            else {
                player.position.x += dist
            }
        }
    }
    
    func AIConditionalMove(dist:CGFloat, dict:String) {
        if dict == "left" {
            if AI.position.x - dist <= size.width * 0.1 {
                AI.position.x = size.width * 0.1
            }
            else {
                AI.position.x -= dist
            }
        }
        else {
            if AI.position.x + dist >= size.width * (1-0.05) {
                AI.position.x = size.width * (1-0.05)
            }
            else {
                AI.position.x += dist
            }
        }
    }
    
}
