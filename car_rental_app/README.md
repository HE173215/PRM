# Car Rental Mobile Application

Ứng dụng di động Thuê xe Ô tô (Car Rental App) xây dựng bằng **Flutter + Dart**, kết nối Backend **Node.js + Express + MongoDB Atlas**.

---

## 🚀 Các tính năng chính (Features)

### 1. Dành cho Khách hàng (Customer Flow)
- **Xác thực:** Đăng ký, Đăng nhập, Tự động đăng nhập qua JWT Bearer Token, Đăng xuất.
- **Trang chủ & Xe:** Khám phá xe nổi bật, lọc theo thương hiệu (VinFast, Mazda, Toyota, Hyundai, Kia...), tìm kiếm theo tên và địa điểm, chi tiết thông số kỹ thuật xe.
- **Đặt xe (Booking):** Chọn ngày nhận/trả xe trực quan, tự động tính số ngày thuê, hiển thị bảng kê chi phí dự kiến.
- **Thanh toán & Hóa đơn (Phase 6):**
  - **Mock Payment Flow:** Xác nhận thanh toán qua API `PATCH /api/bookings/:id/pay`.
  - **Hóa đơn điện tử (Invoice):** Xem chi tiết hóa đơn theo phong cách vé xe sang trọng, đóng dấu `PAID` khi hoàn tất.
  - **Quản lý đơn:** Lịch sử đơn thuê, theo dõi tiến trình (Pending $\rightarrow$ Confirmed $\rightarrow$ Ongoing $\rightarrow$ Completed), hủy đơn an toàn.

### 2. Trung tâm Quản trị Admin CMS & Dashboard (Phase 7)
Chỉ hiển thị cho tài khoản có vai trò `role: "admin"`:
- **Admin Dashboard:**
  - Bảng số liệu KPI: Tổng doanh thu thực tế (chỉ tính từ đơn đã paid), tổng số đơn đặt, phân bổ trạng thái đơn, trạng thái đội xe (sẵn sàng, đang thuê, bảo dưỡng), tổng số người dùng.
  - Top 5 xe được thuê nhiều nhất và doanh thu tạo ra.
- **Quản lý Đội xe (Car Management):**
  - Xem danh sách xe, tìm kiếm, lọc theo trạng thái (`available`, `rented`, `maintenance`).
  - Thêm xe mới, Chỉnh sửa thông tin xe.
  - Xóa xe an toàn (bảo toàn lịch sử booking).
- **Quản lý Đơn thuê (Booking Management):**
  - Danh sách tất cả đơn thuê trong hệ thống, tìm kiếm theo mã đơn hoặc tên xe.
  - Lọc đa chiều: Trạng thái booking (`pending`, `confirmed`, `ongoing`, `completed`, `cancelled`) và Trạng thái thanh toán (`paid`, `unpaid`).
  - Cập nhật trạng thái đơn thuê.
- **Quản lý Người dùng (User Management):**
  - Xem danh sách người dùng, tìm kiếm theo họ tên, email, số điện thoại.
  - Khóa (Block) / Mở khóa (Unblock) tài khoản người dùng (`PATCH /api/admin/users/:id/status`).
  - **Bảo mật:** Không cho phép Admin tự khóa tài khoản của chính mình (*"Admin cannot block own account"*).
- **Báo cáo & Thống kê (Reports):**
  - **Doanh thu theo tháng:** Biểu đồ thanh 12 tháng trực quan, hỗ trợ chọn năm xem báo cáo (`GET /api/admin/reports/revenue?year=YYYY`).
  - **Thống kê Đơn thuê:** Tỷ lệ phần trăm và số lượng đơn theo từng trạng thái (`GET /api/admin/reports/bookings`).
  - **Top xe thuê nhiều nhất:** Bảng xếp hạng Top 10 xe kèm số lượt thuê và tổng doanh thu (`GET /api/admin/reports/top-cars`).

---

## 📡 Danh sách Admin API (Backend Integration)

| Phân hệ | Endpoint | Method | Quyền | Mô tả |
| :--- | :--- | :---: | :---: | :--- |
| **Dashboard** | `/api/admin/dashboard` | GET | Admin | Lấy tổng quan KPI doanh thu, đơn thuê, đội xe, users |
| **Báo cáo** | `/api/admin/reports/revenue?year=2026` | GET | Admin | Thống kê doanh thu theo 12 tháng của năm |
| **Báo cáo** | `/api/admin/reports/bookings` | GET | Admin | Thống kê số lượng đơn theo trạng thái |
| **Báo cáo** | `/api/admin/reports/top-cars?limit=10` | GET | Admin | Danh sách xe được thuê nhiều nhất |
| **Quản lý Xe** | `/api/cars` | POST | Admin | Thêm xe mới |
| **Quản lý Xe** | `/api/cars/:id` | PUT | Admin | Cập nhật thông tin xe |
| **Quản lý Xe** | `/api/cars/:id` | DELETE | Admin | Xóa xe khỏi hệ thống |
| **Quản lý Đơn** | `/api/bookings/admin/all` | GET | Admin | Danh sách tất cả đơn thuê (kèm lọc status, payment, search) |
| **Quản lý Đơn** | `/api/bookings/admin/:id/status` | PATCH | Admin | Cập nhật trạng thái đơn thuê |
| **Thanh toán** | `/api/bookings/:id/pay` | PATCH | Protect | Mock thanh toán đơn thuê |
| **Quản lý User** | `/api/admin/users` | GET | Admin | Danh sách tất cả người dùng |
| **Quản lý User** | `/api/admin/users/:id` | GET | Admin | Chi tiết một người dùng |
| **Quản lý User** | `/api/admin/users/:id/status` | PATCH | Admin | Cập nhật trạng thái người dùng (`active` / `blocked`) |

---

## ⚙️ Cài đặt & Khởi chạy ứng dụng

```bash
# Cài đặt dependencies
flutter pub get

# Kiểm tra lint & code quality
flutter analyze

# Chạy ứng dụng trên thiết bị / máy ảo
flutter run
```
