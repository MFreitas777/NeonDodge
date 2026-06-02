# 🚀 Swift Game Project Plan: Neon Dodge

## 1. Title
**Neon Dodge**

## 2. Elevator Pitch
Um jogo arcade 2D de sobrevivência extrema com uma estética Cyberpunk / Synthwave. O jogador controla uma esfera de energia néon com capacidades de teletransporte (Dash), desviando-se de inimigos com inteligência artificial, recolhendo power-ups dinâmicos e personalizando a sua nave numa "Garagem" virtual, tudo ao som de uma dificuldade escalar.

## 3. Core Gameplay Loop
* **Ação Inimiga:** Geração processual de três tipos de ameaças: Obstáculos estáticos (Vermelhos), Obstáculos em Zig-Zag (Laranjas) e Mísseis Teleguiados via IA (Roxos)
* **Ação do Jogador:** O jogador arrasta o dedo na tela para mover a nave. Um "Duplo Clique" rápido ativa a mecânica de Dash (i-frames / invencibilidade temporária com alteração da contactTestBitMask).
* **Sucesso:** O jogador recolhe esferas Azuis (Escudo de um hit) e Verdes (Slow-Motion do motor de física + pontos extra). A cada 20 pontos, o ambiente muda de cor e a velocidade de queda (Spawn Rate) aumenta.
* **Falha:** A colisão com a hitbox inimiga gera Screen Shake, vibração háptica profunda (UIImpactFeedbackGenerator), explosão de partículas e aciona o Painel de Game Over.

## 4. Why it's fun
O jogo transborda "Game Juice". A ilusão de profundidade criada pela grelha néon em movimento constante no fundo (Parallax-style grid), o rasto de luz dinâmico do jogador, o Screen Shake nas colisões e os efeitos de Slow-Motion criam uma experiência extremamente gratificante. A introdução da "Garagem" cria retenção de jogador, motivando-o a testar novas cores guardadas na memória local.

## 5. Technical Approach (SpriteKit)
* **Arquitetura Modular:** O código foi refatorado e dividido em extensões (ex: `GameScene+Effects.swift`,` GameScene+Spawners.swift`) para separar a lógica de UI, Sistemas de Partículas e Motores de Spawn, aplicando boas práticas de Engenharia de Software.
* **Gráficos e Câmara:** Uso de `SKShapeNode` para criar geometria limpa e com brilho nativo (`glowWidth`). A UI está "ancorada" a um `SKCameraNode`, permitindo fazer zoom e tremer o ecrã inteiro sem dessincronizar os menus.
* **Física e Colisões:** O motor de física (`SKPhysicsContactDelegate`) usa `categoryBitMasks` bit a bit (1, 2, 4, 8) para classificar colisões. A gravidade está desativada (`affectedByGravity = false`), sendo o movimento ditado matematicamente por `SKAction.sequence` e atualizações no ciclo `update()`.
* **Persistência de Dados:** O sistema `UserDefaults` é usado para guardar o recorde absoluto (High Score) e o index da cor escolhida na Garagem pelo jogador.

## 6. Current Implemented Scope (Versão Final)
- [ ] Nave jogável personalizável (6 Skins desbloqueadas).
- [ ] Sistema contínuo de "Spawn" com RNG (Random Number Generator) para ditar a probabilidade (raridade) de Power-ups e Inimigos Especiais.
- [ ] Motor de Partículas processual criado matematicamente em Swift (sem necessidade de ficheiros SKEmitter externos).
- [ ] UI Hierárquica: Menu Inicial Animado, Garagem de Personalização, HUD Watermark de Gameplay, e Painel Popup de Game Over.

## 7. Biggest Risk + Mitigation
* **Risco 1 (Jogabilidade):** O dedo do jogador tapar a visão do sprite tátil.
* **Mitigação:** Implementado um Y-Offset. A área de toque deteta o eixo X, mas o `player.position` é fixado muito acima do ponto de toque.
* **Risco 2 (Estado da UI):** O botão de "Reiniciar" não responder se o motor do jogo estivesse em `isPaused = true` após a morte.
* **Mitigação:** Desacoplamento da UI do estado da física. No momento do clique no ecrã de Game Over, o sistema força um `isPaused = false` antes de executar a animação interativa dos botões, ou recarrega a classe inteira (`SKTransition`) ao voltar ao Menu Principal para garantir uma Clean Slate (memória limpa).
## 8. Future Ideas (Pós-Lançamento)
- [ ] **Leaderboards (Game Center):** Integração com as APIs da Apple para comparar pontuações mundialmente.
- [ ] **Áudio Dinâmico:** Implementar SKAudioNode com uma banda sonora de Synthwave cujo BPM (batidas por minuto) aumenta conforme a fase/velocidade do jogo.
- [ ] **Moeda Virtual (Coins):** Os blocos destruídos com o Escudo dariam "Moedas", usadas para comprar cores mais caras ou padrões de luz diferentes na Garagem.
