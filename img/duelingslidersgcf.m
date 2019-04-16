function duelingslidersgcf(src,eventdata,hMySlider,hOtherSlider,strDir)

myLoc = get(hMySlider,'Value');
otherLoc = get(hOtherSlider,'Value');

switch lower(strDir)
    case 'low'
        if myLoc > otherLoc
            set(hMySlider,'Value',otherLoc);
        end
    case 'high'
        if myLoc < otherLoc
            set(hMySlider,'Value',otherLoc);
        end
end