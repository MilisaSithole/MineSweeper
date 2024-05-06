/* autogenerated by Processing revision 1293 on 2024-05-07 */
import processing.core.*;
import processing.data.*;
import processing.event.*;
import processing.opengl.*;

import java.util.HashMap;
import java.util.ArrayList;
import java.io.File;
import java.io.BufferedReader;
import java.io.PrintWriter;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.IOException;

public class MineSweeper extends PApplet {

int rows = 20, cols = 20;
int numBombs = 60;
float wid;
int hidden = color(50, 132, 255);
int lineCol = color(40, 125, 255);
int shown = color(51);

Board board;

public void setup() {
    /* size commented out by preprocessor */;
    background(51);

    wid = width / cols;
    board = new Board(rows, cols, numBombs);

    drawGrid();
}

public void draw() {
    board.drawBoard();
}

public void mouseReleased(){
    int r = (int)(mouseY / wid);
    int c = (int)(mouseX / wid);

    if(mouseButton == LEFT)
        board.reveal(r, c);
    if(mouseButton == RIGHT)
        board.flag(r, c);
}

public void keyReleased() {
    if(key == 'r')
        board = new Board(rows, cols, numBombs);
}

public void drawGrid(){
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
public class Board{
    Cell[][] board;
    int rows, cols;
    int numBombs, flags;
    boolean firstClick = true;
    boolean gameOver = false;
    PImage mineImg = loadImage("Images/Mine.png");
    PImage flagImg = loadImage("Images/Flag.png");

    int bomb = color(255, 50, 132);
    int hidden = color(50, 132, 255);
    int revealed = color(51, 51, 70);
    int flagged = color(128, 128, 155);
    int textCol = color(204, 204, 255);

    public Board(int rows, int cols, int numBombs){
        this.rows = rows;
        this.cols = cols;
        this.numBombs = numBombs;
        firstClick = true;

        board = new Cell[rows][cols];
        initBoard();
    }

    public void initBoard(){
        surface.setTitle("Minesweeper || " + (numBombs - flags) + " bombs left");
        for(int r = 0; r < rows; r++)
            for(int c = 0; c < cols; c++)
                board[r][c] = new Cell();

        assignBombs();
        updateCellNumbers();
        gameOver = false;
        firstClick = true;
        flags = 0;
    }

    public void assignBombs(){
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

    public void updateCellNumbers(){
        for(int r = 0; r < rows; r++){
            for(int c = 0; c < cols; c++){
                if(board[r][c].isBomb()) continue;

                int adjBombs = getAdjBombCount(r, c);
                board[r][c].setNum(adjBombs);
            }
        }
    }

    public int getAdjBombCount(int r, int c){
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
        
        if(gameOver){
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

        if(!board[r][c].isBomb() && board[r][c].getNum() == 0)
            revealAdjCells(r, c);

        if(board[r][c].isBomb()){
            gameOver = true;
            revealAllBombs();
            noLoop();
        } 
    }

    public void revealAllBombs(){
        for(int r = 0; r < rows; r++){
            for(int c = 0; c < cols; c++){
                if(board[r][c].isBomb()){
                    fill(bomb);
                    if(board[r][c].isFlagged())
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

    public void revealAdjCells(int r, int c){
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

    public void drawBoard(){
        float wid = width / cols;
        textAlign(CENTER, CENTER);
        textSize(24);
        noStroke();

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


  public void settings() { size(800, 800); }

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "MineSweeper" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
