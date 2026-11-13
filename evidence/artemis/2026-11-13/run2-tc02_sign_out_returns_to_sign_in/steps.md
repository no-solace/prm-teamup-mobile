# test_tc02_sign_out_returns_to_sign_in (run 2)

- Session: `12fb94cd-0a5d-42cb-8ae7-a65e0b2ce39b`
- Status: completed, 67.0s
- Output: `{"sign_in_visible": true, "classes_tab_visible": false, "relaunch_sign_in_visible": true}`

| Step | Screen before | Action |
|---|---|---|
| 1 | ![](step-01.jpg) | `manage_app` action=stop, app_name=com.group6.teamup_exe |
| 2 | ![](step-02.jpg) | `manage_app` action=launch, app_name=com.group6.teamup_exe |
| 3 | ![](step-03.jpg) | `wait_for_delay` time_in_ms=2000 |
| 4 | ![](step-04.jpg) | `click` target=16 |
| 5 | ![](step-05.jpg) | `swipe` direction=up |
| 6 | ![](step-06.jpg) | `swipe` direction=up |
| 7 | ![](step-07.jpg) | `click` target=11 |
| 8 | ![](step-08.jpg) | `wait_for_delay` time_in_ms=2000 |
| 9 | ![](step-09.jpg) | `manage_app` action=stop, app_name=com.group6.teamup_exe |
| 10 | ![](step-10.jpg) | `manage_app` action=launch, app_name=com.group6.teamup_exe |
| 11 | ![](step-11.jpg) | `wait_for_delay` time_in_ms=2000 |
| 12 | ![](step-12.jpg) | `report_task_status` completed: {"sign_in_visible": true, "classes_tab_visible": false, "relaunch_sign_in_visible": true} |

Final screen:

![](final.jpg)
