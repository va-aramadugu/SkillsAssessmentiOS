# SkillsAssessmentiOS

A small VA health-care copay statement viewer used as a hands-on technical exercise.

## Setup

1. Clone this repository.
2. Open `SkillsAssessmentiOS.xcodeproj` in **Xcode 16 or later**.
3. Select any iPhone simulator (iOS 18 or later) and run. No signing team or device is required.

There are no third-party dependencies and nothing to install.

## The app

The app shows a Veteran's copay charges loaded from a bundled JSON file. You can
filter by care type, search by description, restrict to the current month, sort
by amount, swipe to delete, and record a new charge from the **+** button.

All of the app's logic currently lives in `ContentView.swift`.

## The exercise

You have inherited this screen from a previous developer. Over 35–45 minutes,
working in a live session, we'd like you to:

1. **Fix the reported issues** listed below, then look for anything else you
   notice. Fix what you can and call out the rest.
2. **Decompose** `ContentView.swift` into a structure/architecture you would be comfortable
   maintaining and extending.
3. **Improve code quality.** Address anything you would push back on in a
   code review: naming, duplication, type safety, error handling, readability,
   and performance.

This order is a suggestion. If you would approach it differently, say so and
go ahead.

You are not expected to finish everything. We are more interested in how you
prioritize, how you reason about the code, and how you communicate what you
see than in the number of items you get through.

## Reported issues

Use these to guide your investigation. They describe what was seen, not what
is wrong.

1. When tapping a care type like **Specialty**, the number of charges changes
   but the **Balance due** at the top stays the same.
2. Filtering to **Specialty** and swiping to delete the physical therapy charge
   leaves it in place and removes a different charge instead.
3. Not all prescriptions show up under **Pharmacy**. Under **All**, some of
   them have a question-mark icon.
4. With **This month** on, an urgent care visit from last year is listed.
5. The average at the top sometimes reads **NaN**.
6. Larger charges like the inpatient stay display as `$1676.0` instead of
   `$1,676.00`, and other amounts are formatted inconsistently.

Not every problem in the code has a report. Some are only visible by reading
the source.

## Ground rules

- Think out loud. Tell us what you are looking at and why.
- Use whatever architecture and patterns you would use on a real project.
  There is no single right answer.
- Feel free to use Xcode's documentation, autocomplete, and the simulator.
- Ask questions at any point.
- Do not add third-party dependencies.

## Getting started

Run the app once and use every control before you touch the code. Then read
`ContentView.swift` from top to bottom — the file header suggests an order.
