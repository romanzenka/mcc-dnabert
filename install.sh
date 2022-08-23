#!/usr/bin/env bash -e
# Clone the repo
if [ ! -d DNABERT ]; then
	git clone https://github.com/ChuanyiZ/DNABERT.git
fi
cd DNABERT

# Current code is done on cz/modular branch
git checkout cz/modular

# Conda is pre-set to cache stuff as root, chown to jupyter user
sudo chown jupyter -R /opt/conda/pkgs/cache # Make conda work for Jupyter (by default set up for root only)

# Make conda work in this shell script
eval "$(conda shell.bash hook)"

# Install dependencies as per https://github.com/jerryji1993/DNABERT#1-environment-setup
# Note python 3.7 to be compatible with pytorch for newer CUDA
conda create -y -n dnabert python=3.7
conda activate dnabert

# This is what the original asked for. This does not work on mforge as Artifactory does not mirror the -c pytorch channel
# conda install pytorch torchvision cudatoolkit=10.0 -c pytorch

# Use pip instead.
# Note the CUDA 11.0 - we do this to be compatible with CUDA preinstalled on the VM. Run nvcc --version to see CUDA version.
# Also note that the download site has SSL certificate issue (because BlueTorch man-in-the-middle checking that is misconfigured)
# so we simply trust the server. DANGEROUS!
pip3 install torch==1.7.0 torchaudio --index-url https://download.pytorch.org/whl/cu110 --extra-index-url https://artifactory.mayo.edu/artifactory/api/pypi/pypi-remote/simple --trusted-host download.pytorch.org

cd DNABERT
python3 -m pip install --editable .
cd examples
python3 -m pip install -r requirements.txt

# Install Nvidia Apex to allow 16-bit precision (faster)
cd ../..
git clone https://github.com/NVIDIA/apex
cd apex
pip install -v --no-cache-dir --global-option="--cpp_ext" --global-option="--cuda_ext" ./
