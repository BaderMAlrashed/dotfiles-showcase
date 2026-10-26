"""Tests for the waybar Hijri/khal module (khal-waybar.py).

Run: python3 -m unittest discover -s tests   (needs `hijridate` installed)
"""

import importlib.util
import pathlib
import unittest
from datetime import date, timedelta
from unittest import mock

SCRIPT = (pathlib.Path(__file__).resolve().parent.parent
          / "waybar/.config/waybar/scripts/khal-waybar.py")
spec = importlib.util.spec_from_file_location("khal_waybar", SCRIPT)
kw = importlib.util.module_from_spec(spec)
spec.loader.exec_module(kw)


def khal_output(*lines):
    return "".join(f"{line}\n" for line in lines)


class GetEvents(unittest.TestCase):
    def events_for(self, out):
        with mock.patch.object(kw.subprocess, "check_output", return_value=out):
            return kw.get_events()

    def test_khal_default_day_first_dates_are_parsed(self):
        # khal prints {start-date} in its configured `dateformat`, e.g.
        # %d/%m/%Y, not ISO. Those events must not be dropped.
        d = date.today() + timedelta(days=3)
        out = khal_output("Today, …",
                          f"Saudi National Day|||{d.strftime('%d/%m/%Y')}")
        self.assertEqual(self.events_for(out),
                         [(3, "National Day", "Saudi National Day", d)])

    def test_iso_dates_are_parsed(self):
        d = date.today()
        out = khal_output(f"Islamic New Year|||{d.isoformat()}")
        self.assertEqual(self.events_for(out),
                         [(0, "Hijri New Year", "Islamic New Year", d)])

    def test_unparseable_date_is_skipped(self):
        self.assertEqual(self.events_for(khal_output("Ramadan|||soon")), [])

    def test_calendars_constant_drives_khal_args(self):
        with mock.patch.object(kw.subprocess, "check_output",
                               return_value="") as run:
            kw.get_events()
        args = run.call_args.args[0]
        self.assertEqual(
            [args[i + 1] for i, a in enumerate(args) if a == "--include-calendar"],
            kw.CALENDARS)

    def test_khal_missing_gives_no_events(self):
        with mock.patch.object(kw.subprocess, "check_output",
                               side_effect=FileNotFoundError):
            self.assertEqual(kw.get_events(), [])


class Shorten(unittest.TestCase):
    def test_known_and_long_names(self):
        self.assertEqual(kw.shorten("Eid al-Adha"), "Eid al-Adha")
        self.assertEqual(kw.shorten("x" * 40), "x" * 28 + "…")

    def test_ramadan_span_is_skipped_and_start_is_named(self):
        # The comment in shorten() says the month-long span is skipped in
        # favour of the "begins" event; the plain "Ramadan" table entry
        # used to match both first.
        # Titles as the islamic calendar spells them (khal, 2026-10-26).
        self.assertIsNone(kw.shorten("Ramadan 1448 AH (full month)"))
        self.assertEqual(kw.shorten("Ramadan 1448 AH begins"), "Ramadan begins")


if __name__ == "__main__":
    unittest.main()
