import tkinter as tk
from tkinter import messagebox, ttk
from backend.business_logic import ShoppingBackend

class MinimalShoppingUI:
    def __init__(self, backend: ShoppingBackend):
        self.backend = backend
        self.root = tk.Tk()
        self.root.title("🛒 Покупки")
        self.root.geometry("600x500")
        self.root.configure(bg="#f5f5f5")
        
        self.create_login_screen()
    
    def create_login_screen(self):
        for w in self.root.winfo_children():
            w.destroy()
        
        frame = tk.Frame(self.root, bg="#f5f5f5")
        frame.pack(expand=True)
        
        tk.Label(frame, text="Система покупок", font=("Arial", 18, "bold"), bg="#f5f5f5").pack(pady=20)
        tk.Label(frame, text="Имя пользователя", bg="#f5f5f5").pack()
        self.login_entry = tk.Entry(frame, width=30)
        self.login_entry.pack(pady=5)
        self.login_entry.bind("<Return>", lambda e: self.do_login())
        
        tk.Button(frame, text="Войти", command=self.do_login, bg="#4CAF50", fg="white", padx=20).pack(pady=10)
        
        # Показать пользователей
        users = self.backend.db.get_all_users()
        if users:
            tk.Label(frame, text="Доступные пользователи:", bg="#f5f5f5", font=("Arial", 9)).pack(pady=(20,0))
            user_list = ", ".join([u["username"] for u in users])
            tk.Label(frame, text=user_list, bg="#f5f5f5", font=("Arial", 8, "italic")).pack()
    
    def do_login(self):
        username = self.login_entry.get().strip()
        if username and self.backend.login(username):
            self.create_main_screen()
        else:
            messagebox.showerror("Ошибка", "Пользователь не найден")
    
    def create_main_screen(self):
        for w in self.root.winfo_children():
            w.destroy()
        
        user = self.backend.get_current_user()
        tk.Label(self.root, text=f"👤 {user['username']} | Баланс: {user['balance']} ₽", 
                bg="#333", fg="white", font=("Arial", 10)).pack(fill=tk.X, pady=(0,5))
        
        notebook = ttk.Notebook(self.root)
        notebook.pack(fill=tk.BOTH, expand=True, padx=10, pady=5)
        
        # Вкладка товары
        products_frame = tk.Frame(notebook)
        notebook.add(products_frame, text="Товары")
        self.create_products_tab(products_frame)
        
        # Вкладка избранное
        fav_frame = tk.Frame(notebook)
        notebook.add(fav_frame, text="Избранное")
        self.create_favorites_tab(fav_frame)
        
        # Вкладка рекомендации
        rec_frame = tk.Frame(notebook)
        notebook.add(rec_frame, text="Рекомендации")
        self.create_recommendations_tab(rec_frame)
        
        tk.Button(self.root, text="Выйти", command=self.logout, bg="#f44336", fg="white").pack(pady=5)
    
    def create_products_tab(self, parent):
        cols = ("ID", "Название", "Цена", "В наличии", "Категория")
        tree = ttk.Treeview(parent, columns=cols, show="headings", height=12)
        for col in cols:
            tree.heading(col, text=col)
            tree.column(col, width=100)
        tree.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        
        products = self.backend.db.get_all_products()
        for p in products:
            tree.insert("", tk.END, values=(p["product_id"], p["name"], f"{p['price']}₽", p["stock"], p["category_name"]))
        
        btn_frame = tk.Frame(parent)
        btn_frame.pack(fill=tk.X, pady=5)
        
        tk.Button(btn_frame, text="❤️ В избранное", command=lambda: self.add_favorite(tree), bg="#ff9800").pack(side=tk.LEFT, padx=5)
        tk.Button(btn_frame, text="💸 Купить", command=lambda: self.buy_product(tree), bg="#4CAF50", fg="white").pack(side=tk.LEFT, padx=5)
    
    def buy_product(self, tree):
        selected = tree.selection()
        if not selected:
            return
        values = tree.item(selected[0])["values"]
        product_id = int(values[0])
        if self.backend.buy_product(product_id):
            messagebox.showinfo("Успех", f"{values[1]} куплен!")
            self.create_main_screen()
        else:
            messagebox.showerror("Ошибка", "Недостаточно средств или товара")
    
    def add_favorite(self, tree):
        selected = tree.selection()
        if selected:
            values = tree.item(selected[0])["values"]
            self.backend.add_to_favorites(int(values[0]))
            messagebox.showinfo("Избранное", f"{values[1]} добавлен")
    
    def create_favorites_tab(self, parent):
        listbox = tk.Listbox(parent, font=("Arial", 11))
        listbox.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        favs = self.backend.db.get_favorites(self.backend.current_user_id)
        for f in favs:
            listbox.insert(tk.END, f"{f['name']} - {f['price']}₽")
    
    def create_recommendations_tab(self, parent):
        listbox = tk.Listbox(parent, font=("Arial", 11))
        listbox.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        recs = self.backend.get_recommendations()
        for r in recs:
            listbox.insert(tk.END, f"{r['name']} (популярность: {r['times_bought']})")
    
    def logout(self):
        self.backend.logout()
        self.create_login_screen()
    
    def run(self):
        self.root.mainloop()
