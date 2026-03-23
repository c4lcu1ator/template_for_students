import sys
import random
from PyQt6.QtWidgets import QApplication, QMainWindow
from mainwindow_ui import Ui_MainWindow

class Game(QMainWindow, Ui_MainWindow):
    def __init__(self):
        super().__init__()
        self.setupUi(self)
        self.number = 0
        self.attempts = 0
        self.new_game()
        self.guessButton.clicked.connect(self.guess)
        self.newGameButton.clicked.connect(self.new_game)
    
    def new_game(self):
        self.number = random.randint(1, 100)
        self.attempts = 0
        self.statusLabel.setText("Угадайте число (1-100)")
        self.attemptsLabel.setText("Попыток: 0")
        self.numberInput.clear()
        self.numberInput.setFocus()
    
    def guess(self):
        try:
            guess = int(self.numberInput.text())
            self.attempts += 1
            self.attemptsLabel.setText(f"Попыток: {self.attempts}")
            if guess == self.number:
                self.statusLabel.setText(f"Победа! {self.attempts} попыток")
            elif guess < self.number:
                self.statusLabel.setText("Больше")
            else:
                self.statusLabel.setText("Меньше")
            self.numberInput.clear()
        except ValueError:
            self.statusLabel.setText("Введите число")

app = QApplication(sys.argv)
win = Game()
win.show()
sys.exit(app.exec())
