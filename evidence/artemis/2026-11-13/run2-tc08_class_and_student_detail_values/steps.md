# test_tc08_class_and_student_detail_values (run 2)

- Session: `7f53d2bd-23be-4d1a-89c0-25f9ac95d7fe`
- Status: completed, 161.4s
- Output: `{"without_team": 3, "need_members": 1, "student_ids": ["AI000012", "GD000011", "MK000010"], "student_id": "AI000012", "group": "None", "major": "AI"}`

| Step | Screen before | Action |
|---|---|---|
| 1 | ![](step-01.jpg) | `manage_app` action=stop, app_name=com.group6.teamup_exe |
| 2 | ![](step-02.jpg) | `manage_app` app_name=com.group6.teamup_exe, action=launch |
| 3 | ![](step-03.jpg) | `click` target=3 |
| 4 | ![](step-04.jpg) | `wait_for_delay` time_in_ms=3000 |
| 5 | ![](step-05.jpg) | `click` target=3 |
| 6 | ![](step-06.jpg) | `wait_for_delay` time_in_ms=3000 |
| 7 | ![](step-07.jpg) | `swipe` direction=down |
| 8 | ![](step-08.jpg) | `wait_for_delay` time_in_ms=2000 |
| 9 | ![](step-09.jpg) | `swipe` direction=up |
| 10 | ![](step-10.jpg) | `click` target=12 |
| 11 | ![](step-11.jpg) | `click` target_description=Choose CSV button, target=[500, 240] |
| 12 | ![](step-12.jpg) | `click` target=11 |
| 13 | ![](step-13.jpg) | `click` target=6 |
| 14 | ![](step-14.jpg) | `click` target=6 |
| 15 | ![](step-15.jpg) | `click` target=5 |
| 16 | ![](step-16.jpg) | `click` target_description=Dương Yến student item, target=[500, 210] |
| 17 | ![](step-17.jpg) | `press_key` key=BACK |
| 18 | ![](step-18.jpg) | `click` target=[500, 280], target_description=Hồ Phúc item |
| 19 | ![](step-19.jpg) | `press_key` key=BACK |
| 20 | ![](step-20.jpg) | `click` target=[500, 350], target_description=Đặng Ngân student item |
| 21 | ![](step-21.jpg) | `report_task_status` completed: {"without_team": 3, "need_members": 1, "student_ids": ["AI000012", "GD000011", "MK000010"], "student_id": "AI000012", "group": "None", "major": "AI"} |

Final screen:

![](final.jpg)
