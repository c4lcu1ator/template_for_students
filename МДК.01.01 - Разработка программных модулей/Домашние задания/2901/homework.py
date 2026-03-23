import sys
from PyQt6.QtWidgets import QApplication, QMainWindow, QVBoxLayout, QWidget, QLabel, QLineEdit, QPushButton

class ConverterService:
    @staticmethod
    def to_binary(number):
        return bin(number)[2:]

class Converter(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Двоичный конвертер")
        self.setGeometry(300, 300, 300, 150)
        
        widget = QWidget()
        self.setCentralWidget(widget)
        layout = QVBoxLayout()
        
        self.input = QLineEdit()
        layout.addWidget(QLabel("Число (int):"))
        layout.addWidget(self.input)
        
        self.result = QLabel("Двоичный: --")
        layout.addWidget(self.result)
        
        btn = QPushButton("Конвертировать")
        btn.clicked.connect(self.convert)
        layout.addWidget(btn)
        
        widget.setLayout(layout)
    
    def convert(self):
        try:
            num = int(self.input.text())
            binary = ConverterService.to_binary(num)
            self.result.setText(f"Двоичный: {binary}")
        except ValueError:
            self.result.setText("Некорректный ввод")

app = QApplication(sys.argv)
win = Converter()
win.show()
sys.exit(app.exec())
