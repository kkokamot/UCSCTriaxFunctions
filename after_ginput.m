%% minimization to closest data point, to get a data point from ginput
function [closest_x, closest_y, IofC] = after_ginput(gx, gy, datax, datay)
    closest_x = gx;
    closest_y = gy;
    IofC = zeros(length(gx),1);
    for i = 1:length(gx)
        dist = sqrt((gx(i)/range(datax) - datax/range(datax)).^2 + (gy(i)/range(datay) - datay/range(datay)).^2);
        [~, minI] = min(dist);
        closest_x(i) = datax(minI);
        closest_y(i) = datay(minI);
        IofC(i) = minI;
    end 
end
