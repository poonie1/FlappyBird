//
//  GameScene.swift
//  FlappyBird
//
//  Created by 大森宗一郎 on 2023/10/12.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene , SKPhysicsContactDelegate /* 追加 */ {
    
    var itemPlayer: AVAudioPlayer! = nil //再生するサウンドのインスタンス
    var bgmPlayer: AVAudioPlayer! = nil
    var attackPlayer: AVAudioPlayer! = nil  //課題用に追加
    
    var scrollNode:SKNode!
    var wallNode:SKNode!    // 追加
    var bird:SKSpriteNode!    // 追加
    var itemNode:SKNode!  // 課題用に追加
    
    // 衝突判定カテゴリー ↓追加
    let birdCategory: UInt32 = 1 << 0       // 0...00001
    let groundCategory: UInt32 = 1 << 1     // 0...00010
    let wallCategory: UInt32 = 1 << 2       // 0...00100
    let scoreCategory: UInt32 = 1 << 3      // 0...01000
    let itemScoreCategory: UInt32 = 1 << 4  //課題用に追加
    
    // スコア用
    var score = 0  // ←追加
    var itemScore = 0  // 課題用に追加
    var scoreLabelNode:SKLabelNode!    // ←追加
    var bestScoreLabelNode:SKLabelNode!    // ←追加
    var itemScoreLabelNode:SKLabelNode!   //課題用に追加
    let userDefaults:UserDefaults = UserDefaults.standard    // 追加
    
    // SKView上にシーンが表示されたときに呼ばれるメソッド
    override func didMove(to view: SKView) {
        
               // 再生する音声ファイルを指定する
               let itemSoundURL = Bundle.main.url(forResource: "itemSound", withExtension: "mp3")
               do {
                   // 効果音を鳴らす
                   itemPlayer = try AVAudioPlayer(contentsOf: itemSoundURL!)
               } catch {
                   print("error...")
               }
        
        //bgmを鳴らす
                let bgmSoundURL = Bundle.main.url(forResource: "flappyBgm", withExtension: "mp3")
                do {
                    bgmPlayer = try AVAudioPlayer(contentsOf: bgmSoundURL!)
                    bgmPlayer.numberOfLoops = 1000
                    bgmPlayer?.play()
                } catch {
                    print("error...")
                }
                
                //衝突音を鳴らす
                let attackSoundURL = Bundle.main.url(forResource: "attackSound", withExtension: "mp3")
                do {
                    attackPlayer = try AVAudioPlayer(contentsOf: attackSoundURL!)
                } catch {
                    print("error...")
                }
        
        // 重力を設定
        physicsWorld.gravity = CGVector(dx: 0, dy: -4.0)    // ←追加
        physicsWorld.contactDelegate = self // ←追加
        
        // 背景色を設定
        backgroundColor = UIColor(red: 0.15, green: 0.75, blue: 0.90, alpha: 1)
        
        // スクロールするスプライトの親ノード
        scrollNode = SKNode()
        addChild(scrollNode)
        
        // 壁用のノード
        wallNode = SKNode()   // 追加
        scrollNode.addChild(wallNode)   // 追加
        
        //アイテム用のノード
                itemNode = SKNode()
                scrollNode.addChild(itemNode)   //scrollNodeに追加  //課題用に追加
        
        // 各種スプライトを生成する処理をメソッドに分割
        setupGround()
        setupCloud()
        setupWall()   // 追加
        setupBird()   // 追加
        setupItem()   //課題用に追加
        
        // スコア表示ラベルの設定
               setupScoreLabel()   // 追加
        
        func setupScoreLabel() {
                // スコア表示を作成
                score = 0
                scoreLabelNode = SKLabelNode()
                scoreLabelNode.fontColor = UIColor.black
                scoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 60)
                scoreLabelNode.zPosition = 100 // 一番手前に表示する
                scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
                scoreLabelNode.text = "Score:\(score)"
                self.addChild(scoreLabelNode)

                    itemScore = 0    //課題用に追加
                    itemScoreLabelNode = SKLabelNode()
                    itemScoreLabelNode.fontColor = UIColor.black
                    itemScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 120)
                    itemScoreLabelNode.zPosition = 100 // 一番手前に表示する
                    itemScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
                    itemScoreLabelNode.text = "Item Score:\(itemScore)"
                    self.addChild(itemScoreLabelNode)
            
                // ベストスコア表示を作成
                let bestScore = userDefaults.integer(forKey: "BEST")
                bestScoreLabelNode = SKLabelNode()
                bestScoreLabelNode.fontColor = UIColor.black
                bestScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 90)
                bestScoreLabelNode.zPosition = 100 // 一番手前に表示する
                bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
                bestScoreLabelNode.text = "Best Score:\(bestScore)"
                self.addChild(bestScoreLabelNode)
            }
        
    }
    
    func setupGround() {
        // 地面の画像を読み込む
        let groundTexture = SKTexture(imageNamed: "ground")
        groundTexture.filteringMode = .nearest
        
        // 必要な枚数を計算
        let needNumber = Int(self.frame.size.width / groundTexture.size().width) + 2
        
        // スクロールするアクションを作成
        // 左方向に画像一枚分スクロールさせるアクション
        let moveGround = SKAction.moveBy(x: -groundTexture.size().width, y: 0, duration: 5)
        
        // 元の位置に戻すアクション
        let resetGround = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0)
        
        // 左にスクロール->元の位置->左にスクロールと無限に繰り返すアクション
        let repeatScrollGround = SKAction.repeatForever(SKAction.sequence([moveGround, resetGround]))
        
        // groundのスプライトを配置する
        for i in 0..<needNumber {
            let sprite = SKSpriteNode(texture: groundTexture)
            
            // スプライトの表示する位置を指定する
            sprite.position = CGPoint(
                x: groundTexture.size().width / 2  + groundTexture.size().width * CGFloat(i),
                y: groundTexture.size().height / 2
            )
            
            // スプライトにアクションを設定する
            sprite.run(repeatScrollGround)
            
            // スプライトに物理体を設定する
            sprite.physicsBody = SKPhysicsBody(rectangleOf: groundTexture.size())   // ←追加
            
            // 衝突のカテゴリー設定
            sprite.physicsBody?.categoryBitMask = groundCategory    // ←追加
            
            // 衝突の時に動かないように設定する
            sprite.physicsBody?.isDynamic = false   // ←追加
            
            // スプライトを追加する
            scrollNode.addChild(sprite)
        }
    }
    //// テクスチャを指定してスプライトを作成する
    //let groundSprite = SKSpriteNode(texture: groundTexture)
    
    //// スプライトの表示する位置を指定する
    //groundSprite.position = CGPoint(
    //x: groundTexture.size().width / 2,
    //y: groundTexture.size().height / 2
    //)
    
    //// シーンにスプライトを追加する
    //addChild(groundSprite)
    
    func setupCloud() {
        // 雲の画像を読み込む
        let cloudTexture = SKTexture(imageNamed: "cloud")
        cloudTexture.filteringMode = .nearest
        
        // 必要な枚数を計算
        let needCloudNumber = Int(self.frame.size.width / cloudTexture.size().width) + 2
        
        // スクロールするアクションを作成
        // 左方向に画像一枚分スクロールさせるアクション
        let moveCloud = SKAction.moveBy(x: -cloudTexture.size().width, y: 0, duration: 20)
        
        // 元の位置に戻すアクション
        let resetCloud = SKAction.moveBy(x: cloudTexture.size().width, y: 0, duration: 0)
        
        // 左にスクロール->元の位置->左にスクロールと無限に繰り返すアクション
        let repeatScrollCloud = SKAction.repeatForever(SKAction.sequence([moveCloud, resetCloud]))
        
        // スプライトを配置する
        for i in 0..<needCloudNumber {
            let sprite = SKSpriteNode(texture: cloudTexture)
            sprite.zPosition = -100 // 一番後ろになるようにする
            
            // スプライトの表示する位置を指定する
            sprite.position = CGPoint(
                x: cloudTexture.size().width / 2 + cloudTexture.size().width * CGFloat(i),
                y: self.size.height - cloudTexture.size().height / 2
            )
            
            // スプライトにアニメーションを設定する
            sprite.run(repeatScrollCloud)
            
            // スプライトを追加する
            scrollNode.addChild(sprite)
        }
    }
    
    func setupWall() {
        // 壁の画像を読み込む
        let wallTexture = SKTexture(imageNamed: "wall")
        wallTexture.filteringMode = .linear
        
        // 移動する距離を計算
        let movingDistance = self.frame.size.width + wallTexture.size().width
        
        // 画面外まで移動するアクションを作成
        let moveWall = SKAction.moveBy(x: -movingDistance, y: 0, duration:4)
        
        // 自身を取り除くアクションを作成
        let removeWall = SKAction.removeFromParent()
        
        // 2つのアニメーションを順に実行するアクションを作成
        let wallAnimation = SKAction.sequence([moveWall, removeWall])
        
        // 鳥の画像サイズを取得
        let birdSize = SKTexture(imageNamed: "bird_a").size()
        
        // 鳥が通り抜ける隙間の大きさを鳥のサイズの4倍とする  //←５倍に変更した。
        let slit_length = birdSize.height * 5
        
        // 隙間位置の上下の振れ幅を60ptとする
        let random_y_range: CGFloat = 60
        
        // 空の中央位置(y座標)を取得
        let groundSize = SKTexture(imageNamed: "ground").size()
        let sky_center_y = groundSize.height + (self.frame.size.height - groundSize.height) / 2
        
        // 空の中央位置を基準にして下側の壁の中央位置を取得
        let under_wall_center_y = sky_center_y - slit_length / 2 - wallTexture.size().height / 2
        
        // 壁を生成するアクションを作成
        let createWallAnimation = SKAction.run({
            // 壁をまとめるノードを作成
            let wall = SKNode()
            wall.position = CGPoint(x: self.frame.size.width + wallTexture.size().width / 2, y: 0)
            wall.zPosition = -50 // 雲より手前、地面より奥
            
            // 下側の壁の中央位置にランダム値を足して、下側の壁の表示位置を決定する
            let random_y = CGFloat.random(in: -random_y_range...random_y_range)
            let under_wall_y = under_wall_center_y + random_y
            
            // 下側の壁を作成
            let under = SKSpriteNode(texture: wallTexture)
            under.position = CGPoint(x: 0, y: under_wall_y)
            
            // 下側の壁に物理体を設定する
            under.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())    // ←追加
            under.physicsBody?.categoryBitMask = self.wallCategory    // ←追加
            under.physicsBody?.isDynamic = false    // ←追加
            
            // 壁をまとめるノードに下側の壁を追加
            wall.addChild(under)
            
            // 上側の壁を作成
            let upper = SKSpriteNode(texture: wallTexture)
            upper.position = CGPoint(x: 0, y: under_wall_y + wallTexture.size().height + slit_length)
            
            // 上側の壁に物理体を設定する
            upper.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())    // ←追加
            upper.physicsBody?.categoryBitMask = self.wallCategory    // ←追加
            upper.physicsBody?.isDynamic = false    // ←追加
            
            // 壁をまとめるノードに上側の壁を追加
            wall.addChild(upper)
            
            // --- ここから ---
            // スコアカウント用の透明な壁を作成
            let scoreNode = SKNode()
            scoreNode.position = CGPoint(x: upper.size.width + birdSize.width / 2, y: self.frame.height / 2)
            
            // 透明な壁に物理体を設定する
            scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upper.size.width, height: self.frame.size.height))
            scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
            scoreNode.physicsBody?.isDynamic = false
            
            // 壁をまとめるノードに透明な壁を追加
            wall.addChild(scoreNode)
            // --- ここまで追加 ---
            
            // 壁をまとめるノードにアニメーションを設定
            wall.run(wallAnimation)
            
            // 壁を表示するノードに今回作成した壁を追加
            self.wallNode.addChild(wall)
        })
        // 次の壁作成までの時間待ちのアクションを作成
        let waitAnimation = SKAction.wait(forDuration: 2)
        // 壁を作成->時間待ち->壁を作成を無限に繰り返すアクションを作成
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createWallAnimation, waitAnimation]))
        
        // // 壁を表示するノードに壁の作成を無限に繰り返すアクションを設定
        wallNode.run(repeatForeverAnimation)
    }
    
    func setupBird() {
        // 鳥の画像を2種類読み込む
        let birdTextureA = SKTexture(imageNamed: "bird_a")
        birdTextureA.filteringMode = .linear
        let birdTextureB = SKTexture(imageNamed: "bird_b")
        birdTextureB.filteringMode = .linear
        
        // 2種類のテクスチャを交互に変更するアニメーションを作成
        let texturesAnimation = SKAction.animate(with: [birdTextureA, birdTextureB], timePerFrame: 0.2)
        let flap = SKAction.repeatForever(texturesAnimation)
        
        // スプライトを作成
        bird = SKSpriteNode(texture: birdTextureA)
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
        
        // 物理体を設定
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2)    // ←追加
        
        // カテゴリー設定
        bird.physicsBody?.categoryBitMask = birdCategory    // ←追加
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory    // ←追加
        bird.physicsBody?.contactTestBitMask = groundCategory | wallCategory | scoreCategory    // ←追加
        
        // 衝突した時に回転させない
        bird.physicsBody?.allowsRotation = false    // ←追加
        
        // アニメーションを設定
        bird.run(flap)
        
        // スプライトを追加する
        addChild(bird)
    }
    
    func setupItem() {    //以下、課題用に追加
            //アイテムの画像を読み込む
            let itemTexture = SKTexture(imageNamed: "item")
            itemTexture.filteringMode = .linear
            
            //移動する距離を計算
            let movingDistance = CGFloat(self.frame.size.width * 2)
            
            // 画面外まで移動するアクションを作成
            let moveItem = SKAction.moveBy(x: -movingDistance, y: 0, duration:4.0)
            
            // 自身を取り除くアクションを作成
            let removeItem = SKAction.removeFromParent()
            
            // 2つのアニメーションを順に実行するアクションを作成
            let itemAnimation = SKAction.sequence([moveItem, removeItem])
            
            // アイテムを生成するアクションを作成
            let createItemAnimation = SKAction.run ({
                // アイテム関連のノードをのせるノードを作成
                let item = SKNode()
                item.position = CGPoint(x: self.frame.size.width + itemTexture.size().width / 2, y: 0.0)
                
                // 画面のY軸の中央値
                let center_y = self.frame.size.height / 2
                // アイテムのY座標を上下ランダムにさせるときの最大値
                let random_y_range = self.frame.size.height / 2
                // アイテムのY軸の下限
                let item_lowest_y = UInt32( center_y - itemTexture.size().height / 2 -  random_y_range / 2)
                // 1〜random_y_rangeまでのランダムな整数を生成
                let random_y = arc4random_uniform( UInt32(random_y_range) )
                // Y軸の下限にランダムな値を足して、アイテムのY座標を決定
                let item_y = CGFloat(item_lowest_y + random_y)
                
                // 画面のx軸の中央値
                let center_x = self.frame.size.width / 2
                // アイテムのX座標を上下ランダムにさせるときの最大値
                let random_x_range = self.frame.size.width / 2
                // アイテムのX軸の下限
                let item_lowest_x = UInt32( center_x - itemTexture.size().width / 2 -  random_x_range / 2)
                // 1〜random_x_rangeまでのランダムな整数を生成
                let random_x = arc4random_uniform( UInt32(random_x_range) )
                // X軸の下限にランダムな値を足して、アイテムのX座標を決定
                let item_x = CGFloat(item_lowest_x + random_x)
                
                //アイテムを生成
                let itemSprite = SKSpriteNode(texture: itemTexture)
                itemSprite.position = CGPoint(x: item_x, y: item_y)

                itemSprite.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: itemSprite.size.width, height: itemSprite.size.height))  //重力を設定
                itemSprite.physicsBody?.isDynamic = false
                itemSprite.physicsBody?.categoryBitMask = self.itemScoreCategory
                itemSprite.physicsBody?.contactTestBitMask = self.birdCategory   //衝突判定させる相手のカテゴリを設定
                
                item.addChild(itemSprite)
                
                item.run(itemAnimation)
                
                self.itemNode.addChild(item)
                
            })
            // 次のアイテム作成までの待ち時間のアクションを作成
            let waitAnimation = SKAction.wait(forDuration: 2)
            
            // アイテムを作成->待ち時間->アイテムを作成を無限に繰り替えるアクションを作成
            let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createItemAnimation, waitAnimation]))
            
            itemNode.run(repeatForeverAnimation)
            
        }
    
    // 画面をタップした時に呼ばれる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if scrollNode.speed > 0 { // 追加        // 鳥の速度をゼロにする
            bird.physicsBody?.velocity = CGVector.zero
            
            // 鳥に縦方向の力を与える
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 10))   //←dy: 15を 10にした。
            
        } else if bird.speed == 0 {// --- ここから ---
            restart()
        } // --- ここまで追加 ---    }
    }
    // SKPhysicsContactDelegateのメソッド。衝突したときに呼ばれる
    func didBegin(_ contact: SKPhysicsContact) {
        // ゲームオーバーのときは何もしない
        if scrollNode.speed <= 0 {
            return
        }
        
        if (contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
            // スコアカウント用の透明な壁と衝突した
            print("ScoreUp")
            score += 1
            scoreLabelNode.text = "Score:\(score)"    // ←追加

            // ベストスコア更新か確認する --- ここから ---
                        var bestScore = userDefaults.integer(forKey: "BEST")
                        if score > bestScore {
                            bestScore = score
                            bestScoreLabelNode.text = "Best Score:\(bestScore)"    // ←追加
                            userDefaults.set(bestScore, forKey: "BEST")
                        } // --- ここまで追加---
            
        } else if (contact.bodyA.categoryBitMask & itemScoreCategory) == itemScoreCategory || (contact.bodyB.categoryBitMask & itemScoreCategory) == itemScoreCategory {
                    //アイテムに衝突した
                    print("ItemGet")
                    itemScore += 1
                    itemScoreLabelNode.text = "Item Score:\(itemScore)"
                    
                    itemPlayer?.play()
                    
                    if (contact.bodyA.categoryBitMask & itemScoreCategory) == itemScoreCategory {
                        contact.bodyA.node?.removeFromParent()
                    }
                    if (contact.bodyB.categoryBitMask & itemScoreCategory) == itemScoreCategory {
                        contact.bodyB.node?.removeFromParent()
                    }
        } else {
            // 壁か地面と衝突した
            print("GameOver")
            
            // スクロールを停止させる
            scrollNode.speed = 0
            
           
            bgmPlayer?.stop()
            
            // 衝突後は地面と反発するのみとする(リスタートするまで壁と反発させない)
            bird.physicsBody?.collisionBitMask = groundCategory
            
            // 鳥が衝突した時の高さを元に、鳥が地面に落ちるまでの秒数(概算)+1を計算
            let duration = bird.position.y / 400.0 + 1.0
            // 指定秒数分、鳥をくるくる回転させる(回転速度は1秒に1周)
            let roll = SKAction.rotate(byAngle: 2.0 * Double.pi * duration, duration: duration)
            bird.run(roll, completion:{
                // 回転が終わったら鳥の動きを止める
                self.bird.speed = 0
            })
        }
    }
    
    func restart() {
        // スコアを0にする
        score = 0
        scoreLabelNode.text = "Score:\(score)"    // ←追加
        
        itemScore = 0
        itemScoreLabelNode.text = String("Item Score:\(itemScore)")  //課題用に追加
        
        // 鳥を初期位置に戻し、壁と地面の両方に反発するように戻す
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
        bird.physicsBody?.velocity = CGVector.zero
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.zRotation = 0
        
        // 全ての壁を取り除く
        wallNode.removeAllChildren()
        
        // 鳥の羽ばたきを戻す
        bird.speed = 1
        
        // スクロールを再開させる
        scrollNode.speed = 1
        
        //    頭から再生
               
               bgmPlayer?.play()
        }
    
}

