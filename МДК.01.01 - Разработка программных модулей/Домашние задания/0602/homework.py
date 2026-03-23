import sys
from PyQt6.QtWidgets import QApplication, QMainWindow
from mainwindow_ui import Ui_MainWindow
from addform_ui import Ui_Dialog

class AddDialog(Ui_Dialog):
    def __init__(self):
        super().__init__()
        self.dialog = self.setupUi(None)  # Создаём диалог

class MainWindow(QMainWindow, Ui_MainWindow):
    def __init__(self):
        super().__init__()
        self.setupUi(self)
        self.addButton.clicked.connect(self.show_add_dialog)
    
    def show_add_dialog(self):
        dialog = AddDialog()
        if dialog.trackEdit.text() and dialog.addButton.clicked.connect(lambda: self.add_track(dialog.trackEdit.text())):
            dialog.show()
        else:
            pass  # Обработка закрытия

    def add_track(self, track_name):
        self.playlistWidget.addItem(track_name)

app = QApplication(sys.argv)
win = MainWindow()
win.show()
sys.exit(app.exec())
