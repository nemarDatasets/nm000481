[![DOI](https://img.shields.io/badge/DOI-10.82901%2Fnemar.nm000481-blue)](https://doi.org/10.82901/nemar.nm000481)

# Ngo, Fell & Staresina (2020): whole-night hippocampal and scalp sleep EEG with spindle and ripple detections

Whole-night sleep recordings from 14 pre-surgical epilepsy patients (Department of Epileptology, University of Bonn),
135.6 h in total, two channels per patient at 1 kHz: `HIPP`, a posterior hippocampal depth contact of the non-pathological
hemisphere (the contact with the highest spindle density, article), and `NC`, scalp electrode Cz. Released by the authors on OSF
(https://osf.io/3hpvr/, CC-BY 4.0) with their ripple and spindle detections, sleep scoring and artifact intervals.

THIS IS A DERIVATIVE DATASET: the release holds the two channels the authors analysed (referenced to linked mastoids, hardware
band-pass 0.01-300 Hz), not the full clinical recordings; the other scalp electrodes (C3, C4, Oz), EOG and EMG are not released.

## Contents
- `sub-NN/ieeg/sub-NN_task-sleep_run-1_ieeg.*`: the night's continuous signal (HIPP typed SEEG, NC typed EEG), float32 of the
  released float64 values (unit µV assumed from the article's thresholds; not stated in the release).
- `events.tsv`: (1) sleep stages as runs of the released per-sample scoring (`sleep_stage_wake/S1/S2/S3/S4/REM`; the release
  codes 0-5 are kept in the `sleep_stage` column; the names follow the Rechtschaffen & Kales scoring reported in the article and
  the detectors' NREM stages 2-4); (2) `artifact_HIPP` / `artifact_NC` intervals from the authors' automated artifact detection;
  (3) `ripple_HIPP`, `spindle_HIPP`, `spindle_NC` events from the authors' detectors with their stage, rejected flag and envelope
  amplitude; the detector parameters are in each `events.json` (DetectorParameters).
- `electrodes.tsv` (space-Other): MNI coordinates of the HIPP contact from Table 3 of the article
  (written because the release patient numbering matches the article; the
  template version is not stated). Verification: detected minus rejected spindle counts per patient (release / Table 2):

| patient | NC spindles | HIPP spindles | ripples |
|---|---|---|---|
| 1 | 1440 / 1440 | 1296 / 1296 | 255 / 135 |
| 2 | 1243 / 1243 | 571 / 571 | 410 / 107 |
| 3 | 1703 / 1703 | 1725 / 1725 | 333 / 116 |
| 4 | 1074 / 1074 | 978 / 978 | 1130 / 626 |
| 5 | 1427 / 1427 | 625 / 625 | 910 / 206 |
| 6 | 1001 / 1001 | 691 / 691 | 769 / 153 |
| 7 | 903 / 903 | 1975 / 1975 | 1869 / 403 |
| 8 | 1004 / 1004 | 892 / 892 | 1167 / 400 |
| 9 | 2079 / 2079 | 2038 / 2038 | 622 / 518 |
| 10 | 1120 / 1120 | 840 / 840 | 412 / 245 |
| 11 | 494 / 494 | 739 / 739 | 256 / 208 |
| 12 | 448 / 448 | 417 / 417 | 113 / 44 |
| 13 | 1339 / 1339 | 406 / 406 | 416 / 45 |
| 14 | 1899 / 1899 | 1555 / 1555 | 808 / 542 |

- `participants.tsv`: no per-patient age or sex in the release (group: 35.4 +- 3.0 years, 7 of 14 female).
- `sourcedata/osf-3hpvr/`: the release files (EEGs, Ripples, Spindles, the control-events zip and the figure source data +
  scripts) with the MAT text-header creation dates reduced to month/year; `DEIDENTIFICATION_MANIFEST.tsv` lists sha-256 before and after.

## Privacy
The release contains no names, dates or identifiers; patients are numbered pat01-pat14. MAT header dates were reduced to month/year.
