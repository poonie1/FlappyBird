//
//  ViewController.swift
//  FlappyBird
//
//  Created by 大森宗一郎 on 2023/10/12.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // SKViewに型を変換する
                let skView = self.view as! SKView

                // FPSを表示する
                skView.showsFPS = true

                // ノードの数を表示する
                skView.showsNodeCount = true

                // ビューと同じサイズでシーンを作成する
                let scene = GameScene(size:skView.frame.size) // ←GameSceneクラスに変更する

                // ビューにシーンを表示する
                skView.presentScene(scene)
            }
     
    override func didReceiveMemoryWarning() {
          super.didReceiveMemoryWarning()
          // Dispose of any resources that can be recreated.
      }
    
    // ステータスバーを消す --- ここから ---
        override var prefersStatusBarHidden: Bool {
            get {
                return true
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
