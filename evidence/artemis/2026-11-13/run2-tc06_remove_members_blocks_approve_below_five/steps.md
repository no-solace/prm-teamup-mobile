# test_tc06_remove_members_blocks_approve_below_five (run 2)

- Session: `ee47a5f4-9241-4af6-9918-9aece64a433b`
- Status: completed, 281.5s
- Output: `None`

| Step | Screen before | Action |
|---|---|---|
| 1 | ![](step-01.jpg) | `manage_app` app_name=com.group6.teamup_exe, action=stop |
| 2 | ![](step-02.jpg) | `manage_app` app_name=com.group6.teamup_exe, action=launch |
| 3 | ![](step-03.jpg) | `wait_for_delay` time_in_ms=2000 |
| 4 | ![](step-04.jpg) | `swipe` direction=up |
| 5 | ![](step-05.jpg) | `swipe` direction=down |
| 6 | ![](step-06.jpg) | `swipe` direction=up |
| 7 | ![](step-07.jpg) | `click` target=18 |
| 8 | ![](step-08.jpg) | `click` target=13 |
| 9 | ![](step-09.jpg) | `swipe` direction=down |
| 10 | ![](step-10.jpg) | `click` target_description=Top right action icon on My classes screen, target=[920, 87] |
| 11 | ![](step-11.jpg) | `click` target=2 |
| 12 | ![](step-12.jpg) | `click` target=1 |
| 13 | ![](step-13.jpg) | `swipe` direction=up |
| 14 | ![](step-14.jpg) | `swipe` direction=up |
| 15 | ![](step-15.jpg) | `click` target=12 |
| 16 | ![](step-16.jpg) | `click` target=[500, 240], target_description=Choose CSV button |
| 17 | ![](step-17.jpg) | `click` target=11 |
| 18 | ![](step-18.jpg) | `click` target=5 |
| 19 | ![](step-19.jpg) | `click` target=9 |
| 20 | ![](step-20.jpg) | `click` target=11 |
| 21 | ![](step-21.jpg) | `wait_for_delay` time_in_ms=5000 |
| 22 | ![](step-22.jpg) | `click` target=2 |
| 23 | ![](step-23.jpg) | `click` target=13 |
| 24 | ![](step-24.jpg) | `click` target=5 |
| 25 | ![](step-25.jpg) | `click` target=13 |
| 26 | ![](step-26.jpg) | `click` target=5 |
| 27 | ![](step-27.jpg) | `swipe` direction=up |
| 28 | ![](step-28.jpg) | `click` target=13 |
| 29 | ![](step-29.jpg) | `click` target=5 |
| 30 | ![](step-30.jpg) | `report_task_status` completed: {"banner_text": "Approval needs at least 5 and at most 6 members.", "approve_enabled": false} |

Final screen:

![](final.jpg)
