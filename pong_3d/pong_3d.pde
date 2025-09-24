// Variables del juego
PVector ballPos, ballSpeed;
float ballRadius = 12;
PVector paddle1Pos, paddle2Pos;
float paddleWidth = 15, paddleHeight = 80, paddleDepth = 10;
float paddleSpeed = 6;

// Puntuación y estado del juego
int score1 = 0, score2 = 0;
int maxScore = 5;
boolean gameOver = false;
boolean gamePaused = false;
String winner = "";

// Efectos visuales
ArrayList<PVector> trailPoints;
color ballColor = color(255, 100, 255);
float ballGlow = 0;
boolean showMenu = true;
int difficulty = 1; // 1=Fácil, 2=Medio, 3=Difícil

// Cámara y 3D
float cameraAngle = 0;
boolean autoCamera = true;

// Partículas
ArrayList<Particle> particles;

// Control de IA
boolean vsAI = true;
float aiDifficulty = 0.08;

void setup() {
  size(1000, 600, P3D);
  
  // Inicializar todas las variables aquí
  ballPos = new PVector(width / 2, height / 2, 0);
  ballSpeed = new PVector(3, 3, 0);
  paddle1Pos = new PVector(10, height / 2 - paddleHeight / 2, 0);
  paddle2Pos = new PVector(width - 25, height / 2 - paddleHeight / 2, 0);
  
  trailPoints = new ArrayList<PVector>();
  particles = new ArrayList<Particle>();
  
  resetGame();
}

void draw() {
  background(5, 5, 20);
  
  if (showMenu) {
    drawMenu();
    return;
  }
  
  setupCamera();
  setupLighting();
  
  if (!gamePaused && !gameOver) {
    updateBall();
    updatePaddles();
    updateAI();
  }
  
  drawField();
  drawBall();
  drawPaddles();
  drawUI();
  drawParticles();
  
  if (gameOver) {
    drawGameOver();
  }
  
  if (gamePaused) {
    drawPauseMenu();
  }
}

void setupCamera() {
  if (autoCamera) {
    cameraAngle += 0.005;
    float x = width/2 + cos(cameraAngle) * 100;
    float z = 500 + sin(cameraAngle) * 50;
    camera(x, height/2 - 50, z, width/2, height/2, 0, 0, 1, 0);
  } else {
    camera(width/2, height/2 - 100, 400, width/2, height/2, 0, 0, 1, 0);
  }
}

void setupLighting() {
  // Luz ambiental
  ambientLight(30, 30, 60);
  
  // Luz direccional principal
  directionalLight(100, 100, 255, -1, 0.5, -1);
  
  // Luz puntual que sigue la pelota
  pointLight(255, 150, 255, ballPos.x, ballPos.y, ballPos.z + 50);
  
  // Luces laterales
  pointLight(50, 255, 150, 0, height/2, 100);
  pointLight(150, 50, 255, width, height/2, 100);
}

void updateBall() {
  // Añadir punto al rastro
  if (frameCount % 3 == 0) {
    trailPoints.add(ballPos.copy());
  }
  
  // Limitar rastro
  while (trailPoints.size() > 10) {
    trailPoints.remove(0);
  }
  
  // Mover pelota
  ballPos.add(ballSpeed);
  
  // Colisión con paredes superior e inferior
  if (ballPos.y <= ballRadius || ballPos.y >= height - ballRadius) {
    ballSpeed.y *= -1;
    ballPos.y = constrain(ballPos.y, ballRadius, height - ballRadius);
    createParticles(ballPos.copy(), color(255, 255, 0));
  }
  
  // Colisión con paredes frontal y trasera (efecto 3D)
  if (ballPos.z <= -50 || ballPos.z >= 50) {
    ballSpeed.z *= -1;
    ballPos.z = constrain(ballPos.z, -50, 50);
  }
  
  // Colisión con paddle izquierda
  if (ballPos.x - ballRadius <= paddle1Pos.x + paddleWidth &&
      ballPos.y >= paddle1Pos.y && ballPos.y <= paddle1Pos.y + paddleHeight &&
      abs(ballPos.z - paddle1Pos.z) <= paddleDepth &&
      ballSpeed.x < 0) {
    
    ballSpeed.x *= -1.05; // Aumentar velocidad gradualmente
    ballSpeed.y += (ballPos.y - (paddle1Pos.y + paddleHeight/2)) * 0.1;
    ballSpeed.z += random(-1, 1);
    ballColor = color(100, 255, 100);
    createParticles(ballPos.copy(), color(0, 255, 0));
  }
  
  // Colisión con paddle derecha
  if (ballPos.x + ballRadius >= paddle2Pos.x &&
      ballPos.y >= paddle2Pos.y && ballPos.y <= paddle2Pos.y + paddleHeight &&
      abs(ballPos.z - paddle2Pos.z) <= paddleDepth &&
      ballSpeed.x > 0) {
    
    ballSpeed.x *= -1.05;
    ballSpeed.y += (ballPos.y - (paddle2Pos.y + paddleHeight/2)) * 0.1;
    ballSpeed.z += random(-1, 1);
    ballColor = color(255, 100, 100);
    createParticles(ballPos.copy(), color(255, 0, 0));
  }
  
  // Gol
  if (ballPos.x < 0) {
    score2++;
    createGoalEffect();
    resetBall();
  } else if (ballPos.x > width) {
    score1++;
    createGoalEffect();
    resetBall();
  }
  
  // Verificar fin del juego
  if (score1 >= maxScore || score2 >= maxScore) {
    gameOver = true;
    winner = score1 >= maxScore ? "Jugador 1" : (vsAI ? "IA" : "Jugador 2");
  }
  
  // Efecto de brillo en la pelota
  ballGlow = sin(frameCount * 0.2) * 30 + 50;
}

void updatePaddles() {
  // Control Jugador 1 (WASD)
  if (keyPressed) {
    if (key == 'w' || key == 'W') paddle1Pos.y = max(0, paddle1Pos.y - paddleSpeed);
    if (key == 's' || key == 'S') paddle1Pos.y = min(height - paddleHeight, paddle1Pos.y + paddleSpeed);
    if (key == 'q' || key == 'Q') paddle1Pos.z = max(-40, paddle1Pos.z - paddleSpeed);
    if (key == 'e' || key == 'E') paddle1Pos.z = min(40, paddle1Pos.z + paddleSpeed);
  }
  
  // Control Jugador 2 (Flechas) - solo si no es vs IA
  if (!vsAI && keyPressed) {
    if (keyCode == UP) paddle2Pos.y = max(0, paddle2Pos.y - paddleSpeed);
    if (keyCode == DOWN) paddle2Pos.y = min(height - paddleHeight, paddle2Pos.y + paddleSpeed);
    if (key == 'i' || key == 'I') paddle2Pos.z = max(-40, paddle2Pos.z - paddleSpeed);
    if (key == 'o' || key == 'O') paddle2Pos.z = min(40, paddle2Pos.z + paddleSpeed);
  }
}

void updateAI() {
  if (!vsAI) return;
  
  float targetY = ballPos.y - paddleHeight/2;
  float diff = targetY - paddle2Pos.y;
  
  // IA con diferentes niveles de dificultad
  float aiSpeed = paddleSpeed * aiDifficulty * difficulty;
  paddle2Pos.y += constrain(diff * 0.1, -aiSpeed, aiSpeed);
  paddle2Pos.y = constrain(paddle2Pos.y, 0, height - paddleHeight);
  
  // IA también controla el eje Z
  float targetZ = ballPos.z;
  float diffZ = targetZ - paddle2Pos.z;
  paddle2Pos.z += constrain(diffZ * 0.05, -aiSpeed, aiSpeed);
  paddle2Pos.z = constrain(paddle2Pos.z, -40, 40);
}

void drawField() {
  // Líneas del campo
  stroke(0, 100, 200);
  strokeWeight(1);
  
  // Grid horizontal
  for (int i = 0; i <= width; i += 50) {
    line(i, 0, -100, i, height, -100);
  }
  // Grid vertical
  for (int j = 0; j <= height; j += 50) {
    line(0, j, -100, width, j, -100);
  }
  
  // Línea central
  stroke(255, 255, 0);
  strokeWeight(3);
  line(width/2, 0, -50, width/2, height, 50);
  
  // Bordes del campo
  stroke(100, 255, 255);
  strokeWeight(2);
  noFill();
  
  // Marco frontal
  pushMatrix();
  translate(0, 0, -50);
  rect(0, 0, width, height);
  popMatrix();
  
  // Marco trasero
  pushMatrix();
  translate(0, 0, 50);
  rect(0, 0, width, height);
  popMatrix();
}

void drawBall() {
  // Rastro de la pelota
  if (trailPoints.size() > 1) {
    strokeWeight(3);
    for (int i = 1; i < trailPoints.size(); i++) {
      PVector curr = trailPoints.get(i);
      PVector prev = trailPoints.get(i-1);
      float alpha = map(i, 0, trailPoints.size()-1, 50, 255);
      stroke(red(ballColor), green(ballColor), blue(ballColor), alpha);
      line(prev.x, prev.y, prev.z, curr.x, curr.y, curr.z);
    }
  }
  
  // Pelota principal
  pushMatrix();
  translate(ballPos.x, ballPos.y, ballPos.z);
  
  // Efecto de brillo
  fill(red(ballColor) + ballGlow, green(ballColor) + ballGlow, blue(ballColor) + ballGlow);
  noStroke();
  sphere(ballRadius);
  
  // Núcleo brillante
  fill(255, 255, 255, 150);
  sphere(ballRadius * 0.6);
  
  popMatrix();
  
  // Restablecer color gradualmente
  ballColor = lerpColor(ballColor, color(255, 100, 255), 0.02);
}

void drawPaddles() {
  // Paddle 1 (Izquierda)
  pushMatrix();
  translate(paddle1Pos.x + paddleWidth/2, paddle1Pos.y + paddleHeight/2, paddle1Pos.z);
  fill(100, 255, 100);
  stroke(200, 255, 200);
  strokeWeight(1);
  box(paddleWidth, paddleHeight, paddleDepth * 2);
  popMatrix();
  
  // Paddle 2 (Derecha)
  pushMatrix();
  translate(paddle2Pos.x + paddleWidth/2, paddle2Pos.y + paddleHeight/2, paddle2Pos.z);
  fill(255, 100, 100);
  stroke(255, 200, 200);
  strokeWeight(1);
  box(paddleWidth, paddleHeight, paddleDepth * 2);
  popMatrix();
}

void drawUI() {
  // Cambiar a 2D para UI
  camera();
  hint(DISABLE_DEPTH_TEST);
  
  // Puntuación
  textAlign(CENTER);
  textSize(48);
  fill(100, 255, 100);
  text(score1, width/4, 60);
  
  fill(255, 100, 100);
  text(score2, 3*width/4, 60);
  
  // Separador
  fill(255);
  textSize(32);
  text(":", width/2, 60);
  
  // Información de controles
  textAlign(LEFT);
  textSize(12);
  fill(255, 200);
  text("J1: W/S - Arriba/Abajo, Q/E - Adelante/Atrás", 10, height - 40);
  if (!vsAI) {
    text("J2: ↑/↓ - Arriba/Abajo, I/O - Adelante/Atrás", 10, height - 25);
  } else {
    text("VS IA - Dificultad: " + 
         (difficulty == 1 ? "Fácil" : difficulty == 2 ? "Medio" : "Difícil"), 10, height - 25);
  }
  text("P - Pausa, R - Reiniciar, C - Cambiar cámara", 10, height - 10);
  
  hint(ENABLE_DEPTH_TEST);
  perspective();
}

void drawMenu() {
  background(5, 5, 30);
  
  // Título
  textAlign(CENTER);
  textSize(64);
  fill(255, 100, 255);
  text("PONG 3D", width/2, 150);
  
  textSize(24);
  fill(255);
  text("Selecciona modo de juego:", width/2, 220);
  
  // Opciones
  textSize(18);
  fill(vsAI ? color(255, 255, 0) : color(200));
  text("1 - VS IA", width/2, 280);
  
  fill(!vsAI ? color(255, 255, 0) : color(200));
  text("2 - VS Jugador", width/2, 310);
  
  fill(255);
  text("Dificultad: " + 
       (difficulty == 1 ? "Fácil (3)" : difficulty == 2 ? "Medio (4)" : "Difícil (5)"), 
       width/2, 360);
  
  text("ESPACIO - Comenzar", width/2, 420);
  
  text("Controles:", width/2, 480);
  textSize(14);
  text("Jugador 1: W/S (arriba/abajo), Q/E (adelante/atrás)", width/2, 510);
  if (!vsAI) {
    text("Jugador 2: ↑/↓ (arriba/abajo), I/O (adelante/atrás)", width/2, 530);
  }
}

void drawGameOver() {
  camera();
  hint(DISABLE_DEPTH_TEST);
  
  // Fondo semi-transparente
  fill(0, 0, 0, 150);
  rect(0, 0, width, height);
  
  // Mensaje de victoria
  textAlign(CENTER);
  textSize(48);
  fill(255, 255, 0);
  text("¡" + winner + " Gana!", width/2, height/2 - 50);
  
  textSize(24);
  fill(255);
  text("Puntuación Final: " + score1 + " - " + score2, width/2, height/2);
  
  textSize(18);
  text("R - Reiniciar    M - Menú Principal", width/2, height/2 + 50);
  
  hint(ENABLE_DEPTH_TEST);
  perspective();
}

void drawPauseMenu() {
  camera();
  hint(DISABLE_DEPTH_TEST);
  
  fill(0, 0, 0, 150);
  rect(0, 0, width, height);
  
  textAlign(CENTER);
  textSize(48);
  fill(255, 255, 0);
  text("PAUSA", width/2, height/2);
  
  textSize(18);
  fill(255);
  text("P - Continuar    R - Reiniciar    M - Menú", width/2, height/2 + 50);
  
  hint(ENABLE_DEPTH_TEST);
  perspective();
}

void createParticles(PVector pos, color c) {
  if (particles != null) {
    for (int i = 0; i < 5; i++) {
      particles.add(new Particle(pos.copy(), c));
    }
  }
}

void createGoalEffect() {
  if (particles != null) {
    for (int i = 0; i < 15; i++) {
      PVector goalPos = new PVector(ballPos.x < width/2 ? 0 : width, 
                                    random(height), random(-50, 50));
      particles.add(new Particle(goalPos, color(255, 255, 0)));
    }
  }
}

void drawParticles() {
  if (particles != null) {
    for (int i = particles.size() - 1; i >= 0; i--) {
      Particle p = particles.get(i);
      if (p != null) {
        p.update();
        p.display();
        
        if (p.isDead()) {
          particles.remove(i);
        }
      }
    }
  }
}

void resetBall() {
  if (ballPos != null && ballSpeed != null) {
    ballPos.set(width/2, height/2, random(-20, 20));
    float speedMag = 3 + difficulty * 0.5;
    ballSpeed.set(random(-1, 1) > 0 ? speedMag : -speedMag, 
                  random(-2, 2), random(-1, 1));
    if (trailPoints != null) {
      trailPoints.clear();
    }
  }
}

void resetGame() {
  score1 = 0;
  score2 = 0;
  gameOver = false;
  gamePaused = false;
  winner = "";
  
  if (paddle1Pos == null) paddle1Pos = new PVector(0, 0, 0);
  if (paddle2Pos == null) paddle2Pos = new PVector(0, 0, 0);
  
  paddle1Pos.set(10, height/2 - paddleHeight/2, 0);
  paddle2Pos.set(width - 25, height/2 - paddleHeight/2, 0);
  
  resetBall();
  
  // Ajustar dificultad de IA
  aiDifficulty = 0.05 + (difficulty - 1) * 0.03;
  maxScore = 2 + difficulty;
}

void keyPressed() {
  if (showMenu) {
    if (key == '1') vsAI = true;
    if (key == '2') vsAI = false;
    if (key == '3') difficulty = 1;
    if (key == '4') difficulty = 2;
    if (key == '5') difficulty = 3;
    if (key == ' ') showMenu = false;
  } else {
    if (key == 'p' || key == 'P') gamePaused = !gamePaused;
    if (key == 'r' || key == 'R') resetGame();
    if (key == 'm' || key == 'M') showMenu = true;
    if (key == 'c' || key == 'C') autoCamera = !autoCamera;
  }
}

// Clase para las partículas
class Particle {
  PVector pos, vel;
  color col;
  float life, maxLife;
  
  Particle(PVector p, color c) {
    pos = p.copy();
    vel = new PVector(random(-3, 3), random(-3, 3), random(-2, 2));
    col = c;
    maxLife = life = random(20, 40);
  }
  
  void update() {
    if (pos != null && vel != null) {
      pos.add(vel);
      vel.mult(0.98);
      life--;
    }
  }
  
  void display() {
    if (pos != null) {
      pushMatrix();
      translate(pos.x, pos.y, pos.z);
      
      float alpha = map(life, 0, maxLife, 0, 255);
      fill(red(col), green(col), blue(col), alpha);
      noStroke();
      
      float size = map(life, 0, maxLife, 1, 4);
      sphere(size);
      
      popMatrix();
    }
  }
  
  boolean isDead() {
    return life <= 0;
  }
}
