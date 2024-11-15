import glob
import os.path


def count_channels(path: str, pattern: str) -> int:
    channel_files = glob.glob(os.path.join(path, pattern))
    print(f"{path} has {len(channel_files)} channels")
    return len(channel_files)


if __name__ == "__main__":
    file_paths = [
        '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/563_MovieParadigm/Experiment-10/CSC_micro',
        '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/563_MovieParadigm/Experiment-11/CSC_micro',
        '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/563_MovieParadigm/Experiment-12/CSC_micro',
    ]

    for file_path in file_paths:
        count_channels(file_path, "G*_001.mat")


