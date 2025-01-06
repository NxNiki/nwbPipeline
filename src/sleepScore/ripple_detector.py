from os import times
from typing import Tuple, List
import pandas as pd
import numpy as np
import sys
import os
import matplotlib.pyplot as plt
from copy import copy

from mne.io import RawArray
from numpy.core.defchararray import endswith
from scipy import stats
from scipy.stats import zscore
import pickle
from scipy import stats,signal,io
import time
import mat73 # this loads .mat files as dicts
import warnings # neuralynx_io gives annoying warnings but seems to work fine
from utils.SWRmodule import *
from utils.general import *

import mne
from scipy.signal import firwin, filtfilt, kaiserord

warnings.filterwarnings("ignore")
plt.rcParams['pdf.fonttype'] = 42; plt.rcParams['ps.fonttype'] = 42 # fix fonts for Illustrator
pd.set_option('display.max_columns', 30); pd.set_option('display.max_rows', 100)


SAVE_VALUES = 0
RECALL_TYPE_SWITCH = 0
REMOVE_SOZ_ICTAL = 0 # 0 for nothing, 1 for remove SOZ, 2 for keep ONLY SOZ ###
MIN_RIPPLE_RATE = 0.1 # Hz. # 0.1 for hamming
MAX_RIPPLE_RATE = 1.5 # Hz. # 1.5 for hamming
MAX_TRIAL_BY_TRIAL_CORRELATION = 0.05 # if ripples correlated more than this remove them # 0.05 for hamming
MAX_ELECTRODE_BY_ELECTRODE_CORRELATION = 0.2 #??? # 0.2 for hamming
FILTER_TYPE = 'hamming' # see local version below for details
DESIRED_SAMPLE_RATE = 500. # in Hz. This seems like lowerst common denominator recording freq.
EEG_BUFFER = 300 # buffer to add to either end of IRI when processing eeg #**


def read_raw_data(files: pd.DataFrame, sampling_rate: int) -> RawArray:
    """
    read raw data and save to mne RawArray.
    """

    signals = []
    ch_names = []
    for file in files:
        if file.endswith('.mat'):
            data = mat73.loadmat(file)
            data = data['data']
        else:
            raise ValueError("unsupported file type!")
        channel_name = os.path.basename(file)
        data = np.array(data['data'])  # Shape: (n_channels, n_samples)
        signals.append(data)
        ch_names.append(channel_name.replace('.mat', ''))

    # Create MNE Raw object
    info = mne.create_info(ch_names=ch_names, sfreq=sampling_rate, ch_types='eeg')
    raw = RawArray(signals, info)

    return raw


def filter_timeseries(timeseries: RawArray, filter_type: str, sampling_rate: int) -> Tuple[RawArray, RawArray]:
    ## FILTERS ##
    trans_width = 5.  # Width of transition region, normalized so that 1 corresponds to pi radians/sample.
    # That is, the frequency is expressed as a fraction of the Nyquist frequency.
    ntaps = (2 / 3) * np.log10(1 / (10 * (1e-3 * 1e-4))) * (sampling_rate / trans_width)  # gives 400 with sr=500, trans=5
    # formula from Belanger's Digital Processing of Signals
    # see https://dsp.stackexchange.com/questions/31066/how-many-taps-does-an-fir-filter-need for how to use

    # filter for ripples using filter selected above
    if filter_type == 'hamming':
        # need to subtract out to get the filtered signal since default is bandstop but want to keep it as PTSA
        FIR_bandstop = firwin(int(ntaps + 1), [70., 178.], fs=sampling_rate, window='hamming', pass_zero='bandstop')
        #         eeg_rip_band = filtfilt(FIR_bandpass,1.,eeg_ptsa) # can't use ptsa_to_mne this way so use eeg minus bandstopped signal
        eeg_rip_band = timeseries - filtfilt(FIR_bandstop, 1., timeseries)
        bandstop_25_60 = firwin(int(ntaps + 1), [20., 58.], fs=sampling_rate, window='hamming',
                                pass_zero='bandstop')  # Norman 2019 IED
        eeg_ied_band = timeseries - filtfilt(bandstop_25_60, 1., timeseries)
    elif filter_type == 'staresina':
        FIR_bandstop = firwin(241, [80., 100.], fs=sampling_rate, window='hamming',
                              pass_zero='bandstop')  # order = 3*80+1
        eeg_rip_band = timeseries - filtfilt(FIR_bandstop, 1., timeseries)
    else:
        raise ValueError("invalid filter_type!")

    if filter_type is not 'staresina':
        time_length = np.shape(eeg_rip_band)[2] / int(sampling_rate / 1000)
        eeg_rip_band = ptsa_to_mne(eeg_rip_band, [0, time_length])  # [0,psth_end-psth_start+2*eeg_buffer])
        _ = eeg_rip_band.apply_hilbert(envelope=True)
        eeg_ied_band = ptsa_to_mne(eeg_ied_band, [0, time_length])  # [0,psth_end-psth_start+2*eeg_buffer])
        _ = eeg_ied_band.apply_hilbert(envelope=True)

    return eeg_rip_band, eeg_ied_band

