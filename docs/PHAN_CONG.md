# Phân công Lab 3: TeamUp EXE

> Sửa lần 2: 05/11/2026, theo `PROPOSAL.md` bản mới. Phạm vi là 3 flow A/B/C, gồm 25 màn của Lab 2 (`docs/prm323-lab2-group6/ux/user-flow.md`). Các luồng D/E/F cũ chỉ làm khi giảng viên đồng ý (PROPOSAL mục 9).

## 1. Bảng phân công

Màn được chia theo flow. Mỗi người sở hữu màn của mình từ UI đến ViewModel, Service, dữ liệu Firestore, analytics, ARTEMIS và phần báo cáo/slide tương ứng.

| # | Thành viên | Màn sở hữu | Dịch vụ Firebase phụ trách | Việc chung |
|---|---|---|---|---|
| **1** | `Ken` | **Khung + đăng nhập**: S1, S19 (Google Sign-In), S6 Profile (phần hồ sơ, Sign out) | **Authentication**; `firebase/firestore.rules` (gộp và review rule của mọi người) | Cấu trúc MVVM + Riverpod, `go_router` 3 tab, `lib/theme/` (Bảng 1 handoff), `lib/widgets/` (Bảng 2: button, card, chip, ô ngành, `StatusView`, dialog), `flutterfire configure`, `docs/architecture.md`, `docs/data-model.md` (chủ trì) |
| **2** | `Dan` | **Flow A**: S2, S22, S23, S3, S4, S7, S8, S18 | **Remote Config** (`ai_matching_enabled`, `max_proposals_shown`), **Cloud Messaging** | `ClassService` (import xlsx/csv), `MatchingService` (ghép theo ngành, R1-R3), `NotificationService` và trung tâm thông báo, quyền Android 13+, payload `route` mở đúng màn |
| **3** | `Cuong` | **Flow B**: S9, S10, S11, S12, S13, S14, S24, S25 | **Crashlytics** (non-fatal, crash thử, user ID, khóa `role` / `class_id`), **Cloud Storage** (`reports/{uid}`, `storage.rules`) | `ProposalService` (duyệt, Undo, quy tắc 5-6), `ReportService` (PDF danh sách nhóm đã duyệt), mục **Firebase demo** ở S6 (thông báo, xuất PDF, giá trị Remote Config, nút crash) |
| **4** | `Khang` | **Flow C**: S5, S15, S16, S21, S20, S17 | **Analytics** (`docs/analytics-plan.md`, DebugView) | **QA lead**: `docs/test-plan.md`, `e2e_test/` (`conftest.py`, `pyproject.toml`), điều phối ARTEMIS và phiên khám phá; `docs/code-review.md`; tổng hợp báo cáo |

**Lý do chia như vậy**
- Mỗi người phụ trách một khối màn liền mạch và ít nhất một dịch vụ Firebase. Như vậy ai cũng có phần để trình bày ở slide "một slide cho mỗi dịch vụ".
- Khang có ít màn nhất (6) vì còn làm QA lead. Ken có ít màn (3) nhưng làm khung dự án và component dùng chung, là phần mọi người phụ thuộc vào.
- Nhiều màn thực chất là **trạng thái của cùng một màn**: S19/S1, S13/S11, S25/S10, S21/S16, S20/S10. Viết thành một widget nhận nhiều state, không tạo màn riêng.

**Sản phẩm dùng chung có người phụ trách**

| Sản phẩm | Người chính | Mọi người đóng góp |
|---|---|---|
| `docs/design-traceability.md` | Khang (khung bảng) | Mỗi người điền dòng của màn mình, viết **trước khi code** |
| `docs/architecture.md`, `docs/data-model.md` | Ken | Mỗi người thêm ViewModel/Service của mình vào bảng |
| `docs/analytics-plan.md` | Khang | Mỗi người đề xuất sự kiện của flow mình ở tuần 0 |
| `firebase/remote-config-defaults.json` | Dan | — |
| `firebase/storage.rules` | Cuong | — |
| `docs/test-plan.md`, `e2e_test/` | Khang | Mỗi người viết ≥ 3 ca cho màn của mình |
| `docs/code-review.md` | Khang | Chủ PR được review sửa và commit |
| `README.md` (phiên bản ghim, commit ARTEMIS, công cụ AI, link video, bản đồ sản phẩm) | Ken | Mỗi người ghi công cụ AI mình đã dùng |
| `evidence/` (ảnh Console, DebugView, Crashlytics, trace ARTEMIS) | Người phụ trách từng dịch vụ | — |
| Báo cáo, slide, video | Khang tổng hợp; video do Dan dựng | Mỗi người: ~2 trang báo cáo, 3 slide, quay phần của mình |

## 2. Quy tắc chung

- **Thiết kế:** bám Figma Lab 2. Chỗ nào khác (ví dụ S1/S19 đổi sang Google Sign-In, mục demo ở S6, trạng thái lỗi ở S22) thì ghi vào `design-traceability.md` kèm lý do **và** cập nhật Figma trong cùng tuần.
- **Kiến trúc:**
  - View không gọi Firebase SDK. Logic lọc, xếp hạng, kiểm tra không viết trong `build()`.
  - Mỗi ViewModel có state model rõ (loading / data / empty / error). Mỗi Service có interface và bản fake.
  - Không hard-code màu, cỡ chữ, padding. Mọi giá trị lấy từ `lib/theme/`.
- **Truy cập:** vùng chạm ≥ 48 dp, chữ ≥ 14 sp, không truyền thông tin chỉ bằng màu, kiểm ở 360 và 412 dp. Thêm `Semantics` cho nút và hàng danh sách để ARTEMIS đọc được.
- **Dữ liệu:** bản nộp không có dữ liệu cứng. Bản fake chỉ dùng cho test.
- **Git:**
  - Mỗi người làm trên nhánh `feature/<flow>`, mở PR, cần 1 người khác review rồi mới merge. Bật branch protection cho `main`.
  - Merge vào `main` ít nhất mỗi tuần một lần, không dồn đến tuần tích hợp.
  - Commit đều đặn: đề Lab 3 và Final đều kiểm lịch sử Git của từng thành viên.
- **Bí mật:** không commit key ARTEMIS, service account, keystore. Được commit `google-services.json`.
- **Buổi kiểm tra 5 phút (cá nhân):** **mỗi người** phải tự làm được 4 việc sau:
  - chạy 1 ca ARTEMIS;
  - đổi 1 giá trị Remote Config trực tiếp;
  - giải thích 1 ViewModel của mình;
  - giải thích 1 quyết định code review.

  Ngoài ra, mỗi người phải giải thích được nguyên lý dịch vụ mình phụ trách. Ví dụ với FCM: token là gì, ai cấp, client có lưu không, gửi bằng cách nào.

## 3. Phụ thuộc giữa các phần

| Phần cần | Lấy từ | Khi chưa có thì dùng |
|---|---|---|
| Theme, widget dùng chung, router, đăng nhập | Ken | Phải xong cuối tuần 0 |
| Lớp, sinh viên, nhóm trong Firestore | Dan (import S22/S23) | Script seed Firestore từ `class_A.xlsx` mẫu (Dan làm ở tuần 0) |
| Đề xuất ghép nhóm (S9) | Dan (`MatchingService`) | `FakeMatchingService` trả 3 đề xuất mẫu như Figma |
| Duyệt đề xuất, S12/S14 (Flow C dùng lại) | Cuong | Gọi interface `ProposalService`; Khang dùng lại widget S10 cho S20 |
| Thông báo nội bộ | Dan (`NotificationService`) | Gọi interface, triển khai sau |
| Sự kiện Analytics | Khang (`AnalyticsService` + plan) | Gọi interface ngay khi code màn |
| Crashlytics | Cuong (`CrashService`) | Gọi interface ở đường lỗi |

## 4. Lịch làm việc

Lịch theo thứ tự giai đoạn của đề Lab 3: Plan → Architect → Integrate → Instrument → Test → Review → Report. Git history phải thể hiện đúng thứ tự này. Tuần 0 bắt đầu khi giảng viên xác nhận phạm vi.

| Giai đoạn | Việc | Người |
|---|---|---|
| **Tuần 0: Plan + Architect** | Hỏi giảng viên các câu ở mục 11 `PROPOSAL.md` | Khang |
| | Tạo dự án Firebase, đăng ký app Android, **thêm SHA-1 debug của cả 4 máy**, mời cả nhóm vào dự án | Ken |
| | Nâng gói Blaze (Cuong gắn thẻ), đặt budget alert 1 USD, tạo bucket Storage ở `us-central1` | Cuong + Ken |
| | `design-traceability.md` (25 màn → route, widget, nguồn dữ liệu) và `analytics-plan.md` | Cả 4, Khang gộp |
| | `architecture.md`, `data-model.md`, khung MVVM, theme, widget dùng chung, router, Google Sign-In | Ken (cả nhóm review) |
| | Seed dữ liệu lớp mẫu lên Firestore | Dan |
| | Thử nhanh FCM trên máy thật và Crashlytics lên Console (để chắc cấu hình đúng) | Dan, Cuong |
| **Tuần 1-2: Integrate** | Code màn của mình trên fake, rồi nối Firestore; đủ 4 trạng thái; unit test ViewModel | Cả 4 song song |
| | Xuất PDF + upload, `storage.rules` | Cuong |
| | Gắn sự kiện Analytics ngay khi code màn | Cả 4 |
| **Tuần 3: Instrument** | FCM 3 trạng thái + chạm mở đúng màn; Remote Config đổi hành vi thấy được; Crashlytics non-fatal + crash thử; DebugView đủ sự kiện; mục demo S6 | Dan, Cuong, Khang |
| | Rules Firestore cho mọi collection, thử truy cập trái phép | Ken |
| | Cập nhật Figma theo các chỗ khác thiết kế đã ghi | Mỗi người, màn của mình |
| **Tuần 4: Test + Review** | `test-plan.md`, ≥ 10 ca ARTEMIS × 3 lần, có ca lỗi và ca tương tác Android gốc, phiên khám phá 15-30 phút | Khang điều phối, cả 4 chạy |
| | AI code review 1 PR: ≥ 5 phát hiện, ≥ 3 commit sửa | Khang điều phối, chủ PR sửa |
| **Tuần 5: Report** | `evidence/`, README, báo cáo 8-12 trang, slide 12-15 trang, video 5-10 phút trên máy thật | Cả 4, Khang tổng hợp |
| | Mỗi người tập buổi kiểm tra 5 phút | Cả 4 |

## 5. Checklist bàn giao theo người

**Ken**
- [ ] Google Sign-In, hủy đăng nhập, mất mạng (S19), đăng xuất xóa state, chặn route khi chưa đăng nhập; ảnh Console → Users
- [ ] Theme từ token, widget dùng chung có đủ biến thể và trạng thái; không có giá trị hard-code ở màn
- [ ] `architecture.md`: cây thư mục, sơ đồ lớp (Mermaid), 1 sequence diagram cho cả flow, bảng ViewModel → Service
- [ ] `firestore.rules` không có `if true`; mentor chỉ đọc/ghi lớp của mình
- [ ] README đầy đủ theo mục 9 đề Lab 3

**Dan**
- [ ] Import xlsx/csv (S22 có trạng thái lỗi), kết quả lọc (S23); S2-S4, S7 đủ 4 trạng thái
- [ ] `MatchingService` đúng R1-R3, có unit test; S8 timeout 30 giây → S18, Try again chạy lại
- [ ] Remote Config: 2 tham số đổi hành vi thấy được; ảnh trước/sau; mất mạng dùng mặc định; `remote-config-defaults.json`
- [ ] FCM: quyền Android 13+, từ chối quyền, 3 trạng thái app, chạm mở đúng màn, trung tâm thông báo; ghi thiết bị và token

**Cuong**
- [ ] Gói Blaze: gắn thẻ, budget alert 1 USD, bucket `us-central1`; gỡ thẻ hoặc hạ về Spark sau khi chấm
- [ ] S9-S14, S24, S25: thêm/bớt thành viên, chặn > 6 (S13) và < 5 (S25), Approve + Undo 5 giây, badge tab Proposals
- [ ] PDF danh sách nhóm đã duyệt, upload `reports/{uid}/…` có tiến độ và URL; `storage.rules` chỉ chủ sở hữu; thử truy cập trái phép
- [ ] Crashlytics: non-fatal từ đường lỗi thật (import, AI timeout), crash thử ở S6, user ID, khóa `role`, `class_id`; ảnh dashboard
- [ ] Mục Firebase demo ở S6

**Khang**
- [ ] S5, S15, S16, S21, S20, S17: ghép tay, khóa "In a team", tìm không ra, Discard
- [ ] `analytics-plan.md` ≥ 7 sự kiện kèm câu hỏi sản phẩm, gắn với bước flow; ảnh DebugView từng sự kiện; `setUserId`
- [ ] `test-plan.md`, `e2e_test/`, bảng kết quả (ca, số lần chạy, tỉ lệ đạt, thời gian), giải thích ca flaky, báo cáo phiên khám phá; ≥ 1 ca kiểm sự kiện analytics
- [ ] `code-review.md` (≥ 5 phát hiện, quyết định có lý do, ≥ 3 commit sửa, khai báo công cụ AI); `design-traceability.md`; báo cáo, slide
