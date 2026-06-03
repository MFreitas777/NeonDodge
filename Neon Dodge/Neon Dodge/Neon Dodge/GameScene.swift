import SpriteKit
import UIKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // NÓS PRINCIPAIS (Elementos gráficos da cena)
    let cameraNode = SKCameraNode()
    var player: SKShapeNode!
    var shieldAura: SKShapeNode!
    
    // CUSTOMIZAÇÃO (Variáveis para guardar as cores da nave)
    var customizationContainer: SKNode!
    var playerColorIndex: Int = 0
    let playerColors: [UIColor] = [.cyan, .magenta, .systemYellow, .systemGreen, .white, .systemOrange]
    
    // UI ELEMENTS (Textos e Interface)
    var scoreLabel: SKLabelNode!
    var score: Int = 0 { didSet { scoreLabel.text = "\(score)" } }
    
    var titleContainer: SKNode!
    var titleLabel: SKLabelNode!
    var subtitleLabel: SKLabelNode!
    
    var highScoreBadge: SKShapeNode!
    var highScoreLabel: SKLabelNode!
    
    var playButtonBg: SKShapeNode!
    var customizeButtonBg: SKShapeNode!
    
    // ELEMENTOS DO GAME OVER (Menus escondidos)
    var gameOverBg: SKShapeNode!
    var gameOverLabel: SKLabelNode!
    var gameOverScoreLabel: SKLabelNode!
    var restartButtonBg: SKShapeNode!
    var homeButtonBg: SKShapeNode!
    
    // ESTADOS DE JOGO (Controlo de regras, tempo e mecânicas)
    var isGameActive = false
    var highScore: Int = 0
    var isSlowMotion = false
    var isDashing = false
    var hasShield = false
    var lastTouchTime: TimeInterval = 0
    var currentSpawnTime: TimeInterval = 0.6
    var obstacleDuration: TimeInterval = 2.0
    var currentPhase = 0
    
    // FEEDBACK TÁTIL (Vibrações do telemóvel para diferentes impactos)
    let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    let lightImpact = UIImpactFeedbackGenerator(style: .light)
    let successImpact = UINotificationFeedbackGenerator()
    
    // MARK: - INICIALIZAÇÃO
    // Chamado automaticamente quando o jogo abre. Configura o motor de física e lê os dados guardados.
    override func didMove(to view: SKView) {
        self.backgroundColor = UIColor(red: 0.03, green: 0.03, blue: 0.08, alpha: 1.0)
        physicsWorld.contactDelegate = self
        
        highScore = UserDefaults.standard.integer(forKey: "NeonDodgeHighScore")
        playerColorIndex = UserDefaults.standard.integer(forKey: "NeonDodgePlayerColor")
        
        setupCamera()
        setupUI()
        setupPlayer()
        setupCustomizationUI()
        applyPlayerColor()
        
        startBackgroundStars()
        startNeonGrid()
    }
    
    // MARK: - CICLO DE ATUALIZAÇÃO
    // Corre 60 frames por segundo. Atualiza processos contínuos (como o rasto visual e a IA dos mísseis).
    override func update(_ currentTime: TimeInterval) {
        if isGameActive {
            createTrail()
            updateHomingMissiles()
        }
    }
    
    // MARK: - CONFIGURAÇÃO VISUAL
    // Centraliza a câmara. Isto permite aplicar efeitos de Screen Shake sem afetar as coordenadas dos menus.
    func setupCamera() {
        cameraNode.position = CGPoint(x: frame.midX, y: frame.midY)
        self.camera = cameraNode
        addChild(cameraNode)
    }
    
    // Constrói todos os menus e botões em memória. Os elementos não necessários ficam ocultos (isHidden = true).
    func setupUI() {
        titleContainer = SKNode()
        titleContainer.position = CGPoint(x: 0, y: 240)
        
        let logoShape = SKShapeNode(rectOf: CGSize(width: 30, height: 30), cornerRadius: 5)
        logoShape.fillColor = .white
        logoShape.strokeColor = .cyan
        logoShape.lineWidth = 3.0
        logoShape.glowWidth = 4.0
        logoShape.position = CGPoint(x: 0, y: 55)
        logoShape.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 2.0)))
        titleContainer.addChild(logoShape)
        
        titleLabel = SKLabelNode(fontNamed: "AvenirNext-HeavyItalic")
        titleLabel.text = "NEON DODGE"
        titleLabel.fontSize = 45
        titleLabel.fontColor = .cyan
        titleLabel.position = CGPoint(x: 0, y: 0)
        titleContainer.addChild(titleLabel)
        
        subtitleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        subtitleLabel.text = "O V E R D R I V E"
        subtitleLabel.fontSize = 16
        subtitleLabel.fontColor = .magenta
        subtitleLabel.position = CGPoint(x: 0, y: -25)
        titleContainer.addChild(subtitleLabel)
        
        let moveUp = SKAction.moveBy(x: 0, y: 15, duration: 2.0); moveUp.timingMode = .easeInEaseOut
        titleContainer.run(SKAction.repeatForever(SKAction.sequence([moveUp, moveUp.reversed()])))
        cameraNode.addChild(titleContainer)
        
        highScoreBadge = SKShapeNode(rectOf: CGSize(width: 220, height: 35), cornerRadius: 17.5)
        highScoreBadge.fillColor = UIColor.black.withAlphaComponent(0.6)
        highScoreBadge.strokeColor = .systemYellow
        highScoreBadge.lineWidth = 1.5
        highScoreBadge.glowWidth = 0.5
        highScoreBadge.position = CGPoint(x: 0, y: 120)
        highScoreBadge.isHidden = highScore == 0
        cameraNode.addChild(highScoreBadge)
        
        highScoreLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        highScoreLabel.text = "RECORDE: \(highScore)"
        highScoreLabel.fontSize = 15
        highScoreLabel.fontColor = .systemYellow
        highScoreLabel.verticalAlignmentMode = .center
        highScoreLabel.position = CGPoint(x: 0, y: 0)
        highScoreBadge.addChild(highScoreLabel)
        
        playButtonBg = SKShapeNode(rectOf: CGSize(width: 280, height: 60), cornerRadius: 8)
        playButtonBg.fillColor = UIColor.cyan.withAlphaComponent(0.2)
        playButtonBg.strokeColor = .cyan
        playButtonBg.lineWidth = 2.5
        playButtonBg.glowWidth = 2.0
        playButtonBg.position = CGPoint(x: 0, y: 20)
        playButtonBg.name = "playButtonBg"
        
        let playButton = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        playButton.text = "INICIAR"
        playButton.fontSize = 24
        playButton.fontColor = .white
        playButton.verticalAlignmentMode = .center
        playButton.name = "playButton"
        playButtonBg.addChild(playButton)
        
        let pulseUp = SKAction.scale(to: 1.05, duration: 0.8); pulseUp.timingMode = .easeInEaseOut
        playButtonBg.run(SKAction.repeatForever(SKAction.sequence([pulseUp, SKAction.scale(to: 1.0, duration: 0.8)])))
        cameraNode.addChild(playButtonBg)
        
        customizeButtonBg = SKShapeNode(rectOf: CGSize(width: 280, height: 50), cornerRadius: 8)
        customizeButtonBg.fillColor = UIColor.magenta.withAlphaComponent(0.1)
        customizeButtonBg.strokeColor = .magenta
        customizeButtonBg.lineWidth = 2.0
        customizeButtonBg.glowWidth = 1.0
        customizeButtonBg.position = CGPoint(x: 0, y: -60)
        customizeButtonBg.name = "customizeButtonBg"
        
        let customizeButton = SKLabelNode(fontNamed: "AvenirNext-Bold")
        customizeButton.text = "GARAGEM"
        customizeButton.fontSize = 18
        customizeButton.fontColor = .white
        customizeButton.verticalAlignmentMode = .center
        customizeButton.name = "customizeButton"
        customizeButtonBg.addChild(customizeButton)
        cameraNode.addChild(customizeButtonBg)
        
        scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        scoreLabel.text = "0"
        scoreLabel.fontSize = 150
        scoreLabel.fontColor = UIColor(white: 1.0, alpha: 0.1)
        scoreLabel.position = CGPoint(x: 0, y: frame.height / 2 - 220)
        scoreLabel.zPosition = -1
        scoreLabel.isHidden = true
        cameraNode.addChild(scoreLabel)
        
        gameOverBg = SKShapeNode(rectOf: CGSize(width: 1000, height: 2000))
        gameOverBg.fillColor = UIColor.black.withAlphaComponent(0.85)
        gameOverBg.strokeColor = .clear
        gameOverBg.zPosition = 15
        gameOverBg.isHidden = true
        cameraNode.addChild(gameOverBg)
        
        gameOverLabel = SKLabelNode(fontNamed: "AvenirNext-HeavyItalic")
        gameOverLabel.text = "SISTEMA FALHOU"
        gameOverLabel.fontSize = 35
        gameOverLabel.fontColor = .red
        gameOverLabel.position = CGPoint(x: 0, y: 130)
        gameOverLabel.zPosition = 20
        gameOverLabel.isHidden = true
        cameraNode.addChild(gameOverLabel)
        
        gameOverScoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        gameOverScoreLabel.text = "PONTUAÇÃO FINAL: 0"
        gameOverScoreLabel.fontSize = 24
        gameOverScoreLabel.fontColor = .white
        gameOverScoreLabel.position = CGPoint(x: 0, y: 60)
        gameOverScoreLabel.zPosition = 20
        gameOverScoreLabel.isHidden = true
        cameraNode.addChild(gameOverScoreLabel)
        
        restartButtonBg = SKShapeNode(rectOf: CGSize(width: 280, height: 60), cornerRadius: 8)
        restartButtonBg.fillColor = UIColor.red.withAlphaComponent(0.2)
        restartButtonBg.strokeColor = .red
        restartButtonBg.lineWidth = 3.0
        restartButtonBg.glowWidth = 2.0
        restartButtonBg.position = CGPoint(x: 0, y: -30)
        restartButtonBg.zPosition = 20
        restartButtonBg.name = "restartButtonBg"
        restartButtonBg.isHidden = true
        
        let restartButton = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        restartButton.text = "REINICIAR SISTEMA"
        restartButton.fontSize = 20
        restartButton.fontColor = .white
        restartButton.verticalAlignmentMode = .center
        restartButton.name = "restartButton"
        restartButtonBg.addChild(restartButton)
        cameraNode.addChild(restartButtonBg)
        
        homeButtonBg = SKShapeNode(rectOf: CGSize(width: 280, height: 60), cornerRadius: 8)
        homeButtonBg.fillColor = UIColor.darkGray.withAlphaComponent(0.6)
        homeButtonBg.strokeColor = .white
        homeButtonBg.lineWidth = 2.0
        homeButtonBg.position = CGPoint(x: 0, y: -110)
        homeButtonBg.zPosition = 20
        homeButtonBg.name = "homeButtonBg"
        homeButtonBg.isHidden = true
        
        let homeButton = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        homeButton.text = "MENU PRINCIPAL"
        homeButton.fontSize = 18
        homeButton.fontColor = .white
        homeButton.verticalAlignmentMode = .center
        homeButton.name = "homeButton"
        homeButtonBg.addChild(homeButton)
        cameraNode.addChild(homeButtonBg)
    }
    
    // Inicializa a nave, desativa a gravidade (movimento por código) e atribui as máscaras de colisão (Bitmasks).
    func setupPlayer() {
        player = SKShapeNode(circleOfRadius: 20)
        player.glowWidth = 4.0
        player.position = CGPoint(x: frame.midX, y: frame.minY + 180)
        player.zPosition = 5
        
        player.physicsBody = SKPhysicsBody(circleOfRadius: 15)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.obstacle | PhysicsCategory.powerUpSlow | PhysicsCategory.powerUpShield
        player.physicsBody?.collisionBitMask = PhysicsCategory.none
        player.physicsBody?.usesPreciseCollisionDetection = true
        
        shieldAura = SKShapeNode(circleOfRadius: 28)
        shieldAura.strokeColor = .blue
        shieldAura.lineWidth = 4.0
        shieldAura.glowWidth = 3.0
        shieldAura.isHidden = true
        player.addChild(shieldAura)
        
        player.isHidden = true
        addChild(player)
    }
    
    // MARK: - TRANSIÇÕES DE ESTADO
    // Inicia uma nova partida. Reinicia variáveis, oculta menus e limpa blocos antigos do ecrã.
    func startGame() {
        isGameActive = true
        self.isPaused = false
        isSlowMotion = false
        isDashing = false
        hasShield = false
        shieldAura.isHidden = true
        score = 0
        currentPhase = 0
        self.backgroundColor = UIColor(red: 0.03, green: 0.03, blue: 0.08, alpha: 1.0)
        currentSpawnTime = 0.6
        obstacleDuration = 2.0
        
        cameraNode.removeAllActions()
        cameraNode.position = CGPoint(x: frame.midX, y: frame.midY)
        cameraNode.setScale(1.0)
        
        titleContainer.isHidden = true
        playButtonBg.isHidden = true
        customizeButtonBg.isHidden = true
        highScoreBadge.isHidden = true
        
        gameOverBg.isHidden = true
        gameOverLabel.isHidden = true
        gameOverScoreLabel.isHidden = true
        restartButtonBg.isHidden = true
        homeButtonBg.isHidden = true
        
        player.isHidden = false
        scoreLabel.isHidden = false
        player.position = CGPoint(x: frame.midX, y: frame.minY + 180)
        player.alpha = 1.0
        applyPlayerColor()
        
        for node in children {
            if node.physicsBody?.categoryBitMask == PhysicsCategory.obstacle ||
               node.physicsBody?.categoryBitMask == PhysicsCategory.powerUpSlow ||
               node.physicsBody?.categoryBitMask == PhysicsCategory.powerUpShield ||
               node.name == "homing" {
                node.removeFromParent()
            }
        }
        
        startSpawning()
        startScoreTimer()
    }
    
    // Processa a morte do jogador. Congela o jogo, aplica Screen Shake, explosões e mostra o painel final.
    func gameOver() {
        isGameActive = false
        heavyImpact.impactOccurred()
        
        let left = SKAction.moveBy(x: -30, y: -20, duration: 0.05)
        let right = SKAction.moveBy(x: 60, y: 40, duration: 0.05)
        let center = SKAction.moveTo(x: frame.midX, duration: 0.05)
        let centerY = SKAction.moveTo(y: frame.midY, duration: 0.05)
        cameraNode.run(SKAction.sequence([left, right, SKAction.group([center, centerY]), left, right, SKAction.group([center, centerY])]))
        
        createExplosion(at: player.position, color: playerColors[playerColorIndex], amount: 30)
        player.alpha = 0
        self.isPaused = true
        removeAction(forKey: "scoreTimer")
        removeAction(forKey: "spawnTimer")
        
        if score > highScore {
            highScore = score
            UserDefaults.standard.set(highScore, forKey: "NeonDodgeHighScore")
        }
        
        gameOverBg.isHidden = false
        gameOverLabel.isHidden = false
        gameOverScoreLabel.text = "PONTUAÇÃO FINAL: \(score)"
        gameOverScoreLabel.isHidden = false
        restartButtonBg.isHidden = false
        homeButtonBg.isHidden = false
    }
    
    // Recarrega completamente a cena SKScene para evitar fugas de memória ao voltar ao Menu Principal.
    func goToMainMenu() {
        if let view = self.view {
            let menuScene = GameScene(size: self.size)
            menuScene.scaleMode = self.scaleMode
            let transition = SKTransition.crossFade(withDuration: 0.4)
            view.presentScene(menuScene, transition: transition)
        }
    }
    
    // Ativa a invencibilidade temporária alterando o contactTestBitMask para ignorar os blocos inimigos.
    func performDash() {
        if isDashing || !isGameActive { return }
        isDashing = true
        lightImpact.impactOccurred()
        
        player.fillColor = .white
        player.physicsBody?.contactTestBitMask = PhysicsCategory.powerUpSlow | PhysicsCategory.powerUpShield
        
        cameraNode.run(SKAction.sequence([SKAction.scale(to: 0.95, duration: 0.1), SKAction.scale(to: 1.0, duration: 0.3)]))
        
        let wait = SKAction.wait(forDuration: 0.3)
        let finishDash = SKAction.run {
            self.isDashing = false
            self.player.fillColor = self.hasShield ? .blue : (self.isSlowMotion ? .green : self.playerColors[self.playerColorIndex])
            self.player.physicsBody?.contactTestBitMask = PhysicsCategory.obstacle | PhysicsCategory.powerUpSlow | PhysicsCategory.powerUpShield
        }
        run(SKAction.sequence([wait, finishDash]))
    }
    
    // MARK: - CONTROLOS E TOQUES
    // Deteta toques nos botões da UI através do nome dos Nodes e também o duplo clique rápido para ativar o Dash.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: cameraNode)
        let touchedNodes = cameraNode.nodes(at: location)
        
        var buttonClicked = false
        
        for node in touchedNodes {
            if buttonClicked { continue }
            
            if !customizationContainer.isHidden {
                if node.name == "backButton" || node.name == "backButtonBg" {
                    closeCustomizationMenu()
                    buttonClicked = true
                }
                else if let name = node.name, name.hasPrefix("colorBtn_") {
                    let indexString = name.replacingOccurrences(of: "colorBtn_", with: "")
                    if let index = Int(indexString) {
                        playerColorIndex = index
                        UserDefaults.standard.set(playerColorIndex, forKey: "NeonDodgePlayerColor")
                        applyPlayerColor()
                        updateColorSelectionFeedback()
                        lightImpact.impactOccurred()
                        
                        node.run(SKAction.sequence([SKAction.scale(to: 0.8, duration: 0.1), SKAction.scale(to: 1.0, duration: 0.1)]))
                        buttonClicked = true
                    }
                }
            }
            else if !isGameActive {
                if node.name == "playButton" || node.name == "playButtonBg" {
                    self.isPaused = false
                    node.run(SKAction.sequence([
                        SKAction.scale(to: 0.8, duration: 0.1),
                        SKAction.run { self.startGame() },
                        SKAction.scale(to: 1.0, duration: 0.1)
                    ]))
                    buttonClicked = true
                }
                else if node.name == "restartButton" || node.name == "restartButtonBg" {
                    self.isPaused = false
                    node.run(SKAction.sequence([
                        SKAction.scale(to: 0.8, duration: 0.1),
                        SKAction.run { self.startGame() },
                        SKAction.scale(to: 1.0, duration: 0.1)
                    ]))
                    buttonClicked = true
                }
                else if node.name == "homeButton" || node.name == "homeButtonBg" {
                    self.isPaused = false
                    node.run(SKAction.sequence([
                        SKAction.scale(to: 0.8, duration: 0.1),
                        SKAction.run { self.goToMainMenu() }
                    ]))
                    buttonClicked = true
                }
                else if node.name == "customizeButton" || node.name == "customizeButtonBg" {
                    openCustomizationMenu()
                    buttonClicked = true
                }
            }
        }
        
        if isGameActive && !buttonClicked {
            let currentTime = touch.timestamp
            if currentTime - lastTouchTime < 0.25 { performDash() }
            lastTouchTime = currentTime
        }
    }
    
    // Iguala a posição horizontal (eixo X) da nave à posição atual do arrasto do dedo no ecrã.
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameActive {
            guard let touch = touches.first else { return }
            let location = touch.location(in: self)
            player.position.x = location.x
        }
    }
    
    // MARK: - SISTEMA DE COLISÕES
    // Delegação de contacto de física. Soma as Bitmasks para identificar qual o objeto atingido e aplica a lógica correta.
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if collision == PhysicsCategory.player | PhysicsCategory.obstacle {
            let obstacleNode = contact.bodyA.categoryBitMask == PhysicsCategory.obstacle ? contact.bodyA.node : contact.bodyB.node
            
            if hasShield {
                hasShield = false
                shieldAura.isHidden = true
                applyPlayerColor()
                createExplosion(at: obstacleNode?.position ?? player.position, color: .blue, amount: 20)
                obstacleNode?.removeFromParent()
                cameraNode.run(SKAction.sequence([SKAction.moveBy(x: -10, y: 0, duration: 0.03), SKAction.moveBy(x: 20, y: 0, duration: 0.03), SKAction.moveTo(x: frame.midX, duration: 0.03)]))
                lightImpact.impactOccurred()
            } else { gameOver() }
        }
        else if collision == PhysicsCategory.player | PhysicsCategory.powerUpSlow {
            let node = contact.bodyA.categoryBitMask == PhysicsCategory.powerUpSlow ? contact.bodyA.node : contact.bodyB.node
            let pos = node?.position ?? player.position
            node?.removeFromParent()
            
            isSlowMotion = true
            successImpact.notificationOccurred(.success)
            createExplosion(at: pos, color: .green, amount: 15)
            
            if !isDashing && !hasShield { player.fillColor = .green }
            score += 5
            startSpawning()
            
            run(SKAction.sequence([
                SKAction.wait(forDuration: 5.0),
                SKAction.run {
                    self.isSlowMotion = false
                    if !self.isDashing && !self.hasShield { self.applyPlayerColor() }
                    self.startSpawning()
                }
            ]), withKey: "powerUpTimer")
        }
        else if collision == PhysicsCategory.player | PhysicsCategory.powerUpShield {
            let node = contact.bodyA.categoryBitMask == PhysicsCategory.powerUpShield ? contact.bodyA.node : contact.bodyB.node
            let pos = node?.position ?? player.position
            node?.removeFromParent()
            
            hasShield = true
            shieldAura.isHidden = false
            successImpact.notificationOccurred(.success)
            createExplosion(at: pos, color: .blue, amount: 15)
            
            if !isDashing { player.fillColor = .blue }
        }
    }
}
