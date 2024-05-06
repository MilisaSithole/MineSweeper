public class Board{
    Cell[][] board;
    int rows, cols;
    int numBombs;
    boolean firstClick = true;

    color bomb = color(255, 50, 132);
    color hidden = color(50, 132, 255);
    color revealed = color(51, 51, 70);
    color textCol = color(204);

    public Board(int rows, int cols, int numBombs){
        this.rows = rows;
        this.cols = cols;
        this.numBombs = numBombs;

        board = new Cell[rows][cols];
        for(int r = 0; r < rows; r++)
            for(int c = 0; c < cols; c++)
                board[r][c] = new Cell();

        assignBombs();
        updateCellNumbers();
    }

    void assignBombs(){
        int[] chosenIndexes = new int[numBombs];
        
        int count = 0;
        while(count < numBombs){
            int num = (int)random(rows * cols);
            boolean found = false;
            for(int i = 0; i < chosenIndexes.length; i++)
                if(chosenIndexes[i] == num){
                    found = true;
                    break;
                }

            if(found) continue;
            else{
                chosenIndexes[count] = num;
                count++;
            }
        }

        for(int idx: chosenIndexes){
            int r = idx / cols;
            int c = idx % cols;
            board[r][c].setBomb();
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
        board[r][c].reveal();
    }

    public void drawBoard(){
        float wid = width / cols;
        textAlign(CENTER, CENTER);
        textSize(24);
        noStroke();

        for(int r = 0; r < rows; r++){
            for(int c = 0; c < cols; c++){
                if(!board[r][c].isRevealed()){  // if cell is revealed
                    fill(hidden);
                    rect(c * wid, r * wid, wid, wid);
                }
                else{                           // if cell is hidden
                    if(board[r][c].isBomb()){
                        fill(bomb);
                        rect(c * wid, r * wid, wid, wid);
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

    public boolean isRevealed(){
        return revealed;
    }
}