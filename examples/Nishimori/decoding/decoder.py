import sys
import numpy as np
import matplotlib.pyplot as plt
from scipy.sparse import hstack, kron, eye, csr_matrix, block_diag
from pymatching import Matching
import os

def hexStabilizers(Ly):
    Lx = 2*Ly - 1
    N = 3*Lx*Ly-Lx-Ly-2
    numplaq = (Ly-1)*(Lx-1)
    H = np.zeros((numplaq, N),dtype=np.uint8)

    for i in range(Ly-1):
        for j in range(Lx-1):

            # order of plaquettes
            num = (Ly-1)*j + i

            # order of edges
            d = 2*(Ly-1)+j*(3*Ly-1)+i
            u = d+1
            ld = (3*Ly-1)*j-1+2*i+np.mod(j,2)+(j==0)
            lu = ld + 1
            rd = ld + (3*Ly-1) - (j==0) - (j==Lx-2)
            ru = rd+1

            H[num, u] = 1
            H[num, d] = 1
            H[num, lu] = 1
            H[num, ru] = 1
            H[num, ld] = 1
            H[num, rd] = 1

    # delete the redundant edges at boundary
    top = np.concatenate(([3*Ly-2], np.arange(5*Ly-3, N+1, 3*Ly-1), [N]))
    bottom = np.concatenate(([1], np.arange(3*Ly-1, N-2*Ly, 3*Ly-1), [N-3*Ly+3]))
    left = np.arange(2,2*Ly-1,2)
    right = np.arange(N-2*Ly+3, N, 2)
    deletelist = np.sort(np.concatenate((bottom, top, left, right))) - 1
    print(deletelist)
    linklist = np.setdiff1d(np.arange(0,N), deletelist)

    Hreduced = np.delete(H, deletelist, axis=1)
    matching = Matching(Hreduced)
    #matching.draw()
    return H, matching, linklist

def hexCorrect(H, matching, linklist, noise):
    syndrome = H@noise % 2
    ref = np.zeros(noise.shape[0],dtype=np.uint8)
    ref[linklist] = matching.decode(syndrome)
    return ref, syndrome

Ly = int(sys.argv[1])
meas_err = float(sys.argv[2])
Lx = 2*Ly-1
numplaq = (Ly-1)*(Lx-1)
N = 3*Lx*Ly-Lx-Ly-2
folder = './data/'
folder2 = './decoding/'
tBpi = 0.25
tApi_list = np.linspace(0,0.25, 21)#np.arange(0.,0.26,0.01)
numsamples = 10000

H, matching, linklist = hexStabilizers(Ly)

# create dir if not existing:
if not os.path.exists(folder):
    os.mkdir(folder)
    
# sweep tApi
for tApi in tApi_list:
    

    if meas_err==0.0:
        filestr = 'bondstring_brickwall_tA'+("%.4f" % tApi)+'pi_L'+("%d" % Ly)+'.txt'
    else:
        filestr = 'bondstring_brickwall_tA'+("%.4f" % tApi)+'pi_L'+("%d" % Ly)+'_fault'+("%.3f" % meas_err)+'.txt'

    if os.path.isfile(folder+'samples_'+filestr): # if sample exists
        if not os.path.isfile(folder+'reference_'+filestr): # if decoding table does not exist yet:
            noise_list = np.loadtxt(folder+'samples_'+filestr, dtype=np.uint8)
            _, numsamples = noise_list.shape

            # preallocate reference & syndrome arrays
            ref_list = np.zeros((N, numsamples), dtype=np.uint8)
            syndrome_list = np.zeros((numplaq, numsamples), dtype=np.uint8)
            # sweep samples
            for i in range(numsamples):
                noise = noise_list[:,i]
                ref, syndrome = hexCorrect(H, matching, linklist, noise)
                ref_list[:,i] = ref
                syndrome_list[:,i] = syndrome
            # write output
            np.savetxt(folder2+'reference_'+filestr, ref_list, fmt='%u', delimiter=' ')
            #np.savetxt(folder+'syndrome_'+filestr, syndrome_list, fmt='%u', delimiter=' ')
