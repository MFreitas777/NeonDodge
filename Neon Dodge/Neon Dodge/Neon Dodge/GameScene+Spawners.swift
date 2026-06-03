import SpriteKit

extension GameScene {
    
    func spawnObstacle() {
        let rand = Int.random(in: 1...100)
        let isPowerUpSlow = rand <= 8
        let isPowerUpShield = rand > 8 && rand <= 13
        let isZigZag = rand > 13 && rand <= 30
        let isHoming = rand > 30 && rand <= 40
        
        var node: SKShapeNode
        
        if isPowerUpSlow {
            node = SKShapeNode(rectOf: CGSize(width: 40, height: 40), cornerRadius: 5)
            node.fillColor = .green
        } else if isPowerUpShield {
            node = SKShapeNode(circleOfRadius: 20)
            node.fillColor = .blue
        } else if isZigZag {
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 0, y: 25)); path.addLine(to: CGPoint(x: 25, y: -20)); path.addLine(to: CGPoint(x: -25, y: -20)); path.closeSubpath()
            node = SKShapeNode(path: path)
            node.fillColor = .orange
        } else if isHoming {
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 0, y: 25)); path.addLine(to: CGPoint(x: 20, y: 0)); path.addLine(to: CGPoint(x: 0, y: -25)); path.addLine(to: CGPoint(x: -20, y: 0)); path.closeSubpath()
            node = SKShapeNode(path: path)
            node.fillColor = .purple
            node.name = "homing"
        } else {
            node = SKShapeNode(rectOf: CGSize(width: 40, height: 40))
            node.fillColor = .red
        }
        
        node.strokeColor = .white
        node.glowWidth = 2.0
        
        let randomX = CGFloat.random(in: frame.minX...frame.maxX)
        node.position = CGPoint(x: randomX, y: frame.maxY + 50)
        
        node.physicsBody = SKPhysicsBody(circleOfRadius: 18)
        node.physicsBody?.isDynamic = true
        node.physicsBody?.affectedByGravity = false
        
        if isPowerUpSlow { node.physicsBody?.categoryBitMask = PhysicsCategory.powerUpSlow }
        else if isPowerUpShield { node.physicsBody?.categoryBitMask = PhysicsCategory.powerUpShield }
        else { node.physicsBody?.categoryBitMask = PhysicsCategory.obstacle }
        
        node.physicsBody?.contactTestBitMask = PhysicsCategory.player
        node.physicsBody?.collisionBitMask = PhysicsCategory.none
        node.physicsBody?.usesPreciseCollisionDetection = true
        
        addChild(node)
        
        let actualDuration = isSlowMotion ? obstacleDuration * 1.5 : obstacleDuration
        let moveDown = SKAction.moveBy(x: 0, y: -frame.height - 100, duration: actualDuration)
        
        if isZigZag {
            let moveR = SKAction.moveBy(x: 90, y: 0, duration: 0.5); moveR.timingMode = .easeInEaseOut
            let moveL = SKAction.moveBy(x: -90, y: 0, duration: 0.5); moveL.timingMode = .easeInEaseOut
            node.run(SKAction.group([moveDown, SKAction.repeatForever(SKAction.sequence([moveR, moveL, moveL, moveR]))]))
        } else if !isPowerUpSlow && !isPowerUpShield && !isHoming {
            node.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1.0)))
            node.run(SKAction.sequence([moveDown, SKAction.removeFromParent()]))
        } else {
            node.run(SKAction.sequence([moveDown, SKAction.removeFromParent()]))
        }
        
        node.run(SKAction.sequence([SKAction.wait(forDuration: actualDuration + 1.0), SKAction.removeFromParent()]))
    }
    
    func startSpawning() {
        removeAction(forKey: "spawnTimer")
        let actualWait = isSlowMotion ? currentSpawnTime * 1.5 : currentSpawnTime
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(spawnObstacle), SKAction.wait(forDuration: actualWait)])), withKey: "spawnTimer")
    }
    
    func startScoreTimer() {
        run(SKAction.repeatForever(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.run {
                self.score += 1
                if self.score > 0 && self.score % 20 == 0 {
                    self.currentSpawnTime = max(0.15, self.currentSpawnTime - 0.05)
                    self.obstacleDuration = max(0.7, self.obstacleDuration - 0.2)
                    self.startSpawning()
                    self.changePhaseColor()
                }
            }
        ])), withKey: "scoreTimer")
    }
    
    func updateHomingMissiles() {
        enumerateChildNodes(withName: "homing") { (node, stop) in
            let dx = self.player.position.x - node.position.x
            node.position.x += dx * 0.025
        }
    }
}
