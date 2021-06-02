## subdir Documentation

This function performs a recursive file search in Matlab.  The input and output format is identical to the `dir` function.

### Syntax

```
subdir
subdir(name)
files = subdir(...)
```

See function help for description of function input and output variables.

### Example

List all the .mat files that come with the base Matlab distribution.

```matlab
subdir(fullfile(matlabroot, 'toolbox', 'matlab', '*.mat'))
```
```
/Applications/MATLAB_R2014b.app/toolbox/matlab/audiovideo/chirp.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/audiovideo/gong.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/audiovideo/handel.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/audiovideo/laughter.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/audiovideo/mtlb.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/audiovideo/splat.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/audiovideo/train.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/demos/accidents.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/demos/airfoil.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/demos/airlineResults.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/demos/cape.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/demos/census.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/demos/clown.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/demos/detail.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/demos/dmbanner.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/demos/durer.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/demos/earth.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/demos/fluidtemp.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/demos/flujet.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/demos/gatlin.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/demos/gatlin2.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/demos/integersignal.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/demos/logo.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/demos/mandrill.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/demos/mapredout.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/demos/membrane.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/demos/mri.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/demos/patients.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/demos/penny.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/demos/quake.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/demos/seamount.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/demos/spine.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/demos/stocks.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/demos/tetmesh.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/demos/topo.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/demos/topography.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/demos/trimesh2d.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/demos/trimesh3d.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/demos/truss.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/demos/usapolygon.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/demos/usborder.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/demos/vibesdat.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/demos/west0479.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/demos/wind.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/demos/xpmndrll.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/graph3d/camtoolbarimages.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/icons/arrow.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/icons/boldfont.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/icons/centertextalign.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/icons/colorbar.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/icons/datatip.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/icons/font.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/icons/italicfont.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/icons/lefttextalign.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/icons/legend.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/icons/line.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/icons/newdoc.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/icons/opendoc.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/icons/pan.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/icons/plottoolsoff.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/icons/plottoolson.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/icons/pointer.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/icons/printdoc.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/icons/redo.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/icons/righttextalign.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/icons/rotate.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/icons/savedoc.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/icons/textcolor.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/icons/undo.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/icons/zoom.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/icons/zoomminus.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/icons/zoomplus.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/icons/zoomx.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/icons/zoomy.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/optimfun/OPTIMTOOL_OPTIONSFIELDS.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/timeseries/prefimag.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/uitools/dialogicons.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/uitools/mwtoolbaricons.mat
/Applications/MATLAB_R2014b.app/toolbox/matlab/uitools/scribeiconcdata.mat
```

Saved output follows the same format as the output of `dir`, so the function can be used interchangeably.

```matlab
A = subdir(fullfile(matlabroot, 'toolbox', 'matlab', '*.mat'))
```
```
A = 

79x1 struct array with fields:

    name
    date
    bytes
    isdir
    datenum
```
