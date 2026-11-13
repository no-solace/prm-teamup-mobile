# test_tc07_discard_then_manual_add_search_empty (run 1)

- Session: `fe3e1b34-8066-41c6-8ac5-ee3eaf70e49d`
- Status: completed, 126.9s
- Output: `{"group2_before": 1, "group2_after": 0, "empty_title": "No student results"}`

| Step | Screen before | Action |
|---|---|---|
| 1 | ![](step-01.jpg) | `manage_app` app_name=com.group6.teamup_exe, action=stop |
| 2 | ![](step-02.jpg) | `manage_app` action=launch, app_name=com.group6.teamup_exe |
| 3 | ![](step-03.jpg) | `wait_for_delay` time_in_ms=3000 |
| 4 | ![](step-04.jpg) | `click` target=10 |
| 5 | ![](step-05.jpg) | `click` target=[500, 240], target_description=Choose CSV button |
| 6 | ![](step-06.jpg) | `click` target=11 |
| 7 | ![](step-07.jpg) | `click` target=5 |
| 8 | ![](step-08.jpg) | `click` target=9 |
| 9 | ![](step-09.jpg) | `click` target=11 |
| 10 | ![](step-10.jpg) | `wait_for_delay` time_in_ms=5000 |
| 11 | ![](step-11.jpg) | `click` target=2 |
| 12 | ![](step-12.jpg) | `swipe` direction=up |
| 13 | ![](step-13.jpg) | `click` target=15 |
| 14 | ![](step-14.jpg) | `click` target=5 |
| 15 | ![](step-15.jpg) | `wait_for_delay` time_in_ms=2000 |
| 16 | ![](step-16.jpg) | `click` target=5 |
| 17 | ![](step-17.jpg) | `click` target=3 |
| 18 | ![](step-18.jpg) | `click` target=6 |
| 19 | ![](step-19.jpg) | `click` target=3 |
| 20 | ![](step-20.jpg) | `input_text` target=4, clear_exist=True, target_description=Search field, text=ZZZ |
| 21 | ![](step-21.jpg) | `input_text` clear_exist=True, text=ZZZ, target=42, target_description=Search name or student ID |
| 22 | ![](step-22.jpg) | `click` target=2 |
| 23 | ![](step-23.jpg) | `report_task_status` completed: {"group2_before": 1, "group2_after": 0, "empty_title": "No student results"} |

Final screen:

![](final.jpg)
