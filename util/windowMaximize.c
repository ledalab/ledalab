/*
|========================================================================|
|                                                                        |
|       Berne University of Applied Sciences                             |
|                                                                        |
|       School of Engineering and Information Technology                 |
|       Division of Electrical- and Communication Engineering            |
|                                                                        |
|========================================================================|
|                         maximize the window                            |
|========================================================================|
|                                                                        |
| Author:    Alain Trostel                                               |
| e-mail:    alain.trostel@bfh.ch										 |
| Date:      April 2007                                                  |
| Version:   2.0                                                         |
|                                                                        |
|========================================================================|
|                                                                        |
| windowMaximize(windowname,resizeState)                                 |
|                                                                        |
| input parameters:                                                      |
| -----------------                                                      |
| windowname    string with the window name                              |
| resizeState	string with the resize state							 |
|				"on":	window is resizable								 |
|				"off":	window is not resizable							 |
|                                                                        |
|                                                                        |
| output parameters:                                                     |
| ------------------                                                     |
| The function has no output parameters.                                 |
|                                                                        |
|                                                                        |
| used files:                                                            |
| -----------                                                            |
| The function doesn't use additional files.                             |
|																		 |
|																		 |
| compilation:															 |
| ------------															 |
| mex windowMaximize.c -output windowMaximize.dll						 |
|                                                                        |
|========================================================================|
*/

/* include header files */
#include <windows.h>
#include "mex.h"


/* interface between MATLAB and the C function */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	/* declare variables */
	HWND hWnd;
	long nStyle;
	int strLength;
	char *windowname, *resizeState;

	/* length of the string */
	strLength = mxGetN(prhs[0])+1;
	/* allocate memory for the window name */
	/* MATLAB frees the allocated memory automatically */
	windowname = mxCalloc(strLength, sizeof(char));
	/* copy the variable from MATLAB */
	mxGetString(prhs[0],windowname,strLength);

	/* length of the string */
	strLength = mxGetN(prhs[1])+1;
	/* allocate memory for the resize state */
	/* MATLAB frees the allocated memory automatically */
	resizeState = mxCalloc(strLength, sizeof(char));
	/* copy the variable from MATLAB */
	mxGetString(prhs[1],resizeState,strLength);


	/* handle of the window */
	hWnd = FindWindow(NULL,windowname);

	/* get current window style */
	nStyle = GetWindowLong(hWnd,GWL_STYLE);

	/* make sure that the window can be resized */
	SetWindowLong(hWnd,GWL_STYLE,nStyle | WS_MAXIMIZEBOX);

	/* maximize window */
	ShowWindow(hWnd,SW_MAXIMIZE);

	/* window is not resizable */
	if(strcmp(resizeState,"off") == 0)
	{
		/* restore the settings */
		SetWindowLong(hWnd,GWL_STYLE,nStyle);
	}

	/* redraw the menu bar */
	DrawMenuBar(hWnd);
}
