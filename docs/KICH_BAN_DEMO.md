# Kịch bản demo (1 trang)

Máy demo: điện thoại Android thật, cài `teamup-exe-release.apk` (build từ máy đã đăng ký SHA-1 để Google Sign-In chạy). Tài khoản Google: `dannguyen2124@gmail.com` hoặc `duycannguyen80@gmail.com` (cả hai đã là admin web).

## Vai trò
| Người | Làm gì |
|---|---|
| A (cầm điện thoại) | Thao tác trong app |
| B (laptop 1) | Mở web admin `https://prm-lab3-cc39e.web.app`, đã đăng nhập sẵn |
| C (laptop 2) | Terminal ở thư mục `tools/`, sẵn lệnh gửi FCM; trình bày slide |

## Chuẩn bị trước giờ demo (làm đủ 1 lượt, không bỏ bước)
1. Cài APK, đăng nhập, bấm **Allow** thông báo (lúc này token FCM được lưu vào `users/{uid}/fcmTokens`).
2. Copy `demo-data/EXE101-demo.csv` và `EXE101-loi-de-demo-bao-loi.csv` vào thư mục Download của điện thoại.
3. Lấy UID của tài khoản đang đăng nhập (Firebase Console → Authentication) và dán vào lệnh gửi FCM.
4. Tải service account key (Project settings → Service accounts) lưu thành `serviceAccount.json` ở máy C. Không commit, không gửi ai.
5. Chạy thử: Test crash một lần và xuất một PDF để web admin đã có dòng dữ liệu cũ. Mở lại app sau khi crash.
6. Bật dữ liệu di động/Wi-Fi ổn định. Tắt chế độ tiết kiệm pin.

## Thứ tự demo
| # | Bước | Làm | Nói / chỉ ra | Kết quả mong đợi |
|---|---|---|---|---|
| 1 | Đăng nhập | A: Continue with Google | Firebase Auth + Google Sign-In; vai trò mentor lấy từ `users/{uid}` | Vào màn My classes |
| 2 | Import lỗi | A: import `EXE101-loi-de-demo-bao-loi.csv` | Validation trước khi ghi | Báo lỗi ngành phải là SE/AI/MKT/GD |
| 3 | Import đúng | A: import `EXE101-demo.csv` | Một batch ghi Firestore | Lớp EXE101-SE1801: 25 SV, 4 nhóm, 6 SV chưa có nhóm |
| 4 | Ghép nhóm | A: Match with AI, duyệt một đề xuất | Rule-based matching; đề xuất cần 5-6 người đủ ngành | Snackbar `Team approved` |
| 5 | Remote Config | C: đổi `max_proposals_shown` trên Console, publish; A: mở lại app | Đổi hành vi không cần build lại | Số đề xuất hiển thị đổi |
| 6 | Upload | A: Profile → xuất PDF | Firebase Storage `reports/{uid}`, có tiến độ | `Uploaded ...`; B: web admin hiện dòng mới ở "Báo cáo PDF" |
| 7 | FCM | C: `node send_fcm.mjs ../serviceAccount.json <uid> "Xin chào" "Thông báo từ server" /notifications` | Token do FCM cấp, client lưu Firestore, server gửi bằng Admin SDK | Thông báo hiện trên máy; vào Notifications thấy lịch sử |
| 8 | Crashlytics | A: Profile → **Test crash**; mở lại app | Crash native, báo cáo gửi lần mở sau | B: web admin hiện dòng crash ngay; Dev: Firebase Console → Crashlytics (chờ vài phút) |

Bước 8 để cuối vì app đóng. Nếu Crashlytics Console chưa cập nhật kịp, mở ảnh chụp đã có sẵn từ lượt chạy thử.

## Nếu có sự cố
| Sự cố | Cách xử lý |
|---|---|
| Đăng nhập Google lỗi 10 / DEVELOPER_ERROR | APK không phải bản build từ máy đã đăng ký SHA-1; cài lại đúng APK |
| Không nhận FCM | Chưa Allow thông báo, hoặc thiếu `data.uid` (app bỏ tin không khớp uid), hoặc token cũ: mở app, Notifications → bật lại |
| Web admin báo không phải admin | Thiếu `admins/<uid>` trong Firestore |
| Upload PDF lỗi | Kiểm tra mạng; Storage rules; dùng ảnh/PDF đã chụp lúc chạy thử |
| Crash không thấy trên Console | Phải là bản release; mở lại app sau crash; chờ vài phút |

## Câu hỏi thầy có thể hỏi (FCM)
- **FCM token là gì, ai cấp?** Định danh app trên một thiết bị, do máy chủ FCM (Google) cấp qua `firebase_messaging` `getToken()`; đổi khi cài lại/xóa dữ liệu/`deleteToken()`.
- **Client có lưu không?** Có: `users/{uid}/fcmTokens/{token}` (Firestore), cập nhật khi `onTokenRefresh`, xóa khi đăng xuất hoặc tắt thông báo. Code: `lib/firebase/fcm_notification_service.dart`.
- **Gửi bằng cách nào, code ở đâu?** `tools/send_fcm.mjs` (Node, Admin SDK, chạy trên máy tin cậy): đọc token từ Firestore rồi gọi FCM HTTP v1.
- **Client dùng ra sao?** Foreground `onMessage`; background `firebaseMessagingBackgroundHandler`; bấm thông báo `onMessageOpenedApp`/`getInitialMessage` rồi chuyển route; bỏ tin nếu `data.uid` không khớp người đang đăng nhập.
