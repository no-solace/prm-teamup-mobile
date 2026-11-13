# test_tc06_remove_members_blocks_approve_below_five (run 1)

- Session: `e5f0435a-b306-4318-8fb7-a24abae6379a`
- Status: completed, 104.0s
- Output: `{"banner_text": "Approval needs at least 5 and at most 6 members.", "approve_enabled": false}`

| Step | Screen before | Action |
|---|---|---|
| 1 | ![](step-01.jpg) | `manage_app` app_name=com.group6.teamup_exe, action=stop |
| 2 | ![](step-02.jpg) | `manage_app` app_name=com.group6.teamup_exe, action=launch |
| 3 | ![](step-03.jpg) | `wait_for_delay` time_in_ms=2000 |
| 4 | ![](step-04.jpg) | `click` target=8 |
| 5 | ![](step-05.jpg) | `click` target=[500, 240], target_description=Choose CSV button |
| 6 | ![](step-06.jpg) | `click` target=11 |
| 7 | ![](step-07.jpg) | `click` target=6 |
| 8 | ![](step-08.jpg) | `click` target=9 |
| 9 | ![](step-09.jpg) | `click` target=11 |
| 10 | ![](step-10.jpg) | `wait_for_delay` time_in_ms=5000 |
| 11 | ![](step-11.jpg) | `click` target=2 |
| 12 | ![](step-12.jpg) | `click` target=13 |
| 13 | ![](step-13.jpg) | `click` target=5 |
| 14 | ![](step-14.jpg) | `click` target=13 |
| 15 | ![](step-15.jpg) | `click` target=5 |
| 16 | ![](step-16.jpg) | `swipe` direction=up |
| 17 | ![](step-17.jpg) | `click` target=13 |
| 18 | ![](step-18.jpg) | `click` target=5 |
| 19 | ![](step-19.jpg) | `report_task_status` completed: {"banner_text": "Approval needs at least 5 and at most 6 members.", "approve_enabled": false} |

Final screen:

![](final.jpg)
