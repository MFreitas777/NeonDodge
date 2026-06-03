import SpriteKit

extension GameScene {
    
    func setupCustomizationUI() {
        customizationContainer = SKNode()
        customizationContainer.isHidden = true
        customizationContainer.zPosition = 50
        cameraNode.addChild(customizationContainer)
        
        let bg = SKShapeNode(rectOf: CGSize(width: 1000, height: 2000))
        bg.fillColor = UIColor.black.withAlphaComponent(0.85)
        bg.strokeColor = .clear
        customizationContainer.addChild(bg)
        
        let title = SKLabelNode(fontNamed: "AvenirNext-HeavyItalic")
        title.text = "PERSONALIZAR NAVE"
        title.fontSize = 40
        title.fontColor = .white
        title.position = CGPoint(x: 0, y: 200)
        customizationContainer.addChild(title)
        
        for (index, color) in playerColors.enumerated() {
            let btn = SKShapeNode(circleOfRadius: 35)
            btn.fillColor = color
            btn.name = "colorBtn_\(index)"
            
            let row = index / 3
            let col = index % 3
            let offsetX = CGFloat(col) * 100.0 - 100.0
            let offsetY = CGFloat(row) * -100.0 + 80.0
            
            btn.position = CGPoint(x: offsetX, y: offsetY)
            
            let floatUp = SKAction.moveBy(x: 0, y: 5, duration: Double.random(in: 1.0...1.5))
            floatUp.timingMode = .easeInEaseOut
            btn.run(SKAction.repeatForever(SKAction.sequence([floatUp, floatUp.reversed()])))
            
            customizationContainer.addChild(btn)
        }
        
        let backBtnBg = SKShapeNode(rectOf: CGSize(width: 200, height: 55), cornerRadius: 27.5)
        backBtnBg.fillColor = UIColor.darkGray.withAlphaComponent(0.5)
        backBtnBg.strokeColor = .white
        backBtnBg.lineWidth = 2.0
        backBtnBg.position = CGPoint(x: 0, y: -180)
        backBtnBg.name = "backButtonBg"
        
        let backBtn = SKLabelNode(fontNamed: "AvenirNext-Bold")
        backBtn.text = "VOLTAR"
        backBtn.fontSize = 20
        backBtn.fontColor = .white
        backBtn.verticalAlignmentMode = .center
        backBtn.name = "backButton"
        backBtnBg.addChild(backBtn)
        
        customizationContainer.addChild(backBtnBg)
        
        // Garante que a cor já escolhida aparece logo marcada
        updateColorSelectionFeedback()
    }
    
    func updateColorSelectionFeedback() {
        for index in 0..<playerColors.count {
            if let btn = customizationContainer.childNode(withName: "colorBtn_\(index)") as? SKShapeNode {
                if index == playerColorIndex {
                    btn.strokeColor = .white
                    btn.lineWidth = 5.0
                    btn.glowWidth = 3.0
                } else {
                    btn.strokeColor = .darkGray
                    btn.lineWidth = 2.0
                    btn.glowWidth = 0.0
                }
            }
        }
    }
    
    func openCustomizationMenu() {
        titleLabel.isHidden = true
        playButtonBg.isHidden = true
        customizeButtonBg.isHidden = true
        highScoreLabel.isHidden = true
        
        customizationContainer.isHidden = false
        customizationContainer.alpha = 0
        customizationContainer.run(SKAction.fadeIn(withDuration: 0.2))
    }
    
    func closeCustomizationMenu() {
        customizationContainer.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.run {
                self.customizationContainer.isHidden = true
                self.titleLabel.isHidden = false
                self.playButtonBg.isHidden = false
                self.customizeButtonBg.isHidden = false
                self.highScoreLabel.isHidden = self.highScore == 0
            }
        ]))
    }
    
    func applyPlayerColor() {
        let chosenColor = playerColors[playerColorIndex]
        player.fillColor = chosenColor
        player.strokeColor = .white
    }
}
