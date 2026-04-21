# 🚀 Swift Game Project Plan: Neon Dodge

## 1. Title
**Neon Dodge**

## 2. Elevator Pitch
Um jogo arcade 2D de ritmo acelerado onde o jogador desliza o dedo horizontalmente para desviar a sua nave de formas geométricas que caem do topo da tela, tentando sobreviver o máximo de tempo possível.

## 3. Core Gameplay Loop
* **Ação Inimiga:** Formas geométricas começam a cair do topo da tela em posições aleatórias.
* **Ação do Jogador:** O jogador mantém o dedo pressionado na parte inferior da tela e arrasta para mover a nave para a esquerda e para a direita.
* **Sucesso:** O jogador consegue desviar dos blocos e ganha pontos por cada segundo que sobrevive.
* **Falha:** A nave colide com qualquer uma das formas geométricas, resultando em *Game Over* imediato.

## 4. Why it's fun
O jogo baseia-se em reflexos rápidos e precisão. Por ter uma mecânica extremamente simples e sessões de jogo que duram apenas alguns minutos, cria facilmente o efeito de **"só mais uma tentativa"** para que o jogador tente bater o seu próprio recorde (High Score).

## 5. Technical Approach (SpriteKit)
* **Gráficos:** Uso de `SKSpriteNode` com blocos de cores neon vibrantes para a nave e para os obstáculos, mantendo um visual limpo.
* **Movimento:** Em vez de usar física e forças para mover a nave, a posição X do jogador será diretamente atrelada ao toque na tela sobrescrevendo a função `touchesMoved()`. Os obstáculos cairão a uma velocidade constante usando `SKAction.moveBy()`.
* **Detecção de Impacto:** O `SKPhysicsBody` será usado sem gravidade simulada (`affectedByGravity = false`). Servirá apenas como um gatilho/sensor (`contactTestBitMask`) para detetar quando os pixéis da nave e do obstáculo se sobrepõem.

## 6. MVP Scope (Minimum Viable Product)
- [ ] Apenas 1 nave jogável e 1 tipo de obstáculo (ex: blocos quadrados vermelhos).
- [ ] Sistema contínuo de "Spawn" (geração) de obstáculos no topo da tela usando `SKAction.sequence`.
- [ ] Contador de pontuação baseado no tempo de sobrevivência daquela rodada.
- [ ] 3 Telas simples: *Start Screen* (botão Play), *Game HUD* (pontuação atual) e *Game Over Screen* (botão Restart).

## 7. Biggest Risk + Mitigation
* **Risco:** Como o jogador precisa tocar na tela para arrastar a nave, existe o risco do próprio dedo tapar a visão do sprite, dificultando a perceção das colisões.
* **Mitigação:** Implementar um **offset (deslocamento) no eixo Y**. O jogador tocará numa "área de controlo" na base da tela, mas a nave será renderizada alguns centímetros mais acima no eixo Y. Assim, a nave move-se acompanhando o dedo horizontalmente, mas fica sempre visível.

## 8. Future Ideas (Stretch Goals)
- [ ] **Dificuldade Progressiva:** A velocidade de queda dos blocos aumenta à medida que a pontuação sobe.
- [ ] **High Score:** Persistência de dados utilizando o `UserDefaults` para guardar o recorde local.
- [ ] **Efeitos Visuais:** Rastro de luz (*trail*) na traseira da nave usando sistemas de partículas (`SKEmitterNode`).
