import sys
from PyQt6.QtWidgets import QApplication, QMainWindow, QVBoxLayout, QWidget, QLabel, QLineEdit, QPushButton


class Converter(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Конвертер температуры")
        self.setGeometry(300, 300, 250, 150)

        widget = QWidget()
        self.setCentralWidget(widget)
        layout = QVBoxLayout()

        self.input = QLineEdit()
        layout.addWidget(QLabel("Цельсий:"))
        layout.addWidget(self.input)

        self.result = QLabel("Фаренгейт: --")
        layout.addWidget(self.result)

        btn = QPushButton("Перевести")
        btn.clicked.connect(self.convert)
        layout.addWidget(btn)

        widget.setLayout(layout)

    def convert(self):
        try:
            c = float(self.input.text())
            f = (c * 9 / 5) + 32
            self.result.setText(f"Фаренгейт: {f:.2f}")
        except:
            self.result.setText("Ошибка ввода")


app = QApplication(sys.argv)
win = Converter()
win.show()
sys.exit(app.exec())
