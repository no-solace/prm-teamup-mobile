# test_tc01_google_sign_in_account_picker (run 2)

- Session: `f633d3cd-d08e-4aff-b660-27b0a3db93d8`
- Status: completed, 69.0s
- Output: `{"signed_in": true, "tabs": ["Classes", "Proposals", "Topics", "Schedule", "Profile"]}`

| Step | Screen before | Action |
|---|---|---|
| 1 | ![](step-01.jpg) | `manage_app` app_name=com.group6.teamup_exe, action=stop |
| 2 | ![](step-02.jpg) | `manage_app` app_name=com.group6.teamup_exe, action=launch |
| 3 | ![](step-03.jpg) | `wait_for_delay` time_in_ms=3000 |
| 4 | ![](step-04.jpg) | `click` target=16 |
| 5 | ![](step-05.jpg) | `swipe` direction=up |
| 6 | ![](step-06.jpg) | `swipe` direction=up |
| 7 | ![](step-07.jpg) | `click` target=11 |
| 8 | ![](step-08.jpg) | `click` target=11 |
| 9 | ![](step-09.jpg) | `click` target=3 |
| 10 | ![](step-10.jpg) | `wait_for_delay` time_in_ms=3000 |
| 11 | ![](step-11.jpg) | `click` target=3 |
| 12 | ![](step-12.jpg) | `wait_for_delay` time_in_ms=5000 |
| 13 | ![](step-13.jpg) | `report_task_status` completed: {"signed_in": true, "tabs": ["Classes", "Proposals", "Topics", "Schedule", "Profile"]} |

Final screen:

![](final.jpg)
