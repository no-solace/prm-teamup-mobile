# ARTEMIS evidence — bằng chứng chạy thật

> Thư mục này chứa **trace + ảnh chụp + báo cáo agent** của các phiên ARTEMIS
> đã chạy thật trên emulator `emulator-5554` (Android 14, Google Play).
>
> Thu thập lại bằng:
>
> ```bash
> python tools/collect_artemis_evidence.py
> ```
>
> Script chỉ gọi `GET` trên daemon ARTEMIS (`http://127.0.0.1:8000`) — không
> sửa gì trên host.

## Cấu trúc mỗi phiên

```
evidence/artemis/<session-id>/
├── session.json      ← metadata phiên: goal, status, device, model, thời gian
├── report.md         ← báo cáo từng bước + ảnh nhúng
└── screenshots/
    ├── step-01-before.jpg
    ├── step-01-after.jpg
    └── …
```

## Các phiên đã chạy

| Session | Trạng thái | Nội dung |
|---|---|---|
| `b495eec3-ff06-485e-812c-0ee943068945` | ✅ **completed** | **TC-02** — bấm 3 tab `Proposals` / `Profile` / `Classes`; agent báo `Proposals, Profile, My classes`; 6 bước, 11 ảnh |
| `96f052cd-e98b-4d59-8eaf-82093aafdc3d` | ✅ completed | Bấm tab `Proposals`, đọc danh sách đề xuất; 4 bước, 7 ảnh |
| `1312b157-16dc-451f-99f0-c54454324263` | ✅ completed | Đọc màn `My classes` (`Class A: 17 students`); 1 ảnh |
| `a5cbbd37-131b-40f4-9dfd-0de881040561` | ✅ completed | Báo cáo tiêu đề màn hình đang mở; 1 ảnh |
| `0797238d-da09-49d8-b3c4-49e5c9041348` | ❌ failed | **TC-01** — chọn tài khoản Google trong account picker; agent không hoàn tất |
| `0a1dca5a-37e8-4061-a9b0-487c182f9ac6` | ❌ failed | Import class list — timeout 429 |
| `1b0a7e4e-5e42-4745-b09d-7313fffb8737` | ❌ failed | Profile → Export PDF — timeout 429 |
| `3154a407-31de-49ad-a27c-36b1dcd86a75` | ❌ failed | Bấm tab `Proposals` — timeout 429 |
| `3fdfc310-1e2f-4486-9b15-c8343883191b` | ❌ failed | Mô tả màn hình hiện tại — timeout 429 |
| `5cc22c6c-9a54-4631-a735-711f1eaf68fb` | ❌ failed | Profile → cuộn xuống — timeout 429 |
| `6d112a1d-30cc-4542-b1c5-97454e548fe1` | ❌ failed | Import class list — timeout 429 |
| `987c7899-6009-4aef-b440-3e0f3c995b02` | ❌ failed | Profile → Export PDF — timeout 429 |

**Tổng: 22 ảnh chụp thật** từ 12 phiên có ảnh. Ngoài ra còn **5 phiên** chỉ có
`session.json` (không có bước nào hoàn thành nên không có ảnh) — xem bảng dưới.

| Session | Trạng thái | Nội dung |
|---|---|---|
| `5648ddd2-f5d2-4ce9-9f28-4d50b162da88` | ❌ failed | **TC-01** — chọn tài khoản Google trong account picker |
| `60aa42a6-8552-408a-a40b-e665cad095c7` | ❌ failed | **TC-02** — hết hạn mức Gemini |
| `3b30dd69-33da-47dc-9638-16a903aff7d4` | ❌ failed | **TC-03** — hết hạn mức Gemini |
| `f27900f8-15f7-478c-8f78-e6ec7294fe3c` | ❌ failed | **TC-04** — hết hạn mức Gemini |

> Các phiên `5648ddd2` / `60aa42a6` / `3b30dd69` / `f27900f8` là lần chạy lại 4 test
> `test_auth.py` **sau khi hạn mức đã cạn** — cả 4 đều dừng ở bước `pre-planning`
> với lỗi 429 `RESOURCE_EXHAUSTED`.
>
> Tổng cộng: **16 phiên** trong thư mục này (4 `completed` có ảnh, 12 `failed`).

## Vì sao phần lớn phiên `failed`

Không phải app sai — mà là **hạn mức Gemini free-tier**:

```
429 Too Many Requests — quota exceeded for metric:
  generativelanguage.googleapis.com/generate_content_free_tier_requests
```

Lần chạy đầu tiên của cả bộ đã dùng hết hạn mức ngày. Hạn mức reset **00:00
theo giờ UTC**. Cách xử lý: chờ ngày mới, dùng key/project khác, hoặc nâng cấp
gói trả phí. Chi tiết ở `docs/WORKLOG.md` §5b.2.

## Việc còn lại

- Chạy lại **≥ 3 lần/ca** trên build **release** + **thiết bị thật** → điền
  `docs/test-plan.md` §6.
- Phiên khám phá (`EX-01`) → `evidence/artemis/exploratory/`.
- Đặt tên thư mục theo mã test để dễ tra: `evidence/artemis/TC-02/` thay vì
  UUID (đã ghi trong `docs/BAN_GIAO_HUONG_DAN_NOP_BAI.md` §3.2).
