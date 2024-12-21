import pandas as pd
import numpy as np
import sys
import os
import matplotlib.pyplot as plt
from copy import copy
from scipy import stats
from scipy.stats import zscore
import pickle
# new for loading .mat and .edf
from scipy import stats,signal,io
import time
import mat73 # this loads .mat files as dicts
import warnings # neuralynx_io gives annoying warnings but seems to work fine
warnings.filterwarnings("ignore")
from utils.general import *
from utils.SWRmodule import *

plt.rcParams['pdf.fonttype'] = 42; plt.rcParams['ps.fonttype'] = 42 # fix fonts for Illustrator
pd.set_option('display.max_columns', 30); pd.set_option('display.max_rows', 100)
