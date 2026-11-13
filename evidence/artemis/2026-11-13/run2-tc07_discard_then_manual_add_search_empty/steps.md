# test_tc07_discard_then_manual_add_search_empty (run 2)

- Session: `28e81070-a3e4-4293-90ee-feee6079b4ee`
- Status: completed, 170.5s
- Output: `{"group2_before": 2, "group2_after": 1, "empty_title": "No student results"}`

| Step | Screen before | Action |
|---|---|---|
| 1 | ![](step-01.jpg) | `manage_app` app_name=com.group6.teamup_exe, action=stop |
| 2 | ![](step-02.jpg) | `manage_app` app_name=com.group6.teamup_exe, action=launch |
| 3 | ![](step-03.jpg) | `wait_for_delay` time_in_ms=3000 |
| 4 | ![](step-04.jpg) | `swipe` direction=up |
| 5 | ![](step-05.jpg) | `swipe` direction=up |
| 6 | ![](step-06.jpg) | `swipe` end=[500, 200], target_description=scroll down classes list, start=[500, 800] |
| 7 | ![](step-07.jpg) | `click` target=12 |
| 8 | ![](step-08.jpg) | `click` target=[500, 240], target_description=Choose CSV button |
| 9 | ![](step-09.jpg) | `click` target=10 |
| 10 | ![](step-10.jpg) | `click` target=6 |
| 11 | ![](step-11.jpg) | `click` target=6 |
| 12 | ![](step-12.jpg) | `click` target=11 |
| 13 | ![](step-13.jpg) | `wait_for_delay` time_in_ms=5000 |
| 14 | ![](step-14.jpg) | `click` target=2 |
| 15 | ![](step-15.jpg) | `swipe` direction=up |
| 16 | ![](step-16.jpg) | `click` target=15 |
| 17 | ![](step-17.jpg) | `click` target=5 |
| 18 | ![](step-18.jpg) | `click` target=3 |
| 19 | ![](step-19.jpg) | `click` target=3 |
| 20 | ![](step-20.jpg) | `click` target=6 |
| 21 | ![](step-21.jpg) | `click` target=3 |
| 22 | ![](step-22.jpg) | `input_text` target=4, text=ZZZ |
| 23 | ![](step-23.jpg) | `input_text` target=42, text=ZZZ |
| 24 | ![](step-24.jpg) | `click_sequence` target_descriptions=['letter z', 'letter z', 'letter z'], sequence=[[201, 849], [201, 849], [201, 849]] |
| 25 | ![](step-25.jpg) | `report_task_status` completed: {"group2_before": 2, "group2_after": 1, "empty_title": "No student results"} |

Final screen:

![](final.jpg)
