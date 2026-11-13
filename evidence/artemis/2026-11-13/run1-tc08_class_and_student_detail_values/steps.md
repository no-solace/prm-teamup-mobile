# test_tc08_class_and_student_detail_values (run 1)

- Session: `392fb26f-43cf-4b70-b6be-dadf1d933245`
- Status: completed, 124.1s
- Output: `{"without_team": 3, "need_members": 1, "student_ids": ["AI000012", "GD000011", "MK000010"], "student_id": "AI000012", "group": "None", "major": "AI"}`

| Step | Screen before | Action |
|---|---|---|
| 1 | ![](step-01.jpg) | `manage_app` app_name=com.group6.teamup_exe, action=stop |
| 2 | ![](step-02.jpg) | `manage_app` action=launch, app_name=com.group6.teamup_exe |
| 3 | ![](step-03.jpg) | `click` target=3 |
| 4 | ![](step-04.jpg) | `wait_for_delay` time_in_ms=3000 |
| 5 | ![](step-05.jpg) | `click` target=3 |
| 6 | ![](step-06.jpg) | `wait_for_delay` time_in_ms=4000 |
| 7 | ![](step-07.jpg) | `click` target=4 |
| 8 | ![](step-08.jpg) | `click` target=[500, 240], target_description=Choose CSV button |
| 9 | ![](step-09.jpg) | `wait_for_delay` time_in_ms=2000 |
| 10 | ![](step-10.jpg) | `click` target=7 |
| 11 | ![](step-11.jpg) | `click` target=4 |
| 12 | ![](step-12.jpg) | `click` target=11 |
| 13 | ![](step-13.jpg) | `click` target=6 |
| 14 | ![](step-14.jpg) | `click` target=9 |
| 15 | ![](step-15.jpg) | `click` target=5 |
| 16 | ![](step-16.jpg) | `click` target=9 |
| 17 | ![](step-17.jpg) | `click` target=1 |
| 18 | ![](step-18.jpg) | `click` target=11 |
| 19 | ![](step-19.jpg) | `click` target=1 |
| 20 | ![](step-20.jpg) | `click` target=13 |
| 21 | ![](step-21.jpg) | `report_task_status` completed: {"without_team": 3, "need_members": 1, "student_ids": ["AI000012", "GD000011", "MK000010"], "student_id": "AI000012", "group": "None", "major": "AI"} |

Final screen:

![](final.jpg)
