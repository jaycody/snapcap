#! /bin/bash

########### BASH TOOLS FOR SNAPCAP ##############


clean_snaps () {
    # Clean the local ./snaps/ directory
    echo ""
    treela ${JAYCI_WORKSPACE}/snapcap/snapcap_util/snaps/ 
    rm -rf ${JAYCI_WORKSPACE}/snapcap/snapcap_util/snaps/* || true 
    echo ""
    echo "Deleting snaps from snapcap/snapcap_util/snaps/"
    echo ""
    treela ${JAYCI_WORKSPACE}/snapcap/snapcap_util/snaps/ 
    echo "snaps deleted"
    echo ""
}




clean_frames () {
    # Clean the local ./snaps/ directory
    echo ""
    treela ${JAYCI_WORKSPACE}/snapcap/snapcap_util/frames/ 
    rm -rf ${JAYCI_WORKSPACE}/snapcap/snapcap_util/frames/* || true 
    echo ""
    echo "Deleting frames from snapcap/snapcap_util/frames/"
    echo ""
    treela ${JAYCI_WORKSPACE}/snapcap/snapcap_util/frames/ 
    echo "frames deleted"
    echo ""
}


# Clean the local ./frames/ directory