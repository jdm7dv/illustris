PRO TiffMakeKeyValue, defs, TagIndex, TagName
; Given a TagValue/TagName table in the form of a string array, return
; two pointers to arrays containing the Tag Indices and the Tag Names,
; respectively.
;
names = defs                    ;Separate tag names....
tags = uint(defs)               ;Extract tag indices
for i=0, n_elements(defs)-1 do begin
    blank = strpos(defs[i], ' ')
    names[i] = strmid(defs[i], blank+1, 100)
endfor
order = sort(tags)              ;Sort by tag value
TagIndex = ptr_new(tags[order])
TagName = ptr_new(names[order])
end


function sonos_tags, Extended
; Return an array of two pointers defining HP Sonos specific TIFF
; tags:  pointer0 = tagValues[], pointer1 = tagNames[i]. 
;
; Extended = if present, return a two element pointer array defining
; the HP Xtag definitions.

defs = [ $                      ;Must be sorted in numerical order
         '33781 ApplicationID', $
         '33782 FramesInFile', $
         '33783 FrameInfo', $
         '33784 ScreenFormat', $
         '33785 SystemMode', $
         '33786 ImageMapType', $
         '33787 Application', $
         '33788 FieldsInFile', $
         '33789 ColorMapSettings', $
         '33790 ColorBaseline', $
         '33791 DataType', $
         '33792 CineTimeLine', $
         '33794 ImageSettings', $
         '33796 ApplicationSpecificData', $
         '33797 TEEangle', $
         '33799 ExtendedTagsOffset']


if arg_present(Extended) Then begin
    extdefs = [ $
                '256 PatientInfo', $
                '257 PatientVitalStatistics', $
                '258 ApplicationTimers', $
                '259 ApplicationTimerDescription', $
                '260 ProtocolDescription', $
                '261 ProtocolStatistics', $
                '262 ExtendedColorMap', $
                '263 EnConcertStudyID', $
                '265 Omni-Angle', $
                '266 CalibrationData']
    TiffMakeKeyValue, extdefs, p1, p2
    extended = [p1, p2]
endif


TiffMakeKeyValue, defs, p1, p2
return, [p1, p2]
end
