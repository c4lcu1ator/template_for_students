import sys
from PyQt6.QtWidgets import (QApplication, QMainWindow, QVBoxLayout, QWidget, 
                             QLabel, QPushButton, QHBoxLayout)
from PyQt6.QtCore import pyqtSignal

class TrackWidget(QWidget):
    track_selected = pyqtSignal(str, str, str)
    
    def __init__(self, title, artist, genre):
        super().__init__()
        self.title = title
        self.artist = artist
        self.genre = genre
        
        layout = QHBoxLayout()
        
        layout.addWidget(QLabel(f"{title} - {artist} ({genre})"))
        
        btn = QPushButton("Выбрать")
        btn.clicked.connect(self.select_track)
        layout.addWidget(btn)
        
        self.setLayout(layout)
    
    def select_track(self):
        self.track_selected.emit(self.title, self.artist, self.genre)

class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Выбор трека")
        self.setGeometry(300, 300, 400, 200)
        
        widget = QWidget()
        self.setCentralWidget(widget)
        layout = QVBoxLayout()
        
        self.track1 = TrackWidget("Bohemian Rhapsody", "Queen", "Rock")
        self.track1.track_selected.connect(self.on_track_selected)
        layout.addWidget(self.track1)
        
        self.track2 = TrackWidget("Billie Jean", "Michael Jackson", "Pop")
        self.track2.track_selected.connect(self.on_track_selected)
        layout.addWidget(self.track2)
        
        self.status = QLabel("Трек не выбран")
        layout.addWidget(self.status)
        
        widget.setLayout(layout)
    
    def on_track_selected(self, title, artist, genre):
        self.status.setText(f"Выбран: {title} - {artist} ({genre})")

app = QApplication(sys.argv)
win = MainWindow()
win.show()
sys.exit(app.exec())
