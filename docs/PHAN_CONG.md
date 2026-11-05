# Phân công Lab 3: TeamUp EXE

> Sửa lần 3: 05/11/2026. **Còn 7 ngày.** Phạm vi: 3 flow A/B/C, 25 màn của Lab 2 (`docs/prm323-lab2-group6/ux/user-flow.md`). D/E/F **không làm** ở Lab 3.

## 0. Nguyên tắc khi chỉ có 7 ngày

1. **Ưu tiên theo điểm.** Slide + video là 2 điểm, ARTEMIS là 1.5 điểm: hai phần này cần app chạy được từ **cuối ngày 4**. Vì vậy ngày 4 là hạn chót cho tính năng.
2. **Làm song song từ ngày 1.** Không ai chờ ai. Trong lúc Ken dựng khung, những người khác viết model, interface Service và bản fake.
3. **Merge vào `main` mỗi tối.** Không để tích hợp dồn vào cuối.
4. **Mỗi màn chỉ làm đúng nội dung Figma.** Không thêm gì ngoài thiết kế. Thứ tự cắt khi trễ ghi ở mục 5.

## 1. Bảng phân công

| # | Thành viên | Màn sở hữu | Dịch vụ Firebase | Việc chung |
|---|---|---|---|---|
| **1** | `Ken` | **Khung + đăng nhập**: S1, S19 (Google Sign-In), S6 (hồ sơ, Sign out) | **Authentication**; `firebase/firestore.rules` | MVVM + Riverpod, `go_router` 3 tab, `lib/theme/`, `lib/widgets/` dùng chung, `flutterfire configure`, `docs/architecture.md`, `docs/data-model.md`, README |
| **2** | `Dan` | **Flow A**: S2, S22, S23, S3, S4, S7, S8, S18 | **Remote Config**, **Cloud Messaging** | `ClassService` (import **CSV**), `MatchingService` (ghép theo ngành), `NotificationService`, trung tâm thông báo, script seed dữ liệu; dựng video |
| **3** | `Cuong` | **Flow B**: S9, S10, S11, S12, S13, S14, S24, S25 | **Crashlytics**, **Cloud Storage** (gói Blaze, `storage.rules`) | `ProposalService`, `ReportService` (PDF), mục **Firebase demo** ở S6 |
| **4** | `Khang` | **Flow C**: S5, S15, S16, S21, S20, S17 | **Analytics** | **QA lead**: `docs/test-plan.md`, `e2e_test/`, điều phối ARTEMIS, `docs/code-review.md`, `docs/design-traceability.md` (khung), tổng hợp báo cáo và slide |

Nhiều màn là **trạng thái của cùng một màn**: S19/S1, S13/S11, S25/S10, S21/S16, S20/S10. Mỗi nhóm như vậy viết thành **một widget có nhiều state**, không làm thành màn riêng.

**Sản phẩm dùng chung**

| Sản phẩm | Người chính | Ngày xong |
|---|---|---|
| `docs/design-traceability.md` | Khang (khung); mỗi người điền màn mình | Ngày 1 |
| `docs/analytics-plan.md` | Khang; mỗi người góp sự kiện của flow mình | Ngày 1 |
| `docs/architecture.md`, `docs/data-model.md` | Ken; mỗi người thêm ViewModel/Service của mình | Ngày 1 (bản đầu), ngày 6 (bản cuối) |
| `firebase/remote-config-defaults.json` | Dan | Ngày 3 |
| `firebase/storage.rules` | Cuong | Ngày 3 |
| `docs/test-plan.md`, `e2e_test/` | Khang; mỗi người viết ≥ 3 ca cho màn mình | Ngày 3 (plan), ngày 5 (chạy) |
| `docs/code-review.md` | Khang; chủ PR sửa | Ngày 5 |
| `evidence/` | Người phụ trách từng dịch vụ | Ngày 5 |
| `README.md` | Ken | Ngày 6 |
| Báo cáo, slide | Khang tổng hợp; mỗi người ~2 trang báo cáo, 3 slide | Ngày 6 |
| Video | Dan dựng; mỗi người quay phần mình | Ngày 7 |

## 2. Quy tắc chung

- **Thiết kế:** bám Figma Lab 2. Chỗ nào khác thì ghi vào `design-traceability.md` kèm lý do, rồi cập nhật Figma ở ngày 5. Các chỗ khác đã biết: S1/S19 đổi sang Google Sign-In, mục demo ở S6, trạng thái lỗi ở S22, empty ở S2.
- **Kiến trúc:**
  - View không gọi Firebase SDK. Logic không viết trong `build()`.
  - Mỗi ViewModel có state model (loading / data / empty / error). Mỗi Service có interface và bản fake.
  - Không hard-code màu, cỡ chữ, padding.
- **Truy cập:** vùng chạm ≥ 48 dp, chữ ≥ 14 sp, không truyền thông tin chỉ bằng màu. Thêm `Semantics` cho nút và hàng danh sách ngay khi code, để ngày 5 chạy ARTEMIS ổn định.
- **Git:**
  - Mỗi người làm trên nhánh `feature/<flow>`. PR cần 1 người review, nhưng **review trong ngày**, không để PR nằm chờ.
  - Merge vào `main` mỗi tối. Commit nhỏ và đều mỗi ngày: đề chấm lịch sử Git của từng người.
- **Bí mật:** không commit key ARTEMIS, service account, keystore. Được commit `google-services.json`.
- **Buổi kiểm tra 5 phút (cá nhân):** mỗi người tự chạy được 1 ca ARTEMIS, đổi Remote Config trực tiếp, giải thích 1 ViewModel và 1 quyết định code review, và nguyên lý dịch vụ mình phụ trách.

## 3. Phụ thuộc

| Phần cần | Lấy từ | Khi chưa có thì dùng |
|---|---|---|
| Theme, widget dùng chung, router | Ken | **Hạn trưa ngày 2**; trước đó viết model, Service và fake |
| Dữ liệu lớp, SV, nhóm trên Firestore | Dan (script seed) | **Hạn tối ngày 1**; trước đó dùng fake |
| Đề xuất ghép nhóm (S9) | Dan (`MatchingService`) | `FakeMatchingService` trả 3 đề xuất như Figma |
| Widget S10, dialog S12, S14 | Cuong | Khang dùng lại cho S20, S17; chốt interface ngày 1 |
| `NotificationService`, `AnalyticsService`, `CrashService` | Dan, Khang, Cuong | Interface có từ ngày 1; ai cũng gọi được ngay |

## 4. Lịch 7 ngày

| Ngày | Ken | Dan | Cuong | Khang |
|---|---|---|---|---|
| **1** | Tạo dự án Firebase, mời cả nhóm, gom **SHA-1 của 4 máy**; dựng khung MVVM, router, theme | Model `Class/Student/Team`; script seed Firestore từ file mẫu; interface `ClassService`, `MatchingService` + fake | Gắn thẻ Blaze, **budget alert 1 USD**, bucket `us-central1`; model `Proposal`; interface `ProposalService`, `ReportService`, `CrashService`, `StorageService` + fake | Khung `design-traceability.md` và `analytics-plan.md`; interface `AnalyticsService`; tạo môi trường ARTEMIS (Python, uv, ADB, API key) |
| | **Cả 4:** điền traceability cho màn mình; chốt `data-model.md` (họp 30 phút) | | | |
| **2** | Widget dùng chung (**trưa**); Google Sign-In S1/S19, chặn route | S2, S3, S4, S7 trên fake | S9, S10 (kèm trạng thái S25) trên fake | S5, S16 (kèm S21) trên fake; ARTEMIS chạy thử 1 ca sign-in |
| **3** | S6 hồ sơ + Sign out; `firestore.rules`; review PR | S22/S23 import CSV; S8/S18; `MatchingService` thật + unit test; Remote Config | S11/S13, S12, S14 (Undo), S24; Crashlytics init + crash thử; `storage.rules` | S15, S20, S17; gắn Analytics vào mọi flow; viết `test-plan.md` (≥ 10 ca) |
| **4** | Nối Firestore toàn app; sửa lỗi tích hợp; **hạn chót tính năng 20h** | FCM: quyền Android 13+, 3 trạng thái, chạm mở đúng màn, trung tâm thông báo | PDF + upload có tiến độ và URL; non-fatal ở S22 / S8; mục demo S6 | Viết ca ARTEMIS trong `e2e_test/`; **mở PR cho AI code review** |
| **5** | Ảnh Console Auth; sửa lỗi từ ARTEMIS | Ảnh Remote Config trước/sau, FCM 3 trạng thái | Ảnh Crashlytics (non-fatal, crash, khóa), Storage | **Chạy ARTEMIS ≥ 10 ca × 3 lần**; ảnh DebugView; ghi `code-review.md` |
| | **Cả 4:** sửa ≥ 3 phát hiện code review (mỗi cái 1 commit); cập nhật Figma các chỗ khác thiết kế | | | |
| **6** | `architecture.md` bản cuối (sơ đồ, sequence, bảng ViewModel); README | Viết báo cáo và slide phần mình | Viết báo cáo và slide phần mình | Phiên ARTEMIS khám phá 15-30 phút; gộp báo cáo (8-12 trang) và slide (12-15) |
| **7** | Kiểm repo, báo cáo, slide, video mở được trong cửa sổ ẩn danh | **Quay và dựng video** 5-10 phút trên máy thật | Quay phần mình; tập buổi kiểm tra 5 phút | Kiểm checklist nộp bài; tập buổi kiểm tra 5 phút |

**Lưu ý:** Crashlytics thường cần vài phút mới hiện trên Console, và báo cáo crash chỉ được gửi khi **mở lại app**. Vì vậy Cuong làm crash thử từ ngày 3, đừng để đến ngày quay video.

## 5. Nếu trễ: cắt theo thứ tự này

Phần nào đề bắt buộc thì giữ. Chỉ cắt phần làm cho đẹp hơn hoặc chắc ăn hơn:

1. Unit test ngoài `MatchingService` → chỉ giữ test cho `MatchingService` (R1-R3).
2. Import `.xlsx` → chỉ đọc `.csv`. Ghi lại chỗ khác thiết kế: Figma hiện `class_A.xlsx`.
3. Skeleton loading → dùng `CircularProgressIndicator`. Vẫn phải có trạng thái loading.
4. Kéo xuống để làm mới ở S2 → bỏ.
5. Cập nhật Figma → chỉ sửa S1/S19 và S6, các chỗ khác ghi trong traceability.

**Không được cắt:** bất kỳ màn nào trong 25 màn, đường lỗi của 3 flow, 6 dịch vụ cùng ca lỗi của chúng, ≥ 10 ca ARTEMIS × 3 lần, ≥ 5 phát hiện / ≥ 3 commit sửa, slide và video.

## 6. Checklist bàn giao

**Ken**
- [ ] Google Sign-In, hủy, mất mạng (S19), đăng xuất xóa state, chặn route; ảnh Console → Users
- [ ] Theme và widget dùng chung; không có giá trị hard-code ở màn
- [ ] `architecture.md` (cây thư mục, sơ đồ lớp, sequence diagram, bảng ViewModel → Service), `data-model.md`
- [ ] `firestore.rules` không có `if true`; README đầy đủ

**Dan**
- [ ] S2, S22, S23, S3, S4, S7, S8, S18 đủ trạng thái; import có trạng thái lỗi
- [ ] `MatchingService` đúng quy tắc 5-6 người và ngành, có unit test; S8 timeout → S18
- [ ] Remote Config 2 tham số đổi hành vi thấy được; ảnh trước/sau; `remote-config-defaults.json`
- [ ] FCM: quyền, từ chối quyền, 3 trạng thái, chạm mở đúng màn, trung tâm thông báo; video

**Cuong**
- [ ] Gói Blaze: gắn thẻ, budget alert 1 USD, bucket `us-central1`; gỡ thẻ hoặc hạ về Spark sau khi chấm
- [ ] S9-S14, S24, S25: chặn > 6 (S13) và < 5 (S25), Approve + Undo, badge tab
- [ ] PDF lên `reports/{uid}/…` có tiến độ và URL; `storage.rules` chỉ chủ sở hữu; thử truy cập trái phép
- [ ] Crashlytics: non-fatal từ đường lỗi thật, crash thử ở S6, user ID, khóa `role`, `class_id`; mục demo S6

**Khang**
- [ ] S5, S15, S16, S21, S20, S17
- [ ] `analytics-plan.md` ≥ 7 sự kiện; ảnh DebugView từng sự kiện; `setUserId`
- [ ] `test-plan.md`, `e2e_test/`, bảng kết quả ≥ 10 ca × 3 lần, giải thích ca flaky, phiên khám phá
- [ ] `code-review.md`, `design-traceability.md`, báo cáo, slide
