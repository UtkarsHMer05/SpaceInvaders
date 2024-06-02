import SwiftUI
import SwiftData
import SpriteKit
import GameKit

class GameScene: SKScene, SKPhysicsContactDelegate, ObservableObject{
    
    let background = SKSpriteNode(imageNamed: "Background-1")
    var player = SKSpriteNode()
    var playerFire = SKSpriteNode()
    var enemy = SKSpriteNode()
    var bossOne = SKSpriteNode()
    var bossOneFire = SKSpriteNode()
    
   @Published var gameOver = false
    
    var score = 0
    var scoreLabel = SKLabelNode()
    var liveArray = [SKSpriteNode]()
    
    var fireTimer = Timer()
    var enemyTimer = Timer()
    var bossOneFireTimer = Timer()
    var bossOneLives = 25
    
    
    struct CBitmask{
        static let playerShip: UInt32 = 0b1
        static let playerFire: UInt32 = 0b10
        static let enemyShip: UInt32  = 0b100
        static let bossOne: UInt32 = 0b1000
        
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        scene?.size = CGSize(width: 750, height: 1335)
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.setScale(1.3)
        background.zPosition = 1
        background.alpha = 0.6
        addChild(background)
        
        makePlayer(playerCh: shipChoice.integer(forKey: "playerChoice")) 
        
        fireTimer = .scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(playerFireFunction), userInfo: nil, repeats: true)
        
        enemyTimer = .scheduledTimer(timeInterval: 1, target: self, selector: #selector(makeEnemys), userInfo: nil, repeats: true)
        
        scoreLabel.text = "Score: \(score)"
        scoreLabel.fontName = "Chalduster"
        scoreLabel.fontSize = 60
        scoreLabel.fontColor = .red
        scoreLabel.zPosition = 10
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height / 1.1)
        addChild(scoreLabel)
        
        addLives(lives: 3)
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let contactA : SKPhysicsBody
        let contactB : SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            contactA = contact.bodyA
            contactB = contact.bodyB
        }else{
            contactA = contact.bodyB
            contactB = contact.bodyA
        }
        
        
        //playerfire hit enemy
        if contactA.categoryBitMask == CBitmask.playerFire && contactB.categoryBitMask == CBitmask.enemyShip{
            
            updateScore()
            
            playerFireHitEnemy(fires : contactA.node as! SKSpriteNode, enemys: contactB.node as! SKSpriteNode)
            
            if score == 5 {
                makeBossOne()
                enemyTimer.invalidate()
                bossOneFireTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(bossOneFireFunc), userInfo: nil, repeats: true)
            }
        }
        // enemy hit player
        if contactA.categoryBitMask == CBitmask.playerShip && contactB.categoryBitMask == CBitmask.enemyShip{
            player.run(SKAction.repeat(SKAction.sequence([SKAction.fadeOut(withDuration: 0.1), SKAction.fadeIn(withDuration: 0.1)]), count: 8))
            
            contactB.node?.removeFromParent()
            
            if let live1 = childNode(withName: "live1"){
                live1.removeFromParent()
            }else if let live2 = childNode(withName: "live2"){
                live2.removeFromParent()
            }else if let live3 = childNode(withName: "live3"){
                live3.removeFromParent()
                player.removeFromParent()
                fireTimer.invalidate()
                enemyTimer.invalidate()
                gameOverFunc()
            }
        }
        if contactA.categoryBitMask == CBitmask.playerFire && contactB.categoryBitMask == CBitmask.bossOne{
            
            let explo = SKEmitterNode(fileNamed: "ExplosionOne")
            explo?.position = contactA.node!.position
            explo?.zPosition = 5
            addChild(explo!)
            
            contactA.node?.removeFromParent()
            
            bossOneLives -= 1
             
            if bossOneLives == 0{
                let explo = SKEmitterNode(fileNamed: "ExplosionOne")
                explo?.position = contactB.node!.position
                explo?.zPosition = 5
                explo?.setScale(2)
                addChild(explo!)
                
                contactB.node?.removeFromParent()
                bossOneFireTimer.invalidate()
                enemyTimer = .scheduledTimer(timeInterval: 0.7, target: self, selector: #selector(makeEnemys), userInfo: nil, repeats: true)
            }
           
        }
        
        
    }
    
    func playerHitEnemy(players: SKSpriteNode, enemys: SKSpriteNode){
        players.removeFromParent()
        enemys.removeFromParent()
        
        fireTimer.invalidate()
        enemyTimer.invalidate()
        
        let explo = SKEmitterNode(fileNamed: "ExplosionOne")
        explo?.position = players.position
        explo?.zPosition = 5
        addChild(explo!)
    }
    
    func playerFireHitEnemy(fires: SKSpriteNode, enemys: SKSpriteNode){
        fires.removeFromParent()
        enemys.removeFromParent()
        
        let explo = SKEmitterNode(fileNamed: "ExplosionOne")
        explo?.position = enemys.position
        explo?.zPosition = 5
        addChild(explo!)
    }
    func addLives(lives: Int){
        for i in 1...lives{
            let live = SKSpriteNode(imageNamed: "playerShip1_green")
            live.setScale(0.65)
            live.position = CGPoint(x: CGFloat(i) * live.size.width + 10, y: size.height - live.size.height - 10)
            live.zPosition = 10
            live.name = "live\(i)"
            liveArray.append(live)
            
            addChild(live)
            
        }
    }
    
    func makePlayer(playerCh: Int){
        
        var shipName = ""
        
        switch playerCh{
        case 1:
            shipName = "7B"
        case 2:
            shipName = "13B"
        
        default:
            shipName = "5B"
            
        }
        
        player = .init(imageNamed: shipName)
        player.position = CGPoint(x: size.width / 2, y: 120)
        player.zPosition = 10
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.isDynamic = true
        player.physicsBody?.categoryBitMask = CBitmask.playerShip
        player.physicsBody?.contactTestBitMask = CBitmask.enemyShip
        player.physicsBody?.collisionBitMask = CBitmask.enemyShip
        addChild(player)
    }
    
    func makeBossOne(){
        bossOne = .init(imageNamed: "6B")
        bossOne.position = CGPoint(x: size.width / 2, y: size.height + bossOne.size.height)
        bossOne.zPosition = 10
        bossOne.setScale(1.6)
        bossOne.physicsBody = SKPhysicsBody(rectangleOf: bossOne.size)
        bossOne.physicsBody?.affectedByGravity = false
        bossOne.physicsBody?.categoryBitMask = CBitmask.bossOne
        bossOne.physicsBody?.contactTestBitMask = CBitmask.playerShip | CBitmask.playerFire
        bossOne.physicsBody?.collisionBitMask = CBitmask.playerShip | CBitmask.playerFire
       
        
        let move1 = SKAction.moveTo(y: size.height / 1.3, duration: 2)
        let move2 = SKAction.moveTo(x: size.width - bossOne.size.width / 2, duration: 2)
        let move3 = SKAction.moveTo(x: 0 + bossOne.size.width / 2, duration: 2)
        let move4 = SKAction.moveTo(x: size.width / 2, duration: 1.5)
        let move5 = SKAction.fadeOut(withDuration: 0.2)
        let move6 = SKAction.fadeIn(withDuration: 0.2)
        let move7 = SKAction.moveTo(y: 0 + bossOne.size.height / 2, duration: 2)
        let move8 = SKAction.moveTo(y: size.height / 1.3, duration: 2)
        
        let action = SKAction.repeat(SKAction.sequence([move5,move6]), count: 6)
        let repeatForever = SKAction.repeatForever(SKAction.sequence([move2,move3,move4,action,move7,move8]))
        let sequence = SKAction.sequence([move1,repeatForever])
        
        bossOne.run(sequence)
        
        addChild(bossOne)
        
    }
    
   @objc func bossOneFireFunc(){
        bossOneFire = .init(imageNamed: "laserBlue02")
        bossOneFire.position = bossOne.position
        bossOneFire.zPosition = 5
       bossOneFire.setScale(1.5)
  
        addChild(bossOneFire)
        
        let move1 = SKAction.moveTo(y: 0 - bossOneFire.size.height, duration: 1.5)
        let removeAction = SKAction.removeFromParent()
        
        let sequence = SKAction.sequence([move1,removeAction])
        bossOneFire.run(sequence)
        
    
    }
    @objc func playerFireFunction(){
        playerFire = .init(imageNamed: "laserGreen04")
        playerFire.position = player.position
        playerFire.zPosition = 3
        playerFire.physicsBody = SKPhysicsBody(rectangleOf: playerFire.size)
        playerFire.physicsBody?.affectedByGravity = false
        playerFire.physicsBody?.categoryBitMask = CBitmask.playerFire
        playerFire.physicsBody?.contactTestBitMask = CBitmask.enemyShip | CBitmask.bossOne
        playerFire.physicsBody?.collisionBitMask = CBitmask.enemyShip | CBitmask.bossOne
        
        addChild(playerFire)
        
        let moveAction = SKAction.moveTo(y: 1400, duration: 1)
        let delateAction = SKAction.removeFromParent()
        let combine =  SKAction.sequence([moveAction,delateAction])
        
        playerFire.run(combine)
    }
    
    @objc func makeEnemys(){
        let randomNumber = GKRandomDistribution(lowestValue: 50, highestValue: 700)
        
        
        enemy = .init(imageNamed: "1")
        enemy.position = CGPoint(x: randomNumber.nextInt(), y: 1400)
        enemy.zPosition = 5
        enemy.setScale(0.7)
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody?.affectedByGravity = false
        enemy.physicsBody?.categoryBitMask = CBitmask.enemyShip
        enemy.physicsBody?.contactTestBitMask = CBitmask.playerShip | CBitmask.playerFire
        enemy.physicsBody?.collisionBitMask = CBitmask.playerShip | CBitmask.playerFire
        addChild(enemy)
        
        let moveAction = SKAction.moveTo(y: -100, duration: 2)
        let delateAction = SKAction.removeFromParent()
        let combine = SKAction.sequence([moveAction,delateAction])
        
        enemy.run(combine)
        
    }
    func updateScore(){
        score += 1
        
        scoreLabel.text = "Score \(score)"
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            let location = touch.location(in: self)
            
            player.position.x = location.x
        }
    }
    func gameOverFunc(){
        removeAllChildren()
        gameOver = true
        
        let gameOverLabel = SKLabelNode()
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontSize = 90
        gameOverLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        gameOverLabel.fontColor = UIColor.red
        addChild(gameOverLabel)
    }
    
}
struct ContentView:View {
  @ObservedObject  var scene = GameScene()
    var body: some View {
        NavigationView{
            HStack{
                ZStack{
                    SpriteView(scene: scene)
                        .ignoresSafeArea()
                    
                    if scene.gameOver == true{
                        NavigationLink{
                            StartView().navigationBarBackButtonHidden(true)
                                .navigationBarBackButtonHidden(true)
                            
                        }label: {
                            Text("BACK TO START")
                                .padding()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
