# 🏋️ Gym Tracker Core — Architecture, Database & Algorithms

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.0+-blue.svg)](https://www.typescriptlang.org/)
[![Database: SQLite & PostgreSQL](https://img.shields.io/badge/Database-SQLite%20%7C%20PostgreSQL-003B57.svg)](https://www.sqlite.org/)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/)

> **Kiến trúc, lược đồ cơ sở dữ liệu và thuật toán cốt lõi cho ứng dụng theo dõi tập gym cá nhân.**  
> Dự án được tổng hợp và tối ưu từ các tinh hoa của những app gym hàng đầu: [Hevy](https://www.hevyapp.com/), [Strong](https://www.strong.app/), [Boostcamp](https://www.boostcamp.app/), [Alpha Progression](https://alphaprogression.com/) và [Liftosaur](https://www.liftosaur.com/).

---

## 📌 Mục lục

- [Tổng quan kiến trúc](#-tổng-quan-kiến-trúc)
- [Cấu trúc thư mục](#-cấu-trúc-thư-mục)
- [Cơ sở dữ liệu (Database Schema)](#-cơ-sở-dữ-liệu-database-schema)
- [Bộ dữ liệu bài tập mở (Exercise Dataset)](#-bộ-dữ-liệu-bài-tập-mở-exercise-dataset)
- [Các thuật toán cốt lõi (Core Algorithms)](#-các-thuật-toán-cốt-lõi-core-algorithms)
  - [1. Ước tính 1-Rep Max (1RM)](#1-ước-tính-1-rep-max-1rm)
  - [2. Máy tính chia bánh tạ (Plate Calculator)](#2-máy-tính-chia-bánh-tạ-plate-calculator)
  - [3. Tự động tính hiệp khởi động (Warm-up Sets)](#3-tự-động-tính-hiệp-khởi-động-warm-up-sets)
  - [4. Thuật toán tiến tạ kép (Double Progression)](#4-thuật-toán-tiến-tạ-kép-double-progression)
- [Hướng dẫn đẩy lên GitHub cá nhân](#-hướng-dẫn-đẩy-lên-github-cá-nhân)
- [Lộ trình phát triển (Roadmap)](#-lộ-trình-phát-triển-roadmap)
- [Đóng góp & Giấy phép](#-đóng-góp--giấy-phép)

---

## 🏛️ Tổng quan kiến trúc

Ứng dụng được thiết kế theo triết lý **Local-First (Ưu tiên ngoại tuyến)**:
- **Tốc độ 0ms**: Toàn bộ thao tác ghi log set, bấm giờ nghỉ (rest timer) và tra cứu bài tập đều thao tác trực tiếp trên SQLite cục bộ. Không bị trễ hay mất kết nối khi tập ở tầng hầm hoặc nơi sóng yếu.
- **Đồng bộ nền (Background Sync)**: Khi có kết nối mạng, dữ liệu sẽ tự động đồng bộ hai chiều lên đám mây (Supabase / PostgreSQL) để lưu trữ an toàn.

```
+-------------------------------------------------------+
|                    Client Mobile App                  |
|          (React Native + Expo / Flutter)              |
|                                                       |
|   +-------------------+       +-------------------+   |
|   | Fast-Log UI       |       | Rest Timer        |   |
|   +-------------------+       +-------------------+   |
|             \                       /                 |
|              v                     v                  |
|           +---------------------------+               |
|           | Local SQLite (Drizzle ORM)|               |
|           +---------------------------+               |
+--------------------------|----------------------------+
                           | (Auto Sync when online)
                           v
+-------------------------------------------------------+
|                  Backend Cloud Storage                |
|             (Supabase PostgreSQL + Storage)           |
+-------------------------------------------------------+
```

---

## 📂 Cấu trúc thư mục

```bash
gym-tracker-core/
├── README.md               # Tài liệu dự án đầy đủ
├── LICENSE                 # Giấy phép mã nguồn mở (MIT)
├── .gitignore              # Cấu hình bỏ qua file rác khi git commit
├── database/
│   └── schema.sql          # Toàn bộ DDL khởi tạo bảng (PostgreSQL & SQLite)
├── src/
│   └── utils/
│       └── algorithms.ts   # Mã nguồn TypeScript cho các thuật toán tập luyện
└── scripts/
    └── seed_exercises.py   # Script tự động kéo 800+ bài tập từ free-exercise-db
```

---

## 🗄️ Cơ sở dữ liệu (Database Schema)

Tất cả bảng và quan hệ được định nghĩa chi tiết tại [`database/schema.sql`](database/schema.sql).

### Các bảng chính:
1. `muscles`: Danh mục các nhóm cơ (Ngực, Lưng, Chân, Vai, Tay trước, Tay sau, Bụng,...).
2. `exercises`: Danh mục 800+ bài tập chuẩn, loại thiết bị, cơ chế chuyển động và ảnh động tác.
3. `routines` & `routine_exercises`: Quản lý các giáo án tập mẫu (VD: Push Day, Pull Day, Legs Day).
4. `workouts`: Lưu lại từng buổi tập thực tế (thời gian bắt đầu, kết thúc, tổng volume, đánh giá).
5. `workout_sets`: Từng set cụ thể (số kg, số reps, loại set: Warmup/Normal/Dropset, RPE, RIR, cờ PR).
6. `personal_records`: Bảng ghi nhận kỷ lục cá nhân (Max 1RM, Max Volume, Max Reps).
7. `body_metrics`: Theo dõi cân nặng, chỉ số mỡ (% Bodyfat) và số đo các vòng.

---

## 📦 Bộ dữ liệu bài tập mở (Exercise Dataset)

Dự án tích hợp sẵn nguồn dữ liệu mở miễn phí từ [[GitHub] yuhonas/free-exercise-db](https://github.com/yuhonas/free-exercise-db):
- Hơn 800 bài tập tập luyện kháng lực.
- Đi kèm ảnh minh họa và hướng dẫn kỹ thuật chi tiết.
- Sử dụng script `scripts/seed_exercises.py` để tự động chuyển đổi JSON sang định dạng database.

---

## 🧮 Các thuật toán cốt lõi (Core Algorithms)

Toàn bộ thuật toán được viết bằng TypeScript tại [`src/utils/algorithms.ts`](src/utils/algorithms.ts):

### 1. Ước tính 1-Rep Max (1RM)
Dùng trung bình có trọng số giữa 2 công thức khoa học phổ biến nhất:
- **Epley**: $1\text{RM} = W \times (1 + \frac{R}{30})$
- **Brzycki**: $1\text{RM} = W \times \frac{36}{37 - R}$

### 2. Máy tính chia bánh tạ (Plate Calculator)
Tự động tính toán số bánh tạ chuẩn Olympic (25kg, 20kg, 15kg, 10kg, 5kg, 2.5kg, 1.25kg) cho mỗi bên thanh đòn theo thuật toán Greedy.

### 3. Tự động tính hiệp khởi động (Warm-up Sets)
Tự động chia tỉ lệ làm nóng an toàn trước hiệp chính (Working Set):
- Set 1: Đòn không (20kg) x 10 reps (Làm ấm khớp).
- Set 2: 50% mức tạ chính x 5 reps.
- Set 3: 70% mức tạ chính x 3 reps.
- Set 4: 85% mức tạ chính x 1 rep (Chuẩn bị thần kinh).

### 4. Thuật toán tiến tạ kép (Double Progression)
Tự động đánh giá hiệu suất buổi tập: Nếu người dùng đạt mốc rep tối đa ở mọi set -> Gợi ý tăng +2.5kg ở buổi tập kế tiếp và quay về mốc rep sàn.

---

## 🚀 Hướng dẫn đẩy lên GitHub cá nhân

Để đưa dự án này lên tài khoản GitHub của bạn:

```bash
# 1. Khởi tạo kho chứa Git cục bộ
git init

# 2. Thêm tất cả các file vào Git
git add .

# 3. Tạo commit đầu tiên
git commit -m "feat: initial commit for gym-tracker-core architecture & algorithms"

# 4. Đổi nhánh mặc định thành main
git branch -M main

# 5. Liên kết tới repository bạn vừa tạo trên GitHub (thay URL bằng link repo của bạn)
git remote add origin https://github.com/<your-username>/gym-tracker-core.git

# 6. Đẩy code lên GitHub
git push -u origin main
```

---

## 🗺️ Lộ trình phát triển (Roadmap)

- [x] Thiết kế Database Schema chuẩn (PostgreSQL & SQLite).
- [x] Xây dựng bộ thuật toán tính toán nền tảng (1RM, Plate, Progression).
- [x] Tạo script seed dữ liệu 800+ bài tập.
- [ ] Xây dựng Mobile UI với React Native & Expo (Active Workout, Fast Logging).
- [ ] Triển khai Rest Timer chạy ngầm (Live Activity / Background Notification).
- [ ] Tích hợp đồng bộ đám mây với Supabase.
- [ ] Kết nối Apple Health & Google Health Connect.

---

## 📄 Đóng góp & Giấy phép

Dự án phát hành dưới giấy phép mã nguồn mở [MIT License](LICENSE). Bạn hoàn toàn tự do sử dụng, chỉnh sửa và đóng góp cho dự án.
