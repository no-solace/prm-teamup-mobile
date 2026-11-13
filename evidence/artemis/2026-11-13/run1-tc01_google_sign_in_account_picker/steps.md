# test_tc01_google_sign_in_account_picker (run 1)

- Session: `978291ef-f733-43f6-bdd4-e6528878a607`
- Status: completed, 63.8s
- Output: `{"signed_in": true, "tabs": ["Classes", "Proposals", "Topics", "Schedule", "Profile"]}`

| Step | Screen before | Action |
|---|---|---|
| 1 | ![](step-01.jpg) | `manage_app` action=stop, app_name=com.group6.teamup_exe |
| 2 | ![](step-02.jpg) | `manage_app` action=launch, app_name=com.group6.teamup_exe |
| 3 | ![](step-03.jpg) | `wait_for_delay` time_in_ms=2000 |
| 4 | ![](step-04.jpg) | `click` target=9 |
| 5 | ![](step-05.jpg) | `swipe` direction=up |
| 6 | ![](step-06.jpg) | `click` target=7 |
| 7 | ![](step-07.jpg) | `click` target=7 |
| 8 | ![](step-08.jpg) | `click` target=3 |
| 9 | ![](step-09.jpg) | `click` target=3 |
| 10 | ![](step-10.jpg) | `wait_for_delay` time_in_ms=3000 |
| 11 | ![](step-11.jpg) | `report_task_status` completed: {"signed_in": true, "tabs": ["Classes", "Proposals", "Topics", "Schedule", "Profile"]} |

Final screen:

![](final.jpg)
