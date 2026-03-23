import sys
from PyQt6.QtWidgets import (
    QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout,
    QTableWidget, QTableWidgetItem, QLineEdit, QPushButton, QMessageBox
)


class TaskManager(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Менеджер задач")
        self.resize(600, 400)

        central = QWidget()
        self.setCentralWidget(central)
        main_layout = QVBoxLayout()
        central.setLayout(main_layout)

        self.table = QTableWidget()
        self.table.setColumnCount(2)
        self.table.setHorizontalHeaderLabels(["ID", "Задача"])
        self.table.horizontalHeader().setStretchLastSection(True)
        main_layout.addWidget(self.table)

        form_layout = QHBoxLayout()
        self.task_input = QLineEdit()
        self.task_input.setPlaceholderText("Новая задача...")
        form_layout.addWidget(self.task_input)

        self.add_button = QPushButton("Добавить")
        form_layout.addWidget(self.add_button)

        self.delete_button = QPushButton("Удалить выбранную")
        form_layout.addWidget(self.delete_button)

        main_layout.addLayout(form_layout)

        self.tasks = []
        self.next_id = 1

        self.add_button.clicked.connect(self.add_task)
        self.delete_button.clicked.connect(self.delete_task)

        self.refresh_table()

    def refresh_table(self):
        self.table.setRowCount(0)
        for row_idx, task in enumerate(self.tasks):
            self.table.insertRow(row_idx)
            self.table.setItem(row_idx, 0, QTableWidgetItem(str(task["id"])))
            self.table.setItem(row_idx, 1, QTableWidgetItem(task["title"]))

    def add_task(self):
        title = self.task_input.text().strip()
        if not title:
            QMessageBox.warning(self, "Ошибка", "Введите название задачи")
            return
        self.tasks.append({"id": self.next_id, "title": title})
        self.next_id += 1
        self.task_input.clear()
        self.refresh_table()

    def delete_task(self):
        row = self.table.currentRow()
        if row < 0:
            QMessageBox.warning(self, "Ошибка", "Не выбрана задача для удаления")
            return
        task_id_item = self.table.item(row, 0)
        if not task_id_item:
            QMessageBox.warning(self, "Ошибка", "Некорректная строка")
            return
        task_id = int(task_id_item.text())
        self.tasks = [t for t in self.tasks if t["id"] != task_id]
        self.refresh_table()


if __name__ == "__main__":
    app = QApplication(sys.argv)
    win = TaskManager()
    win.show()
    sys.exit(app.exec())
