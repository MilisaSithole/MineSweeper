public class Board{
    Cell[][] board;
    int rows, cols;
    int numBombs;

    color bomb = color(255, 50, 132);
    color nonBomb = color(50, 132, 255);

    public Board(int rows, int cols, int numBombs){
        this.rows = rows;
        this.cols = cols;
        this.numBombs = numBombs;

        board = new Cell[rows][cols];
        for(int r = 0; r < rows; r++)
            for(int c = 0; c < cols; c++)
                board[r][c] = new Cell();
        assignBombs();
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

    public void drawBoard(){
        float wid = width / cols;

        for(int r = 0; r < rows; r++){
            for(int c = 0; c < cols; c++){
                if(board[r][c].isBomb())
                    fill(bomb);
                else
                    fill(nonBomb);

                noStroke();
                rect(c * wid, r * wid, wid, wid);
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
}