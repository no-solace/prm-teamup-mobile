# Design traceability: Lab 2 → Flutter

> Nguồn thiết kế: [docs/prm323-lab2-group6/](prm323-lab2-group6/) (`ux/user-flow.md`, `design/screen-spec.md`, `handoff/flutter-handoff.md`).
> Cập nhật: 12/11/2026. Cột **Trạng thái** ghi đúng những gì đã kiểm chứng:
> - **Test**: có widget/ViewModel test tự động trong `test/` (`flutter test`: 153 test pass).
> - **Máy thật**: đã chạy trên thiết bị Android với Firebase thật. *Mục này chưa được đánh dấu cho màn nào; xem [evidence/README.md](../evidence/README.md).*

## 1. Màn hình → route → widget → nguồn dữ liệu

Route là hằng số trong [`lib/router/routes.dart`](../lib/router/routes.dart). Nguồn dữ liệu đi qua service, không qua widget (xem [architecture.md](architecture.md)).

| Màn | Route | Widget (`lib/screens/…`) | ViewModel | Nguồn dữ liệu | Trạng thái |
|---|---|---|---|---|---|
| S1 Sign in | `/sign-in` | `sign_in/sign_in_screen.dart` | `SignInViewModel` | Firebase Auth (Google, email, SĐT); `users/{uid}` | Test |
| S19 Sign in – error | `/sign-in` (trạng thái lỗi) | cùng widget | cùng ViewModel | `AuthValidation` (email sai) và `AuthErrorMapper` | Test |
| S2 My classes | `/classes` | `my_classes/my_classes_screen.dart` | `MyClassesViewModel` | Firestore `classes` (`mentorUid == uid`) | Test |
| S22 Import class list | `/classes/import` | `flow_a/import_class_screen.dart` | `ImportClassViewModel` | File CSV do mentor chọn → `CsvClassImporter` | Test |
| S23 Import result | `/classes/import/result` | `flow_a/import_result_screen.dart` | `ClassDetailViewModel` | Firestore `classes/{id}` | Test |
| S3 Class detail | `/classes/:classId` | `flow_a/class_detail_screen.dart` | `ClassDetailViewModel` | Firestore `classes/{id}` | Test |
| S4 No team | `/classes/:classId/no-team` | `flow_a/no_team_screen.dart` | `NoTeamViewModel` | `classes/{id}/students` (`teamId == null`) | Test |
| S5 Need members | `/classes/:classId/need-members` | `flow_c/need_members_screen.dart` | provider trong `proposal_view_model.dart` | `classes/{id}/teams` | Test |
| S7 Student detail | `/classes/:classId/students/:studentId` | `flow_a/student_detail_screen.dart` | `StudentDetailViewModel` | `classes/{id}/students/{mssv}` | Test |
| S8 AI matching | `/classes/:classId/matching` | `flow_a/matching_screen.dart` | `MatchingViewModel` | `RuleBasedMatchingService` → `classes/{id}/proposals` | Test |
| S18 Offline | cùng route S8 (trạng thái lỗi) | cùng widget | cùng ViewModel | `NetworkError` / `TimeoutAppError` (30 giây) | Test |
| S15 No match | `/classes/:classId/no-match` | `flow_c/no_match_screen.dart` | `MatchingViewModel` (`Empty`) | kết quả matching rỗng | Test |
| S16 Add student | `/classes/:classId/add-student` | `flow_c/add_student_screen.dart` | `ProposalActionViewModel` | `students` + `teams` | Test |
| S21 Add student – no results | cùng route S16 (trạng thái rỗng) | cùng widget | cùng ViewModel | lọc cục bộ | Test |
| S9 Proposals | `/proposals` | `flow_b/proposals_screen.dart` | `pendingProposalsProvider` | collection group `proposals` (`status == pending`) | Test |
| S14 All matched | `/proposals` (trạng thái rỗng + snackbar Undo) | cùng widget | cùng provider | như S9 | Test |
| S10 Proposal detail | `/proposals/:proposalId` | `flow_b/proposal_detail_screen.dart` | `proposalDetailProvider`, `ProposalActionViewModel` | `classes/{id}/proposals/{id}` | Test |
| S20 Hand-built | cùng route S10 (`source: manual`) | cùng widget | cùng ViewModel | như S10 | Test |
| S25 Approve blocked | cùng route S10 (nhóm < 5 người) | cùng widget | cùng ViewModel | như S10 | Test |
| S11 Add member | `/proposals/:proposalId/add-member` | `flow_b/add_member_screen.dart` | `ProposalActionViewModel` | `students` | Test |
| S13 Add member – error | cùng route S11 (vượt 6 người) | cùng widget | cùng ViewModel | quy tắc `TeamRules.maxMembers` | Test |
| S12 Approve dialog | dialog trên S10 | `widgets/confirm_dialog.dart` | `ProposalActionViewModel.approve` | giao dịch Firestore (roster + proposal) | Test |
| S17 Discard dialog | dialog trên S10 | `widgets/confirm_dialog.dart` | `ProposalActionViewModel.discard` | `proposals/{id}.status = discarded` | Test |
| S24 Remove member dialog | dialog trên S10 | `widgets/confirm_dialog.dart` | `ProposalActionViewModel.updateMembers` | `proposals/{id}` | Test |
| S6 Profile | `/profile` | `profile/profile_screen.dart` | `ProfileViewModel` | Auth, `users/{uid}`, Remote Config, Storage, FCM | Test |

## 2. Flow → màn

| Flow | Đường chính | Đường lỗi/phụ | Màn |
|---|---|---|---|
| A: duyệt gợi ý AI | S2 → S3 → S8 → S9 → S10 → S12 → S14 | S19 (email sai), S18 (mất mạng), nhánh import S22 → S23 | S1, S2, S3, S4, S7, S8, S9, S10, S12, S14, S18, S19, S22, S23 |
| B: thêm/bỏ thành viên | S9 → S10 → S11 → S10 | S13 (vượt 6), S24 → S25 (dưới 5) | S7, S9, S10, S11, S12, S13, S14, S24, S25 |
| C: ghép tay khi AI không ghép được | S3 → S5 → S16 → S20 | S15, S21, S17 | S3, S5, S8, S15, S16, S17, S20, S21 |

## 3. Component Lab 2 → widget Flutter

Token nằm ở [`lib/theme/`](../lib/theme/): `app_colors.dart` (`ColorScheme` và hằng màu), `app_typography.dart` (`TextTheme`, font Be Vietnam Pro), `app_spacing.dart` (spacing, radius), `app_theme.dart` (`ThemeData`).

| Component Figma | Widget (`lib/widgets/`) | Biến thể / trạng thái |
|---|---|---|
| Button primary / tonal / text / destructive | `app_button.dart` (`AppButton`, `AppButtonVariant`) | `loading`, vô hiệu khi `onPressed == null` |
| Text field | `app_text_field.dart` | `errorText`, `hint` |
| Card | `app_card.dart` | |
| Navigation bar, App bar | `screens/app_shell.dart` (`NavigationBar` 3 tab) | |
| Dialog confirm / destructive | `confirm_dialog.dart` | destructive |
| Loading, Empty, Error | `view_state_builder.dart` + `status_view.dart` | 4 nhánh `Loading/Empty/Data/Failure` |
| Error banner | `error_banner.dart` | |
| Chip lọc ngành | `major_filter_chips.dart` | chọn/bỏ |
| Fit chip (strong/good) | `fit_chip.dart` | |
| Ô ngành (major slot) | `major_slot.dart` | đầy, trống nét đứt |
| Hàng sinh viên (checkbox row) | `student_row.dart` | đã có nhóm (khóa) |
| Thống kê 3 số | `stat_triple.dart` | |
| Chọn sinh viên cho đề xuất | `proposal_student_picker.dart` | đếm `x of 6` |

## 4. Thay đổi so với thiết kế (có lý do)

Mọi khác biệt dưới đây là cố ý. **Chưa cập nhật Figma cho các mục này** (việc còn lại, xem mục 5).

| # | Màn | Thiết kế Lab 2 | Bản app | Lý do |
|---|---|---|---|---|
| D1 | S1, S19 | Chỉ nhập email, không có bước mã | Google Sign-In là phương thức chính; thêm email + mật khẩu và SĐT + OTP. S19 là trạng thái lỗi của form email | Đề Lab 3 bắt buộc Google Sign-In; cần tài khoản thật để áp rules theo `uid` |
| D2 | S22 | File mẫu `class_A.xlsx` | Chỉ nhận `.csv` (5 cột: MSSV, họ tên, lớp, nhóm, ngành) | Cắt phạm vi theo thứ tự ưu tiên trong `PHAN_CONG.md` mục 5 (7 ngày làm Lab 3); app báo rõ khi chọn file không phải CSV |
| D3 | S6 | Thông tin mentor, Sign out | Thêm mục Notifications (inbox), Language, vùng **Firebase demo** (Remote Config, xuất PDF + upload, Test crash) | Đề Lab 3 yêu cầu vùng demo Firebase ở Profile |
| D4 | thêm mới | Không có | `/profile/notifications` (trung tâm thông báo FCM) | Đề yêu cầu giữ danh sách thông báo nhận được trong app |
| D5 | S2, S22 | Không vẽ trạng thái rỗng và lỗi | Thêm empty (chưa có lớp) và error (import lỗi, thử lại) | Đề yêu cầu loading/empty/error trên mọi màn tải dữ liệu |
| D6 | S3, S4, S5 | Nút "Match with AI" luôn hiện | Ẩn khi Remote Config `ai_matching_enabled = false` | Remote Config phải đổi hành vi nhìn thấy được |
| D7 | S9 | 3 thẻ đề xuất | Số thẻ theo Remote Config `max_proposals_shown` (1 đến 20, mặc định 3) | Như trên |
| D8 | S8 → S18 | Offline là lỗi mạng | Thêm giới hạn 30 giây; quá hạn cũng hiện S18 | Tránh spinner vô hạn (rubric "Spinner forever") |
| D9 | S10 | Hai trạng thái pending/approved | Thêm trạng thái dữ liệu `superseded` (không hiện ra UI) | Matching chạy lại thay bản nháp AI cũ nguyên tử (xem `docs/matching-service.md`) |

## 5. Việc còn lại

- [ ] Cập nhật Figma cho D1 đến D9 (đề: "unrecorded difference … graded as a defect").
- [ ] Chạy từng màn trên thiết bị thật rồi đổi cột Trạng thái thành **Máy thật**; lưu ảnh vào `evidence/`.
- [ ] Kiểm tra bố cục ở 360 dp và 412 dp, vùng chạm ≥ 48 dp, chữ ≥ 14 sp (có widget test cho S22).
