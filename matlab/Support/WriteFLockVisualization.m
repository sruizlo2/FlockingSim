function WriteFlockVisualization(frames, framerate, filename)
% create the video writer with 1 fps
writerObj = VideoWriter(filename);
writerObj.FrameRate = framerate;
% set the seconds per image
% open the video writer
open(writerObj);
% write the frames to the video
for i=1:length(frames)
  % convert the image to a frame
  frame = frames(i);
  writeVideo(writerObj, frame);
end
% close the writer object
close(writerObj);
