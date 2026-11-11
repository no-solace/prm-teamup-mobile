# Design traceability — Lab 2 → Lab 3 app

> Traceability matrix: mỗi màn Lab 2, flow và component → route Flutter, widget
> và nguồn dữ liệu. Mọi **sai lệch** so với thiết kế đều được ghi lại kèm lý do.
> Nguồn thiết kế: `docs/prm323-lab2-group6/` (Figma Final UI, `design/screen-spec.md`,
> `handoff/flutter-handoff.md`, `ux/user-flow.md`).

**Bảng trạng thái**: `Done` = dựng đúng và đã có test · `Partial` = dựng nhưng còn
khác thiết kế (xem cột *Ghi chú / sai lệch*) · `Deviation` = cố ý khác, đã ghi lý do.

---

## 1. Ma trận màn hình (S1–S25)

| Màn | Lab 2 flow | Route Flutter | Widget / màn hiện thực | Nguồn dữ liệu | Trạng thái | Ghi chú / sai lệch |
|---|---|---|---|---|---|---|
| S1 Sign in | A | `/sign-in` | `screens/sign_in/sign_in_screen.dart` | `AuthService.signInWithGoogle()` | Done | **Sai lệch D1**: Lab 2 là email không mã; Lab 3 yêu cầu Google Sign-In → dùng Google, email/password/phone vẫn còn trong `SignInViewModel`. |
| S19 Sign in - error | A | `/sign-in` (state) | `SignInViewModel.state.error` + `AppTextField` | `AuthService` | Done | Ô viền đỏ + "Enter a valid email" khi format sai. |
| S2 My classes | A | `/classes` | `screens/my_classes/my_classes_screen.dart` | `ClassService.watchMyClasses()` (Firestore `classes`) | Done | |
| S22 Import class list | A | `/classes/import` | `screens/flow_a/import_class_screen.dart` | `ClassService.parseImportFile()` | Partial | **Sai lệch D2**: Lab 2 dùng `class_A.xlsx`; app nhận **CSV** (`.csv`) vì `csv` package không đọc XLSX. Xem §5. |
| S23 Import result | A | `/classes/import/result` | `screens/flow_a/import_result_screen.dart` | `ClassService.importClass()` → `ImportResult` | Done | 3 số + 2 hàng điều hướng + "Filtered automatically". |
| S3 Class detail | A, C | `/classes/{classId}` | `screens/flow_a/class_detail_screen.dart` | `ClassService.watchClass()` | Done | Nút "Match with AI" bị ẩn khi `ai_matching_enabled = false` (Remote Config). |
| S4 No team | A | `/classes/{classId}/no-team` | `screens/flow_a/no_team_screen.dart` | `ClassService.watchStudents()` | Done | |
| S7 Student detail | B | `/classes/{classId}/students/{studentId}` | `screens/flow_a/student_detail_screen.dart` | `ClassService.getStudent()` + `watchClass()` | Done | |
| S8 AI matching | A, C | `/classes/{classId}/matching` | `screens/flow_a/matching_screen.dart` | `MatchingViewModel` → `MatchingService.propose()` | Done | Timeout 30 s → S18. |
| S18 Offline | A | `/classes/{classId}/no-match`? không — S18 là error state của S8 | `StatusView.error` trong `matching_screen.dart` | `AppError` (NetworkError / TimeoutAppError) | Done | Nút "Try again" gọi lại `MatchingViewModel.start()`. |
| S9 Proposals | A, B | `/proposals` | `screens/flow_b/proposals_screen.dart` | `ProposalService.watchAllPending()` (Firestore `collectionGroup('proposals')`) | Done | Badge số đề xuất trên tab Proposals (`app_shell.dart`). Số thẻ bị giới hạn bởi `max_proposals_shown`. |
| S14 Proposals - All matched | A, B, C | trạng thái empty của `/proposals` | `StatusView` + snackbar "Approved" + Undo | `ProposalService.watchAllPending()` | Done | Snackbar 5 s rồi Undo (transaction `undoApprove`). |
| S10 Proposal detail | A, B, C | `/proposals/{proposalId}` | `screens/flow_b/proposal_detail_screen.dart` | `ProposalService.watchProposal(id)` | Done | Hàng ngành 48 dp (`kMajorSlotLarge`), `FitChip`, `showConfirmDialog`. |
| S20 Proposal detail - hand-built | C | `/proposals/{proposalId}` (source = manual) | cùng `proposal_detail_screen.dart` | `ProposalService.watchProposal(id)` | Done | Chip "Added by you" (`TagChip`) hiện khi `source == manual`. |
| S25 Approve blocked | B | `/proposals/{proposalId}` (state) | `ErrorBanner` trong `proposal_detail_screen.dart` | `Proposal.canApprove` | Done | Đúng chữ: "Needs at least 5 members (now 4)". Nút Approve khoá, Add member vẫn dùng được. |
| S12 Approve dialog | A, B, C | dialog trên S10 | `widgets/confirm_dialog.dart` → `showConfirmDialog(confirmLabel: 'Approve')` | — | Done | **Sai lệch D3**: nút xác nhận ghi "Approve" thay vì "Confirm" để đúng vai trò; xem §5. |
| S17 Discard dialog | C | dialog trên S10 | `showConfirmDialog(destructive: true, confirmLabel: 'Discard')` | — | Done | |
| S24 Remove member dialog | B | dialog trên S10 | `showConfirmDialog(destructive: true, confirmLabel: 'Remove')` | — | Done | "Team will have N members." |
| S11 Add member | B | `/proposals/{proposalId}/add-member` | `screens/flow_b/add_member_screen.dart` + `widgets/proposal_student_picker.dart` | `ClassService.watchStudents()` | Done | |
| S13 Add member - Error | B | state của S11 | `ErrorBanner("Max 6 members")` trong `proposal_student_picker.dart` | `TeamRules.maxMembers` | Done | Lỗi hiện **tại chỗ**, không chỉ snackbar. |
| S5 Need members | C | `/classes/{classId}/need-members` | `screens/flow_c/need_members_screen.dart` | `ProposalService.watchTeams()` | Done | `MajorSlotRow` 40 dp + dòng "Needs SE, AI, MKT to reach 5". |
| S16 Add student | C | `/classes/{classId}/add-student` | `screens/flow_c/add_student_screen.dart` | `ClassService.watchStudents()` | Done | Dòng "In a team" bị khoá. |
| S21 Add student - no results | C | state empty của S16 | `StatusView` trong `add_student_screen.dart` | `ClassService.watchStudents()` | Done | |
| S15 No match | C | `/classes/{classId}/no-match` | `screens/flow_c/no_match_screen.dart` | `MatchingViewModel` → `Empty` | Done | Nút "Add manually" + "See teams". |
| S6 Profile | (tab) | `/profile` | `screens/profile/profile_screen.dart` | `AuthService.currentUser` | Done | **Sai lệch D4**: thêm khu demo Firebase (bắt buộc theo Lab 3 §3). |
| (demo) Config & FCM | — | `/profile/notifications` | `screens/notifications/config_demo_panel.dart` | `ConfigService.watch()` + `NotificationService` | Done | Khu demo bắt buộc Lab 3: Remote Config values, FCM token, notification center. |
| (demo) Export PDF | — | `/profile` | `screens/profile/report_demo_panel.dart` | `ReportService.buildClassTeamsPdf()` + `StorageService.uploadReport()` | Done | Hiện progress **và** download URL. |

**Tổng: 25 màn Lab 2 → 25 route/state đã dựng, 4 sai lệch có ghi lý do.**

---

## 2. Ma trận 3 flow

| Flow | Bước (route) | Nhánh lỗi | Nguồn dữ liệu | Test tự động |
|---|---|---|---|---|
| **A** — Duyệt gợi ý AI cho một lớp | `/sign-in` → `/classes` → `/classes/import` → `/classes/import/result` → `/classes/{id}` → `/classes/{id}/matching` → `/proposals` → `/proposals/{id}` | S19 (email sai), S18 (mất mạng khi AI chạy) | Firestore `classes/{id}/students`, `teams`, `proposals` | `test/flow_a/flow_a_viewmodels_test.dart`, `test/demo/full_demo_smoke_test.dart` |
| **B** — Thêm thành viên vào đề xuất | `/proposals` → `/proposals/{id}` → `/proposals/{id}/add-member` → (S11) → S10 | S13 (vượt 6), S25 (dưới 5) | Firestore `proposals/{id}` + transaction approve | `test/flow_b/flow_b_viewmodels_test.dart` |
| **C** — AI không ghép được, mentor ghép tay | `/classes/{id}` → `/classes/{id}/need-members` → `/classes/{id}/add-student` → `/proposals/{id}` (manual) | S21 (không tìm ra SV), SV đã có nhóm bị khoá, S17 (discard) | Firestore `teams/{id}` + transaction `createManual` | `test/flow_c/flow_c_viewmodels_test.dart` |

---

## 3. Ma trận component (Lab 2 → `lib/widgets/`)

| Component Figma | Widget Flutter | Trạng thái (params) | Dùng ở màn |
|---|---|---|---|
| Button primary / tonal / destructive | `widgets/app_button.dart` → `AppButton` | `variant`, `icon`, `loading`, `onPressed` | S2, S3, S5, S10, S11, S22, S23 |
| Text field | `widgets/app_text_field.dart` → `AppTextField` | `errorText`, `hint`, `onChanged`, `label` | S1, S4, S11, S16 |
| Card | `widgets/app_card.dart` → `AppCard` | `onTap`, `semanticsLabel`, `padding` | S2, S5, S9, S10 |
| Navigation bar | `screens/app_shell.dart` → `NavigationBar` | 3 tab, badge Proposals | S2 / S9 / S6 |
| App bar | `MaterialApp` `AppBar` + `screens/flow_a/flow_a_layout.dart` → `FlowAScaffold` | `title`, back | mọi màn có app bar |
| Dialog confirm / destructive | `widgets/confirm_dialog.dart` → `showConfirmDialog` | `title`, `message`, `confirmLabel`, `destructive` | S12, S17, S24 |
| Loading | `CircularProgressIndicator` + `LinearProgressIndicator` | — | S3, S8, S22, S6 demo |
| Empty / Error state | `widgets/status_view.dart` → `StatusView` | `icon`, `title`, `message`, `actionLabel`, `onRetry` | S4, S9, S14, S15, S18, S21 |
| Error banner | `widgets/error_banner.dart` → `ErrorBanner` | `message` | S13, S22, S25 |
| Chip lọc ngành | `widgets/major_filter_chips.dart` → `MajorFilterChips` | `selected`, `onSelected` | S4, S11, S16 |
| Fit chip | `widgets/fit_chip.dart` → `FitChip` | `fit` (strong/good) | S9, S10 |
| Tag chip ("Added by you") | `widgets/fit_chip.dart` → `TagChip` | `label`, `icon` | S20 |
| Ô ngành (major slot) | `widgets/major_slot.dart` → `MajorSlot`, `MajorSlotRow` | `kind` (filled/proposed/open), `size` (40/48) | S5, S9, S10, S20, S25 |
| Checkbox row | `widgets/student_row.dart` → `StudentRow` | `checked`, `onChecked`, `locked` | S4, S11, S16 |
| Snackbar | `SnackBar` + `SnackBarAction` | `duration`, `action` | S14 (Approved + Undo) |
| Badge | `Badge` (NavigationBar) + `ProposalsBadge` | `count` | S9 (tab Proposals) |
| Stat triple | `widgets/stat_triple.dart` → `StatTriple` | 3 số + nhãn | S3, S23 |
| Student picker (dùng chung S11/S16) | `widgets/proposal_student_picker.dart` | `capacity`, `onLimit` | S11, S16 |

---

## 4. Token → theme

| Nhóm | Nơi lưu | Ghi chú |
|---|---|---|
| Màu (`ColorScheme`) | `lib/theme/app_colors.dart` | primary `#B23E00`, secondary `#2F2E2A`, tertiary `#1B6B3C`, error `#B3261E`… theo Bảng 1 handoff. |
| Chữ (`TextTheme`) | `lib/theme/app_typography.dart` | Be Vietnam Pro, `headlineSmall` 24/32 700, `bodyMedium` 14/20, `labelLarge` 14/20 600. |
| Spacing / radius / kích thước | `lib/theme/app_spacing.dart` | `kSpaceXs..kSpaceXl`, `kRadiusSm..kRadiusFull`, `kTouchTarget = 48`, `kMajorSlotSmall = 40`, `kMajorSlotLarge = 48`, `kMaxContentWidth = 600`. |
| Theme | `lib/theme/app_theme.dart` | `ThemeData(useMaterial3: true)` + `ColorScheme.fromSeed` theo seed brand, chỉ theme sáng. |

`tool/check_layers.sh` chặn `Color(0x...)`, `fontSize:` và `EdgeInsets.all(<số>)` trong
`lib/screens/` — bảo đảm không có màu/kích thước hard-code trong màn.

---

## 5. Sai lệch đã ghi nhận (bắt buộc theo Lab 3 §3)

| ID | Sai lệch | Lý do | Ảnh hưởng | Đã cập nhật Figma? |
|---|---|---|---|---|
| **D1** | S1 đăng nhập bằng **Google Sign-In** (kèm email/password/phone) thay vì chỉ email không mã. | Lab 3 §6 yêu cầu "Authentication: **Google Sign-In**; app routes by auth state". Design Lab 2 chưa có bước Google. | Đăng nhập có thêm bước chọn tài khoản; trạng thái loading/error (S19) vẫn giữ nguyên. | Chưa — cần cập nhật frame S1 trong Figma Final UI. |
| **D2** | S22/S23 dùng file **CSV** (`.csv`) thay vì `.xlsx`. | Package `csv` (Dart) không đọc XLSX; thêm `excel` làm app nặng và Lab 3 không yêu cầu định dạng file cụ thể. Cột và quy tắc giữ nguyên: MSSV, Full name, Class name, Group, Major. | Mentor phải lưu danh sách dưới dạng CSV; nhãn trên S22 ghi rõ định dạng. | Chưa — cần sửa nhãn file mẫu trong Figma. |
| **D3** | Nút xác nhận trong S12/S17/S24 ghi **"Approve" / "Discard" / "Remove"** thay vì "Confirm". | Dialog dùng chung (`showConfirmDialog`) phải nêu đúng hành động; nhãn "Confirm" chung chung gây rủi ro bấm nhầm. Nhãn tiếng Anh đúng ngữ nghĩa. | Không đổi bố cục, chỉ đổi chữ trên nút. | Chưa — cần sửa nhãn nút trong Figma. |
| **D4** | S6 Profile có thêm **khu demo Firebase** (Remote Config, FCM token, export PDF, Crashlytics). | Lab 3 §3: "Provide a Firebase demo area, usually on the Profile screen". | Profile dài hơn; dùng `ExpansionTile`/card chia khu rõ ràng. | Chưa — cần thêm frame demo trong Figma. |
| **D5** | S9 giới hạn số thẻ đề xuất theo Remote Config `max_proposals_shown` (mặc định 3). | Lab 3 §6 yêu cầu ≥ 2 tham số thay đổi hành vi hiển thị. Mặc định 3 khớp thiết kế Lab 2 (3 thẻ). | Khi hạ giá trị trong Console, mentor chỉ thấy N thẻ đầu. | Không cần (giá trị mặc định khớp thiết kế). |

---

## 6. Data source mapping

| Nội dung | Nguồn thật | Ghi chú Lab 3 |
|---|---|---|
| Danh sách lớp, sinh viên, nhóm | Cloud Firestore `classes/{classId}/{students,teams}` | "Cloud Firestore when the app stores the user's own data" — hợp lệ. |
| Đề xuất (proposals) | Cloud Firestore `classes/{classId}/proposals` + `collectionGroup` | Ghi bằng batch, duyệt bằng transaction. |
| File PDF | `pdf` package → Cloud Storage `reports/{uid}/{id}.pdf` | File sinh ra **phản ánh đúng** dữ liệu mentor đang xem (`PdfReportService` đọc cùng stream Firestore). |
| FCM token | `users/{uid}/fcmTokens/{tokenId}` | |
| Hồ sơ mentor | `users/{uid}` (`FirestoreMentorProfileService`) | |
| Analytics / Crashlytics / Remote Config | Firebase Analytics, Crashlytics, Remote Config | Không hard-code trong bản nộp. |

> **Không có mock data trong bản nộp**: `lib/main.dart` chỉ dùng service thật.
> `lib/main_fake.dart` (fake) chỉ để dev/demo ngoài bài nộp và không được gọi từ entrypoint chính.

---

## 7. Trạng thái loading / empty / error

Mọi màn nạp dữ liệu dùng `ViewState<T>` (`viewmodels/view_state.dart`): `Loading`,
`Empty`, `Data<T>`, `Failure<T>`. Bảng yêu cầu của Lab 2 (`screen-spec.md`, mục
"Trạng thái cần có theo màn") được đối chiếu:

| Màn | Loading | Empty | Error |
|---|---|---|---|
| S2, S3, S4, S5, S7, S9, S10, S16, S20, S22, S23 | ✔ | ✔ | ✔ (kèm nút Try again) |
| S1 | ✔ (nút loading) | — | ✔ (S19) |
| S8 | ✔ (chính là màn loading) | — | ✔ (S18) |
| S6 | ✔ | ✔ (chưa có báo cáo) | ✔ (nạp danh sách báo cáo hỏng) |

Không màn nào có trạng thái "spinner vô hạn": mọi `Stream` đều có nhánh `error` và
`StatusView.error(onRetry: ...)`.
