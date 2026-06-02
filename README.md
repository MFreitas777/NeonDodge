# 🚀 Swift Game Project Plan: Neon Dodge

## 1. 🎮 Informação Base
* **Título:** Neon Dodge: Overdrive
* **Género:** Arcade / Sobrevivência 2D
* **Plataforma:** iOS (iPhone)
* **Motor:** Swift / SpriteKit nativo

## 2. ⚡ Elevator Pitch
Um jogo arcade 2D de sobrevivência extrema com uma estética *Cyberpunk / Synthwave*. O jogador controla uma esfera de energia néon com capacidades de esquiva (*Dash*), desviando-se de inimigos com inteligência artificial, recolhendo *power-ups* táticos e personalizando a sua nave numa "Garagem" virtual, tudo isto enquanto a dificuldade e a velocidade do jogo escalam dinamicamente.

## 3. 💡 Game Concept (Mecânicas Principais)
* **Foco na Sobrevivência:** O objetivo não é chegar a uma meta, mas sim sobreviver o máximo de tempo possível enquanto a velocidade global aumenta.
* **Sistema de Ameaças:** Obstáculos caem do topo com diferentes comportamentos:
  * *Vermelhos:* Queda livre rotativa (Obstáculo base).
  * *Laranjas:* Movimento de zig-zag horizontal (Desafiam a precisão).
  * *Roxos:* Mísseis teleguiados por IA que seguem a posição X da nave.
* **Sistema de Vantagens (Power-ups):**
  * *Esfera Verde:* Abranda o tempo do motor de física (Slow-Mo) e dá pontos de bónus.
  * *Esfera Azul:* Cria um escudo de impacto único (1-hit shield).

## 4. 🔁 Core Gameplay Loop
1. **Início:** O jogador entra no Menu Principal e escolhe "Iniciar" ou vai à "Garagem" trocar a cor da nave.
2. **Ação:** Formas geométricas começam a cair em posições e comportamentos aleatórios (RNG).
3. **Reação:** O jogador move a nave horizontalmente e usa o *Dash* em situações de aperto.
4. **Escalonamento:** A cada 20 pontos, o ambiente sofre uma transição de cor (*Phase Shift*) e a velocidade de geração de inimigos aumenta (Dificuldade Progressiva).
5. **Resolução:** A colisão sem escudo resulta num Game Over, que exibe o painel final, avalia se há um novo *High Score*, e permite reiniciar ou voltar ao menu.

## 5. 🕹️ Player Actions
* **Arraste Contínuo (Pan/Drag):** Mover o dedo na horizontal na base do ecrã para controlar a posição X da nave.
* **Duplo Clique (Double Tap):** Executa o *Dash*, garantindo *i-frames* (invencibilidade temporal) durante 0.3 segundos, permitindo atravessar inimigos.
* **Navegação (Tap):** Toques precisos para interagir com a UI dos menus.

## 6. 📱 UI Screens & Fluxo
* **Menu Principal:** Título flutuante com logo rotativo, Botões de "Iniciar" e "Garagem", e display do Recorde Atual.
* **Garagem (Customization):** Grelha interativa com 6 cores desbloqueadas e botão de retorno. Feedback visual com outline branco na cor selecionada.
* **HUD de Jogo:** Pontuação atual apresentada como uma marca de água gigante e semitransparente no fundo do ecrã para não poluir a ação visual.
* **Game Over Panel:** Painel centralizado (*pop-up*) com pontuação final, aviso dourado intermitente de "NOVO RECORDE", e botões para "Reiniciar Sistema" ou "Menu Principal".

## 7. 🗺️ Fluxo de Navegação (Game Flow)
1. `Ecrã de Carregamento (Splash)` ➔ 
2. `Menu Principal` ➔ *(Opção A)* `Iniciar Jogo` | *(Opção B)* `Garagem (Personalização)`
3. `Core Gameplay` ➔ *(Em caso de colisão)* ➔
4. `Game Over Pop-up` ➔ *(Opção A)* `Reiniciar Imediato` | *(Opção B)* `Voltar ao Menu Principal`

## 8. Why it's fun
O jogo transborda *"Game Juice"*. A ilusão de profundidade criada pela grelha néon em movimento constante no fundo (*Parallax-style grid*), o rasto de luz dinâmico do jogador, o *Screen Shake* nas colisões pesadas e os efeitos de *Slow-Motion* criam uma experiência visualmente extrema e gratificante. A introdução da "Garagem" cria retenção de jogador, motivando-o a bater recordes com o seu estilo favorito.

## 9. 🎨 Direção de Arte e Áudio
* **Paleta de Cores:** Foco em cores de alto contraste num fundo quase totalmente preto (`#080814`). Uso intensivo de *Ciano* (Nave), *Magenta* (Inimigos de IA e Menus) e *Amarelo Néon* (Recordes e UI de destaque).
* **Estilo Visual:** *Cyberpunk / Tron / Synthwave*. Formas geométricas minimalistas (`SKShapeNode`) mas com forte aplicação de *Glow* (incandescência) para simular luzes néon. A grelha dinâmica ao fundo cria um efeito de perspetiva falsa (Pseudo-3D).
* **Soundscape (Visão):** Efeitos sonoros *retro-arcade* (8-bit bleeps) misturados com uma banda sonora eletrónica pesada baseada em sintetizadores.

## 10. ⚙️ Abordagem Técnica (SpriteKit)
* **Arquitetura Modular:** O código foi refatorado e dividido em extensões (`+Effects`, `+Spawners`, `+Customization`) para separar a lógica de UI, Sistemas de Partículas e Motores de Spawn, aplicando boas práticas de Engenharia de Software.
* **Gráficos e Câmara:** Uso de `SKShapeNode` para criar geometria limpa e com brilho nativo (`glowWidth`). A UI está "ancorada" a um `SKCameraNode`, permitindo fazer zoom e tremer o ecrã inteiro nas colisões sem dessincronizar os menus.
* **Física e Colisões:** O motor de física (`SKPhysicsContactDelegate`) usa `categoryBitMasks` bit a bit (1, 2, 4, 8) para classificar colisões. A gravidade está desativada (`affectedByGravity = false`), sendo o movimento ditado matematicamente por `SKAction`.
* **Persistência de Dados:** O sistema `UserDefaults` é usado para guardar o recorde absoluto (*High Score*) e o *index* da cor escolhida pelo jogador.

## 11. 🧱 Arquitetura de Ficheiros
* `Physics.swift`: Structs e constantes de colisão.
* `GameScene.swift`: Classe principal, gestão de estados, toques e contactos físicos.
* `GameScene+Effects.swift`: Grelha de fundo dinâmico, geração de explosões, texto flutuante e rasto da nave.
* `GameScene+Spawners.swift`: Funções randómicas de *spawn* e rotinas de IA para inimigos teleguiados.
* `GameScene+Customization.swift`: Lógica e UI exclusivas da garagem, integradas com `UserDefaults`.

## 12. ✅ Âmbito Implementado (Versão Final)
- [x] Nave jogável personalizável (6 *Skins* funcionais e guardadas em memória).
- [x] Sistema contínuo de "Spawn" com RNG (Random Number Generator) para ditar a raridade de *Power-ups* e Inimigos de IA.
- [x] Motor de Partículas processual criado matematicamente em Swift (explosões de diferentes cores por código).
- [x] UI Hierárquica Premium: Menu Inicial Animado, Garagem de Personalização, HUD *Watermark* de Gameplay

## 13. 🎯 Público-Alvo e Modelo de Negócio
* **Target Demographics:** Jogadores casuais (*Hypercasual gamers*), idades entre 12-35 anos, que procuram sessões de jogo rápidas (1 a 3 minutos) enquanto esperam por transportes ou em pausas curtas.
* **Modelo de Monetização (Teórico):** *Free-to-Play* (F2P).
  * **Anúncios (Ads):** Opção de ver um vídeo curto no ecrã de *Game Over* para reviver 1 vez por partida com o Escudo ativo.
  * **Microtransações (IAP):** Compra de *Skins* Premium (padrões com animação) na Garagem.

## 14. ⚠️ Riscos e Mitigações
* **Risco 1 (Jogabilidade):** O dedo do jogador tapar a visão do *sprite* tátil.
* **Mitigação:** Implementado um *Y-Offset*. A área de toque deteta o eixo X em todo o ecrã, mas a `player.position` é fixada sempre visível na metade inferior.
* **Risco 2 (Estado da UI):** Os botões encravarem após o Game Over devido a paragens na física (`isPaused = true`).
* **Mitigação:** Desacoplamento da UI do estado da física. No momento do clique no ecrã de Game Over, o sistema força um `isPaused = false` antes de executar animações, ou recarrega a classe inteira via `SKTransition` ao voltar ao Menu Principal para garantir uma memória 100% limpa.

## 15. 🔮 Ideias Futuras (Pós-Lançamento)
- [ ] **Leaderboards (Game Center):** Integração com as APIs da Apple para comparar pontuações mundialmente.
- [ ] **Áudio Dinâmico:** Implementar `SKAudioNode` com uma banda sonora de Synthwave cujo BPM (batidas por minuto) aumenta conforme a velocidade do jogo.
- [ ] **Moeda Virtual (Coins):** Os blocos destruídos dariam moedas virtuais para comprar padrões de luz diferentes na Garagem.

## 16. ✅ Conclusão
Neon Dodge: Overdrive é um projeto altamente focado em *Game Feel* e *Polimento*. Em vez de expandir o escopo com multiplayer complexo ou mecânicas excessivas, o projeto foca-se num MVP extremamente robusto, demonstrando domínio sobre o motor SpriteKit, manipulação de estados complexos de UI, e estruturação profissional de código em Swift.
