//
//  GameViewController.swift
//  Duel
//
//  Created by Zifan  Yang on 5/12/18.
//  Copyright © 2018 Zifan  Yang. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

//    override func viewDidLoad() {
//        let scene = GameScene(size: view.frame.size)
//        let skView = view as! SKView
//        skView.presentScene(scene)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if let view = self.view as! SKView? {
//            // Load the SKScene from 'GameScene.sks'
//            if let scene = SKScene(fileNamed: "GameScene") {
//                // Set the scale mode to scale to fit the window
//                scene.scaleMode = .aspectFill
//
//                // Present the scene
//                view.presentScene(scene)
//            }
//
//            view.ignoresSiblingOrder = true
//
//            view.showsFPS = true
//            view.showsNodeCount = true
//        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // 1.对view进行父类向子类的变形，结果是一个可选类型 因此需要解包
        if let  skView = self.view as? SKView{
            // 倘若skView中没有场景Scene，需要重新创建创建一个
            if skView.scene == nil{
                
                /*==  创建场景代码  ==*/
                
                // 2.获得高宽比例
                let aspectRatio = skView.bounds.size.height / skView.bounds.size.width
                // 3.new一个场景实例 这里注意场景的width始终为320 至于高是通过width * aspectRatio获得
                let scene = GameScene(size: CGSize(width: 320, height: 320 * aspectRatio))
                
                // 4.设置一些调试参数
                skView.showsFPS = true          // 显示帧数
                skView.showsNodeCount = true    // 显示当前场景下节点个数
                skView.showsPhysics = true      // 显示物理体
                skView.ignoresSiblingOrder = true   // 忽略节点添加顺序
                
                // 5.设置场景呈现模式
                scene.scaleMode = .aspectFill
                
                // 6.呈现场景
                skView.presentScene(scene)
            }
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
