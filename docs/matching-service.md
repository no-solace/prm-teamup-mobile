# Rule-based matching — Lab 3

`RuleBasedMatchingService` triển khai interface `MatchingService`. Thuật toán
trả về đề xuất `pending`, `source: ai` và không ghi dữ liệu nhóm. Nhãn AI ở
đây chỉ thuật toán dựa trên quy tắc.

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

Kết quả xếp theo ID nhóm. ID đề xuất là hash ổn định của lớp, nhóm và dãy MSSV
hiện tại và được chọn. Thuật toán xét thành viên hiện tại theo thứ tự MSSV,
còn snapshot đề xuất giữ thứ tự roster đã lưu để đối chiếu khi duyệt. Tên sinh
viên và lịch sử lần gọi không quyết định phân bổ. Snapshot là bản sao bất biến.

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

Bản ghi sinh viên có MSSV rỗng hoặc chỉ gồm khoảng trắng bị bỏ qua có chủ đích:
không có định danh thì không thể đề xuất hay kiểm tra trùng người một cách an
toàn, và Firestore Rules không cho tạo tài liệu sinh viên với ID như vậy. Một
nhóm có `memberIds` rỗng vẫn bị đánh dấu xung đột (xem `team.memberIds.any(...)`).
Ghi nhận theo finding F10 trong `docs/code-review.md`.

Thuật toán chỉ tính đề xuất. `ProposalService.savePending` đối chiếu roster và
sinh viên hiện tại trước khi lưu. S8 chuyển trang theo danh sách `pending` do
service trả về. Cùng ID thì giữ bản nháp hợp lệ đã được mentor sửa, bỏ qua
`discarded` và `approved`.

Khi một bản nháp AI thay thế xuất hiện, các bản nháp AI `pending` khác của
cùng nhóm chuyển sang `superseded` trong cùng giao dịch. Bản nháp AI đã lỗi
thời cũng được rút khi lần chạy không tìm được bản thay thế. Nếu thuật toán
sinh lại ID đã `superseded`, service có thể lưu kết quả mới dưới ID đó. Các bản
nháp thủ công do mentor quản lý riêng. Firestore dùng tài liệu
`classes/{classId}/matching/state` để các lần matching đồng thời chạy lại giao
dịch khi danh sách bản nháp thay đổi.

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

Ca tích hợp của `savePending` nằm trong
`test/services/fake_proposal_integration_test.dart`. Ca kiểm thử chuyển trạng
thái trên Firestore Emulator nằm trong `firebase/test/firestore.rules.test.mjs`.
