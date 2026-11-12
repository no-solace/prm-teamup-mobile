"""Detail screens (S3 class, S4 list, S7 student) and the three top-level tabs."""

from conftest import IMPORT_DEMO


async def test_tc08_class_and_student_detail_values(artemis, fixture_on_device):
    got = await artemis(
        IMPORT_DEMO
        + "On the class screen report without_team and need_members (the two numbers next to the "
        "labels 'without team' and 'need members'). Tap 'Students without team', report "
        "student_ids (the MSSV or ID of every student listed), then open the student 'Dương Yến' "
        "and report student_id, group and major exactly as shown on the Student detail screen.",
        ["without_team", "need_members", "student_ids", "student_id", "group", "major"],
    )
    assert got.values["without_team"] == 3
    assert got.values["need_members"] == 1
    assert sorted(got.values["student_ids"]) == ["AI000012", "GD000011", "MK000010"]
    assert got.values["student_id"] == "AI000012"
    assert got.values["major"] == "AI"


async def test_tc09_tabs_and_back_navigation(artemis):
    got = await artemis(
        "Make sure you are signed in. Tap the 'Proposals' tab and report proposals_title (the "
        "screen title). Tap the 'Profile' tab and report profile_title. Tap the 'Classes' tab "
        "and report classes_title. Open any class, then press the Android Back button once and "
        "report back_title (the title of the screen you land on).",
        ["proposals_title", "profile_title", "classes_title", "back_title"],
    )
    assert got.values["proposals_title"] == "Proposals"
    assert got.values["profile_title"] == "Profile"
    assert got.values["classes_title"] == got.values["back_title"]
