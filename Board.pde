public class Board{
    Cell[][] board;
    int rows, cols;
    int numBombs, flags;
    int availMoves;
    int gameOver = 0; // -1 lost, 0 playing, 1 won
    int startTime;
    boolean firstClick = true;
    boolean timerOn = false;
    PImage mineImg = loadImage("Images/Mine.png");
    PImage flagImg = loadImage("Images/Flag.png");

    color bomb = color(255, 50, 132);
    color hidden = color(50, 132, 255);
    color revealed = color(51, 51, 70);
    color flagged = color(128, 128, 155);
    color won = color(50, 255, 132);
    color textCol = color(204, 204, 255);

    public Board(int rows, int cols, int numBombs){
        this.rows = rows;
        this.cols = cols;
        this.numBombs = numBombs;

        board = new Cell[rows][cols];
        initBoard();
    }

    void initBoard(){
        for(int r = 0; r < rows; r++)
            for(int c = 0; c < cols; c++)
                board[r][c] = new Cell();

        assignBombs();
        updateCellNumbers();
        gameOver = 0;
        firstClick = true;
        flags = 0;
        timerOn = false;
    }

    void assignBombs(){
        int count = 0;
        while(count < numBombs){
            int num = (int)random(rows * cols);

            if(!board[num / cols][num % cols].isBomb()){
                board[num / cols][num % cols].setBomb();
                count++;
            }
        }
    }

    void updateCellNumbers(){
        for(int r = 0; r < rows; r++){
            for(int c = 0; c < cols; c++){
                if(board[r][c].isBomb()) continue;

                int adjBombs = getAdjBombCount(r, c);
                board[r][c].setNum(adjBombs);
            }
        }
    }

    int getAdjBombCount(int r, int c){
        int count = 0;
        for(int sqrR = r - 1; sqrR <= r + 1; sqrR++){
            if(sqrR < 0 || sqrR >= rows) continue;
            for(int sqrC = c - 1; sqrC <= c + 1; sqrC++){
                if(sqrC < 0 || sqrC >= cols) continue;
                if(sqrR == r && sqrC == c) continue;

                if(board[sqrR][sqrC].isBomb())
                    count++;
            }
        }

        return count;
    }

    public void reveal(int r, int c){
        if(board[r][c].isFlagged()) return;

        if(gameOver != 0){ // If game already over
            initBoard();
            loop();
            return;
        }

        if(firstClick){
            while(board[r][c].isBomb() || board[r][c].getNum() > 0)
                initBoard();
        }
        firstClick = false;

        board[r][c].reveal();
        if(!timerOn) {
            startTime = millis();
            timerOn = true;
        }

        if(!board[r][c].isBomb() && board[r][c].getNum() == 0)
            revealAdjCells(r, c);

        if(board[r][c].isBomb()){
            gameOver = -1;
            revealAllBombs(bomb);
            noLoop();
        } 

        if(checkWinState()){
            drawBoard();
            gameOver = 1;
            revealAllBombs(won);
            noLoop();
        }
    }

    void revealAllBombs(color col){
        for(int r = 0; r < rows; r++){
            for(int c = 0; c < cols; c++){
                if(board[r][c].isBomb()){
                    fill(col);
                    if(col == bomb && board[r][c].isFlagged())
                        fill(flagged);

                    rect(c * wid, r * wid, wid, wid);
                    image(mineImg, c*wid, r*wid, wid, wid);
                }
            }
        }
    }

    public void flag(int r, int c){
        if(board[r][c].isRevealed()) return;

        board[r][c].flag();
        if(board[r][c].isFlagged()) flags++;
        else flags--;
    }

    void revealAdjCells(int r, int c){
        if(r < 0 || r >= rows || c < 0 || c >= cols) return;

        for(int sqrR = r - 1; sqrR <= r + 1; sqrR++){
            if(sqrR < 0 || sqrR >= rows) continue;
            for(int sqrC = c - 1; sqrC <= c + 1; sqrC++){
                if(sqrC < 0 || sqrC >= cols) continue;
                if(sqrR == r && sqrC == c) continue;
                if(board[sqrR][sqrC].isRevealed()) continue;
                
                board[sqrR][sqrC].reveal();

                if(!board[sqrR][sqrC].isBomb() && !board[r][c].isFlagged() && board[sqrR][sqrC].getNum() == 0)
                    revealAdjCells(sqrR, sqrC);
            }
        }
    }

    int countAvailMoves(){
        int count = 0;
        for(int r = 0; r < rows; r++)
            for(int c = 0; c < cols; c++)
                if(!board[r][c].isRevealed())
                    count++;

        return count;
    }

    boolean checkWinState(){
        availMoves = countAvailMoves();
        if(availMoves == numBombs){
            gameOver = 1;
            return true;
        } 
        return false;
    }

    String getFormattedTime() {
        int elapsedTime = (millis() - startTime) / 1000; // Calculate elapsed time in seconds
        int minutes = elapsedTime / 60; 
        int seconds = elapsedTime % 60; 

        // Format the time as MM:SS
        return String.format("%02d:%02d", minutes, seconds);
    }

    public void drawBoard(){
        float wid = width / cols;
        textAlign(CENTER, CENTER);
        textSize(24);
        noStroke();

        if(timerOn)
            surface.setTitle("Minesweeper || " + (numBombs - flags) + " bombs left || Time: " + getFormattedTime());
        else
            surface.setTitle("Minesweeper || " + (numBombs - flags) + " bombs left");

        for(int r = 0; r < rows; r++){
            for(int c = 0; c < cols; c++){
                if(board[r][c].isFlagged()){        // if cell is flagged
                    fill(flagged);
                    rect(c * wid, r * wid, wid, wid);
                    image(flagImg, c * wid, r * wid, wid, wid);
                }
                else if(!board[r][c].isRevealed()){ // if cell is hidden
                    fill(hidden);
                    rect(c * wid, r * wid, wid, wid);
                }
                else{                               // if cell is revealed
                    if(board[r][c].isBomb()){
                        fill(bomb);
                        rect(c * wid, r * wid, wid, wid);
                        image(mineImg, c * wid, r * wid, wid, wid);
                    }
                    else if(board[r][c].getNum() == 0){
                        fill(revealed);
                        rect(c * wid, r * wid, wid, wid);
                    }
                    else{
                        fill(revealed);
                        rect(c * wid, r * wid, wid, wid);
                        fill(255);
                        text(board[r][c].getNum(), c * wid + wid/2, r * wid + wid/2);
                    }
                }
            }
        }
    }
}

class Cell{
    boolean isBomb;
    int number;
    boolean isFlagged = false;
    boolean revealed = false;

    public Cell(){
        isBomb = false;
        number = 0;
    }

    public void setBomb(){
        isBomb = true;
    }

    public boolean isBomb(){
        return isBomb;
    }

    public void setNum(int number){
        this.number = number;
    }

    public int getNum(){
        return number;
    }

    public void reveal(){
        revealed = true;
    }

    public void flag(){
        isFlagged = !isFlagged;
    }

    public boolean isRevealed(){
        return revealed;
    }

    public boolean isFlagged(){
        return isFlagged;
    }
}