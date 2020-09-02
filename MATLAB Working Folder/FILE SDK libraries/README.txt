H.E.T. Veerman
26-05-2016

Instructie uit "Documentation" sectie "Introduction" van File SDK:
To use the file sdk with MATLAB you need to copy the dlls from the Redistribution section along with FlirMovieReaderMex.mex* into your MATLAB project. You will also need to copy FlirMovieReader.m from the src/FileMovieReaderMex folder into your MATLAB project. Depending on which version of MATLAB you are using (32-bit or 64-bit) you will need to copy dlls from either the Win32 folder or the x64 folder. The extension of the mex file will be mexw32 for 32-bit and mex64 for 64-bit. FlirMovieReaderMex is a mex wrapper around the dlls in the file SDK. FlirMovieReader.m is a MATLAB class interface on top of the mex file. Basic usage of the FlirMovieReader is below, for more details refer to FlirMovieReader.m

Redistribution dir met DLL's:
C:\Program Files (x86)\FLIR Systems\ATS-US\sdks\file\bin\x64

FileMovieReader.m dir:
C:\Program Files (x86)\FLIR Systems\ATS-US\sdks\file\src\FlirMovieReaderMex

Use of function:
[Image,FrameHeader,FileHeader,TotalFrames] = RIRreader(File,Frame)

FrameHeader contains time stamps (FrameHeader.Time).