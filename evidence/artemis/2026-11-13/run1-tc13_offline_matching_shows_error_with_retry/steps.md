# test_tc13_offline_matching_shows_error_with_retry (run 1)

- Session: `a5bb08f9-93d3-49c6-8b8e-e41a91ea3450`
- Status: completed, 124.3s
- Output: `{"error_visible": true, "retry_label": "Try again", "recovered": true}`

| Step | Screen before | Action |
|---|---|---|
| 1 | ![](step-01.jpg) | `manage_app` action=stop, app_name=com.group6.teamup_exe |
| 2 | ![](step-02.jpg) | `manage_app` action=launch, app_name=com.group6.teamup_exe |
| 3 | ![](step-03.jpg) | `wait_for_delay` time_in_ms=2000 |
| 4 | ![](step-04.jpg) | `swipe` direction=up |
| 5 | ![](step-05.jpg) | `click` target=12 |
| 6 | ![](step-06.jpg) | `click` target_description=Choose CSV button, target=[499, 240] |
| 7 | ![](step-07.jpg) | `click` target=11 |
| 8 | ![](step-08.jpg) | `click` target=5 |
| 9 | ![](step-09.jpg) | `click` target=6 |
| 10 | ![](step-10.jpg) | `swipe` end=[500, 600], start=[500, 10], target_description=pull down status bar for quick settings |
| 11 | ![](step-11.jpg) | `swipe` start=[500, 200], target_description=pull down quick settings further to reveal airplane mode, end=[500, 700] |
| 12 | ![](step-12.jpg) | `click` target=15 |
| 13 | ![](step-13.jpg) | `press_key` key=BACK |
| 14 | ![](step-14.jpg) | `press_key` key=BACK |
| 15 | ![](step-15.jpg) | `click` target=11 |
| 16 | ![](step-16.jpg) | `swipe` target_description=pull down status bar, start=[500, 10], end=[500, 600] |
| 17 | ![](step-17.jpg) | `swipe` target_description=pull down quick settings further, start=[500, 200], end=[500, 700] |
| 18 | ![](step-18.jpg) | `click` target=13 |
| 19 | ![](step-19.jpg) | `press_key` key=BACK |
| 20 | ![](step-20.jpg) | `press_key` key=BACK |
| 21 | ![](step-21.jpg) | `click` target=5 |
| 22 | ![](step-22.jpg) | `wait_for_delay` time_in_ms=5000 |
| 23 | ![](step-23.jpg) | `report_task_status` completed: {"error_visible": true, "retry_label": "Try again", "recovered": true} |

Final screen:

![](final.jpg)
