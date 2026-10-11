"""src-literature-201 (OSF 3hpvr, CC-BY-4.0; Ngo, Fell & Staresina 2020 eLife 9:e57011 doi:10.7554/eLife.57011 "Sleep spindles
mediate hippocampal-neocortical coupling during long-duration ripples") -> iEEG-BIDS DERIVATIVE: whole-night sleep recordings,
14 patients (Bonn), 2 channels each: HIPP (posterior hippocampal depth contact, non-pathological hemisphere) and NC (scalp Cz),
1 kHz, referenced to linked mastoids (article). Source: files/Raw data/EEGs/patNN_{HIPP,NC}.mat (FieldTrip raw, one trial, float64),
patNN_{HIPP,NC}_supplement.mat (scoring per sample, artifacts [2 x n] start/end samples, datalen), Raw data/Ripples and Spindles
(detector output EvtInfo: staTime/endTime/maxTime samples, stage, duration, rejects). Values written unchanged (float32).
Sleep scoring, artifacts, ripples and spindles -> events.tsv. MNI coordinates of the HIPP contact (article Table 3) are written
only if the release patient numbering is verified against the article's Table 2 spindle counts (detected minus rejected).
Usage: python o5c_A2_convert_lit201.py <open500 record dir> <bids root>"""
import glob, json, os, re, shutil, sys
import numpy as np, h5py
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from o5c_A2_common import write_run, wtsv, wjson, finalize_common, copy_code, copy_sourcedata, h5str, sha256_file

REC, OUT = sys.argv[1], sys.argv[2]
RAW = os.path.join(REC, "files", "Raw data")
SD = os.path.join(OUT, "sourcedata", "osf-3hpvr")
report = {"recordings": [], "mapping": {}}
# article Table 2 (patient: NC spindles, HIPP spindles, SW-R count) and Table 3 (MNI x y z of the HIPP contact; none for 2, 3, 5)
TABLE2 = {1: (1440, 1296, 135), 2: (1243, 571, 107), 3: (1703, 1725, 116), 4: (1074, 978, 626), 5: (1427, 625, 206), 6: (1001, 691, 153),
          7: (903, 1975, 403), 8: (1004, 892, 400), 9: (2079, 2038, 518), 10: (1120, 840, 245), 11: (494, 739, 208), 12: (448, 417, 44),
          13: (1339, 406, 45), 14: (1899, 1555, 542)}
TABLE3 = {1: (-26, -29, -8), 4: (26, -28, -7), 6: (27, -29, -3), 7: (-25, -28, 0), 8: (-33, -33, -2), 9: (27, -31, -9), 10: (28, -35, -7),
          11: (-29, -38, -9), 12: (29, -31, 3), 13: (32, -30, -1), 14: (-28, -34, -5)}
STAGE = {0: "wake", 1: "S1", 2: "S2", 3: "S3", 4: "S4", 5: "REM"}  # R&K codes as used by the detector (slStages 2-4 = NREM); see README


def ft_raw(p):
    with h5py.File(p, "r") as f:
        fs = float(np.asarray(f["fsample"][()]).ravel()[0])
        lab = h5str(f, f[np.asarray(f["label"][()]).ravel()[0]])
        d = f[np.asarray(f["trial"][()]).ravel()[0]]
        x = np.asarray(d[()]).reshape(-1).astype(np.float64)
        si = np.asarray(f["sampleinfo"][()]).ravel().tolist()
    return fs, lab, x, si


def supp(p):
    with h5py.File(p, "r") as f:
        sc = np.asarray(f["scoring"][()]).ravel()
        art = np.asarray(f["artifacts"][()])
        if art.ndim == 2 and art.shape[0] != 2 and art.shape[1] == 2:
            art = art.T
        dl = float(np.asarray(f["datalen"][()]).ravel()[0])
        lab = h5str(f, f[np.asarray(f["label"][()]).ravel()[0]])
    return sc, art, dl, lab


def evts(p):
    with h5py.File(p, "r") as f:
        E = f["EvtInfo"]
        n = int(np.asarray(E["numEvt"][()]).ravel()[0])
        if n == 0:
            return {"n": 0}
        g = lambda k: np.asarray(E[k][()]).ravel()
        rej = np.asarray(f["rejects"][()]).ravel().astype(int) if "rejects" in f else np.zeros(n, int)
        params = {k: (h5str(f, f[k]) if f[k].attrs.get("MATLAB_class", b"") == b"char" else np.asarray(f[k][()]).ravel().tolist())
                  for k in ("bpfreq", "criterionLen", "criterionScale", "criterionVar", "envelopeType", "envelopeWin", "filtType", "slStages", "upperCutoff", "EvtThres", "minCyclesNum", "minCycles") if k in f and f[k].attrs.get("MATLAB_class", b"") != b"cell"}
        return {"n": n, "sta": g("staTime"), "end": g("endTime"), "mx": g("maxTime"), "dur": g("duration"), "stage": g("stage"), "amp": g("envMaxAmp"), "rej": rej, "params": params}


pats = sorted({re.match(r"(pat\d+)_", os.path.basename(p)).group(1) for p in glob.glob(os.path.join(RAW, "EEGs", "pat*_HIPP.mat"))})
assert len(pats) == 14, pats
# first pass: verify patient numbering against Table 2 using spindle counts (detected - rejected)
counts = {}
for pat in pats:
    k = int(pat[3:])
    nc = evts(os.path.join(RAW, "Spindles", f"{pat}_NC_spindles.mat")); hp = evts(os.path.join(RAW, "Spindles", f"{pat}_HIPP_spindles.mat"))
    rp = evts(os.path.join(RAW, "Ripples", f"{pat}_HIPP_ripples.mat"))
    counts[k] = {"NC_spindles": int(nc["n"] - nc["rej"].sum()), "HIPP_spindles": int(hp["n"] - hp["rej"].sum()), "ripples": int(rp["n"] - rp["rej"].sum()),
                 "NC_detected": nc["n"], "HIPP_detected": hp["n"], "ripples_detected": rp["n"], "table2": TABLE2[k]}
match_sp = all(counts[k]["NC_spindles"] == TABLE2[k][0] and counts[k]["HIPP_spindles"] == TABLE2[k][1] for k in counts)
match_rp = all(counts[k]["ripples"] == TABLE2[k][2] for k in counts)
report["mapping"] = {"counts": counts, "spindles_match_table2": match_sp, "ripples_match_table2": match_rp}
print("mapping check: spindles", match_sp, "ripples", match_rp, json.dumps(counts, default=str)[:1500], flush=True)
USE_MNI = match_sp
scans = {}
for pat in pats:
    k = int(pat[3:]); S = f"sub-{k:02d}"; D = os.path.join(OUT, S, "ieeg"); stem = f"{S}_task-sleep_run-1"
    fsH, labH, xH, siH = ft_raw(os.path.join(RAW, "EEGs", f"{pat}_HIPP.mat"))
    fsN, labN, xN, siN = ft_raw(os.path.join(RAW, "EEGs", f"{pat}_NC.mat"))
    assert fsH == fsN == 1000.0 and labH == "HIPP" and labN == "NC" and xH.size == xN.size, (fsH, fsN, labH, labN, xH.size, xN.size)
    scH, artH, dlH, _ = supp(os.path.join(RAW, "EEGs", f"{pat}_HIPP_supplement.mat"))
    scN, artN, dlN, _ = supp(os.path.join(RAW, "EEGs", f"{pat}_NC_supplement.mat"))
    assert dlH == dlN == xH.size and scH.size == xH.size and np.array_equal(scH, scN), (dlH, dlN, xH.size, scH.size)
    n = xH.size; fs = 1000.0
    X = np.stack([xH, xN], axis=1)
    del xH, xN
    r = write_run(D, stem, X, fs, ["HIPP", "NC"], ["µV", "µV"], ["SEEG", "EEG"], {
        "TaskName": "sleep", "TaskDescription": "Whole-night sleep recording in the epilepsy monitoring unit (no task); sleep stages scored visually per 20 s epoch (Rechtschaffen & Kales) from scalp EEG, EOG and EMG (article).",
        "Instructions": "n/a (sleep)", "PowerLineFrequency": 50,
        "HardwareFilters": {"Bandpass": {"HighpassCutoff": 0.01, "HighpassRollOff": "6 dB/octave", "LowpassCutoff": 300, "LowpassRollOff": "12 dB/octave"}},
        "SoftwareFilters": "n/a",
        "iEEGReference": "linked mastoids (article)", "Manufacturer": "n/a",
        "iEEGPlacementScheme": "Bilateral hippocampal depth electrodes implanted stereotactically for presurgical evaluation (University of Bonn); the released channel HIPP is the posterior hippocampal contact of the non-pathological hemisphere with the highest spindle density (article). NC is scalp electrode Cz (10-20).",
        "ElectricalStimulation": False, "RecordingType": "continuous",
    }, ch_extra=[{"description": "posterior hippocampal depth contact (non-pathological hemisphere), selected by the authors; label as released", "group": "HIPP",
                  "low_cutoff": 0.01, "high_cutoff": 300, "reference": "linked mastoids"},
                 {"description": "scalp EEG electrode Cz (10-20), labelled NC (neocortex) in the release", "group": "n/a", "low_cutoff": 0.01, "high_cutoff": 300, "reference": "linked mastoids"}],
        comment=f"o5c_A2_convert_lit201.py: {pat}_HIPP.mat + {pat}_NC.mat (FieldTrip raw, float64) -> float32, values unchanged")
    # events: sleep stages (runs of the per-sample scoring), artifacts, ripples, spindles
    rows = []
    ch = np.flatnonzero(np.diff(scH) != 0)
    starts = np.r_[0, ch + 1]; ends = np.r_[ch + 1, n]
    for s0, s1 in zip(starts, ends):
        c = int(scH[s0])
        rows.append([s0 / fs, (s1 - s0) / fs, f"sleep_stage_{STAGE.get(c, c)}", "n/a", c, "n/a", "n/a", int(s0)])
    for lab, art in (("HIPP", artH), ("NC", artN)):
        for a, b in zip(art[0], art[1]):
            rows.append([(a - 1) / fs, (b - a + 1) / fs, f"artifact_{lab}", lab, "n/a", "n/a", "n/a", int(a - 1)])
    ev_par = {}
    for kind, lab in (("ripple", "HIPP"), ("spindle", "HIPP"), ("spindle", "NC")):
        e = evts(os.path.join(RAW, "Ripples" if kind == "ripple" else "Spindles", f"{pat}_{lab}_{kind}s.mat"))
        ev_par[f"{kind}_{lab}"] = e.get("params")
        for i in range(e["n"]):
            rows.append([(e["sta"][i] - 1) / fs, (e["end"][i] - e["sta"][i] + 1) / fs, f"{kind}_{lab}", lab, int(e["stage"][i]), int(e["rej"][i]), round(float(e["amp"][i]), 4), int(e["sta"][i] - 1)])
    rows.sort(key=lambda r: (r[0], r[2]))
    rows = [[round(r[0], 4), round(r[1], 4)] + r[2:] for r in rows]
    wtsv(os.path.join(D, stem + "_events.tsv"), ["onset", "duration", "trial_type", "channel", "sleep_stage", "rejected", "envelope_max_amplitude", "sample"], rows)
    wjson(os.path.join(D, stem + "_events.json"), {
        "onset": {"Description": "Event onset in the recording", "Units": "s"}, "duration": {"Description": "Event duration", "Units": "s"},
        "trial_type": {"Description": "sleep_stage_<stage>: run of constant sleep scoring (per-sample 'scoring' of the release supplement files; stage codes 0-5 as released, named wake/S1/S2/S3/S4/REM after the Rechtschaffen & Kales scoring reported in the article and the detector's NREM stages 2-4); artifact_<channel>: artifact interval from the authors' automated artifact detection (release 'artifacts' start/end samples); ripple_HIPP, spindle_HIPP, spindle_NC: events of the authors' detectors (release Ripples/Spindles EvtInfo staTime..endTime)."},
        "channel": {"Description": "Channel the event belongs to (HIPP or NC); n/a for sleep stages (one scoring for the night)"},
        "sleep_stage": {"Description": "Sleep stage code (release value): for sleep_stage rows the code of the run; for ripples/spindles the EvtInfo.stage of the event"},
        "rejected": {"Description": "1 if the authors' detector flagged the event as rejected (release 'rejects'), else 0; the article counts exclude rejected events"},
        "envelope_max_amplitude": {"Description": "EvtInfo.envMaxAmp of the detected event (band-passed envelope maximum, µV)"},
        "sample": {"Description": "Onset sample (0-based)"},
        "DetectorParameters": ev_par})
    sc_counts = {STAGE.get(int(v), int(v)): int(c) for v, c in zip(*np.unique(scH, return_counts=True))}
    r.update(sub=S, pat=pat, sampleinfo=[siH, siN], n_events=len(rows), scoring_samples=sc_counts, n_artifacts={"HIPP": int(artH.shape[1]), "NC": int(artN.shape[1])})
    report["recordings"].append(r)
    scans.setdefault(S, []).append([f"ieeg/{stem}_ieeg.vhdr", "n/a"])
    # electrodes: HIPP contact
    if USE_MNI and k in TABLE3:
        wtsv(os.path.join(D, f"{S}_space-Other_electrodes.tsv"), ["name", "x", "y", "z", "size", "group"], [["HIPP", *TABLE3[k], "n/a", "HIPP"]])
        desc = "MNI coordinates of the included hippocampal contact as listed in Table 3 of the article (doi:10.7554/eLife.57011); the MNI template version is not stated, so the system is recorded as Other. Patient numbering verified against the article's Table 2 spindle counts (see README)."
    else:
        wtsv(os.path.join(D, f"{S}_space-Other_electrodes.tsv"), ["name", "x", "y", "z", "size", "group"], [["HIPP", "n/a", "n/a", "n/a", "n/a", "HIPP"]])
        desc = ("No MRI/coordinates for this patient in the article (Table 3 lists none for patients 2, 3 and 5)." if USE_MNI else
                "Coordinates not written: the release patient numbering could not be verified against the article's tables (see README).")
    wjson(os.path.join(D, f"{S}_space-Other_electrodes.json"), {"SpatialReference": "MNI template of the article's Table 3 (version not stated)" if (USE_MNI and k in TABLE3) else "n/a (no coordinates)"})
    wjson(os.path.join(D, f"{S}_space-Other_coordsystem.json"), {"iEEGCoordinateSystem": "Other", "iEEGCoordinateUnits": "mm", "iEEGCoordinateSystemDescription": desc,
                                                                  "iEEGCoordinateProcessingDescription": "Values copied from the article table; no processing."})
    print(stem, json.dumps({kk: vv for kk, vv in r.items() if kk not in ("sampleinfo",)}, default=str), flush=True)
for S, rws in scans.items():
    wtsv(os.path.join(OUT, S, f"{S}_scans.tsv"), ["filename", "acq_time"], sorted(rws))
subs = sorted(scans)
wtsv(os.path.join(OUT, "participants.tsv"), ["participant_id", "age", "sex", "source_id"], [[s, "n/a", "n/a", f"pat{int(s[4:]):02d}"] for s in subs])
wjson(os.path.join(OUT, "participants.json"), {"age": {"Description": "not given per patient (article: 35.4 +- 3.0 years, group mean)", "Units": "year"},
                                               "sex": {"Description": "not given per patient (article: seven females of 14)"}, "source_id": {"Description": "patient code in the release file names"}})
# sourcedata: EEGs (MAT header date scrubbed), Ripples, Spindles, control-events zip, figure source data + scripts
sd = []
for sub in ("EEGs", "Ripples", "Spindles", "Control events"):
    for p in sorted(glob.glob(os.path.join(RAW, sub, "*"))):
        if os.path.isfile(p):
            sd.append((p, os.path.join("Raw data", sub, os.path.basename(p))))
for p in sorted(glob.glob(os.path.join(REC, "files", "Figure source data", "**", "*"), recursive=True)):
    if os.path.isfile(p):
        sd.append((p, os.path.relpath(p, os.path.join(REC, "files"))))
rows = copy_sourcedata(sd, SD, scrub=True)
copy_code(OUT, [__file__])
Rr = report["recordings"]; hrs = sum(r["duration_s"] for r in Rr) / 3600
tbl = "\n".join(f"| {k} | {v['NC_spindles']} / {v['table2'][0]} | {v['HIPP_spindles']} / {v['table2'][1]} | {v['ripples']} / {v['table2'][2]} |" for k, v in sorted(counts.items()))
finalize_common(OUT,
    name="s500-literature-201: Whole-night hippocampal depth and scalp Cz sleep EEG with spindle and ripple detections, 14 epilepsy patients (Ngo, Fell & Staresina, 2020) (derivative)",
    dtype="derivative", license_="CC-BY-4.0",
    authors=["Hong-Viet V. Ngo", "Juergen Fell", "Bernhard P. Staresina"],
    refs=["https://doi.org/10.7554/eLife.57011", "https://doi.org/10.17605/OSF.IO/3HPVR", "https://osf.io/3hpvr/", "https://github.com/episodicmemorylab/Ngo_et_al_eLife2020", "https://doi.org/10.1038/nn.4119"],
    howto="Cite Ngo HV, Fell J, Staresina B (2020) Sleep spindles mediate hippocampal-neocortical coupling during long-duration ripples. eLife 9:e57011, doi:10.7554/eLife.57011; and the OSF dataset doi:10.17605/OSF.IO/3HPVR.",
    keywords=["sleep", "hippocampus", "ripples", "sleep spindles", "intracranial EEG", "scalp EEG", "memory consolidation", "epilepsy"],
    source=[{"DOI": "doi:10.17605/OSF.IO/3HPVR", "URL": "https://osf.io/3hpvr/", "Version": "OSF node 3hpvr, 127 files as listed 2026-10-11 (sha256 per file in sourcedata/osf-3hpvr/DEIDENTIFICATION_MANIFEST.tsv)"}],
    generated_by=[{"Name": "o5c_A2_convert_lit201.py", "Description": "Repackaging of the released FieldTrip raw structures (HIPP + NC per patient) into BrainVision float32 (values unchanged, MNE read-back checked); sleep scoring, artifact intervals and the authors' ripple/spindle detections into events.tsv. Code in code/."}],
    ethics=["Approved by the ethics committee of the Medical Faculty of the University of Bonn (reference number 042/16); informed consent from all patients (article)."],
    funding=["ERC Starting Grant 'RECALL' (Staresina, as acknowledged in the article)", "Deutsche Forschungsgemeinschaft SFB1089 (Fell)"],
    readme=f"""# Ngo, Fell & Staresina (2020): whole-night hippocampal and scalp sleep EEG with spindle and ripple detections

Whole-night sleep recordings from {len(subs)} pre-surgical epilepsy patients (Department of Epileptology, University of Bonn),
{hrs:.1f} h in total, two channels per patient at 1 kHz: `HIPP`, a posterior hippocampal depth contact of the non-pathological
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
  ({'written because the release patient numbering matches the article' if USE_MNI else 'NOT written: patient numbering not verified'}; the
  template version is not stated). Verification: detected minus rejected spindle counts per patient (release / Table 2):

| patient | NC spindles | HIPP spindles | ripples |
|---|---|---|---|
{tbl}

- `participants.tsv`: no per-patient age or sex in the release (group: 35.4 +- 3.0 years, 7 of 14 female).
- `sourcedata/osf-3hpvr/`: the release files (EEGs, Ripples, Spindles, the control-events zip and the figure source data +
  scripts) with the MAT text-header creation dates reduced to month/year; `DEIDENTIFICATION_MANIFEST.tsv` lists sha-256 before and after.

## Privacy
The release contains no names, dates or identifiers; patients are numbered pat01-pat14. MAT header dates were reduced to month/year.
""",
    changes_note="BIDS (derivative) repackaging of the OSF 3hpvr release (Ngo et al. 2020) for NEMAR (o5c lane A2).")
json.dump(report, open(os.path.join(OUT, "code", "conversion_report.json"), "w"), indent=1, default=str)
print(json.dumps({"recordings": len(Rr), "subjects": len(subs), "hours": hrs, "rt_all": all(r["roundtrip_ok"] for r in Rr), "use_mni": USE_MNI, "ripples_match": match_rp}, indent=1))
assert all(r["roundtrip_ok"] for r in Rr)
print("CONVERT_DONE")
