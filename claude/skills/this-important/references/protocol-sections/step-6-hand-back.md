## Step 6 — Hand Back

When invoked by another skill, return the filtered result as the new working set of findings. The calling skill should use only the **Kept** and **Downgraded** items for downstream action (raising, fixing, posting). **Deferred** items become follow-ups, not actions. **Dropped** items are gone — do not silently resurrect them.

When invoked directly by the user, end with a one-line summary:
> "Filtered N findings → K kept, D downgraded, F deferred, X dropped. Proceed with the K + D items?"
