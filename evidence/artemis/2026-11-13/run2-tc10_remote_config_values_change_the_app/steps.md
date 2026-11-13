# test_tc10_remote_config_values_change_the_app (run 2)

- Session: `9379bb79-8503-41c8-a010-790a2bbfd2b0`
- Status: completed, 131.6s
- Output: `{"match_button_visible": true, "ai_matching_enabled": true, "max_proposals_shown": 3}`

| Step | Screen before | Action |
|---|---|---|
| 1 | ![](step-01.jpg) | `manage_app` action=stop, app_name=com.group6.teamup_exe |
| 2 | ![](step-02.jpg) | `manage_app` app_name=com.group6.teamup_exe, action=launch |
| 3 | ![](step-03.jpg) | `wait_for_delay` time_in_ms=2000 |
| 4 | ![](step-04.jpg) | `swipe` direction=down |
| 5 | ![](step-05.jpg) | `wait_for_delay` time_in_ms=2000 |
| 6 | ![](step-06.jpg) | `swipe` direction=up |
| 7 | ![](step-07.jpg) | `swipe` direction=up |
| 8 | ![](step-08.jpg) | `click` target=12 |
| 9 | ![](step-09.jpg) | `click` target_description=Choose CSV button, target=[500, 240] |
| 10 | ![](step-10.jpg) | `click` target=11 |
| 11 | ![](step-11.jpg) | `click` target=6 |
| 12 | ![](step-12.jpg) | `wait_for_delay` time_in_ms=2000 |
| 13 | ![](step-13.jpg) | `click` target=9 |
| 14 | ![](step-14.jpg) | `click` target=1 |
| 15 | ![](step-15.jpg) | `click` target=16 |
| 16 | ![](step-16.jpg) | `report_task_status` completed: {"match_button_visible": true, "ai_matching_enabled": true, "max_proposals_shown": 3} |

Final screen:

![](final.jpg)
