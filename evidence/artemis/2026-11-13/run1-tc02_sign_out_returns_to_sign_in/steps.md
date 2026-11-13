# test_tc02_sign_out_returns_to_sign_in (run 1)

- Session: `c99f2904-4134-4433-b72c-f1d526e819a5`
- Status: completed, 69.0s
- Output: `{"sign_in_visible": true, "classes_tab_visible": false, "relaunch_sign_in_visible": true}`

| Step | Screen before | Action |
|---|---|---|
| 1 | ![](step-01.jpg) | `manage_app` action=stop, app_name=com.group6.teamup_exe |
| 2 | ![](step-02.jpg) | `manage_app` action=launch, app_name=com.group6.teamup_exe |
| 3 | ![](step-03.jpg) | `wait_for_delay` time_in_ms=2000 |
| 4 | ![](step-04.jpg) | `click` target=9 |
| 5 | ![](step-05.jpg) | `swipe` direction=up |
| 6 | ![](step-06.jpg) | `click` target=7 |
| 7 | ![](step-07.jpg) | `click` target=7 |
| 8 | ![](step-08.jpg) | `click` target_description=Tap outside account chooser overlay to dismiss it, target=[500, 200] |
| 9 | ![](step-09.jpg) | `swipe` direction=up |
| 10 | ![](step-10.jpg) | `click` target=7 |
| 11 | ![](step-11.jpg) | `manage_app` action=stop, app_name=com.group6.teamup_exe |
| 12 | ![](step-12.jpg) | `manage_app` action=launch, app_name=com.group6.teamup_exe |
| 13 | ![](step-13.jpg) | `report_task_status` completed: {"sign_in_visible": true, "classes_tab_visible": false, "relaunch_sign_in_visible": true} |

Final screen:

![](final.jpg)
