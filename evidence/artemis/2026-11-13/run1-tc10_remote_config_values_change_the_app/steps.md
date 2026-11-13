# test_tc10_remote_config_values_change_the_app (run 1)

- Session: `28bb6923-08af-4168-a09d-fe9409904600`
- Status: completed, 92.2s
- Output: `{"match_button_visible": true, "ai_matching_enabled": true, "max_proposals_shown": 3}`

| Step | Screen before | Action |
|---|---|---|
| 1 | ![](step-01.jpg) | `manage_app` app_name=com.group6.teamup_exe, action=stop |
| 2 | ![](step-02.jpg) | `manage_app` action=launch, app_name=com.group6.teamup_exe |
| 3 | ![](step-03.jpg) | `wait_for_delay` time_in_ms=3000 |
| 4 | ![](step-04.jpg) | `swipe` direction=up |
| 5 | ![](step-05.jpg) | `click` target=12 |
| 6 | ![](step-06.jpg) | `click` target_description=Choose CSV button, target=[500, 240] |
| 7 | ![](step-07.jpg) | `click` target=11 |
| 8 | ![](step-08.jpg) | `click` target=6 |
| 9 | ![](step-09.jpg) | `click` target=6 |
| 10 | ![](step-10.jpg) | `click` target=1 |
| 11 | ![](step-11.jpg) | `click` target=16 |
| 12 | ![](step-12.jpg) | `report_task_status` completed: {"match_button_visible": true, "ai_matching_enabled": true, "max_proposals_shown": 3} |

Final screen:

![](final.jpg)
