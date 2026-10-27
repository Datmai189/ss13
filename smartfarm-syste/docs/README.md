# SmartFarm System

Hệ thống mẫu hỗ trợ quản lý thiết bị trạm cảm biến và tự động lọc các sự cố nghiêm trọng từ nhật ký máy chủ.

## Cấu trúc thư mục

```text
smartfarm-system/
├── .env
├── backup/
│   └── bao-cao-su-co.txt
├── data/
│   ├── log-he-thong.log
│   └── quan-ly-thiet-bi.xlsx
├── docs/
│   └── README.md
└── scripts/
    └── auto_report.ps1
```

## Khởi tạo căn cứ số

Tạo thư mục gốc và bốn thư mục con bằng đúng một dòng PowerShell:

```powershell
New-Item -ItemType Directory -Path smartfarm-system, smartfarm-system\docs, smartfarm-system\scripts, smartfarm-system\data, smartfarm-system\backup -Force
```

Đứng trong thư mục `data`, dùng đường dẫn tương đối để tạo và ẩn tệp `.env` ở thư mục gốc:

```powershell
"DB_PASSWORD=demo_123456" | Set-Content ..\.env
attrib +h ..\.env
```

## Hướng dẫn chạy script

Mở PowerShell, chuyển vào thư mục `scripts` và chạy:

```powershell
cd smartfarm-system\scripts
.\auto_report.ps1
```

Nếu PowerShell chặn script do `ExecutionPolicy`, chạy:

```powershell
powershell -ExecutionPolicy Bypass -File .\auto_report.ps1
```

Báo cáo được ghi vào `backup\bao-cao-su-co.txt`.

## Checklist kiểm tra thiết bị

- [x] Kiểm tra kết nối của `sensor-03`.
- [ ] Kiểm tra dung lượng lưu trữ của các gateway.
- [ ] Xác nhận dung lượng RAM đúng với hồ sơ trạm.
- [ ] Kiểm tra ngày lắp đặt và lịch bảo trì gần nhất.

## Bảng thông số phần cứng

| Tên thiết bị | Đơn giá (VND) | Loại storage |
|---|---:|---|
| Cảm biến nhiệt độ | 850.000 | Flash |
| Cảm biến độ ẩm đất | 1.250.000 | Flash |
| Modem LoRa | 2.400.000 | eMMC |
| Gateway điều khiển | 6.800.000 | SSD |
| Camera giám sát | 4.500.000 | MicroSD |

## Phân tích hệ thống

### Mô hình IPO cho chức năng lọc log

| Thành phần | Nội dung |
|---|---|
| Input | Tệp `data\log-he-thong.log`; từ khóa lọc `ERROR` và `CRITICAL`; thời điểm chạy script. |
| Process | `Get-Content` đọc log; Pipeline chuyển dữ liệu sang `Select-String`; các dòng khớp được nối vào báo cáo bằng `>>`; `Measure-Object` đếm số sự cố. |
| Output | Tệp `backup\bao-cao-su-co.txt` có tiêu đề, ngày giờ tạo, danh sách sự cố và tổng số sự cố. |

### Phân loại DIKW

| Tầng | Phát biểu | Giải thích |
|---|---|---|
| Data | (b) `2026-10-12 08:15:01 [ERROR] sensor-03 Connection TIMEOUT after 30s` | Một bản ghi thô chưa được tổng hợp. |
| Information | (c) Hôm nay hệ thống ghi nhận 8 sự cố, trong đó 4 sự cố đến từ trạm `sensor-03`. | Dữ liệu đã được lọc và tổng hợp thành thông tin có ý nghĩa. |
| Knowledge | (d) Trạm `sensor-03` hay mất kết nối vào buổi chiều do sóng yếu, nên cần lắp thêm anten. | Thông tin được phân tích để tìm mẫu, nguyên nhân và biện pháp phù hợp. |
| Wisdom | (a) Quyết định thay modem trạm `sensor-03` trước thứ Sáu. | Kiến thức được dùng để đưa ra quyết định hành động cụ thể. |

## Bẫy phần cứng

Tốc độ mạng là `100 Mbps`, còn kích thước tệp là `500 MB`.

```text
100 Mbps ÷ 8 = 12,5 MB/s
500 MB ÷ 12,5 MB/s = 40 giây
```

Trong điều kiện lý tưởng, tải tệp log 500 MB qua mạng 100 Mbps mất **40 giây**. Thực tế có thể lâu hơn do overhead giao thức và chất lượng đường truyền.

## Đối soát Excel

Trong sheet `trang-thai-tram`:

- Cột `ma_linh_kien_sach` dùng công thức `=TRIM(B2)` rồi sao chép xuống các dòng còn lại.
- Cột `ten_thiet_bi` dùng công thức `=VLOOKUP(E2,'danh-muc-linh-kien'!$A$2:$D$6,2,FALSE)` rồi sao chép xuống.
- Hai vùng dữ liệu đã bật AutoFilter, không có hàng trống và không dùng Merge Cell.
