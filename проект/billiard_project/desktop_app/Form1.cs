using System;
using System.Windows.Forms;

namespace BilliardAdminPanel
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            this.Text = "Панель администратора бильярдного клуба";
            LoadLocalDemoData();
        }

        private void btnRefresh_Click(object sender, EventArgs e)
        {
            // На этой ветке данные обновляются локально. Интеграция с Битриксом будет позже.
            LoadLocalDemoData();
            MessageBox.Show("Данные успешно обновлены из локальной базы!", "Уведомление", MessageBoxButtons.OK, MessageBoxIcon.Information);
        }

        private void LoadLocalDemoData()
        {
            listBoxBookings.Items.Clear();
            listBoxBookings.Items.Add("Стол №1 - Алексей (Ожидает подтверждения)");
            listBoxBookings.Items.Add("Стол №3 - Иван (Бронь на 20:00, Бургер x2, Кола x1)");
            listBoxBookings.Items.Add("Стол №2 - Свободен");
        }
    }
}
