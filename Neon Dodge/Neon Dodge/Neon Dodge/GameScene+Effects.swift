import SpriteKit

extension GameScene {
    
    // NOVO: A grelha néon animada que dá a sensação de velocidade 3D!
    func startNeonGrid() {
        let gridNode = SKNode()
        gridNode.zPosition = 0 // Fica no fundo, atrás de tudo
        gridNode.alpha = 0.15 // Subtil para não distrair
        self.addChild(gridNode)
        
        // Linhas verticais fixas
        for i in -10...10 {
            let line = SKShapeNode(rectOf: CGSize(width: 2, height: frame.height * 3))
            line.fillColor = .magenta
            line.strokeColor = .clear
            line.position = CGPoint(x: CGFloat(i) * 60, y: frame.midY)
            gridNode.addChild(line)
        }
        
        // Linhas horizontais que caem infinitamente
        let spawnLine = SKAction.run {
            let line = SKShapeNode(rectOf: CGSize(width: self.frame.width * 2, height: 2))
            line.fillColor = .magenta
            line.strokeColor = .clear
            line.position = CGPoint(x: self.frame.midX, y: self.frame.maxY + 50)
            gridNode.addChild(line)
            
            let moveDown = SKAction.moveBy(x: 0, y: -self.frame.height - 100, duration: 1.5)
            line.run(SKAction.sequence([moveDown, SKAction.removeFromParent()]))
        }
        
        // Gera uma linha nova a cada 0.2 segundos
        run(SKAction.repeatForever(SKAction.sequence([spawnLine, SKAction.wait(forDuration: 0.2)])))
    }
    
    func createTrail() {
        let trail = SKShapeNode(circleOfRadius: isDashing ? 22 : 18)
        
        if isDashing { trail.fillColor = .white }
        else if isSlowMotion { trail.fillColor = .green }
        else if hasShield { trail.fillColor = .blue }
        else { trail.fillColor = playerColors[playerColorIndex] }
        
        trail.strokeColor = .clear
        trail.position = player.position
        trail.zPosition = 4
        trail.alpha = isDashing ? 0.8 : 0.4
        addChild(trail)
        
        let shrink = SKAction.scale(to: 0.1, duration: 0.25)
        let fadeOut = SKAction.fadeOut(withDuration: 0.25)
        trail.run(SKAction.sequence([SKAction.group([shrink, fadeOut]), SKAction.removeFromParent()]))
    }
    
    func startBackgroundStars() {
        let spawn = SKAction.run {
            let star = SKShapeNode(rectOf: CGSize(width: 2, height: CGFloat.random(in: 15...40)))
            star.fillColor = UIColor(white: 1.0, alpha: CGFloat.random(in: 0.1...0.4))
            star.strokeColor = .clear
            star.position = CGPoint(x: CGFloat.random(in: self.frame.minX...self.frame.maxX), y: self.frame.maxY + 50)
            star.zPosition = 1
            self.addChild(star)
            star.run(SKAction.sequence([SKAction.moveBy(x: 0, y: -self.frame.height - 100, duration: Double.random(in: 0.4...1.2)), SKAction.removeFromParent()]))
        }
        run(SKAction.repeatForever(SKAction.sequence([spawn, SKAction.wait(forDuration: 0.05)])))
    }
    
    func changePhaseColor() {
        currentPhase += 1
        var newColor: UIColor
        switch currentPhase % 4 {
            case 1: newColor = UIColor(red: 0.1, green: 0.0, blue: 0.2, alpha: 1.0)
            case 2: newColor = UIColor(red: 0.2, green: 0.0, blue: 0.05, alpha: 1.0)
            case 3: newColor = UIColor(red: 0.0, green: 0.1, blue: 0.1, alpha: 1.0)
            default: newColor = UIColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 1.0)
        }
        self.run(SKAction.colorize(with: newColor, colorBlendFactor: 1.0, duration: 2.0))
        showFloatingText("MÁXIMA VELOCIDADE!", at: CGPoint(x: frame.midX, y: frame.midY), color: .white)
    }
    
    func showFloatingText(_ text: String, at position: CGPoint, color: UIColor) {
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = text
        label.fontSize = 25
        label.fontColor = color
        label.position = position
        label.zPosition = 25
        addChild(label)
        label.run(SKAction.sequence([SKAction.group([SKAction.moveBy(x: 0, y: 80, duration: 0.8), SKAction.fadeOut(withDuration: 0.8)]), SKAction.removeFromParent()]))
    }
    
    func createExplosion(at position: CGPoint, color: UIColor, amount: Int) {
        for _ in 0..<amount {
            let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...6))
            particle.fillColor = color
            particle.strokeColor = .white
            particle.position = position
            particle.zPosition = 20
            addChild(particle)
            particle.run(SKAction.sequence([SKAction.group([
                SKAction.moveBy(x: CGFloat.random(in: -200...200), y: CGFloat.random(in: -200...200), duration: 0.5),
                SKAction.fadeOut(withDuration: 0.5),
                SKAction.scale(to: 0.1, duration: 0.5)
            ]), SKAction.removeFromParent()]))
        }
    }
}
