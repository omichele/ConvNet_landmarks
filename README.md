# ConvNet_landmarks

This package contain an implementation of te work presented in []. Furthermore
some modifications has been added to the original work like a procedure for
geometrical reranking of the candidate matches. Lastly the package includes
a new visual place recognition module that makes use of the original ConvNet
landmarks algorithm as a simple feature extractor for a Bag Of Word model [].

## Test

Run 

	startup.m

in order to add the necessary folders to the matlab search path. 
Otherwise just run one of the scripts which automatically calls startup 
before anything else.

After this step in order to start the module just run one between script
script_convNet_bow and script_convNet_online.

## Parameters

use_odometry
use_mem
build_mem
use_odom
enable_figures

## Main scripts

script_convNet_bow.m :  at the beginning of this script there is a call to
                        get_defaults_bow.m that is the script containing all
                        the configurations neede that will be loaded to the
                        global variable ds. So it was used just with the use_mem
                        and build_mem flags unset. At the end of the execution
                        the results gathered in the ds variable are saved to 
                        a date and time named folder.

script_convNet_online :



loadImgset_mine : this script it is responsible for the procedure of loading of the
                  dataset comprehending also grount truth and odometry information.
                  While loading the dataset it also subsample it by using the odometry
                  information.

make_pr_cruve : thi scripts load the confusion matrix, the configurations of the
                experiments and the ground truth files and make the precision
                recall curves by sweeping the matching threshold. Images and statistics
                are then saved on the result folder.

save_results : this script is charged with the task of saving all the information
               contained in the ds variable to a destination folder.

make_ground_truth : produce the two ground truth matrices that will be used to
                    generate the precision-recall curves.

ConvNet_eb_feature_extractor_warp :  This function embeds the object proposal
                                     and the desriptor generation from the CNN
                                     in one features extractor routine.

eb_convNet_build_BoW_small_net_batch_warp : use this script to generate the vocabulary
                                            and the inverted index necessary for the
                                            online BoW ConvNet landmark algorithm.

Check_codewords_warp_BoW_using_extractor : use this script to make a visualization of
                                           the vocabulary learnt in the training phase 
                                           of the BoW model.

The following scripts must be executed in the result folder.

plot_confMat : It loads the confusion matrix in the confusionMat.txt file and
               plot it while also saving the plot as an image in the same folder.

plot_ground_truth : It loads the ground truth in the gt_unique.txt and gt_enlarged.txt files and
               plot them while also saving the plots as images in the same folder.

plot_timing : It loads the timing information in the timing.yalm file; it plot the images
              and saves them.

plot_matches : This script helps with the playback of the matches offline after the
               the algorithm has already finished his job and the results has been saved.


## ds developement environment

Taking inspiration by the idea of ... in this work a global variable ds is
declared. This a struct in which all the necessary information are written
to. At the moment of writing something on the disk it is just necessary to
extract the needed fields from the ds variable.

## Datset management

In this work we suppose the user will insert the path of two datasets namely
the memory dataset and the live dataset. The recognition of course will be of 
the live images against the ones in memory. Also along the visual information
ground truth and odometry must be extracted. Use the package frame_extractor
in order to extract from the bag file (recorded with FLUENCE car) all the 
necessary data.


## Result analysis

## Data needed

The matrix G is generated once offline, stored, and used for all the subsequent
executions of the algorithm.


## Requirements

The following packages must be installed on the computer and included in the 
MATLAB search path by setting the script startup.m


- Piotr Vision Toolbox : It conatins some important tools such as the edge detector 
                       that is used by the object proposal algortihm.
- Edge boxes : Software for the object proposal proposed in []
- Caffe : A working copy of Caffe must be present on the pc and compiled with matlab,
        CUDA, CUDNN support. We will use a slightly modified network model that is
        basically identical to the caffe reference model AlexNet but cut at the 3rd 
        level of convolution. The modified model and the relative weights can be find
        in the model folder. The user can optinally choose to use a different model 
        based on [] that is trainend specifically on scene classification. This model
        has shown lower performances for our algorithm but it has been included for
        further research.
- subplot_tight: for visualization
- yamlmatlab: used to write and read configuration files in yalm format to
              be used in the code.
- GPS2Cart: package to transform GPS measurements in meters and also get a
            visualization of the GPS position in a local map downloaded 
            from Google.








