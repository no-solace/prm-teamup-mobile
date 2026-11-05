# Flutter handoff

App: TeamUp EXE (mentor). Flutter, Material 3, Android, khung thiết kế 360 x 800 dp, kiểm 412 dp. Không viết code trong lab này; tài liệu này đủ để dựng từng màn mà chỉ cần xem Figma để nhìn hình.

## Quy ước chung

- `MaterialApp(theme: ThemeData(useMaterial3: true, colorScheme: lightScheme, textTheme: appTextTheme))`. Chỉ có theme sáng.
- Font Be Vietnam Pro khai báo trong `pubspec.yaml`, fallback Roboto.
- Điều hướng: `GoRouter` hoặc `Navigator 2.0`; ba tab `NavigationBar` (Classes, Proposals, Profile) dùng `StatefulShellRoute`; các màn lồng nhau đẩy lên trên tab.
- Dialog dùng `showDialog` với `AlertDialog`; snackbar dùng `ScaffoldMessenger`.
- Dữ liệu mẫu cố định trong lab; trạng thái loading dùng `Future.delayed` giả lập.

## Bảng 1: token → Flutter

| Token (DESIGN.md) | Giá trị | Flutter |
|---|---|---|
| primary | #B23E00 | `ColorScheme.primary` |
| on-primary | #FFFFFF | `ColorScheme.onPrimary` |
| primary-container | #FFE2D2 | `ColorScheme.primaryContainer` |
| on-primary-container | #3B1400 | `ColorScheme.onPrimaryContainer` |
| secondary | #2F2E2A | `ColorScheme.secondary` |
| secondary-container | #E9E7E2 | `ColorScheme.secondaryContainer` |
| on-secondary-container | #1C1B18 | `ColorScheme.onSecondaryContainer` |
| tertiary | #1B6B3C | `ColorScheme.tertiary` |
| tertiary-container | #D6F0DD | `ColorScheme.tertiaryContainer` |
| on-tertiary-container | #07301A | `ColorScheme.onTertiaryContainer` |
| error | #B3261E | `ColorScheme.error` |
| error-container | #F9DEDC | `ColorScheme.errorContainer` |
| surface | #FFFFFF | `ColorScheme.surface` |
| surface-container-low | #F3F2EF | `ColorScheme.surfaceContainerLow` |
| surface-container | #E9E7E2 | `ColorScheme.surfaceContainer` |
| on-surface | #1C1B18 | `ColorScheme.onSurface` |
| on-surface-variant | #55534D | `ColorScheme.onSurfaceVariant` |
| outline | #77756F | `ColorScheme.outline` |
| outline-variant | #D6D4CE | `ColorScheme.outlineVariant` |
| brand-orange | #F37021 | `const brandOrange = Color(0xFFF37021)` (chỉ logo) |
| scrim | #000000, 40% | `Colors.black.withOpacity(0.4)` (`barrierColor` của `showDialog`) |
| stitch/primary-container | #8A2E00 | `const kPrimaryPressed = Color(0xFF8A2E00)` (nút primary khi nhấn) |
| stitch/text-secondary | #6F5A4E | `const kTextSecondary = Color(0xFF6F5A4E)` |
| stitch/on-surface-variant | #584239 | `const kOnSurfaceVariantWarm = Color(0xFF584239)` |
| stitch/surface-container-low | #F2EDE8 | `const kFieldFill = Color(0xFFF2EDE8)` |
| stitch/outline-variant (E6E2DD, DED9D4, E0C0B4) | xem `design/DESIGN.md` | hằng số trong `app_colors.dart`, dùng cho viền và đường kẻ |
| icon | Material Symbols Outlined 24 dp; tab đang chọn dùng glyph filled | `Icon(Symbols.xxx)` hoặc `Icons.xxx_outlined` |
| headline-small | 24/32, 700 | `TextTheme.headlineSmall` |
| title-large | 20/28, 600 | `TextTheme.titleLarge` |
| title-medium | 16/24, 600 | `TextTheme.titleMedium` |
| body-large | 16/24, 400 | `TextTheme.bodyLarge` |
| body-medium | 14/20, 400 | `TextTheme.bodyMedium` |
| label-large | 14/20, 600 | `TextTheme.labelLarge` |
| spacing xs/sm/md/lg/xl | 4/8/16/24/32 | `const kSpaceXs/kSpaceSm/kSpaceMd/kSpaceLg/kSpaceXl` |
| rounded sm/md/lg/full | 8/12/16/999 | `const kRadiusSm/Md/Lg/Full` (BorderRadius.circular) |
| elevation | 0 mặc định; dialog và snackbar dùng elevation của Material | `Card(elevation: 0)`, mặc định cho `AlertDialog`/`SnackBar` |

## Bảng 2: component → widget

| Component Figma | Widget Flutter |
|---|---|
| Button primary | `FilledButton` |
| Button tonal | `FilledButton.tonal` |
| Button text | `TextButton` |
| Text field | `TextFormField` với `InputDecoration(filled: true)` |
| Card | `Card(elevation: 0, shape: RoundedRectangleBorder(side: BorderSide(color: outlineVariant)))` |
| Navigation bar | `NavigationBar` với `NavigationDestination` |
| App bar | `AppBar` |
| Dialog confirm / destructive | `AlertDialog` (nút Discard dùng `FilledButton` với `backgroundColor: error`) |
| Loading | `CircularProgressIndicator` (màn) và skeleton bằng `Container` xám |
| Empty / Error state | `Center(Column(Icon, Text, FilledButton))` (widget dùng chung `StatusView`) |
| Chip lọc | `FilterChip` |
| Fit chip | `Chip` với `avatar: Icon` |
| Ô ngành (major slot) | `Container(40x40 hoặc 48x48)` + `Text` hoặc `Icon`; viền đứt bằng `CustomPaint` hoặc package `dotted_border` |
| Checkbox row | `CheckboxListTile` |
| Snackbar | `SnackBar(action: SnackBarAction)` |
| Badge | `Badge(label: Text)` |

## Tổng hợp trạng thái và ràng buộc chung

- Vùng chạm tối thiểu 48 x 48 dp, khoảng cách giữa hai vùng chạm tối thiểu 8 dp.
- Chữ tối thiểu 14 sp; không dùng chữ viết hoa toàn bộ; không truyền thông tin chỉ bằng màu.
- Bàn phím: màn có ô nhập dùng `resizeToAvoidBottomInset: true`, nút sticky nằm trong `SafeArea` và đẩy lên cùng bàn phím.
- Tràn chữ: tên 1 dòng `TextOverflow.ellipsis`; đoạn mô tả tối đa 2 dòng.
- Chữ có dấu tiếng Việt: chừa +30% chiều dài.

## Màn rộng (600 dp trở lên, không thiết kế, chỉ đặc tả)

- Thay `NavigationBar` bằng `NavigationRail`.
- Classes: danh sách bên trái (rộng 360), chi tiết lớp bên phải (master-detail).
- Proposals: danh sách bên trái, chi tiết đề xuất bên phải; dialog giữ nguyên, rộng tối đa 400 dp.
- Nội dung form và danh sách không rộng quá 600 dp (`ConstrainedBox(maxWidth: 600)`, căn giữa).
- Hàng ngành vẫn 1 hàng, tối đa 6 ô.

## Đặc tả từng màn

Mỗi màn có đủ 6 mục: layout, components, states, interactions, navigation, constraints.

### S1 Sign in

1. **Layout:** Scaffold(body: SafeArea → Padding(16) → Column: Text, Text, SizedBox(24), TextFormField, Spacer, FilledButton). Không cuộn trừ khi bàn phím mở (SingleChildScrollView).
2. **Components:** Text field (default/focused/error), Button primary.
3. **States:** default; error (email sai); loading (nút đang gửi).
4. **User interactions:** Nhập email; Continue kiểm tra định dạng. Sai: lỗi dưới ô 'Enter a valid email', giữ nội dung. Đúng: nút sang loading rồi vào S2.
5. **Navigation:** Vào từ khởi động app (chưa đăng nhập). Continue thành công sang S2 (thay thế, Back thoát app).
6. **Important UI constraints:** Nút cao 48dp; ô 56dp; bàn phím email, action done; email dài cắt ellipsis; tối đa 254 ký tự. Vùng chạm ≥ 48dp, chữ ≥ 14sp; trên màn ≥ 600dp theo mục "Màn rộng".

### S2 My classes

1. **Layout:** Scaffold(AppBar title, body: ListView(padding 16, separated 16) of Card, bottomNavigationBar: NavigationBar). Cuộn dọc, AppBar và NavigationBar cố định.
2. **Components:** App bar default, Card (tappable), Navigation (Classes selected).
3. **States:** populated; loading (skeleton thẻ); empty (chưa có lớp); error (offline).
4. **User interactions:** Chạm thẻ mở S3. Nút 'Import class list' mở S22. Kéo xuống để làm mới.
5. **Navigation:** Tab gốc. Chạm thẻ sang S3. Back thoát app.
6. **Important UI constraints:** Mỗi thẻ cao ≥ 96dp, toàn thẻ là vùng chạm; tên lớp 1 dòng ellipsis; số hiển thị tabular. Vùng chạm ≥ 48dp, chữ ≥ 14sp; trên màn ≥ 600dp theo mục "Màn rộng".

### S3 Class detail

1. **Layout:** Scaffold(AppBar back + title, body: Column: Row(3 × Expanded stat) với VerticalDivider, ListTile × 2; bottom: Padding(16) FilledButton sticky).
2. **Components:** App bar (back), Button primary, list row.
3. **States:** populated; loading; error.
4. **User interactions:** Chạm hàng sang S4 hoặc S5. Match with AI sang S8 (ghép theo ngành, nhóm 5-6 người). Nếu 0 SV chưa có nhóm thì nút bị khóa (disabled).
5. **Navigation:** Từ S2. Back về S2. Match with AI sang S8.
6. **Important UI constraints:** Số 24sp, nhãn 14sp; hàng cao ≥ 56dp; nút sticky cách đáy 16dp. Vùng chạm ≥ 48dp, chữ ≥ 14sp; trên màn ≥ 600dp theo mục "Màn rộng".

### S4 No team

1. **Layout:** Scaffold(AppBar back, body: Column: chip row (SingleChildScrollView ngang) + Expanded(ListView) , sticky FilledButton).
2. **Components:** App bar (back), chip lọc, list row, Button primary.
3. **States:** populated; loading; empty (không còn SV: chuyển S14); error.
4. **User interactions:** Chọn chip lọc danh sách (một lựa chọn). Chạm hàng sang S7. Match with AI sang S8.
5. **Navigation:** Từ S3. Back về S3.
6. **Important UI constraints:** Chip cao 48dp vùng chạm (32dp hiển thị + padding); tên 1 dòng ellipsis. Vùng chạm ≥ 48dp, chữ ≥ 14sp; trên màn ≥ 600dp theo mục "Màn rộng".

### S5 Need members

1. **Layout:** Scaffold(AppBar back, body: ListView of Card, sticky FilledButton).
2. **Components:** App bar (back), Card, ô ngành (đầy/mở), Button primary.
3. **States:** populated; loading; empty.
4. **User interactions:** Chạm thẻ không mở gì (chỉ xem). Match with AI sang S8. Mỗi thẻ hiện số thành viên và 'Needs ... to reach 5'.
5. **Navigation:** Từ S3 hoặc S15 (See teams). Back về nơi đã đến.
6. **Important UI constraints:** Tối đa 6 ô mỗi hàng, không cuộn ngang; tên nhóm 1 dòng. Vùng chạm ≥ 48dp, chữ ≥ 14sp; trên màn ≥ 600dp theo mục "Màn rộng".

### S6 Profile

1. **Layout:** Scaffold(AppBar, body: ListView: avatar header + ListTile × 2, tonal button, bottomNavigationBar).
2. **Components:** App bar, Navigation (Profile selected), Button tonal.
3. **States:** populated.
4. **User interactions:** Switch bật tắt thông báo ngay. Sign out sang S1 (xóa phiên).
5. **Navigation:** Tab gốc. Sign out thay thế stack bằng S1.
6. **Important UI constraints:** Hàng cao 56dp, switch có nhãn đọc được bởi screen reader. Vùng chạm ≥ 48dp, chữ ≥ 14sp; trên màn ≥ 600dp theo mục "Màn rộng".

### S7 Student detail

1. **Layout:** Scaffold(AppBar back, body: SingleChildScrollView → Column: thẻ hồ sơ, thẻ 'Student info' 4 hàng nhãn-giá trị; sticky FilledButton).
2. **Components:** App bar, chip, Card, Button primary.
3. **States:** populated; loading.
4. **User interactions:** Add to team quay về màn trước và đánh dấu sinh viên đã chọn.
5. **Navigation:** Từ S4 hoặc S11. Back về màn trước.
6. **Important UI constraints:** Giá trị căn phải, nhãn 14sp; tên 1 dòng. Vùng chạm ≥ 48dp, chữ ≥ 14sp; trên màn ≥ 600dp theo mục "Màn rộng".

### S8 AI matching

1. **Layout:** Scaffold(AppBar back, body: Center(Column: CircularProgressIndicator, Text, Text), Cancel TextButton).
2. **Components:** Loading state, Button text.
3. **States:** loading (màn này là loading); error (mất mạng: S18).
4. **User interactions:** Tự chuyển sang S9 khi có kết quả, hoặc S15 nếu không tìm được. Cancel hủy và về màn trước. Mất mạng sang S18.
5. **Navigation:** Từ S3, S4, S5. Back/Cancel hủy phép ghép.
6. **Important UI constraints:** Timeout 30 giây thì hiện S18; không chặn nút Back. Vùng chạm ≥ 48dp, chữ ≥ 14sp; trên màn ≥ 600dp theo mục "Màn rộng".

### S9 Proposals

1. **Layout:** Scaffold(AppBar, ListView of Card, NavigationBar).
2. **Components:** App bar, Card (tappable), Navigation (Proposals selected, badge).
3. **States:** populated; empty (S14); loading.
4. **User interactions:** Chạm thẻ mở S10.
5. **Navigation:** Tab gốc. Từ S8 (thay thế S8).
6. **Important UI constraints:** Badge cỡ ≥ 14sp hoặc dùng Badge của Material; chip kèm biểu tượng, không chỉ màu. Vùng chạm ≥ 48dp, chữ ≥ 14sp; trên màn ≥ 600dp theo mục "Màn rộng".

### S10 Proposal detail

1. **Layout:** Scaffold(AppBar back, body: ListView sections, bottom: Column(FilledButton Approve, TextButton Discard (error color))).
2. **Components:** App bar, ô ngành, chip, Button primary, Button text (destructive), Dialog.
3. **States:** populated; loading; error.
4. **User interactions:** Add member sang S11. Nút bỏ thành viên (IconButton 48dp ở mỗi hàng) mở S24. Approve mở S12 (dialog), bị khóa khi nhóm dưới 5 người (S25). Discard mở S17 (dialog).
5. **Navigation:** Từ S9. Back về S9. (Nhóm ghép tay dùng S20.)
6. **Important UI constraints:** Hai nút ở đáy cách nhau 8dp; Discard cao 48dp. Vùng chạm ≥ 48dp, chữ ≥ 14sp; trên màn ≥ 600dp theo mục "Màn rộng".

### S11 Add member

1. **Layout:** Scaffold(AppBar back, Column: Text, chip row, Expanded(ListView CheckboxListTile), sticky FilledButton).
2. **Components:** App bar, chip, checkbox row, Button primary.
3. **States:** populated; error (S13: vượt 6).
4. **User interactions:** Tick checkbox cập nhật số 'x of 6'. Add xác nhận và về S10. Tick quá 6 hiện lỗi (S13).
5. **Navigation:** Từ S10. Chạm tên sang S7. Back về S10.
6. **Important UI constraints:** Checkbox vùng chạm 48dp; đếm cập nhật tức thì. Vùng chạm ≥ 48dp, chữ ≥ 14sp; trên màn ≥ 600dp theo mục "Màn rộng".

### S12 Approve dialog

1. **Layout:** showDialog(AlertDialog(title, content, actions: [TextButton, FilledButton])) trên S10.
2. **Components:** Dialog (confirmation).
3. **States:** default.
4. **User interactions:** Approve đóng dialog, về S9 và hiện S14. Cancel đóng dialog.
5. **Navigation:** Mở từ S10. Back đóng dialog.
6. **Important UI constraints:** Rộng tối đa 320dp; nút ≥ 48dp. Vùng chạm ≥ 48dp, chữ ≥ 14sp; trên màn ≥ 600dp theo mục "Màn rộng".

### S13 Add member - Error

1. **Layout:** Như S11, thêm Row(error icon + Text) trên đáy danh sách.
2. **Components:** Checkbox row, error text, Button primary (disabled).
3. **States:** error.
4. **User interactions:** Bỏ một lựa chọn thì lỗi biến mất và nút Add bật.
5. **Navigation:** Từ S11. Back về S11.
6. **Important UI constraints:** Lỗi dùng biểu tượng + chữ, không chỉ màu; tối đa 5 từ. Vùng chạm ≥ 48dp, chữ ≥ 14sp; trên màn ≥ 600dp theo mục "Màn rộng".

### S14 Proposals - All matched

1. **Layout:** Như S9 với Center(Column), ScaffoldMessenger.showSnackBar.
2. **Components:** Empty state, Button primary, Snackbar.
3. **States:** empty; snackbar 5 giây.
4. **User interactions:** View teams sang S5. Undo hoàn tác lần duyệt cuối.
5. **Navigation:** Hiện sau S12 trên tab Proposals.
6. **Important UI constraints:** Snackbar nằm trên NavigationBar; Undo vùng chạm ≥ 48dp. Vùng chạm ≥ 48dp, chữ ≥ 14sp; trên màn ≥ 600dp theo mục "Màn rộng".

### S15 No match

1. **Layout:** Scaffold(AppBar back, Center(Column icon, Text, FilledButton, TextButton)).
2. **Components:** Error/empty state, Button primary, Button text.
3. **States:** empty.
4. **User interactions:** Add manually sang S16. See teams sang S5.
5. **Navigation:** Từ S8. Back về S3.
6. **Important UI constraints:** Thông báo nêu rõ ngành thiếu. Vùng chạm ≥ 48dp, chữ ≥ 14sp; trên màn ≥ 600dp theo mục "Màn rộng".

### S16 Add student

1. **Layout:** Scaffold(AppBar back, Column: TextField, chip row, Expanded(ListView), sticky FilledButton).
2. **Components:** Text field, chip, checkbox row (disabled), Button primary.
3. **States:** populated; empty (không có kết quả); error (hàng đã có nhóm bị khóa).
4. **User interactions:** Tìm theo tên (lọc tức thì); không có kết quả thì sang S21. Chỉ tick được hàng chưa có nhóm. Add sang S20.
5. **Navigation:** Từ S15. Back về S15.
6. **Important UI constraints:** Hàng bị khóa có biểu tượng khóa và chữ, không chỉ làm mờ. Vùng chạm ≥ 48dp, chữ ≥ 14sp; trên màn ≥ 600dp theo mục "Màn rộng".

### S17 Discard dialog

1. **Layout:** showDialog(AlertDialog) trên S10; nút Discard dùng màu error.
2. **Components:** Dialog (destructive).
3. **States:** default.
4. **User interactions:** Discard xóa đề xuất và về S9. Cancel đóng dialog.
5. **Navigation:** Mở từ S10.
6. **Important UI constraints:** Nút Discard dùng nền error và chữ trắng (6.54:1). Vùng chạm ≥ 48dp, chữ ≥ 14sp; trên màn ≥ 600dp theo mục "Màn rộng".

### S18 Offline

1. **Layout:** Scaffold(AppBar back, Center(Column icon, Text, FilledButton)).
2. **Components:** Error state, Button primary.
3. **States:** error.
4. **User interactions:** Try again chạy lại phép ghép (S8).
5. **Navigation:** Từ S8. Back về S3.
6. **Important UI constraints:** Nêu nguyên nhân (mất mạng) và cách khắc phục (thử lại). Vùng chạm ≥ 48dp, chữ ≥ 14sp; trên màn ≥ 600dp theo mục "Màn rộng".

### S19 Sign in - error

1. **Layout:** Như S1: Scaffold(Column: tiêu đề, TextField, bottom FilledButton).
2. **Components:** Text field (error), Button primary.
3. **States:** error (email sai).
4. **User interactions:** Sai định dạng email thì hiện lỗi dưới ô khi bấm Continue; sửa lại rồi Continue sang S2.
5. **Navigation:** Từ S1. Continue với email đúng sang S2.
6. **Important UI constraints:** Lỗi có viền đỏ 2dp, biểu tượng và chữ "Enter a valid email" (không chỉ màu); `InputDecoration.errorText`. Vùng chạm ≥ 48dp, chữ ≥ 14sp; trên màn ≥ 600dp theo mục "Màn rộng".

### S20 Proposal detail - hand-built

1. **Layout:** Như S10: Scaffold(AppBar back, body ListView: hàng ngành 48dp, chip, New member, Members; bottom: FilledButton Approve, TextButton Discard).
2. **Components:** App bar, ô ngành, chip ("Added by you"), Button tonal (Change), Button primary, Button text (destructive).
3. **States:** populated; loading; error.
4. **User interactions:** Approve mở S12. Discard mở S17. Change đổi sinh viên đã chọn.
5. **Navigation:** Từ S16 (sau Add). Back về S16.
6. **Important UI constraints:** Chip "Added by you" có biểu tượng, phân biệt với đề xuất AI. Vùng chạm ≥ 48dp, chữ ≥ 14sp; trên màn ≥ 600dp theo mục "Màn rộng".

### S21 Add student - no results

1. **Layout:** Scaffold(AppBar back, Column: TextField có nút xóa, chip row, Expanded(Center(Column icon, Text, FilledButton.tonal))).
2. **Components:** Text field, chip, Empty state, Button tonal.
3. **States:** empty (không có kết quả).
4. **User interactions:** Clear search xóa từ khóa và về danh sách S16.
5. **Navigation:** Từ S16 khi tìm không ra. Back về S16.
6. **Important UI constraints:** Thông báo nêu nguyên nhân ("No student found") và cách xử lý (Clear search). Vùng chạm ≥ 48dp, chữ ≥ 14sp; trên màn ≥ 600dp theo mục "Màn rộng".

### S22 Import class list

1. **Layout:** Scaffold(AppBar back, body: ListView(padding 16, separated 16): Card file, Card 'Columns detected' (5 hàng nhãn-giá trị), Card ghi chú; bottom: FilledButton sticky).
2. **Components:** App bar (back), Card, list row, Button primary.
3. **States:** default; loading (đang nhập, nút hiện tiến trình); error (sai định dạng hoặc thiếu cột: dùng chung mẫu lỗi S19, thiết kế sau).
4. **User interactions:** Import sang S23. Cột bắt buộc: MSSV, họ tên, lớp, nhóm, ngành.
5. **Navigation:** Từ S2 (nút Import class list). Back về S2.
6. **Important UI constraints:** Nút nêu số dòng sẽ nhập ("Import 42 students"). Vùng chạm ≥ 48dp, chữ ≥ 14sp; trên màn ≥ 600dp theo mục "Màn rộng".

### S23 Import result

1. **Layout:** Như S3: Scaffold(AppBar back, Column: Row(3 × Expanded stat), ListTile × 2, Card ghi chú; bottom: FilledButton sticky).
2. **Components:** App bar (back), Card, list row, Button primary.
3. **States:** populated; empty (không còn SV khả dụng: chuyển S14).
4. **User interactions:** Chạm hàng sang S4 hoặc S5. Open Class A sang S3.
5. **Navigation:** Từ S22. Back về S22.
6. **Important UI constraints:** SV đã có nhóm và nhóm đủ 6 người bị ẩn tự động, ghi chú nói rõ điều đó. Vùng chạm ≥ 48dp, chữ ≥ 14sp; trên màn ≥ 600dp theo mục "Màn rộng".

### S24 Remove member dialog

1. **Layout:** Như S17: S10 phía sau, Dialog giữa màn.
2. **Components:** Dialog, Button text, Button text (destructive).
3. **States:** default.
4. **User interactions:** Cancel đóng dialog. Remove bỏ thành viên và mở S25 khi nhóm còn dưới 5 người.
5. **Navigation:** Từ nút bỏ thành viên ở S10 hoặc S20. Cancel về màn trước.
6. **Important UI constraints:** Nút Remove màu đỏ, nêu hậu quả ("Team will have 4 members."). Vùng chạm ≥ 48dp, chữ ≥ 14sp; trên màn ≥ 600dp theo mục "Màn rộng".

### S25 Approve blocked

1. **Layout:** Như S10: hàng ngành 48dp (có một ô trống nét đứt), Members (còn 3 hàng), banner lỗi, bottom: FilledButton Approve (disabled), TextButton Discard.
2. **Components:** App bar (back), ô ngành (đầy/trống), Button tonal (Add member), banner lỗi, Button primary (disabled), Button text (destructive).
3. **States:** error (dưới 5 người). Đủ 5 người thì trở lại S10.
4. **User interactions:** Add member sang S11. Bỏ thêm người mở lại S24. Approve không bấm được.
5. **Navigation:** Từ S24 (Remove). Back về S10.
6. **Important UI constraints:** Lỗi nêu nguyên nhân và con số ("Needs at least 5 members (now 4)"), có biểu tượng và màu (không chỉ màu); Approve disabled phải có `Semantics` giải thích. Vùng chạm ≥ 48dp, chữ ≥ 14sp; trên màn ≥ 600dp theo mục "Màn rộng".
