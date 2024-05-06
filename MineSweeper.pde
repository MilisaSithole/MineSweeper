int rows = 20, cols = 20;
int numBombs = 60;
float wid;
color hidden = color(50, 132, 255);
color lineCol = color(40, 125, 255);
color shown = color(51);

Board board;

void setup() {
    size(800, 800);
    background(51);

    wid = width / cols;
    board = new Board(rows, cols, numBombs);

    drawGrid();
}

void draw() {
    board.drawBoard();
}

void mouseReleased(){
    int r = (int)(mouseY / wid);
    int c = (int)(mouseX / wid);

    if(mouseButton == LEFT)
        board.reveal(r, c);
    if(mouseButton == RIGHT)
        board.flag(r, c);
}

void keyReleased() {
    if(key == 'r')
        board = new Board(rows, cols, numBombs);
}

void drawGrid(){
    for(int r = 0; r < rows; r++){
        for(int c = 0; c < cols; c++){
            fill(hidden);
            noStroke();
            rect(c * wid, r * wid, wid, wid);
        }
    }

    stroke(lineCol);
    strokeWeight(1);
    for(int r = 0; r <= rows; r++){
        line(0, r * wid, width, r * wid);
        for(int c = 0; c <= cols; c++){
            line(c * wid, 0, c * wid, height);
        }
    }
}