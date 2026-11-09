# Rule-based matching — Lab 3

Phạm vi: `RuleBasedMatchingService` triển khai nguyên interface `MatchingService`;
không đổi model, fake, UI, Firebase hoặc dữ liệu nhóm. Kết quả chỉ là đề xuất
`pending`, `source: ai`; nhãn AI ở đây là quy tắc, không có mô hình học máy.

## Chính sách R1–R3

- **R1:** chỉ đề xuất nếu nhóm hiện hữu có thể đạt 5–6 người. Hoàn thành nhóm
  dưới 5 trước khi thêm người thứ 6. Không tạo nhóm mới, không đưa ra đề xuất
  1–4 người. Sau lượt hoàn thành, dùng pool còn lại để điền chỗ thứ 6.
- **R2:** chỉ xét lớp được chọn. Sinh viên có `teamId` khác null hoặc xuất hiện
  trong bất kỳ roster nào của lớp đều bị giữ ngoài pool, kể cả roster đầy/lỗi.
  Mỗi MSSV chỉ dùng một lần trong toàn bộ kết quả. Nhóm từ 6 người không là đích.
- **R3:** chỉ dùng ngành SE/AI/MKT/GD. Mỗi lần chọn, ưu tiên ngành chưa có,
  rồi ngành có nhiều người còn lại (giữ ngành hiếm cho nhóm khác), rồi thứ tự
  enum SE/AI/MKT/GD, cuối cùng MSSV tăng dần. Trong các nhóm dưới 5, ưu tiên
  phương án đạt ít nhất 3 ngành, rồi cần ít người bổ sung hơn, rồi ID nhóm.
  Các nhóm vốn có 5 người được xét sau nhóm thiếu; không cấp đề xuất rỗng.

Kết quả xếp theo ID nhóm; member IDs và ngành hiện tại được sắp theo MSSV theo
cặp. ID đề xuất ổn định theo cặp lớp/nhóm. Tên sinh viên, thứ tự input và lịch sử
lần gọi không quyết định phân bổ. Snapshot đề xuất là bản sao không cho sửa list.

`strong` nghĩa là kết quả có ít nhất 3 ngành; `good` nghĩa là đủ 5–6 người nhưng
chưa đạt 3 ngành. Lý do ghi số người, các ngành kết quả, ngành mới bổ sung và
yêu cầu mentor xem xét nếu chưa đạt 3 ngành. Không tự tạo ngành hoặc sinh viên.

## Dữ liệu thiếu hoặc xung đột

- Lớp rỗng: `ValidationError`. Không có pool/đích/phương án đủ 5: list rỗng
  để caller dùng trạng thái No match.
- MSSV hoặc ID nhóm rỗng: bỏ qua. ID được so sánh chính xác như model; service
  không tự đổi hoa/thường hoặc sửa khóa dữ liệu nhập.
- Trùng MSSV cùng ngành và cùng `teamId`: gộp. Khác ngành/assignment: loại
  MSSV khỏi pool; nếu là thành viên roster thì loại cả đích không đáng tin đó.
- Snapshot nhóm giống nhau (kể cả đảo thứ tự các cặp thành viên/ngành): gộp.
  Snapshot cùng ID khác tên/roster/ngành: bỏ đích đó.
- Roster lặp thành viên, thiếu ngành tương ứng, ID thành viên rỗng, quá 6 người,
  hoặc chung thành viên giữa các nhóm: bỏ đích lỗi. Vẫn giữ thành viên ngoài pool.
- Student ghi assignment không có trong roster, assignment sang nhóm khác hoặc
  ngành khác roster: không đoán sửa dữ liệu; bỏ đích xung đột.
- Thiếu bản ghi Student cho thành viên hiện tại: dùng ngành đã ghép đúng cặp
  trong Team. Nếu Student ghi chưa có nhóm nhưng roster có tên, roster giữ
  sinh viên ngoài pool.

## Giới hạn tích hợp

Đây là heuristic tham lam, không bảo đảm tối ưu số nhóm hoặc độ đa dạng trên
toàn lớp khi nguồn ngành khan hiếm. Ba ngành là ưu tiên; giới hạn 5–6 và không
trùng người là điều kiện cứng. Mentor xem các đề xuất `good` và sửa/ghép tay khi
cần. Không di chuyển thành viên cũ để tăng độ đa dạng.

Service không đọc trạng thái discarded/pending, không lưu Firestore và không
chặn tranh chấp từ hai lần duyệt đồng thời. Caller/ProposalService chịu trách
nhiệm R4 (Discard/Approve/Undo), kiểm tra roster mới nhất và lưu giao dịch.
ID ổn định không thay cho việc kiểm tra trạng thái đã discard.

## Kiểm tra

`test/services/rule_based_matching_service_test.dart` kiểm tra R1–R3, lớp khác,
dữ liệu lỗi/trùng/xung đột, snapshot bất biến, nhiều lần gọi và đảo input,
60 bộ dữ liệu sinh từ seed, cùng khả năng dùng fake qua interface cũ.

Chạy tại bản sao matching:

```text
flutter analyze --no-pub
flutter test --no-pub
```

Không cần khởi tạo Firebase hoặc kết nối mạng để kiểm thử thuật toán.

Đã chạy ngày 06/11/2026 với Flutter 3.47.3 / Dart 3.13.3:

- `flutter analyze --no-pub`: **No issues found**, 29,5 giây.
- `flutter test --no-pub`: **34 tests passed** (31 matching, 3 ViewModel có sẵn).
- `git diff --check`: sạch.

Chưa kiểm tra UI, thiết bị thật, dữ liệu Firestore hoặc giao dịch duyệt; những
phần này nằm ngoài phạm vi triển khai matching thuần Dart.
