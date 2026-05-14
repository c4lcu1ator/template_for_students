import tkinter as tk
from tkinter import messagebox, ttk
import json
import os

class ShoppingManager:
    def __init__(self, root):
        self.root = root
        self.root.title("Покупки")
        self.root.geometry("500x400")
        
        # Файл для сохранения
        self.data_file = "shopping_list.json"
        self.items = self.load_items()
        
        # Интерфейс
        self.create_widgets()
        self.update_list()
    
    def create_widgets(self):
        # Верхняя панель: добавление
        top_frame = tk.Frame(self.root)
        top_frame.pack(pady=10, padx=10, fill=tk.X)
        
        self.entry = tk.Entry(top_frame, font=("Arial", 12))
        self.entry.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(0, 5))
        self.entry.bind("<Return>", lambda e: self.add_item())
        
        add_btn = tk.Button(top_frame, text="+", width=3, command=self.add_item, 
                           font=("Arial", 12))
        add_btn.pack(side=tk.RIGHT)
        
        # Список покупок
        self.listbox = tk.Listbox(self.root, font=("Arial", 11), selectmode=tk.SINGLE)
        self.listbox.pack(fill=tk.BOTH, expand=True, padx=10, pady=5)
        
        # Нижняя панель: кнопки действий
        btn_frame = tk.Frame(self.root)
        btn_frame.pack(pady=10, padx=10, fill=tk.X)
        
        remove_btn = tk.Button(btn_frame, text="Удалить", command=self.remove_item,
                              font=("Arial", 10), bg="#ff6b6b", fg="white")
        remove_btn.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(0, 5))
        
        clear_btn = tk.Button(btn_frame, text="Очистить всё", command=self.clear_all,
                             font=("Arial", 10), bg="#ffa502", fg="white")
        clear_btn.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(0, 5))
        
        save_btn = tk.Button(btn_frame, text="Сохранить", command=self.save_items,
                            font=("Arial", 10), bg="#2ed573", fg="white")
        save_btn.pack(side=tk.LEFT, fill=tk.X, expand=True)
    
    def load_items(self):
        if os.path.exists(self.data_file):
            try:
                with open(self.data_file, 'r', encoding='utf-8') as f:
                    return json.load(f)
            except:
                return []
        return []
    
    def save_items(self):
        with open(self.data_file, 'w', encoding='utf-8') as f:
            json.dump(self.items, f, ensure_ascii=False, indent=2)
        messagebox.showinfo("Успех", "Список сохранён")
    
    def add_item(self):
        item = self.entry.get().strip()
        if item:
            self.items.append(item)
            self.update_list()
            self.entry.delete(0, tk.END)
        else:
            self.entry.focus()
    
    def remove_item(self):
        selection = self.listbox.curselection()
        if selection:
            index = selection[0]
            del self.items[index]
            self.update_list()
    
    def clear_all(self):
        if messagebox.askyesno("Подтверждение", "Очистить весь список?"):
            self.items.clear()
            self.update_list()
    
    def update_list(self):
        self.listbox.delete(0, tk.END)
        for idx, item in enumerate(self.items, 1):
            self.listbox.insert(tk.END, f"{idx}. {item}")

if __name__ == "__main__":
    root = tk.Tk()
    app = ShoppingManager(root)
    root.mainloop()
