# assets/figma/

PNG xuất từ file Figma: https://www.figma.com/design/X5WcaK4s20AYF53cvRdouV

Trạng thái file Figma (14/10/2026, 25 màn), 6 page đúng thứ tự:

| Page | Nội dung |
|---|---|
| 01 User Flow | Cây IA, Flow A/B/C vẽ bằng layer Figma từ `assets/flows/build_flows.py`, bảng phủ màn S1-S25 (Flow A qua S19, S22, S23; Flow B qua S24, S25; Flow C qua S20 và S21) |
| 02 Wireframe | W01-W25 xám, 360x800, **suy ra từ layout Final UI sau khi Stitch sinh ra** (không phải bản phác trước) |
| 03 Final UI | S01-S25 360x800 (S01-S21 dựng từ code HTML của Stitch; S22-S25 nhân bản từ S07, S03, S17, S10) thành layer Figma; màu và chữ đã gắn Variables và text style |
| 04 Design System | Variables Color / Spacing / Radius, 6 text style, bảng tương phản tính từ giá trị thật, icon, ô ngành |
| 05 Components | 14 component set có variant và state (Button, Major slot, Filter chip, Fit chip, Checkbox row, Text field, Card, Team card, App bar, Navigation bar, Dialog, Loading, Empty, Error) và Snackbar |
| 06 Prototype | 35 frame, 3 hàng Flow A/B/C, mỗi hàng có điểm bắt đầu riêng, loading tự chuyển sau 3-4 giây, đường lỗi S19, S18, S13, S21, S17, S25; Flow C đi qua S20; nhánh phụ A12-A13 (nhập lớp) và B8-B9 (bỏ thành viên) |

## PNG đã xuất (15/10/2026, 1x; page 04 và 05 giữ bản 11/10 vì không đổi)

| Thư mục | Nội dung |
|---|---|
| `01-user-flow/` | 1 ảnh toàn page 01 (1400x6974, đã có S22-S25) |
| `02-wireframe/` | W01-W25 (360x800) + `wireframe-note.png`; đã sửa nội dung: W02, W03, W05, W07, W10, W12, W17, W20; mới: w22-w25 |
| `03-final-ui/` | S01-S25 (360x800); đã sửa nội dung: s02, s03, s05, s07, s10, s12, s17, s20; mới: s22-s25; S04 và S17 là bản đã sửa trong Figma (ảnh "before" ở `../stitch/mentor-v2/s04-no-team/screen.png` và `s17-discard-dialog/screen.png`) |
| `04-design-system/` | Page 04 |
| `05-components/` | Page 05 |
| `06-prototype/` | 35 frame A0-A13, B0-B9, C0-C10 (mới: a12, a13, b8, b9; sửa nội dung: a1, a2, a7, a8, b1, b3, b5, b6, c0, c3, c5, c6, c7) + 4 ảnh nhãn (header, Flow A/B/C label) |

Quy ước tên file (khi xuất từ Figma ra sẽ có tên gốc dạng `S22 · Import class list.png`, cần đổi sang): chữ thường, dấu gạch ngang, không dấu cách, bỏ dấu phẩy và ngoặc (ví dụ `s04-no-team.png`, `w04-no-team.png`, `a3-s04-no-team.png`). Prototype: chữ cái A/B/C là flow, số là thứ tự frame trong flow.
