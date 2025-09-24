int[][] board = new int[3][3];
boolean xTurn = true;
boolean gameEnded = false;
int winner = 0; // 0: no winner, 1: X wins, 2: O wins, 3: tie
String gameMessage = "";
boolean showMessage = false;

// Botón de reinicio
int buttonX = 110;
int buttonY = 320;
int buttonW = 80;
int buttonH = 30;

// Colores
color bgColor = color(240, 240, 240);
color lineColor = color(100);
color xColor = color(220, 50, 50);
color oColor = color(50, 50, 220);
color buttonColor = color(100, 200, 100);
color buttonHover = color(80, 180, 80);

void setup() {
  size(300, 360); // Más alto para el botón
  resetGame();
}

void draw() {
  background(bgColor);
  drawBoard();
  drawButton();
  
  if (showMessage) {
    drawMessage();
  }
  
  if (!gameEnded) {
    checkWin();
  }
}

void drawBoard() {
  // Líneas del tablero
  stroke(lineColor);
  strokeWeight(3);
  for (int i = 1; i < 3; i++) {
    line(i * 100, 0, i * 100, 300);
    line(0, i * 100, 300, i * 100);
  }
  
  // Dibujar X y O
  strokeWeight(6);
  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
      if (board[i][j] == 1) {
        drawX(i, j);
      } else if (board[i][j] == 2) {
        drawO(i, j);
      }
    }
  }
  
  // Indicador de turno
  if (!gameEnded) {
    textAlign(CENTER);
    textSize(16);
    fill(0);
    String turnText = "Turno: " + (xTurn ? "X" : "O");
    text(turnText, 150, 320);
  }
}

void drawX(int i, int j) {
  stroke(xColor);
  line(i * 100 + 20, j * 100 + 20, (i + 1) * 100 - 20, (j + 1) * 100 - 20);
  line(i * 100 + 20, (j + 1) * 100 - 20, (i + 1) * 100 - 20, j * 100 + 20);
}

void drawO(int i, int j) {
  stroke(oColor);
  noFill();
  ellipse(i * 100 + 50, j * 100 + 50, 60, 60);
}

void drawButton() {
  // Color del botón (hover effect)
  boolean isHover = mouseX >= buttonX && mouseX <= buttonX + buttonW && 
                   mouseY >= buttonY && mouseY <= buttonY + buttonH;
  
  fill(isHover ? buttonHover : buttonColor);
  stroke(0);
  strokeWeight(2);
  rect(buttonX, buttonY, buttonW, buttonH, 5);
  
  // Texto del botón
  fill(0);
  textAlign(CENTER, CENTER);
  textSize(14);
  text("Reiniciar", buttonX + buttonW/2, buttonY + buttonH/2);
}

void drawMessage() {
  // Fondo semi-transparente
  fill(0, 0, 0, 150);
  rect(0, 0, width, height);
  
  // Caja del mensaje
  fill(255);
  stroke(0);
  strokeWeight(3);
  rectMode(CENTER);
  rect(150, 150, 200, 80, 10);
  
  // Texto del mensaje
  fill(0);
  textAlign(CENTER, CENTER);
  textSize(18);
  text(gameMessage, 150, 140);
  
  textSize(14);
  fill(100);
  text("Click para continuar", 150, 165);
  
  rectMode(CORNER);
}

void mousePressed() {
  // Si hay mensaje mostrado, ocultarlo al hacer click
  if (showMessage) {
    showMessage = false;
    return;
  }
  
  // Verificar click en botón de reinicio
  if (mouseX >= buttonX && mouseX <= buttonX + buttonW && 
      mouseY >= buttonY && mouseY <= buttonY + buttonH) {
    resetGame();
    return;
  }
  
  // Juego normal
  if (gameEnded || mouseY >= 300) return; // No permitir clicks si el juego terminó o fuera del tablero
  
  int i = mouseX / 100;
  int j = mouseY / 100;
  
  // Verificar que la casilla esté vacía y dentro del tablero
  if (i >= 0 && i < 3 && j >= 0 && j < 3 && board[i][j] == 0) {
    board[i][j] = xTurn ? 1 : 2;
    xTurn = !xTurn;
  }
}

void checkWin() {
  // Verificar filas
  for (int i = 0; i < 3; i++) {
    if (board[i][0] != 0 && board[i][0] == board[i][1] && board[i][1] == board[i][2]) {
      winner = board[i][0];
      gameEnded = true;
      highlightWinningLine(i, 0, i, 2);
      return;
    }
  }
  
  // Verificar columnas
  for (int j = 0; j < 3; j++) {
    if (board[0][j] != 0 && board[0][j] == board[1][j] && board[1][j] == board[2][j]) {
      winner = board[0][j];
      gameEnded = true;
      highlightWinningLine(0, j, 2, j);
      return;
    }
  }
  
  // Verificar diagonal principal
  if (board[0][0] != 0 && board[0][0] == board[1][1] && board[1][1] == board[2][2]) {
    winner = board[0][0];
    gameEnded = true;
    highlightWinningLine(0, 0, 2, 2);
    return;
  }
  
  // Verificar diagonal secundaria
  if (board[0][2] != 0 && board[0][2] == board[1][1] && board[1][1] == board[2][0]) {
    winner = board[0][2];
    gameEnded = true;
    highlightWinningLine(0, 2, 2, 0);
    return;
  }
  
  // Verificar empate
  boolean boardFull = true;
  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
      if (board[i][j] == 0) {
        boardFull = false;
        break;
      }
    }
    if (!boardFull) break;
  }
  
  if (boardFull) {
    winner = 3; // Empate
    gameEnded = true;
    showWinMessage();
  }
}

void highlightWinningLine(int x1, int y1, int x2, int y2) {
  // Mostrar línea ganadora
  stroke(255, 215, 0); // Dorado
  strokeWeight(8);
  line(x1 * 100 + 50, y1 * 100 + 50, x2 * 100 + 50, y2 * 100 + 50);
  
  // Mostrar mensaje de ganador después de un pequeño delay
  showWinMessage();
}

void showWinMessage() {
  if (winner == 1) {
    gameMessage = "¡X Gana!";
  } else if (winner == 2) {
    gameMessage = "¡O Gana!";
  } else if (winner == 3) {
    gameMessage = "¡Empate!";
  }
  showMessage = true;
}

void resetGame() {
  // Reiniciar todas las variables
  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
      board[i][j] = 0;
    }
  }
  xTurn = true;
  gameEnded = false;
  winner = 0;
  gameMessage = "";
  showMessage = false;
}

// Función extra: detectar teclas para funcionalidades adicionales
void keyPressed() {
  if (key == 'r' || key == 'R') {
    resetGame();
  }
  if (key == ' ' && showMessage) {
    showMessage = false;
  }
}
